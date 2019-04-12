//
//  DDDownloadDBManager.m
//  DDDownloaderDemo
//
//  Created by wuqh on 2019/4/10.
//  Copyright © 2019 吴启晗. All rights reserved.
//

#import "DDDownloadDBManager.h"
#import "DDDownloadFileHandler.h"
#import <FMDB/FMDB.h>
#import "DDDownloadModel.h"

const NSString *table_name = @"downloads";

//const NSString *key_downloadId = @"downloadId";
const NSString *key_url = @"url";
const NSString *key_status = @"status";
const NSString *key_localpath = @"localpath";
const NSString *key_progress = @"progress";

const NSString *key_userId = @"userId";
const NSString *key_type = @"type";
const NSString *key_category = @"category";
const NSString *key_customId = @"customId";
const NSString *key_extra = @"extra";

@interface DDDownloadDBManager()

@property (nonatomic, strong) FMDatabaseQueue *databaseQueue;

@end

@implementation DDDownloadDBManager

static DDDownloadDBManager *_instance;
+(instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[DDDownloadDBManager alloc] init];
    });
    return _instance;
}

- (instancetype)init {
    if (self = [super init]) {
        
        [self createDatabase];
        
    }
    return self;
}

- (BOOL)createDatabase {
    
    __block BOOL created = YES;
    if (![NSFileManager.defaultManager fileExistsAtPath:DDDownloadFileHandler.databaseFilePath]) {
        
        self.databaseQueue = [FMDatabaseQueue databaseQueueWithPath:DDDownloadFileHandler.databaseFilePath];
        
        [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
            NSString *createDownloadsTableSql = [NSString stringWithFormat:@"create table if not exists %@ (\
                                                 %@ text primary key,\
                                                 %@ integer,\
                                                 %@ text,\
                                                 %@ real,\
                                                 %@ text,\
                                                 %@ text,\
                                                 %@ text,\
                                                 %@ text,\
                                                 %@ text)"
                                                 ,table_name,key_url,key_status,key_localpath,key_progress,key_userId,key_type,key_category,key_customId,key_extra];
            created = [db executeUpdate:createDownloadsTableSql];
            if (created == NO) {
                NSLog(@"%@",db.lastError);
            }
            
        }];
    }else {
        self.databaseQueue = [FMDatabaseQueue databaseQueueWithPath:DDDownloadFileHandler.databaseFilePath];
    }
    
    return created;
}

- (BOOL)insertDownloadModel:(DDDownloadModel *)downoadModel{
    
    NSLog(@"开始写入");
    NSLog(@"%lf",downoadModel.progress);
    
    if (downoadModel.url.length <= 0) {
        return NO;
    }

    NSString *url = downoadModel.url ? : @"";
    NSNumber *status = [NSNumber numberWithInteger:downoadModel.status] ? : @(0);
    NSString *localpath = downoadModel.localpath ? : @"";
    NSNumber *progress = [NSNumber numberWithFloat:downoadModel.progress] ? : @(0);
    NSString *userId = downoadModel.userId ? : @"";
    NSString *type = downoadModel.type ? : @"";
    NSString *category = downoadModel.category ? : @"";
    NSString *customId = downoadModel.customId ? : @"";
    NSString *extra = downoadModel.extra ? : @"";
    
    
    NSString *insertDownloadSql = [NSString stringWithFormat:@"insert or replace into %@ (%@,%@,%@,%@,%@,%@,%@,%@,%@) values (?,?,?,?,?,?,?,?,?)",table_name,key_url,key_status,key_localpath,key_progress,key_userId,key_type,key_category,key_customId,key_extra];
    NSLog(@"%@",insertDownloadSql);
    
    [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
        [db open];
        [db executeUpdate:insertDownloadSql withArgumentsInArray:@[url,status,localpath,progress,userId,type,category,customId,extra]];
        [db close];
    }];
    
    return YES;
    
}

- (DDDownloadModel *)queryDownloadModelWithUrl:(NSString *)url {
    NSString *queryDonwloadModelSql = [NSString stringWithFormat:@"select * from %@ where %@ = '%@'",table_name,key_url,url];
    __block DDDownloadModel *download;
    [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *resultSet = [db executeQuery:queryDonwloadModelSql];
        if (resultSet.next) {
            NSLog(@"查询成功");
            DDDownloadModel *downloadModel = [[DDDownloadModel alloc] init];
            [downloadModel setValuesForKeysWithDictionary:resultSet.resultDictionary];
            download = downloadModel;
        }
    }];
    return download;
}

- (NSArray<DDDownloadModel *> *)queryDownloadModels {
    NSMutableArray <DDDownloadModel *>*downloadModels = [NSMutableArray array];
    
    NSString *queryDownloadsSql = [NSString stringWithFormat:@"select * from %@",table_name];
    [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
        
        FMResultSet *resultSet = [db executeQuery:queryDownloadsSql];
        
        while (resultSet.next) {
            DDDownloadModel *downloadModel = [[DDDownloadModel alloc] init];
            [downloadModel setValuesForKeysWithDictionary:resultSet.resultDictionary];
            [downloadModels addObject:downloadModel];
        }
    }];
    return downloadModels;
}

- (BOOL)deleteDownloadModelsWithUrls:(NSMutableArray<NSString *> *)urls {
    
    [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
        for (NSString *url  in urls) {
            NSString *deleteSql = [NSString stringWithFormat:@"delete from %@ WHERE %@ = '%@'",table_name,key_url,url];
            [db executeUpdate:deleteSql];
        }
    }];
    
    return YES;
}

@end
