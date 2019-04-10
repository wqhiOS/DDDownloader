//
//  DDDownloaderManager.m
//  DDDownloaderDemo
//
//  Created by wuqh on 2019/4/10.
//  Copyright © 2019 吴启晗. All rights reserved.
//

#import "DDDownloaderManager.h"

@implementation DDDownloaderManager

static DDDownloaderManager *instance;
+(instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[DDDownloaderManager alloc] init];
    });
    return instance;
}


@end
