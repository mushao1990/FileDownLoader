//
//  DownloadCell.m
//  MSItemViewController
//
//  Created by apple on 2017/12/18.
//  Copyright © 2017年 Zhangmen. All rights reserved.
//

#import "DownloadCell.h"
#import "MSFDownloadModel.h"
#import "NSString+MSFStringConvience.h"
#import "MSFDownloadManager.h"
#import "MSFDownloadOperation.h"

@implementation DownloadCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        _fileNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _fileNameLabel.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:_fileNameLabel];
        
        _percentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _percentLabel.font = [UIFont systemFontOfSize:14];
        _percentLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_percentLabel];
        
        _progressView = [[UIProgressView alloc] initWithFrame:CGRectZero];
        _progressView.progress = 0.0f;
        _progressView.progressTintColor = [UIColor blueColor];
        _progressView.trackTintColor = [UIColor grayColor];
        [self.contentView addSubview:_progressView];
        
        _downloadInfoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _downloadInfoLabel.font = [UIFont systemFontOfSize:14];
        _downloadInfoLabel.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:_downloadInfoLabel];
        
        _speedLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _speedLabel.font = [UIFont systemFontOfSize:14];
        _speedLabel.adjustsFontSizeToFitWidth = YES;
        _speedLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_speedLabel];
        
        _downloadBtn = [[UIButton alloc] initWithFrame:CGRectZero];
        [_downloadBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _downloadBtn.titleLabel.font  = [UIFont systemFontOfSize:14];
        [_downloadBtn addTarget:self action:@selector(tapTheButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_downloadBtn];
        
    }
    return self;
}

- (void)configSubViewsLayout {
    
    // 为了不想依赖太多第三方，这里就使用frame布局了。（大家可以用Masonry代替）
    CGFloat   contentViewWidth = CGRectGetWidth(self.contentView.frame);
    CGFloat   contentViewHeight = CGRectGetHeight(self.contentView.frame);
    
    _progressView.frame = CGRectMake(15, (contentViewHeight - 2)/2.0, contentViewWidth - 100, 2);
    
    _fileNameLabel.frame = CGRectMake(15, CGRectGetMinY(_progressView.frame) - 25, contentViewWidth - 30 - 70, 20);
    
    _percentLabel.frame = CGRectMake(contentViewWidth - 75, CGRectGetMinY(_progressView.frame) - 25, 60, 20);
    
    _downloadBtn.frame = CGRectMake(contentViewWidth - 75, (contentViewHeight - 44)/2.0, 60, 44);
    
    _downloadInfoLabel.frame = CGRectMake(15, CGRectGetMaxY(_progressView.frame) + 5, CGRectGetWidth(_progressView.frame)/2.0, 20);
    
    _speedLabel.frame = CGRectMake(CGRectGetMaxX(_downloadInfoLabel.frame), CGRectGetMaxY(_progressView.frame) + 5, CGRectGetWidth(_progressView.frame)/2.0, 20);
}

- (void)tapTheButton:(UIButton *)button {
    
    MSFDownloadOperation   * operation = self.model.dowloadOperation;
    if (!operation || operation.downloadState == MSFDownloadStateReady || operation.downloadState == MSFDownloadStateFailure) {
    
        MSFDownloadOperation    * operation = [[MSFDownloadManager sharedManager] beginDownloadByMd5String:self.model.md5String orUrlString:self.model.urlString];
        self.model.dowloadOperation = operation;
    }
    else {
        if (operation.downloadState == MSFDownloadStateLoading || operation.downloadState == MSFDownloadStateWaiting) {
            [[MSFDownloadManager sharedManager] cancleDownloadByByMd5String:self.model.md5String orUrlString:self.model.urlString];
        }
    }
}

- (void)setModel:(MSFDownloadModel *)model {
    if (_model != model) {
        _model = model;
        _fileNameLabel.text = [model.urlString lastPathComponent];
        [self configSubViewsLayout];
        [self reloadTheCell];
    }
}

- (void)reloadTheCell {
    MSFDownloadOperation   * operation = self.model.dowloadOperation;
    if (!operation || operation.downloadState == MSFDownloadStateReady) {
        _progressView.progress = 0;
        _downloadInfoLabel.text = nil;
        _speedLabel.text = nil;
        _percentLabel.text = nil;
        [_downloadBtn setTitle:@"点击下载" forState:UIControlStateNormal];
        return;
    }
    
    _speedLabel.text = nil;
    _progressView.progress = 0;
    _percentLabel.text = nil;
    
    int64_t getedSize = operation.recivedSize;
    int64_t totalSize = operation.totalSize;
    
    NSString    * getedSizeString = [NSString getTheFileSizeStringByUnit:getedSize];
    NSString    * totalSizeString = [NSString getTheFileSizeStringByUnit:totalSize];
    
    if (operation.downloadState == MSFDownloadStateLoading) {//正在下载
        [_downloadBtn setTitle:@"点击暂停" forState:UIControlStateNormal];
    }
    else if (operation.downloadState == MSFDownloadStateComplete) {//任务完成
        [_downloadBtn setTitle:@"下载完成" forState:UIControlStateNormal];
    }
    else if (operation.downloadState == MSFDownloadStateWaiting) {//任务等待下载
        [_downloadBtn setTitle:@"等待下载" forState:UIControlStateNormal];
    }
    else if (operation.downloadState == MSFDownloadStateReady) {
        [_downloadBtn setTitle:@"点击下载" forState:UIControlStateNormal];
    }
    else if (operation.downloadState == MSFDownloadStateFailure) {
        [_downloadBtn setTitle:@"重新下载" forState:UIControlStateNormal];
    }
    if (totalSize > 0) {
        _progressView.progress = (float)getedSize/totalSize;
        _percentLabel.text = [NSString stringWithFormat:@"%.2f%%",_progressView.progress*100];
    }
    
    _downloadInfoLabel.text = [NSString stringWithFormat:@"%@/%@",getedSizeString,totalSizeString];
}

@end
