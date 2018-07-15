//
//  MSSecurityPolicy.h
//  MSItemViewController
//
//  Created by apple on 2018/7/10.
//  Copyright © 2018年 Zhangmen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Foundation/Foundation.h>
#import <Security/Security.h>

typedef NS_ENUM(NSUInteger, MSSSLPinningMode) {
    MSSSLPinningModeNone,
    MSSSLPinningModePublicKey,
    MSSSLPinningModeCertificate,
};

NS_ASSUME_NONNULL_BEGIN

@interface MSSecurityPolicy : NSObject

@property (readonly, nonatomic, assign) MSSSLPinningMode SSLPinningMode;

@property (nonatomic, strong, nullable) NSSet <NSData *> *pinnedCertificates;

@property (nonatomic, assign) BOOL allowInvalidCertificates;

@property (nonatomic, assign) BOOL validatesDomainName;

+ (NSSet <NSData *> *)certificatesInBundle:(NSBundle *)bundle;

+ (instancetype)defaultPolicy;

+ (instancetype)policyWithPinningMode:(MSSSLPinningMode)pinningMode;

+ (instancetype)policyWithPinningMode:(MSSSLPinningMode)pinningMode withPinnedCertificates:(NSSet <NSData *> *)pinnedCertificates;

- (BOOL)evaluateServerTrust:(SecTrustRef)serverTrust
                  forDomain:(nullable NSString *)domain;

@end

NS_ASSUME_NONNULL_END
