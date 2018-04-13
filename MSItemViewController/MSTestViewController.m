//
//  MSTestViewController.m
//  MSItemViewController
//
//  Created by apple on 2017/12/18.
//  Copyright © 2017年 Zhangmen. All rights reserved.
//

#import "MSTestViewController.h"
#import "DownloadCell.h"
#import "MSFTimerManager.h"
#import "MSFDownloadModel.h"
#import "MSFDownloadManager.h"


@interface MSTestViewController ()
@property (nonatomic, strong) NSMutableArray    * dataSourceArray;
@property (nonatomic, strong) MSFTimerManager    * timerManager;//
@end

static NSString    * reuseId = @"reuseId";

@implementation MSTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[DownloadCell class] forCellReuseIdentifier:reuseId];
    self.tableView.separatorStyle = 0;
    self.tableView.tableFooterView = [UIView new];
    
    [MSFDownloadManager sharedManager].maxConcurrent = 5;

    NSArray    * urlStringArray = [self forTest];
    for (NSString   * urlString in urlStringArray) {
        MSFDownloadModel   * model = [[MSFDownloadModel alloc] init];
        model.urlString = urlString;
        model.dowloadOperation = [[MSFDownloadManager sharedManager] getTheDownloadInfoByMd5String:nil orUrlstring:urlString];
        [self.dataSourceArray addObject:model];
    }
    
    __weak MSTestViewController    * weakSelf = self;
    // 每隔一秒，进行界面刷新
    self.timerManager = [[MSFTimerManager alloc] init];
    [self.timerManager startWithTimeInterVal:1 andBlock:^{
        __strong MSTestViewController    * strongSelf = weakSelf;
        NSArray    * visbleCells = [strongSelf.tableView visibleCells];
        if (visbleCells.count > 0) {
            for (DownloadCell    * cell in visbleCells) {
                [cell reloadTheCell];
            }
        }
    }];
    
}

#pragma mark------------------scrollview delegate--------

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.timerManager timerPause];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self.timerManager timerContinue];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSourceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DownloadCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId forIndexPath:indexPath];
    if (indexPath.row < self.dataSourceArray.count) {
        cell.model = self.dataSourceArray[indexPath.row];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (NSMutableArray *)dataSourceArray {
    if (!_dataSourceArray) {
        _dataSourceArray = [NSMutableArray array];
    }
    return _dataSourceArray;
}

- (NSArray *)forTest {
    return @[
             @"http://sw.bos.baidu.com/sw-search-sp/software/9629a8d93b17f/teamviewer_11.0.65280.dmg",
             @"http://sw.bos.baidu.com/sw-search-sp/software/797b4439e2551/QQ_mac_5.0.2.dmg",
             @"http://sw.bos.baidu.com/sw-search-sp/software/0b515d1625a74/BaiduPinyinSetup_5.4.4920.0.exe",
             @"http://dlsw.baidu.com/sw-search-sp/soft/75/14896/directx_9.29.952.3111.3613753789.exe",
             @"http://sw.bos.baidu.com/sw-search-sp/software/9bcaba4a439bd/donetRepair.exe",
             @"http://dlsw.baidu.com/sw-search-sp/soft/78/17803/GoogleChromeframeStandaloneEnterprise.4144293914.msi",
             @"http://dlsw.baidu.com/sw-search-sp/soft/d4/20458/Windows7-USB-DVD-Download1.0.30.0.577229788.exe",
             @"http://sw.bos.baidu.com/sw-search-sp/software/b0958c08df8cf/360SRInst_5.0.0.1005.exe",
             @"http://dlsw.baidu.com/sw-search-sp/soft/66/17890/Windows7Upgrade_2.0.exe?version=3497831609",
             @"http://dlsw.baidu.com/sw-search-sp/soft/80/11854/apploc1.3.3.31.1393985731.msi",
             @"http://dlsw.baidu.com/sw-search-sp/soft/5a/18140/visualPCsetup.3645387493.exe",
             @"http://dlsw.baidu.com/sw-search-sp/soft/05/18292/FixitCenter_Setup.3282420936.exe",
             @"http://dlsw.baidu.com/sw-search-sp/soft/75/25388/wpilauncher.1395140850.exe",
             @"http://sw.bos.baidu.com/sw-search-sp/software/971c5ee8a7dd4/Silverlight_x64_5.1.50907.0.exe",
             @"http://dlsw.baidu.com/sw-search-sp/soft/62/18291/SyncToySetupPackage_v21_x86.1244633704.exe",
             @"http://dlsw.baidu.com/sw-search-sp/soft/7b/18310/ApplicationCompatibilityToolkitSetup.1344524709.exe",
             @"http://dlsw.baidu.com/sw-search-sp/soft/a5/18731/FreeDuplicateRemover_0.5.1185392965.exe",
             @"http://dlsw.baidu.com/sw-search-sp/soft/cc/22218/WindowsXP-KB942288-v3-x86.1429065152.exe",
             @"http://sw.bos.baidu.com/sw-search-sp/software/47ea17d12a5b9/Silverlight_5.1.50907.0.exe",
             @"http://sw.bos.baidu.com/sw-search-sp/software/2b23fe31d6232/systemupdate_5.07.0053.exe",
             @"http://sw.bos.baidu.com/sw-search-sp/software/6bda11b7d3256/VirtualBox-5.1.30.18389-Win.exe",
             @"http://sw.bos.baidu.com/sw-search-sp/software/f0c412a763731/drivethelife7_setup_7.0.9.18.exe",
             @"http://dlsw.baidu.com/sw-search-sp/soft/be/24392/SyncSDK-v2.1-x86-CHS.1393326463.msi"];
}

@end
