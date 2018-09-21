            //
//  HqDownloadManager.m
//  HqBTDownLoad
//
//  Created by hqmac on 2018/9/20.
//  Copyright © 2018年 hehuiqi. All rights reserved.
//

#import "HqDownloadManager.h"
#import "AppDelegate.h"
@interface HqDownloadManager()<NSURLSessionDelegate,NSURLSessionDownloadDelegate>

@property (nonatomic,strong) NSURLSession *hqSession;

@end

@implementation HqDownloadManager

+ (instancetype)shareInstance{
    static HqDownloadManager *downLoad = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        downLoad = [[self alloc] init];
    });
    return downLoad;
}

- (NSURLSession *)hqSession{
    if (!_hqSession) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"hqback"];
        _hqSession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    }
    return _hqSession;
}
- (NSURLSessionTask *)reuqestSource:(NSString *)sourceUrl{
    NSURLSession *urlSession = [self hqSession];
    NSURL *url = [NSURL URLWithString:sourceUrl];
    NSURLSessionTask *task =  [urlSession downloadTaskWithURL:url];
    [task resume];
    return nil;
}
#pragma mark - NSURLSessionDelegate

//处理重定向
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response
        newRequest:(NSURLRequest *)request
 completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler{
    
    NSLog(@"currentRequest= %@",task.currentRequest.URL);
    NSLog(@"newRequest= %@",request.URL);
    completionHandler(request);

}
//证书处理
- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler{
    
    // 1.判断服务器返回的证书类型, 是否是服务器信任
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
//        NSLog(@"调用了里面这一层是服务器信任的证书");
        /*
         NSURLSessionAuthChallengeUseCredential = 0,                     使用证书
         NSURLSessionAuthChallengePerformDefaultHandling = 1,            忽略证书(默认的处理方式)
         NSURLSessionAuthChallengeCancelAuthenticationChallenge = 2,     忽略书证, 并取消这次请求
         NSURLSessionAuthChallengeRejectProtectionSpace = 3,            拒绝当前这一次, 下一次再询问
         */
        //        NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        
        NSURLCredential *card = [[NSURLCredential alloc]initWithTrust:challenge.protectionSpace.serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential , card);
    }
}
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    if (error) {
        if (self.complateBlock) {
            self.complateBlock(NO);
        }
    }
}

#pragma mark - NSURLSessionDownloadDelegate

//下载进度
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    float progress = 1.0*totalBytesWritten/totalBytesExpectedToWrite;
    NSLog(@"%f",progress);
    if (self.progressBlock) {
        self.progressBlock(progress);
    }
}

//回复下载
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes{
    NSLog(@"expectedTotalBytes");
    
}
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location{
    
    NSString *fullPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSLog(@"fullPath==%@",fullPath);
    
    fullPath = [fullPath stringByAppendingPathComponent:downloadTask.response.suggestedFilename];
    NSLog(@"location==%@",location);
    
    // 将临时文件剪切或者复制Caches文件夹
    NSFileManager *mgr = [NSFileManager defaultManager];
    
    // AtPath : 剪切前的文件路径
    // ToPath : 剪切后的文件路径
    [mgr moveItemAtPath:location.path toPath:fullPath error:nil];
    if (self.complateBlock) {
        self.complateBlock(YES);
    }
    
}
// 应用处于后台，所有下载任务完成及NSURLSession协议调用之后调用
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    dispatch_async(dispatch_get_main_queue(), ^{
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        if (appDelegate.backgroundSessionCompletionHandler) {
            void (^completionHandler)(void) = appDelegate.backgroundSessionCompletionHandler;
            appDelegate.backgroundSessionCompletionHandler = nil;
            
            // 执行block，系统后台生成快照，释放阻止应用挂起的断言
            completionHandler();
        }
    });
}
+ (void)startDownloadWithURLString:(NSString *)urltring{
    [[HqDownloadManager shareInstance] reuqestSource:urltring];
}
@end
