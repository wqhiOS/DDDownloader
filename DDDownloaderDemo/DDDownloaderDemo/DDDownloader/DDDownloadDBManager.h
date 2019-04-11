//
//  DDDownloadDBManager.h
//  DDDownloaderDemo
//
//  Created by wuqh on 2019/4/10.
//  Copyright © 2019 吴启晗. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DDDownloadModel;

//NS_ASSUME_NONNULL_BEGIN

@interface DDDownloadDBManager : NSObject

+(instancetype)sharedManager;

- (BOOL)insertDownloadModel:(DDDownloadModel *)downoadModel;

- (void)queryDownloadModelsComplete:(void(^)(NSMutableArray<DDDownloadModel*> *))complete;
- (void)queryDownloadModelWithUrl:(NSString*)url complete:(void(^)(DDDownloadModel *))complete;

- (BOOL)deleteDownloadModelsWithUrls: (NSMutableArray<NSString*>*)urls;


@end

//NS_ASSUME_NONNULL_END
