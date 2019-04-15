//
//  DDDownloaderManager.m
//  DDDownloaderDemo
//
//  Created by wuqh on 2019/4/10.
//  Copyright © 2019 吴启晗. All rights reserved.
//

#import "DDDownloadManager.h"
#import "DDDownloadFileHandler.h"
#import "DDDownloadModel.h"
#import "DDDownloadDBManager.h"
#import "NSString+DDExtensions.h"
@interface DDDownloadManager()<NSURLSessionDownloadDelegate>

@property (nonatomic, strong) NSURLSession *session;

/**
 all tasks
 */
@property (nonatomic, strong) NSMutableDictionary<NSString*,NSURLSessionDownloadTask*> *downloadTasks;

/**
 dowloding tasks
 */
@property (nonatomic, strong) NSMutableArray<NSURLSessionDownloadTask*> *downloadingTasks;

@end


@implementation DDDownloadManager

static DDDownloadManager *_instance;
+(instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[DDDownloadManager alloc] init];
    });
    return _instance;
}

- (instancetype)init {
    if (self = [super init]) {
        
        NSMutableArray *downloadModels = [DDDownloadDBManager.sharedManager queryDownloadModels];
        for (DDDownloadModel *downloadModel in downloadModels) {
            if (downloadModel.status == DDDownloadStatusDownloading) {
                downloadModel.status = DDDownloadStatusPause;
                [DDDownloadDBManager.sharedManager insertDownloadModel:downloadModel];
            }
        }
        
        self.maximumDownloading = 3;
        self.downloadTasks = [[NSMutableDictionary alloc]init];
        self.downloadingTasks = [NSMutableArray array];
        
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"DDDownloader"];
        config.timeoutIntervalForRequest = 10;
        self.session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];

        NSArray *sessionDownloadTask = [self sessionDownloadTasks];
        for (NSURLSessionDownloadTask *downloadTask in sessionDownloadTask) {
            if (downloadTask.state == NSURLSessionTaskStateRunning) {
                NSString *url = downloadTask.currentRequest.URL.absoluteString;
                DDDownloadModel *downloadModel = [DDDownloadDBManager.sharedManager queryDownloadModelWithUrl:url];
                [downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
                    if (resumeData.length <= 0 ) {
                        NSLog(@"失败！！！");
                    }
                    if ([resumeData writeToFile:[DDDownloadFileHandler getResumeDataPathWithUrl:url] atomically:YES]) {
                        
                    }else {
                        NSLog(@"保存失败了！！");
                    }
                    CGFloat progress = (downloadTask.countOfBytesReceived*1.0) / (downloadTask.countOfBytesExpectedToReceive*1.0);
                    downloadModel.status = DDDownloadStatusPause;
                    downloadModel.progress = progress;
                    [DDDownloadDBManager.sharedManager insertDownloadModel:downloadModel];
                    [NSNotificationCenter.defaultCenter postNotificationName:downloadModel.url.DD_md5 object:nil userInfo:@{DD_NotificationModelKey:downloadModel}];
                }];
            }else if(downloadTask.state == NSURLSessionTaskStateCompleted) {
                NSString *url = downloadTask.currentRequest.URL.absoluteString;
                DDDownloadModel *downloadModel = [DDDownloadDBManager.sharedManager queryDownloadModelWithUrl:url];
                downloadModel.progress = 1;
                downloadModel.status = DDDownloadStatusSuccess;
                [DDDownloadDBManager.sharedManager insertDownloadModel:downloadModel];
                [NSNotificationCenter.defaultCenter postNotificationName:downloadModel.url.DD_md5 object:nil userInfo:@{DD_NotificationModelKey:downloadModel}];
            }
            
        }

        
        [DDDownloadFileHandler createResumeDataDirectory];
        [DDDownloadFileHandler createDownloadDirectory];
        
    }
    return self;
}

