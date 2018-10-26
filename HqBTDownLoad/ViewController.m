//
//  ViewController.m
//  HqBTDownLoad
//
//  Created by hehuiqi on 2018/9/16.
//  Copyright © 2018年 hehuiqi. All rights reserved.
//

#import "ViewController.h"
#import "HqDownloadManager.h"
#import "HqFileListVC.h"

@interface ViewController ()<HqFileListVCDelegate>
@property (nonatomic,strong) UIButton *downLoadBtn;
@property (nonatomic,strong) UIWebView *webView;
@property (nonatomic,strong) HqDownloadManager *dm;
@property (nonatomic,strong) NSFileManager *fm;
@property (nonatomic,strong) UIProgressView *progressView;
@property (nonatomic,strong) UITextField *sourceTf;

@property (nonatomic,strong) NSArray *files;
@property (nonatomic,strong) NSString *localDir;
@property (nonatomic,strong) UILabel *fileNameLab;

@property (nonatomic,strong) UIDocumentInteractionController *docVC;
@property (nonatomic,copy) NSURL *currentFileURL;


@end

@implementation ViewController

- (UIDocumentInteractionController *)docVC{
    if (!_docVC) {
        _docVC = [[UIDocumentInteractionController alloc] init];
        _docVC.URL = self.currentFileURL;
    }
    return _docVC;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Download";
    [self.view addSubview:self.sourceTf];
    [self.view addSubview:self.downLoadBtn];
    [self.view addSubview:self.progressView];
    [self.view addSubview:self.fileNameLab];
    [self.view addSubview:self.webView];
    self.webView.hidden = YES;
    
    self.dm = [HqDownloadManager shareInstance];
    self.fm = [NSFileManager defaultManager];

    __weak typeof(self) wealSelf = self;
    self.dm.progressBlock = ^(float progress) {
        __strong typeof(wealSelf) strongSelf = wealSelf;
    
        dispatch_async(dispatch_get_main_queue(), ^{
           strongSelf.progressView.progress = progress;
        });
    };
    self.dm.complateBlock = ^(BOOL result) {
        __strong typeof(wealSelf) strongSelf = wealSelf;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            strongSelf.progressView.progress = 0;
        });
    };
   
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [leftBtn setTitle:@"显示播放" forState:UIControlStateNormal];
    [leftBtn setTitle:@"隐藏播放" forState:UIControlStateSelected];
    [leftBtn sizeToFit];
    [leftBtn addTarget:self action:@selector(showPlay:) forControlEvents:UIControlEventTouchUpInside];
     UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = left;
    
    UIBarButtonItem *file = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:(UIBarButtonSystemItemOrganize) target:self action:@selector(enterMyFile)];
    UIBarButtonItem *share = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:(UIBarButtonSystemItemAction) target:self action:@selector(share)];
    self.navigationItem.rightBarButtonItems = @[file,share];
}
- (void)showPlay:(UIButton *)btn{
    btn.selected = !btn.selected;
    
    self.webView.hidden = !btn.selected;
}
- (void)enterMyFile{
    HqFileListVC *fileList = [[HqFileListVC alloc] init];
    fileList.delegate = self;
    [self.navigationController pushViewController:fileList animated:YES];
}
- (void)share{
    if (self.currentFileURL) {
        [self.docVC presentOpenInMenuFromRect:self.view.bounds inView:self.view animated:YES];
    }
}
- (UITextField *)sourceTf{
    if (!_sourceTf) {
        _sourceTf = [[UITextField alloc] initWithFrame:CGRectMake(30, 100, self.view.bounds.size.width-60, 30)];
        _sourceTf.placeholder = @"请输入资源路径";
        _sourceTf.clearButtonMode = UITextFieldViewModeWhileEditing;
        _sourceTf.borderStyle = UITextBorderStyleRoundedRect;
    }
    return _sourceTf;
}

- (UIButton *)downLoadBtn{
    if (!_downLoadBtn) {
        _downLoadBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_downLoadBtn setTitle:@"Download" forState:UIControlStateNormal];
        [_downLoadBtn addTarget:self action:@selector(dowloadSource:) forControlEvents:UIControlEventTouchUpInside];
        _downLoadBtn.frame = CGRectMake(self.view.bounds.size.width-100, CGRectGetMaxY(self.sourceTf.frame)+20, 100, 50);
    }
    return _downLoadBtn;
}
- (UIProgressView *)progressView{
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(30, CGRectGetMaxY(self.downLoadBtn.frame)+20, self.view.bounds.size.width-60, 30)];
    }
    return _progressView;
}
- (UILabel *)fileNameLab{
    if (!_fileNameLab) {
        _fileNameLab = [[UILabel alloc] initWithFrame:CGRectMake(30, CGRectGetMaxY(self.progressView.frame)+10, self.view.bounds.size.width-60, 40)];
        _fileNameLab.font = [UIFont systemFontOfSize:15.0];
        _fileNameLab.numberOfLines = 0;
    }
    return _fileNameLab;
}
- (UIWebView *)webView{
    if (!_webView) {
        CGFloat y = CGRectGetMaxY(self.fileNameLab.frame)+20;
        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0,y, self.view.bounds.size.width, self.view.bounds.size.height-y-30)];
        _webView.scalesPageToFit = YES;
        

    }
    return _webView;
}
- (void)dowloadSource:(UIButton *)btn{
    NSString *url = self.sourceTf.text;
    if (self.sourceTf.text.length == 0) {
        url = @"https://file.wtfjj.com/videosmp4.php?vid=35310739/0.mp4";
//        url = @"https://static.cobowallet.cn/_next/static/images/iphone_1_1_v2_zh-15bb37445f0caddeba87ab818d50eca7.png";
//        url = @"https://gslb.miaopai.com/stream/RAi4IFHKGhOEwtb7u3mneNTChYbBwG92.mp4";
    }
    [HqDownloadManager startDownloadWithURLString:url];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}
#pragma mark - HqFileListVCDelegate
- (void)HqFileListVC:(HqFileListVC *)vc palyUrl:(NSString *)url filename:(NSString *)filename{
    NSURL *localUrl = [NSURL fileURLWithPath:url];
    self.currentFileURL = localUrl;
    [self.webView loadRequest:[NSURLRequest requestWithURL:localUrl]];
    self.title = filename;
    self.fileNameLab.text = filename;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
