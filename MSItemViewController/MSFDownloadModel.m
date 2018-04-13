//
//  MSFDownloadModel.m
//  MSItemViewController
//
//  Created by apple on 2017/12/21.
//  Copyright © 2017年 Zhangmen. All rights reserved.
//

#import "MSFDownloadModel.h"
#import "NSString+MSFStringConvience.h"

@implementation MSFDownloadModel

- (void)setUrlString:(NSString *)urlString {
    if (_urlString != urlString) {
        _urlString = [urlString copy];
        
        _md5String = [NSString md5String:urlString];
    }
}

@end
