//
//  DDDownloaderManager.m
//  DDDownloaderDemo
//
//  Created by wuqh on 2019/4/10.
//  Copyright © 2019 吴启晗. All rights reserved.
//

#import "DDDownloadManager.h"
#import "DDDownloadFileHandler.h"

@interface DDDownloadManager()<NSURLSessionDelegate>

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSMutableDictionary<NSString*,NSURLSessionDownloadTask*> *downloadTasks;

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
        
        self.downloadTasks = [[NSMutableDictionary alloc]init];
        
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
- (void)downloadWithUrl:(NSString*)url {
    
    if (url.length <= 0) {
        return;
    }
    
    NSData *resumeData = [self getResumeDataWithUrl:url];
    NSURLSessionDownloadTask *downloadTask;
    if (resumeData) {
        downloadTask = [self.session downloadTaskWithResumeData:resumeData];
    }else {
        downloadTask = [self.session downloadTaskWithURL:[NSURL URLWithString:url]];
    }
    self.downloadTasks[url] = downloadTask;
    [downloadTask resume];
}

- (void)suspendWithUrl:(NSString *)url {
    NSURLSessionDownloadTask *downloadTask = self.downloadTasks[url];
    [downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        if (resumeData) {
            if ([self setResumeDataWithUrl:url resumeData:resumeData]) {
                NSAssert(YES, @"resumeData write fail");
            }
        }else {
            NSAssert(resumeData == nil, @"resumeData == nil");
        }
    }];
}
- (void)deleteWithUrl:(NSString *)url {
    
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
    NSLog(@"%s",__FUNCTION__);
}

@end
