//
//  HqFileListVC.h
//  HqBTDownLoad
//
//  Created by hqmac on 2018/9/20.
//  Copyright © 2018年 hehuiqi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HqFileListVCDelegate;

@interface HqFileListVC : UIViewController

@property (nonatomic,weak) id<HqFileListVCDelegate> delegate;

@end

@protocol HqFileListVCDelegate
@optional
- (void)HqFileListVC:(HqFileListVC *)vc palyUrl:(NSString *)url;
- (void)HqFileListVC:(HqFileListVC *)vc palyUrl:(NSString *)url filename:(NSString *)filename;

@end
