//
//  DDDownloaderFileHandler.m
//  DDDownloaderDemo
//
//  Created by wuqh on 2019/4/10.
//  Copyright © 2019 吴启晗. All rights reserved.
//

#import "DDDownloadFileHandler.h"
#import "NSString+DDExtensions.h"


@implementation DDDownloadFileHandler

#pragma mark - static property
+ (NSString *)resumeDataDirectory {
    return [NSString stringWithFormat:@"%@/resumeData/",NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)];
}

+ (NSString *)downloadDirectory {
    return [NSString stringWithFormat:@"%@/DDDownloads/",NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)];
}
+ (NSString *)databaseFilePath {
    return [NSString stringWithFormat:@"%@/DDDownloader.sqlite",NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)];
}

#pragma mark - static methpd
+ (void)createResumeDataDirectory {
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.resumeDataDirectory]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:self.resumeDataDirectory withIntermediateDirectories:NO attributes:nil error:nil];
    }
}
+ (void)createDownloadDirectory {
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.downloadDirectory]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:self.downloadDirectory withIntermediateDirectories:NO attributes:nil error:nil];
    }
}

+ (NSString *)getResumeDataPathWithUrl:(NSString *)url {
    return [NSString stringWithFormat:@"%@%@",self.resumeDataDirectory,url.DD_md5];
}

+ (NSString *)getDownloadFilePathWithUrl:(NSString *)url {
    return [NSString stringWithFormat:@"%@%@.%@",self.downloadDirectory,url.DD_md5,url.pathExtension];
}

@end
