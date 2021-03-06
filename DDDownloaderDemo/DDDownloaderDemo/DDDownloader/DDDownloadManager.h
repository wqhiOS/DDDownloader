//
//  DDDownloaderManager.h
//  DDDownloaderDemo
//
//  Created by wuqh on 2019/4/10.
//  Copyright © 2019 吴启晗. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DDDownloadModel;

#define DD_NotificationModelKey @"DD_NotificationModelKey"


@interface DDDownloadManager : NSObject

/**
 The maximum number of simultaneous downloads， default is 3
 */
@property (nonatomic, assign) NSInteger maximumDownloading;
@property (nonatomic, copy) void(^backgroundHandler)(void);

+(instancetype)sharedManager;

- (void)download:(DDDownloadModel *)downloadModel;
- (void)suspendWithUrl:(NSString *)url;
- (void)deleteWithUrls:(NSMutableArray<NSString*> *)urls;

- (BOOL)isDownloadingWithUrl:(NSString *)url;


@end

