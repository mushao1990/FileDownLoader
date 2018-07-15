//
//  ViewController.m
//  MSItemViewController
//
//  Created by apple on 2017/7/20.
//  Copyright © 2017年 Zhangmen. All rights reserved.
//

#import "ViewController.h"
#import "MSTestViewController.h"
#import "MSHTTPSessionManager.h"
#import "MSURLRequestSerializer.h"
#import <AFNetworking.h>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UILabel   * tipLabl = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 20)];
    tipLabl.font = [UIFont systemFontOfSize:25];
    tipLabl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    tipLabl.textColor = [UIColor blackColor];
    tipLabl.textAlignment = NSTextAlignmentCenter;
    tipLabl.text = @"点击屏幕";
    [self.view addSubview:tipLabl];
}

- (void)name {
    NSLog(@"--------");
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    //POST  HTTP/1.1
    NSString    * urlString = @"https://teacherapi.zmlearn.com/v1/teachApp/app/sys/config/getAppConfigs";
//    sessionId=8fb628d0-30de-4dac-b158-9f86570b0bae
    
//    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
//    [request setValue:kVersion_ZMT forHTTPHeaderField:@"version"];
//    [request setValue:kPlatform forHTTPHeaderField:@"platform"];
//    [request setValue:kVersionBuild_ZMT forHTTPHeaderField:@"version_code"];
//    [request setHTTPMethod:@"POST"];
//    [request setValue:[self readCurrentCookie] forHTTPHeaderField:@"Cookie"];
//    [request setValue:kAPI_Version forHTTPHeaderField:@"Api-Version"];
//    [request setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    NSDictionary    * postDic = @{
                                  @"belongType":@2
                                  };
    MSHTTPSessionManager    * manger = [[MSHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:@""] sessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    MSURLRequestSerializer    * requestSerialize = (MSURLRequestSerializer *)manger.requestSerializer;
    
//    AFHTTPSessionManager    * manger = [AFHTTPSessionManager manager];
//    AFHTTPRequestSerializer * requestSerialize = manger.requestSerializer;
    [requestSerialize setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [requestSerialize setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [requestSerialize setValue:@"2.5.0" forHTTPHeaderField:@"version"];
    [requestSerialize setValue:@"1.8.0" forHTTPHeaderField:@"Api-Version"];
    [requestSerialize setValue:@"230" forHTTPHeaderField:@"version_code"];
    [requestSerialize setValue:@"ios_phone" forHTTPHeaderField:@"platform"];
    [requestSerialize setValue:@"sessionId=8fb628d0-30de-4dac-b158-9f86570b0bae" forHTTPHeaderField:@"Cookie"];

    [manger POST:urlString parameters:postDic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"success:%@",responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error:%@",error);
    }];
//    NSLog(@"success:%@",responseObject);
}

@end
