//
//  DownloadCell.h
//  DDDownloaderDemo
//
//  Created by wuqh on 2019/4/12.
//  Copyright © 2019 吴启晗. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DDDownloadModel;

NS_ASSUME_NONNULL_BEGIN

@interface DownloadCell : UITableViewCell

@property (nonatomic, strong) DDDownloadModel *downloadModel;

@end

NS_ASSUME_NONNULL_END
