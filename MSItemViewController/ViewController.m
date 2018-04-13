//
//  ViewController.m
//  MSItemViewController
//
//  Created by apple on 2017/7/20.
//  Copyright © 2017年 Zhangmen. All rights reserved.
//

#import "ViewController.h"
#import "MSTestViewController.h"

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
    MSTestViewController   * testVc = [[MSTestViewController alloc] initWithStyle:UITableViewStylePlain];
    [self presentViewController:testVc animated:YES completion:nil];
}

@end
