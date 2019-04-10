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

@property (nonatomic, assign) DDDownloadStatus status;

@property (nonatomic, copy) NSString *downloadUrl;

@property (nonatomic, copy) NSString *localpath;

@property (nonatomic, assign) CGFloat progress;


@end

NS_ASSUME_NONNULL_END
