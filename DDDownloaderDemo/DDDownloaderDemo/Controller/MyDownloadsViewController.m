//
//  MyDownloadsViewController.m
//  DDDownloaderDemo
//
//  Created by wuqh on 2019/4/10.
//  Copyright © 2019 吴启晗. All rights reserved.
//

#import "MyDownloadsViewController.h"
#import "DownloadCell.h"
#import "DDDownloader.h"
#import <AVKit/AVKit.h>
@interface MyDownloadsViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *downloadArray;

@end

@implementation MyDownloadsViewController

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;
    self.title = @"My Downloads";
    [self.view addSubview:self.tableView];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadData];
}

- (void)loadData {
    self.downloadArray = [DDDownloadDBManager.sharedManager queryDownloadModels];
    for (DDDownloadModel *downloadModel in self.downloadArray) {
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(downloadNotification:) name:downloadModel.url.DD_md5 object:nil];
    }
    [self.tableView reloadData];
}

- (void)downloadNotification:(NSNotification *)notification {
    
    DDDownloadModel *nf_downloadModel = notification.userInfo[DD_NotificationModelKey];
    
    for (NSInteger i = 0; i < self.downloadArray.count; ++i) {
        DDDownloadModel *downloadModel = self.downloadArray[i];
        if ([downloadModel.url isEqualToString:nf_downloadModel.url]) {
            NSInteger index = [self.downloadArray indexOfObject:downloadModel];
            downloadModel.progress = nf_downloadModel.progress;
            downloadModel.status = nf_downloadModel.status;
            dispatch_async(dispatch_get_main_queue(), ^{
                DownloadCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
                cell.downloadModel = downloadModel;
            });
            break;
        }
    }
    
}

#pragma mark - getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.rowHeight = 60;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerNib:[UINib nibWithNibName:NSStringFromClass([DownloadCell class]) bundle:NSBundle.mainBundle] forCellReuseIdentifier:NSStringFromClass([DownloadCell class])];
    }
    return _tableView;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.downloadArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DownloadCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(DownloadCell.class) forIndexPath:indexPath];
    DDDownloadModel *downloadModel = self.downloadArray[indexPath.row];
    cell.downloadModel = downloadModel;
    
    __weak typeof(self) weakSelf = self;
    cell.clickPlayButton = ^(UIButton * _Nonnull button) {
        AVPlayerViewController *playerVc = [[AVPlayerViewController alloc] init];
        AVPlayer *player = [AVPlayer playerWithURL:[NSURL fileURLWithPath:downloadModel.localpath]];
        playerVc.player = player;
        [playerVc.player play];
        [weakSelf presentViewController:playerVc animated:YES completion:nil];
    };
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    DDDownloadModel *downloadModel = self.downloadArray[indexPath.row];
    [NSNotificationCenter.defaultCenter removeObserver:self name:downloadModel.url.DD_md5 object:nil];
    [DDDownloadDBManager.sharedManager deleteDownloadModelsWithUrls:@[downloadModel.url]];
    [self loadData];
}

@end
