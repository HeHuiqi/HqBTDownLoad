//
//  HqFileListVC.m
//  HqBTDownLoad
//
//  Created by hqmac on 2018/9/20.
//  Copyright © 2018年 hehuiqi. All rights reserved.
//

#import "HqFileListVC.h"
// 在app.info.plist中添加 Application supports iTunes file sharing = YES 即可实现文件共享
#import "HqFileManager/HqFileManager.h"
#import "HqAlertView.h"
@interface HqFileListVC ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) HqFileManager *fm;
@property (nonatomic,strong) NSMutableArray *files;
@property (nonatomic,strong) UITableView *tableView;

@end

@implementation HqFileListVC
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"我的文件";
    self.fm = [HqFileManager shareInstance];
    [self.fm fileDefaultDir];
    [self.view addSubview:self.tableView];
    
}
- (NSMutableArray *)files{
    if (!_files) {
        NSArray *simpleFiles = [self.fm hqDocumentFiles];
        _files = [[NSMutableArray alloc] initWithArray:simpleFiles];
    }
    return _files;
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}
#pragma mark - UITableViewDelegate,UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.files.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIndentifer = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifer];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifer];
    }
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.text = self.files[indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *fileName = self.files[indexPath.row];
    NSString *filepath = [self.fm.localDir stringByAppendingPathComponent:fileName];
    
    if ([self.fm fileExistsAtPath:filepath]) {
        if (self.delegate) {
            [self.delegate HqFileListVC:self palyUrl:filepath filename:fileName];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
    
   
}
- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(nonnull NSIndexPath *)indexPath API_AVAILABLE(ios(11.0)){

    
    if (@available(iOS 11.0, *)) {
        UIContextualAction *del = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"删除" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {

            [self showDeleteFileIndexPath:indexPath];
            completionHandler(NO);
        }];
        
        UIContextualAction *rename = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"重命名" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
            
            [self showRenameViewIndexPath:indexPath];

            completionHandler(NO);
            
        }];
      
        
        UISwipeActionsConfiguration *actions = [UISwipeActionsConfiguration configurationWithActions:@[del,rename]];
        actions.performsFirstActionWithFullSwipe = NO;
        return actions;
        
    }else{
        
        return nil;
        
    }
}
- ( NSArray*)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
 
    UITableViewRowAction *deleteAc = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
      
        [self showDeleteFileIndexPath:indexPath];
        tableView.editing = NO;
                
    }];
    UITableViewRowAction *renameAc = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"重命名" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        [self showRenameViewIndexPath:indexPath];
        tableView.editing = NO;
        
    }];
    

    
    return  @[deleteAc,renameAc];
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)showDeleteFileIndexPath:(NSIndexPath *)indexPath{
    HqAlertView *alert = [[HqAlertView alloc] initWithTitle:@"确定删除?" message:nil];
    alert.btnTitles = @[@"取消",@"确定"];
    [alert showVC:self.navigationController callBack:^(UIAlertAction *action, int index) {
        if (index==1) {
            NSString *fileName = self.files[indexPath.row];
            NSString *fullPath = [self.fm.localDir stringByAppendingPathComponent:fileName];
            BOOL suc = [self.fm  hqDelateFileWithPath:fullPath];
            if (suc) {
               
                [self.files removeObjectAtIndex:indexPath.row];
                [self.tableView reloadData];

            }
        }
    }];
}
- (void)showRenameViewIndexPath:(NSIndexPath *)indexPath{
    
   NSString *filename = self.files[indexPath.row];
    UIAlertController  *alert = [UIAlertController alertControllerWithTitle:@"重命名文件" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *a1  =[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *a2  =[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        UITextField *tf = [alert.textFields firstObject];
        if (![tf.text isEqualToString: filename]&&tf.text.length>0) {
            NSString *fullPath = [self.fm.localDir stringByAppendingPathComponent:filename];
            
            BOOL suc = [self.fm  hqRenameFileWithPath:fullPath newPath:tf.text];
            if (suc) {
                   NSString *ext = [[filename componentsSeparatedByString:@"."] lastObject];
                NSString *newName = tf.text;
                if (![newName hasSuffix:ext]) {
                    newName = [tf.text stringByAppendingFormat:@".%@",ext];
                }
                self.files[indexPath.row] = newName;
                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            }
        }
        
        
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text =  filename;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }];
    [alert addAction:a1];
    [alert addAction:a2];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
