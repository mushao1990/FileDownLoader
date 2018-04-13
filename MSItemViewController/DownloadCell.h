//
//  DownloadCell.h
//  MSItemViewController
//
//  Created by apple on 2017/12/18.
//  Copyright © 2017年 Zhangmen. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MSFDownloadModel;

@interface DownloadCell : UITableViewCell

@property (nonatomic, strong) UIButton    * downloadBtn;//

@property (nonatomic, strong) UILabel    * fileNameLabel;//

@property (nonatomic, strong) UILabel    * percentLabel;//

@property (nonatomic, strong) UIProgressView    * progressView;//

@property (nonatomic, strong) UILabel    * speedLabel;//

@property (nonatomic, strong) UILabel    * downloadInfoLabel;//

@property (nonatomic, weak) MSFDownloadModel    * model;//

- (void)reloadTheCell;

@end
