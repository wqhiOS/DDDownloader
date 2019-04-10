//
//  MainViewController.m
//  DDDownloaderDemo
//
//  Created by wuqh on 2019/4/10.
//  Copyright © 2019 吴启晗. All rights reserved.
//

#import "MainViewController.h"
#import "SettingViewController.h"
#import "MyDownloadsViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = UIColor.whiteColor;
    self.title = @"DDDownloader";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"setting" style:UIBarButtonItemStylePlain target:self action:@selector(setting)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"myDonwloads" style:UIBarButtonItemStylePlain target:self action:@selector(toMyDownloads)];
    
}
- (void)setting {
    [self.navigationController pushViewController:[SettingViewController new] animated:YES];
}

- (void)toMyDownloads {
    [self.navigationController pushViewController:[MyDownloadsViewController new] animated:YES];
}

@end
