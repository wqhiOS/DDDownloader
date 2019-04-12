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

@interface MyDownloadsViewController ()<UITableViewDataSource>

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
            downloadModel = nf_downloadModel;
            dispatch_async(dispatch_get_main_queue(), ^{
                DownloadCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
                cell.downloadModel = nf_downloadModel;
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
//        _tableView.delegate = self;
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
    cell.downloadModel = self.downloadArray[indexPath.row];
    return cell;
}

@end
