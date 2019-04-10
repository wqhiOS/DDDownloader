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

@interface MainViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = UIColor.whiteColor;
    self.title = @"DDDownloader";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"setting"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(setting)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"downloads"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(toMyDownloads)];
    
    [self loadData];
    [self.view addSubview:self.tableView];
    
}

#pragma mark - load data
- (void)loadData {
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"downloadSource" ofType:@"plist"];
    self.dataArray = [[NSMutableArray alloc] initWithContentsOfFile:plistPath];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MainCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(MainCell.class) forIndexPath:indexPath];
    cell.sourceDict = self.dataArray[indexPath.row];
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


