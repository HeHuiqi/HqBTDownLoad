//
//  HqFileManager.h
//  HqBTDownLoad
//
//  Created by hqmac on 2018/9/21.
//  Copyright © 2018年 hehuiqi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HqFileManager : NSObject

@property (nonatomic,copy) NSString *localDir;
+ (instancetype)shareInstance;
+ (NSArray *)hqDocumentFiles;
+ (NSArray *)hqListFilesWithDir:(NSString *)dir;
+ (BOOL)hqDelateFileWithPath:(NSString *)path;
+ (BOOL)hqRenameFileWithPath:(NSString *)path newPath:(NSString *)newPath;

@end

NS_ASSUME_NONNULL_END
