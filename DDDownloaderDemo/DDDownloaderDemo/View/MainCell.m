//
//  MainCell.m
//  DDDownloaderDemo
//
//  Created by wuqh on 2019/4/10.
//  Copyright © 2019 吴启晗. All rights reserved.
//

#import "MainCell.h"

@interface MainCell()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *statusButton;
@property (weak, nonatomic) IBOutlet UISlider *slider;


@end

@implementation MainCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code生成透明图片
    
    [self setupSlider];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)statusButtonClick:(UIButton *)sender {
}

- (void)setupSlider {
    CGSize s=CGSizeMake(1, 1);
    UIGraphicsBeginImageContextWithOptions(s, 0, [UIScreen mainScreen].scale);
    UIRectFill(CGRectMake(0, 0, 1, 1));
    UIImage *img=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [_slider setThumbImage:img forState:UIControlStateNormal];
}

- (void)setSourceDict:(NSDictionary *)sourceDict {
    _sourceDict = sourceDict;
    
    self.titleLabel.text = sourceDict[@"title"];
}

@end