#pragma mark - public method
- (void)download:(DDDownloadModel *)downloadModel {
    
    //validate url
    if ((downloadModel.url.length) < 0 || ([NSURL URLWithString:downloadModel.url] == nil)) {
        return;
    }
    
    // is downloading
    if ([self isDownloadingWithUrl:downloadModel.url]) {
        return;
    }
    // is completed
    DDDownloadModel *pastDownloadModel = [DDDownloadDBManager.sharedManager queryDownloadModelWithUrl:downloadModel.url];
    if (pastDownloadModel.status == DDDownloadStatusSuccess && [DDDownloadFileHandler downlaodFileIsExist:pastDownloadModel.url]) {
        [NSNotificationCenter.defaultCenter postNotificationName:pastDownloadModel.url.DD_md5 object:nil userInfo:@{DD_NotificationModelKey:pastDownloadModel}];
        return;
    }

    // It's time to download
    if (pastDownloadModel != nil) {
        downloadModel = pastDownloadModel;
    }
    
    NSData *resumeData = [self getResumeDataWithUrl:downloadModel.url];
    NSURLSessionDownloadTask *downloadTask;
    if (resumeData) {
        downloadTask = [self.session downloadTaskWithResumeData:resumeData];
    }else {
        downloadTask = [self.session downloadTaskWithURL:[NSURL URLWithString:downloadModel.url]];
    }
    self.downloadTasks[downloadModel.url] = downloadTask;
    [downloadTask resume];
    
    downloadModel.status = DDDownloadStatusDownloading;
    
    //save DDDownloadModel
    [DDDownloadDBManager.sharedManager insertDownloadModel:downloadModel];
    [NSNotificationCenter.defaultCenter postNotificationName:downloadModel.url.DD_md5 object:nil userInfo:@{DD_NotificationModelKey:downloadModel}];
    
}

- (void)suspendWithUrl:(NSString *)url {
    NSURLSessionDownloadTask *downloadTask = self.downloadTasks[url];

    [downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
//        dispatch_async(dispatch_get_main_queue(), ^{
            if (resumeData) {
                
                CGFloat progress = (downloadTask.countOfBytesReceived*1.0) / (downloadTask.countOfBytesExpectedToReceive*1.0);
                
                if ([self setResumeDataWithUrl:url resumeData:resumeData]) {
                    
                    DDDownloadModel *downloadModel = [DDDownloadDBManager.sharedManager queryDownloadModelWithUrl:url];
                    downloadModel.status = DDDownloadStatusPause;
                    if (progress > 0) {
                        downloadModel.progress = progress;
                    }
                    [NSNotificationCenter.defaultCenter postNotificationName:url.DD_md5 object:nil userInfo:@{DD_NotificationModelKey:downloadModel}];
                    [DDDownloadDBManager.sharedManager insertDownloadModel:downloadModel];
                    
                }else {
                    NSAssert(YES, @"resumeData write fail");
                }
            }else {
                NSAssert(resumeData == nil, @"resumeData == nil");
            }
//        });
        
    }];
}
- (void)deleteWithUrls:(NSMutableArray<NSString *> *)urls {
    
    //cancel task
    for (NSString *url in urls) {
        NSURLSessionDownloadTask *downloadTask = self.downloadTasks[url];
        [downloadTask cancel];
        [self setResumeDataWithUrl:url resumeData:nil];
    }
    
    // delete downloadModels
    [DDDownloadDBManager.sharedManager deleteDownloadModelsWithUrls:urls];
}

- (BOOL)isDownloadingWithUrl:(NSString *)url {
    for (NSURLSessionDownloadTask *task in self.downloadTasks.allValues) {
        if ([task.currentRequest.URL.absoluteString isEqualToString:url]) {
            if (task.state == NSURLSessionTaskStateRunning) {
                return YES;
            }else {
                return NO;
            }
        }
    }
    return NO;
}

#pragma mark - private method
#pragma mark resumeData
- (NSData *)getResumeDataWithUrl:(NSString *)url {
    NSString *resumeDataPath = [DDDownloadFileHandler getResumeDataPathWithUrl:url];
    return [NSData dataWithContentsOfFile:resumeDataPath];
}
- (BOOL)setResumeDataWithUrl:(NSString *)url resumeData:(NSData *)resumeData {
    if (resumeData != nil) {
        [DDDownloadFileHandler createResumeDataDirectory];
        NSString *resumeDataPath = [DDDownloadFileHandler getResumeDataPathWithUrl:url];
        return [resumeData writeToFile:resumeDataPath atomically:YES];
    }else {
        return [NSFileManager.defaultManager removeItemAtPath:[DDDownloadFileHandler getResumeDataPathWithUrl:url] error:nil];
    }
    
}
#pragma mark downloadTask
- (NSArray<NSURLSessionDownloadTask*> *)sessionDownloadTasks
{
    __block NSArray *tasks = nil;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);//使用信号量把异步变同步，是这个函数返回时tasks有值
    [self.session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        NSLog(@"%@",downloadTasks);
        tasks = downloadTasks;
        if (tasks.count > 0) {
            NSURLSessionDownloadTask *task = tasks[0];
            NSLog(@"aa");
        }
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return tasks;
}

