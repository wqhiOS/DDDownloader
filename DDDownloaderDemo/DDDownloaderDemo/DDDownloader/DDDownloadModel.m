//
//  DDDownloadModel.m
//  DDDownloaderDemo
//
//  Created by wuqh on 2019/4/10.
//  Copyright © 2019 吴启晗. All rights reserved.
//

#import "DDDownloadModel.h"
#import "DDDownloadFileHandler.h"

@implementation DDDownloadModel

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

-(void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}
- (void)setNilValueForKey:(NSString *)key {
    
}

- (NSString *)localpath {
    return [DDDownloadFileHandler getDownloadFilePathWithUrl:self.url];
}

@end
