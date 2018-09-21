//
//  HqDownloadManager.h
//  HqBTDownLoad
//
//  Created by hqmac on 2018/9/20.
//  Copyright © 2018年 hehuiqi. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^HqDownloadManagerProgress) (float progress);
typedef void (^HqDownloadManagerComplate) (BOOL result);

@interface HqDownloadManager : NSObject
+ (instancetype)shareInstance;
@property (nonatomic,copy) HqDownloadManagerProgress progressBlock;
@property (nonatomic,copy) HqDownloadManagerComplate complateBlock;

+ (void)startDownloadWithURLString:(NSString *)urltring;

@end
