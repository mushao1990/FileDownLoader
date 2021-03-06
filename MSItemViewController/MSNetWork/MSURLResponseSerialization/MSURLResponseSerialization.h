//
//  MSURLResponseSerialization.h
//  MSItemViewController
//
//  Created by apple on 2018/7/11.
//  Copyright © 2018年 Zhangmen. All rights reserved.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

@protocol MSURLResponseSerialization <NSObject>

- (nullable id)responseObjectForResponse:(nullable NSURLResponse *)response
                                    data:(nullable NSData *)data
                                   error:(NSError * _Nullable __autoreleasing *)error;

@end

NS_ASSUME_NONNULL_END
