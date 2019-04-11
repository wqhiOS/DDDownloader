//
//  NSString+DDExtensions.m
//  DDDownloaderDemo
//
//  Created by wuqh on 2019/4/10.
//  Copyright © 2019 吴启晗. All rights reserved.
//

#import "NSString+DDExtensions.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation NSString (DDExtensions)
- (NSString *)DD_md5 {
    const char* str = [self UTF8String];
    unsigned char result[16];
    CC_MD5(str, (CC_LONG)strlen(str), result);
    NSMutableString *ret = [NSMutableString stringWithCapacity:16 * 2];
    for(int i = 0; i<16; i++) {
        [ret appendFormat:@"%02x",(unsigned int)(result[i])];
    }
    return ret;
}


@end
