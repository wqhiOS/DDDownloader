//
//  DDDownloadModel.h
//  DDDownloaderDemo
//
//  Created by wuqh on 2019/4/10.
//  Copyright © 2019 吴启晗. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "DDDownloadStatus.h"

NS_ASSUME_NONNULL_BEGIN

@interface DDDownloadModel : NSObject

/**
 net url
 */
@property (nonatomic, copy) NSString *url;


/**
 download status
 */
@property (nonatomic, assign) DDDownloadStatus status;


/**
 local file path
 */
@property (nonatomic, copy) NSString *localpath;

/**
 prgress 0~1
 */
@property (nonatomic, assign) CGFloat progress;

/**
 total file size
 */
@property (nonatomic, assign) NSInteger fileSize;


/**
 download recieved size
 */
@property (nonatomic, assign) NSInteger recievedSize;


/**
 The following four parameters are used by the user according to the business logic
 */
@property (nonatomic, copy) NSString *customId;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *category;
@property (nonatomic, copy) NSString *extra;


@end

NS_ASSUME_NONNULL_END
