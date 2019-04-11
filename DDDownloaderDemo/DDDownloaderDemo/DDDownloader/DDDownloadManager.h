//
//  DDDownloaderManager.h
//  DDDownloaderDemo
//
//  Created by wuqh on 2019/4/10.
//  Copyright © 2019 吴启晗. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DDDownloadModel;

NS_ASSUME_NONNULL_BEGIN

@interface DDDownloadManager : NSObject

+(instancetype)sharedManager;

- (void)download:(DDDownloadModel *)downloadModel;
- (void)suspendWithUrl:(NSString *)url;
- (void)deleteWithUrls:(NSMutableArray<NSString*> *)urls;

- (BOOL)isDownloadingWithUrl:(NSString *)url;


@end

NS_ASSUME_NONNULL_END
