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
        
        self.maximumDownloading = 3;
        self.downloadTasks = [[NSMutableDictionary alloc]init];
        self.downloadingTasks = [NSMutableArray array];
        
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"com.wuqh.DDDownloader"];
        config.timeoutIntervalForRequest = 10;
        config.sessionSendsLaunchEvents = YES;
        self.session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
        
        [DDDownloadFileHandler createResumeDataDirectory];
        [DDDownloadFileHandler createDownloadDirectory];
        
    }
    return self;
}

#pragma mark - public method
- (void)download:(DDDownloadModel *)downloadModel {
    
    //validate url
    if (downloadModel.url.length < 0) {
        return;
    }
    
    if ([self isDownloadingWithUrl:downloadModel.url]) {
        return;
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
    
}

- (void)suspendWithUrl:(NSString *)url {
    NSURLSessionDownloadTask *downloadTask = self.downloadTasks[url];
    [downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        if (resumeData) {
            if ([self setResumeDataWithUrl:url resumeData:resumeData]) {
                [DDDownloadDBManager.sharedManager queryDownloadModelWithUrl:url complete:^(DDDownloadModel * _Nonnull downloadModel) {
                    downloadModel.status = DDDownloadStatusPause;
                    [DDDownloadDBManager.sharedManager insertDownloadModel:downloadModel];
                    [NSNotificationCenter.defaultCenter postNotificationName:url.DD_md5 object:nil userInfo:@{DD_NotificationModelKey:downloadModel}];
                }];
            }else {
                NSAssert(YES, @"resumeData write fail");
            }
        }else {
            NSAssert(resumeData == nil, @"resumeData == nil");
        }
    }];
}
- (void)deleteWithUrls:(NSMutableArray<NSString *> *)urls {
    
    //cancel task
    for (NSString *url in urls) {
        NSURLSessionDownloadTask *downloadTask = self.downloadTasks[url];
        [downloadTask cancel];
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
    [DDDownloadFileHandler createResumeDataDirectory];
    NSString *resumeDataPath = [DDDownloadFileHandler getResumeDataPathWithUrl:url];
    return [resumeData writeToFile:resumeDataPath atomically:YES];
}

#pragma mark - NSURLSessionDelegate
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    NSLog(@"###### didFinishEventsForBackgroundURLSession");
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
        [DDDownloadDBManager.sharedManager queryDownloadModelWithUrl:url complete:^(DDDownloadModel * downloadModel) {
            if (downloadModel) {
                downloadModel.status = DDDownloadStatusError;
                [DDDownloadDBManager.sharedManager insertDownloadModel:downloadModel];
                [NSNotificationCenter.defaultCenter postNotificationName:url.DD_md5 object:nil userInfo:@{DD_NotificationModelKey:downloadModel}];
                
            }
        }];
        
    }else {
        [DDDownloadDBManager.sharedManager queryDownloadModelWithUrl:url complete:^(DDDownloadModel * downloadModel) {
            if (downloadModel) {
                downloadModel.status = DDDownloadStatusSuccess;
                [DDDownloadDBManager.sharedManager insertDownloadModel:downloadModel];
                [NSNotificationCenter.defaultCenter postNotificationName:url.DD_md5 object:nil userInfo:@{DD_NotificationModelKey:downloadModel}];
            }
        }];
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



@end
