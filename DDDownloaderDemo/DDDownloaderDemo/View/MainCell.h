//
//  MainCell.h
//  DDDownloaderDemo
//
//  Created by wuqh on 2019/4/10.
//  Copyright © 2019 吴启晗. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DDDownloadModel;

NS_ASSUME_NONNULL_BEGIN

@interface MainCell : UITableViewCell

@property (nonatomic, copy) void(^clickStatusButton)(UIButton*);

@property (nonatomic, weak) NSDictionary *sourceDict;

@property (nonatomic, strong) DDDownloadModel *downloadModel;

@end

NS_ASSUME_NONNULL_END
