//
//  MSFDownloadModel.h
//  MSItemViewController
//
//  Created by apple on 2017/12/21.
//  Copyright © 2017年 Zhangmen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSFDownloadOperation.h"

@interface MSFDownloadModel : NSObject

@property (nonatomic, weak) MSFDownloadOperation    * dowloadOperation;

@property (nonatomic, copy) NSString    * urlString;//

@property (nonatomic, copy) NSString    * md5String;//加密过的

@end
