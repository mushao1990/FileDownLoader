//
//  MSFDownloadManager.m
//  MSItemViewController
//
//  Created by apple on 2017/12/20.
//  Copyright © 2017年 Zhangmen. All rights reserved.
//

#import "MSFDownloadManager.h"
#import "NSString+MSFStringConvience.h"
#import "MSFDownloadOperation.h"

@interface MSFDownloadManager()

@property (nonatomic, strong) NSMutableDictionary   * dataSourceDic;//当前的所有下载项目

@property (nonatomic, strong) NSMutableArray    * downloadingArray;//正在下载的

@property (nonatomic, strong) NSMutableArray    * downloadWaitingArray;//在等待下载的

@end

@implementation MSFDownloadManager

+ (instancetype)sharedManager {
    static MSFDownloadManager    * __shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __shareInstance = [[MSFDownloadManager alloc] init];
        __shareInstance.maxConcurrent = 1;
        [__shareInstance loadTheLocalOperations];//获取本地的
    });
    return __shareInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadComplete:) name:MSF_DOWNLOADCOMPLETE_NOTIFICATION object:nil];
    }
    return self;
}

- (MSFDownloadOperation *)beginDownloadByMd5String:(NSString *)md5String orUrlString:(NSString *)urlString {
    MSFDownloadOperation    * operation = [self getTheDownloadInfoByMd5String:md5String orUrlstring:urlString];
    if (operation.downloadState == MSFDownloadStateReady || operation.downloadState == MSFDownloadStateFailure) {
        if (self.downloadingArray.count >= self.maxConcurrent) {
            operation.downloadState = MSFDownloadStateWaiting;
            [self.downloadWaitingArray addObject:operation];//排队等待
        }
        else {
            operation.downloadState = MSFDownloadStateLoading;
            [self.downloadingArray addObject:operation];
            [operation downloadBeigin];
        }
    }
    return operation;
}

- (void)cancleDownloadByByMd5String:(NSString *)md5String orUrlString:(NSString *)urlString {
    
    MSFDownloadOperation    * operation = [self getTheDownloadInfoByMd5String:md5String orUrlstring:urlString];
    if (operation.downloadState == MSFDownloadStateLoading) {
        operation.downloadState = MSFDownloadStateReady;
        [self.downloadingArray removeObject:operation];
        [operation downloadCancle];
    }
    else if (operation.downloadState == MSFDownloadStateWaiting) {
        [self.downloadWaitingArray removeObject:operation];
    }
}

- (MSFDownloadOperation *)getTheDownloadInfoByMd5String:(NSString *)md5String orUrlstring:(NSString *)urlString {
    
    if (!urlString && !md5String) {
        return nil;
    }
    
    NSString    * md5_string = md5String;
    if (!md5String) {
        md5_string = [NSString md5String:urlString];
    }
    // 先看看是否已经存在
    MSFDownloadOperation    * operation = self.dataSourceDic[md5_string];
    if (operation) {
        return operation;
    }
    // 不存在就创建一个
    operation = [[MSFDownloadOperation alloc] initWithDownloadUrlString:urlString];
    // 装在字典里
    [self.dataSourceDic setObject:operation forKey:md5_string];
    return operation;
}

- (void)cancleAllDownloads {
    //需要对已经开始的任务，也进行取消  
    [self.dataSourceDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        MSFDownloadOperation   * operation = obj;
        
        if (operation.downloadState == MSFDownloadStateWaiting) {
            [self.downloadWaitingArray removeObject:operation];
        }
        
        if (operation.downloadState == MSFDownloadStateLoading) {
            [operation downloadCancle];
            [self.downloadingArray removeObject:operation];
        }

    }];
}

- (void)loadTheLocalOperations {
    NSString    * fileUrlString = [NSString getTheDestionPathByFolder:@"ms_local_operation" ByFileName:@"operations"];
    NSArray    * localArray = [NSKeyedUnarchiver unarchiveObjectWithFile:fileUrlString];
    for (MSFDownloadOperation    * operation in localArray) {
        NSString    * md5_String = [NSString md5String:operation.downloadUrlString];
        NSLog(@"operation:%zd state:%zd",operation.recivedSize,operation.downloadState);
        [self.dataSourceDic setObject:operation forKey:md5_String];
    }
}

- (NSMutableDictionary *)dataSourceDic {
    if (!_dataSourceDic) {
        _dataSourceDic = [NSMutableDictionary dictionary];
    }
    return _dataSourceDic;
}

- (NSMutableArray *)downloadingArray {
    if (!_downloadingArray) {
        _downloadingArray = [NSMutableArray array];
    }
    return _downloadingArray;
}

- (NSMutableArray *)downloadWaitingArray {
    if (!_downloadWaitingArray) {
        _downloadWaitingArray = [NSMutableArray array];
    }
    return _downloadWaitingArray;
}

#pragma mark-----------------

- (void)downloadComplete:(NSNotification *)noty {
    
    @synchronized (self) {
        
        MSFDownloadOperation    * opeation = (MSFDownloadOperation *)noty.object;
        [self.downloadingArray removeObject:opeation];
        // 找到下一个开始下载
        if (self.downloadWaitingArray.count > 0 && self.downloadingArray.count < self.maxConcurrent) {
            MSFDownloadOperation    * nextOperation = [self.downloadWaitingArray firstObject];
            [nextOperation downloadBeigin];
            [self.downloadingArray addObject:nextOperation];
            [self.downloadWaitingArray removeObject:nextOperation];
        }
        
    }
}

#pragma mark------------------
- (void)saveTheOperations {
    
    [self cancleAllDownloads];
    NSArray    * values = [self.dataSourceDic allValues];
    NSString    * fileUrlString = [NSString getTheDestionPathByFolder:@"ms_local_operation" ByFileName:@"operations"];
    [NSKeyedArchiver archiveRootObject:values toFile:fileUrlString];
}

@end

