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

@property (nonatomic, strong) FMDatabase *database;

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
    
    BOOL created = YES;
    if (![NSFileManager.defaultManager fileExistsAtPath:DDDownloadFileHandler.databaseFilePath]) {
        
        self.database = [[FMDatabase alloc] initWithPath:DDDownloadFileHandler.databaseFilePath];
        
        if ([self.database open]) {
            // 9 col
            NSString *createDownloadsTableSql = [NSString stringWithFormat:@"create table if not exists %@ (\
                                                 %@ text primary key,\
                                                 %@ text,\
                                                 %@ integer,\
                                                 %@ text,\
                                                 %@ float,\
                                                 %@ text,\
                                                 %@ text,\
                                                 %@ text,\
                                                 %@ text)"
            ,table_name,key_url,key_status,key_localpath,key_progress,key_userId,key_type,key_category,key_customId,key_extra];
            
            created = [self.database executeUpdate:createDownloadsTableSql];
            if (created == NO) {
                NSLog(@"%@",self.database.lastError);
            }
            [self.database close];
        }
    }
    
    return created;
}

- (BOOL)openDatabase {
    if (self.database == nil) {
        [self createDatabase];
    }
    
    if (self.database) {
        return [self.database open];
    }else {
        return NO;
    }
}

- (BOOL)insertDownloadModel:(DDDownloadModel *)downoadModel{
    
    if ([self openDatabase] == NO) {
        return NO;
    }
    if (downoadModel.url.length <= 0) {
        return NO;
    }

    NSString *url = downoadModel.url ? : @"";
    NSNumber *status = [NSNumber numberWithInteger:downoadModel.status];
    NSString *localpath = downoadModel.localpath ? : @"";
    NSNumber *progress = [NSNumber numberWithFloat:downoadModel.progress];
    NSString *userId = downoadModel.userId ? : @"";
    NSString *type = downoadModel.type ? : @"";
    NSString *category = downoadModel.category ? : @"";
    NSString *customId = downoadModel.customId ? : @"";
    NSString *extra = downoadModel.extra ? : @"";
    
    
    NSString *insertDownloadSql = [NSString stringWithFormat:@"insert or replace into %@ (%@,%@,%@,%@,%@,%@,%@,%@,%@) values (?,?,?,?,?,?,?,?,?)",table_name,key_url,key_status,key_localpath,key_progress,key_userId,key_type,key_category,key_customId,key_extra];
    NSLog(@"%@",insertDownloadSql);
    [self.database executeUpdate:insertDownloadSql withArgumentsInArray:@[url,status,localpath,progress,userId,type,category,customId,extra]];
    [self.database close];
    
    return YES;
    
}

- (void)queryDownloadModelsComplete:(void(^)(NSMutableArray<DDDownloadModel*> *))complete {
    NSMutableArray <DDDownloadModel *>*downloadModels = [NSMutableArray array];
    
    if ([self openDatabase] == NO) {
        complete(downloadModels);
        return;
    }
    
    NSString *queryDownloadsSql = [NSString stringWithFormat:@"select * from %@",table_name];
    FMResultSet *resultSet = [self.database executeQuery:queryDownloadsSql];
    
    while (resultSet.next) {
        DDDownloadModel *downloadModel = [[DDDownloadModel alloc] init];
        [downloadModel setValuesForKeysWithDictionary:resultSet.resultDictionary];
        [downloadModels addObject:downloadModel];
    }
    
    complete(downloadModels);
    
    [self.database close];
}

- (void)queryDownloadModelWithUrl:(NSString *)url complete:(void (^)(DDDownloadModel * _Nullable))complete {
    if ([self openDatabase] == NO) {
        complete(nil);
        return;
    }
    NSString *queryDonwloadModelSql = [NSString stringWithFormat:@"select * from %@ where %@ = '%@'",table_name,key_url,url];
    FMResultSet *resultSet = [self.database executeQuery:queryDonwloadModelSql];
    if (resultSet.next) {
        DDDownloadModel *downloadModel = [[DDDownloadModel alloc] init];
        [downloadModel setValuesForKeysWithDictionary:resultSet.resultDictionary];
        complete(downloadModel);
    }else {
        complete(nil);
    }
    
}


- (BOOL)deleteDownloadModelsWithUrls:(NSMutableArray<NSString *> *)urls {
    
    if ([self openDatabase] == NO) {
        return NO;
    }
    
    for (NSString *url  in urls) {
        NSString *deleteSql = [NSString stringWithFormat:@"delete from %@ WHERE %@ = '%@'",table_name,key_url,url];
        [self.database executeUpdate:deleteSql];
    }
    [self.database close];
    
    return YES;
}

@end
