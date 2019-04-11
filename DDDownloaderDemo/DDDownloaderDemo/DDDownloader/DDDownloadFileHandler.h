//
//  DDDownloaderFileHandler.h
//  DDDownloaderDemo
//
//  Created by wuqh on 2019/4/10.
//  Copyright © 2019 吴启晗. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DDDownloadFileHandler : NSObject

@property(class, nonatomic, readonly) NSString *resumeDataDirectory;
@property(class, nonatomic, readonly) NSString *downloadDirectory;
@property(class, nonatomic, readonly) NSString *databaseFilePath;

+ (void)createResumeDataDirectory;
+ (void)createDownloadDirectory;

+ (NSString *)getResumeDataPathWithUrl:(NSString *)url;

@end

NS_ASSUME_NONNULL_END
