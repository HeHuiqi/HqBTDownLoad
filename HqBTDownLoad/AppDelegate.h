//
//  AppDelegate.h
//  HqBTDownLoad
//
//  Created by hehuiqi on 2018/9/16.
//  Copyright © 2018年 hehuiqi. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^HqBackgroundHanlder)(void);

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic,copy) HqBackgroundHanlder backgroundSessionCompletionHandler;

@end

