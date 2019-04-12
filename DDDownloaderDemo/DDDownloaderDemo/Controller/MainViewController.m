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
#import "MainCell.h"
#import "DDDownloader.h"

@interface MainViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableDictionary<NSString *,DDDownloadModel*>*downloadModelArrayDict;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self loadData];
    [self setupUI];
    
    [self queryDownloadModels];
    
}

#pragma mark - notification
- (void)downloadNotification:(NSNotification *)notification {

    DDDownloadModel *downloadModel = notification.userInfo[DD_NotificationModelKey];
    
    for (NSDictionary  *dict in self.dataArray) {
        if ([dict[@"url"] isEqualToString:downloadModel.url]) {
            NSInteger index = [self.dataArray indexOfObject:dict];
            dispatch_async(dispatch_get_main_queue(), ^{
                MainCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
                if (cell != nil) {
                    cell.downloadModel = downloadModel;
                }
            });
            break;
        }
    }
    self.downloadModelArrayDict[downloadModel.url] = downloadModel;
    
}

#pragma mark - priate
/**
 load local data with plist
 */
- (void)loadData {
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"downloadSource" ofType:@"plist"];
    self.dataArray = [[NSMutableArray alloc] initWithContentsOfFile:plistPath];
}

- (void)queryDownloadModels {
    NSArray *downloadModelArray = [DDDownloadDBManager.sharedManager queryDownloadModels];
    self.downloadModelArrayDict = @{}.mutableCopy;
    for (DDDownloadModel *downloadModel in downloadModelArray) {
        self.downloadModelArrayDict[downloadModel.url] = downloadModel;
    }
    [self.tableView reloadData];
}

- (void)setupUI {
    self.view.backgroundColor = UIColor.whiteColor;
    self.title = @"DDDownloader";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"setting"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(setting)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"downloads"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(toMyDownloads)];
    
    
    [self.view addSubview:self.tableView];
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MainCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(MainCell.class) forIndexPath:indexPath];
    NSDictionary *sourceDict = self.dataArray[indexPath.row];
    cell.sourceDict = sourceDict;
    
    DDDownloadModel *downloadModel = self.downloadModelArrayDict[sourceDict[@"url"]];
    NSLog(@"%@",downloadModel);
    cell.downloadModel = downloadModel;
    
//    __weak typeof(self) weakSelf = self;
    cell.clickStatusButton = ^(UIButton * _Nonnull statusButton) {
        //start or pause
        NSString *url = sourceDict[@"url"];
        if ([DDDownloadManager.sharedManager isDownloadingWithUrl:url]) {
            //cancel operation
            [DDDownloadManager.sharedManager suspendWithUrl:url];
        }else {
            //to download operation
            DDDownloadModel *downloadModel = [[DDDownloadModel alloc]init];
            downloadModel.url = url;
            downloadModel.extra = sourceDict[@"title"];
            [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(downloadNotification:) name:url.DD_md5 object:nil];
            [DDDownloadManager.sharedManager download:downloadModel];
            
        }
    };
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
}

#pragma mark - Setter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.rowHeight = 60;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerNib:[UINib nibWithNibName:NSStringFromClass([MainCell class]) bundle:NSBundle.mainBundle] forCellReuseIdentifier:NSStringFromClass([MainCell class])];
    }
    return _tableView;
}

#pragma mark - Action
- (void)setting {
    [self.navigationController pushViewController:[SettingViewController new] animated:YES];
}

- (void)toMyDownloads {
    [self.navigationController pushViewController:[MyDownloadsViewController new] animated:YES];
}




@end


