//
//  HqAlertView.m
//  QRCode
//
//  Created by macpro on 2018/1/25.
//  Copyright © 2018年 macpro. All rights reserved.
//

#import "HqAlertView.h"
#import <UIKit/UIKit.h>
@interface HqAlertView()
@property (nonatomic,strong) UIAlertController *avc;
@end
@implementation HqAlertView

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message{
    
    if (self = [super init]) {
        [self setupWithTitle:title message:message style:UIAlertControllerStyleAlert];
    }
    return self;
}
- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message style:(UIAlertControllerStyle)style{
    if (self = [super init]) {
        [self setupWithTitle:title message:message style:style];
    }
    return self;
}
- (void)setupWithTitle:(NSString *)title message:(NSString *)message style:(UIAlertControllerStyle)style{
    self.title = title;
    self.message = message;
    self.avc = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:style];
}
- (void)setBtnTitles:(NSArray *)btnTitles{
    
    _btnTitles = btnTitles;
    if (_btnTitles) {
        int index = 0;
        for (NSString *myTitle in _btnTitles) {
            if (index==0) {
             UIAlertAction *action = [self addBtnsWithTitle:myTitle type:UIAlertActionStyleCancel];
                
                index = 1;
                [action setValue:self.firstBtnColor forKey:@"titleTextColor"];

            }else{
               UIAlertAction *action =  [self addBtnsWithTitle:myTitle type:UIAlertActionStyleDefault];
                [action setValue:self.otherBtnColor forKey:@"titleTextColor"];
            }            
        }
    }
    
}
- (UIAlertAction *)addBtnsWithTitle:(NSString *)title type:(UIAlertActionStyle)style{
    UIAlertAction *action = [UIAlertAction actionWithTitle:title style:style handler:^(UIAlertAction * _Nonnull action) {
        for (int i = 0; i<self.avc.actions.count; i++) {
            UIAlertAction *innerAction = self.avc.actions[i];
        
           
            if ([innerAction isEqual:action]) {
                if (self.alertCallBack) {
                    self.alertCallBack(action, i);
                }
                break;
            }
        }
    }];
    [self.avc addAction:action];
    return action;
}
- (void)showVC:(UIViewController *)vc callBack:(HqAlertCallBack)callBack{
    self.alertCallBack = callBack;
    [vc presentViewController:self.avc animated:YES completion:nil];
}
@end
