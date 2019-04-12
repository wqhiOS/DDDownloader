//
//  DownloadCell.m
//  DDDownloaderDemo
//
//  Created by wuqh on 2019/4/12.
//  Copyright © 2019 吴启晗. All rights reserved.
//

#import "DownloadCell.h"
#import "DDDownloadModel.h"

@interface DownloadCell()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *statusButton;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UIButton *playButton;

@end

@implementation DownloadCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self setupSlider];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setDownloadModel:(DDDownloadModel *)downloadModel {
    _downloadModel = downloadModel;
    
    switch (downloadModel.status) {
        case DDDownloadStatusWait:
            [self.statusButton setTitle:@"wait" forState:UIControlStateNormal];
            break;
        case DDDownloadStatusPause:
            [self.statusButton setTitle:@"pause" forState:UIControlStateNormal];
            break;
        case DDDownloadStatusDownloading:
            [self.statusButton setTitle:@"loading" forState:UIControlStateNormal];
            break;
        case DDDownloadStatusSuccess:
            [self.statusButton setTitle:@"success" forState:UIControlStateNormal];
            break;
        case DDDownloadStatusError:
            [self.statusButton setTitle:@"error" forState:UIControlStateNormal];
            break;
        default:
            break;
    }
    [self.playButton setHidden:(downloadModel.status != DDDownloadStatusSuccess)];
    self.slider.value = downloadModel.progress;
    self.titleLabel.text = downloadModel.extra;
    
}

- (void)setupSlider {
    CGSize s=CGSizeMake(1, 1);
    UIGraphicsBeginImageContextWithOptions(s, 0, [UIScreen mainScreen].scale);
    UIRectFill(CGRectMake(0, 0, 1, 1));
    UIImage *img=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [_slider setThumbImage:img forState:UIControlStateNormal];
}


@end
