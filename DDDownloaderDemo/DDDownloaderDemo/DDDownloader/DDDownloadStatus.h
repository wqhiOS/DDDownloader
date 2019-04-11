//
//  DDDownloadStatus.h
//  DDDownloaderDemo
//
//  Created by wuqh on 2019/4/10.
//  Copyright © 2019 吴启晗. All rights reserved.
//

#ifndef DDDownloadStatus_h
#define DDDownloadStatus_h

typedef NS_ENUM(NSInteger, DDDownloadStatus) {
    DDDownloadStatusWait = 0,
    DDDownloadStatusDownloading = 1,
    DDDownloadStatusPause = 2,
    DDDownloadStatusSuccess = 3,
    DDDownloadStatusError = 4
};


#endif /* DDDownloadStatus_h */