#pragma mark - NSURLSessionDelegate
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    NSLog(@"###### didFinishEventsForBackgroundURLSession");
    if (self.backgroundHandler) {
        self.backgroundHandler();
        self.backgroundHandler = nil;
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    NSLog(@"###### success");
    
    NSString *url = downloadTask.currentRequest.URL.absoluteString;
    
    if ([NSFileManager.defaultManager fileExistsAtPath:[DDDownloadFileHandler getDownloadFilePathWithUrl:url]]) {
        [NSFileManager.defaultManager removeItemAtPath:[DDDownloadFileHandler getDownloadFilePathWithUrl:url] error:nil];
    }
    
    NSError *error;
    [NSFileManager.defaultManager moveItemAtURL:location toURL:[NSURL fileURLWithPath:[DDDownloadFileHandler getDownloadFilePathWithUrl:url]] error:&error];
    
    if (error) {
        NSLog(@"%@",error);
        DDDownloadModel *downloadModel = [DDDownloadDBManager.sharedManager queryDownloadModelWithUrl:url];
        downloadModel.status = DDDownloadStatusError;
        [DDDownloadDBManager.sharedManager insertDownloadModel:downloadModel];
        [NSNotificationCenter.defaultCenter postNotificationName:url.DD_md5 object:nil userInfo:@{DD_NotificationModelKey:downloadModel}];
        
    }else {
        DDDownloadModel *downloadModel = [DDDownloadDBManager.sharedManager queryDownloadModelWithUrl:url];
        downloadModel.status = DDDownloadStatusSuccess;
        downloadModel.progress = 1;
        [self setResumeDataWithUrl:downloadModel.url resumeData:nil];
        [DDDownloadDBManager.sharedManager insertDownloadModel:downloadModel];
        [NSNotificationCenter.defaultCenter postNotificationName:url.DD_md5 object:nil userInfo:@{DD_NotificationModelKey:downloadModel}];
        
    }

}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    NSString *url = downloadTask.currentRequest.URL.absoluteString;
    
    DDDownloadModel *downloadModel = [[DDDownloadModel alloc] init];
    downloadModel.fileSize = totalBytesExpectedToWrite;
    downloadModel.recievedSize = totalBytesWritten;
    downloadModel.progress = (totalBytesWritten*1.0) / (totalBytesExpectedToWrite*1.0);
    downloadModel.status = DDDownloadStatusDownloading;
    downloadModel.url = url;
    
    [NSNotificationCenter.defaultCenter postNotificationName:url.DD_md5 object:nil userInfo:@{DD_NotificationModelKey:downloadModel}];
    
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes {
    NSLog(@"###### continu");
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    
    NSString *url = task.currentRequest.URL.absoluteString;
    
    if (error) {
        
        NSLog(@"###### error");
        NSLog(@"%@",error);
        NSLog(@"errorCode: %ld",error.code);
        NSLog(@"%@",error.description);
        
        
        if (error.code == -999) {
            
            NSData *resumeData = error.userInfo[NSURLSessionDownloadTaskResumeData];
            [self setResumeDataWithUrl:url resumeData:resumeData];
            
            CGFloat progress = (task.countOfBytesReceived*1.0) / (task.countOfBytesExpectedToReceive*1.0);
            DDDownloadModel *downloadModel = [DDDownloadDBManager.sharedManager queryDownloadModelWithUrl:url];
            downloadModel.status = DDDownloadStatusPause;
            downloadModel.progress = progress;
            
            [DDDownloadDBManager.sharedManager insertDownloadModel:downloadModel];
            
            [NSNotificationCenter.defaultCenter postNotificationName:downloadModel.url.DD_md5 object:nil userInfo:@{DD_NotificationModelKey:downloadModel}];
            
        }else if (error.code == 2) {
            
        }else {
            
        }
    }
    
    
}



@end
