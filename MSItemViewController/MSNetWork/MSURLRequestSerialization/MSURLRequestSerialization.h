//
//  MSURLRequestSerialization.h
//  MSItemViewController
//
//  Created by 慕少锋 on 2018/7/12.
//  Copyright © 2018年 Zhangmen. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MSURLRequestSerialization <NSObject>

- (nullable NSURLRequest *)requestBySerializingRequest:(NSURLRequest *)request
                                        withParameters:(nullable id)parameters
                                                 error:(NSError * _Nullable __autoreleasing *)error NS_SWIFT_NOTHROW;

@end

NS_ASSUME_NONNULL_END
