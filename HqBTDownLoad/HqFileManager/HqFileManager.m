//
//  HqFileManager.m
//  HqBTDownLoad
//
//  Created by hqmac on 2018/9/21.
//  Copyright © 2018年 hehuiqi. All rights reserved.
//

#import "HqFileManager.h"

@implementation HqFileManager

+ (NSFileManager *)fm{
    return  [NSFileManager defaultManager];
}

+ (BOOL)isDirectory:(NSString *)filePath
{
    NSNumber *isDirectory;
    NSURL *fileUrl = [NSURL fileURLWithPath:filePath];
    [fileUrl getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:nil];
    return isDirectory.boolValue;
}
+ (NSArray *)filesWithDir:(NSString *)dir{
    NSString *fullPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    [HqFileManager shareInstance].localDir = fullPath;
    NSArray *files = [self.fm contentsOfDirectoryAtPath:fullPath error:nil];
  
    NSMutableArray *simpleFiles = @[].mutableCopy;
    for (NSString *file in files) {
        NSString *filePath = [fullPath stringByAppendingPathComponent:file];
//        id strs =  [self.fm attributesOfItemAtPath:filePath error:nil];
//        NSLog(@"file-atr==%@",strs);
        if (![self isDirectory:filePath]) {
            [simpleFiles addObject:file];
        }
    }
//    NSLog(@"files == %@",files);
    return simpleFiles;
}

+ (instancetype)shareInstance{
    static HqFileManager *hfm = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        hfm = [[self alloc] init];
    });
    return hfm;
}
+ (NSArray *)hqDocumentFiles{
    
    return [self filesWithDir:nil];

}
+ (NSArray *)hqListFilesWithDir:(NSString *)dir{
   
    if (!dir) {
        return [self filesWithDir:dir];
    }
    return nil;
}

+ (BOOL)hqDelateFileWithPath:(NSString *)path{
    if (path) {
        path = [[HqFileManager shareInstance].localDir stringByAppendingPathComponent:path];
    }
    NSError *error;
    BOOL suc = [self.fm removeItemAtPath:path error:&error];
    if (error) {
        return NO;
    }
    return suc;
}
+ (BOOL)hqRenameFileWithPath:(NSString *)path newPath:(NSString *)newPath{
    NSString *ext = [[path componentsSeparatedByString:@"."] lastObject];
    path = [[HqFileManager shareInstance].localDir stringByAppendingPathComponent:path];
    NSString *subfix = [@"" stringByAppendingFormat:@".%@",ext];
    if (![newPath containsString:subfix]) {
        newPath = [newPath stringByAppendingFormat:@"%@",subfix];
    }
    newPath = [[HqFileManager shareInstance].localDir stringByAppendingPathComponent:newPath];
    NSError *error;
    BOOL suc = [self.fm moveItemAtPath:path toPath:newPath error:&error];
    NSLog(@"error ==%@",error);
    return suc;
}
@end
