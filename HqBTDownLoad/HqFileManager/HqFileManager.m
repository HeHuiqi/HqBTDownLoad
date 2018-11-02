//
//  HqFileManager.m
//  HqBTDownLoad
//
//  Created by hqmac on 2018/9/21.
//  Copyright © 2018年 hehuiqi. All rights reserved.
//

#import "HqFileManager.h"

@implementation HqFileManager

+ (instancetype)shareInstance{
    static HqFileManager *hfm = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        hfm = [[self alloc] init];
    });
    return hfm;
}

- (NSFileManager *)fm{
    return  [NSFileManager defaultManager];
}

- (BOOL)isDirectory:(NSString *)filePath
{
    NSNumber *isDirectory;
    NSURL *fileUrl = [NSURL fileURLWithPath:filePath];
    [fileUrl getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:nil];
    return isDirectory.boolValue;
}
- (BOOL)fileExistsAtPath:(NSString *)path{
    return [self.fm fileExistsAtPath:path];
}
- (NSString *)fileDefaultDir{
        NSString *fullPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
       self.localDir = fullPath;
    return fullPath;
}
- (NSArray *)filesWithDir:(NSString *)dir{
    NSString *fullPath = [self fileDefaultDir];
    NSArray *files = [self.fm contentsOfDirectoryAtPath:fullPath error:nil];
  
    NSMutableArray *simpleFiles = @[].mutableCopy;
    for (NSString *file in files) {
        NSString *filePath = [fullPath stringByAppendingPathComponent:file];
        if (![self isDirectory:filePath]) {
            [simpleFiles addObject:file];
        }
    }
    return simpleFiles;
}


- (NSArray *)hqDocumentFiles{
    
    return [self filesWithDir:nil];

}
- (NSArray *)hqListFilesWithDir:(NSString *)dir{
   
    if (!dir) {
        return [self filesWithDir:dir];
    }
    return nil;
}

- (BOOL)hqDelateFileWithPath:(NSString *)path{
   
    NSError *error;
    BOOL suc = [self.fm removeItemAtPath:path error:&error];
    if (error) {
        NSLog(@"delate-error ==%@",error);

        return NO;
    }
    return suc;
}
- (BOOL)hqRenameFileWithPath:(NSString *)path newPath:(NSString *)newPath{
    NSString *ext = [[path componentsSeparatedByString:@"."] lastObject];
    NSString *subfix = [@"" stringByAppendingFormat:@".%@",ext];
    if (![newPath containsString:subfix]) {
        newPath = [newPath stringByAppendingFormat:@"%@",subfix];
    }
    newPath = [self.localDir stringByAppendingPathComponent:newPath];
    NSError *error;
    BOOL suc = [self.fm moveItemAtPath:path toPath:newPath error:&error];
    if (error) {
        NSLog(@"rename-error ==%@",error);
    }
    return suc;
}
@end
