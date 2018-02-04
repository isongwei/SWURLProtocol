//
//  ViewController.m
//  NSURLProtocol黑魔法
//
//  Created by iSongWei on 2017/8/8.
//  Copyright © 2017年 iSong. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
@interface ViewController ()

@property (strong, nonatomic) UIWebView *web;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _web = [[UIWebView alloc]initWithFrame:(CGRectMake(0, 20, 375, 375))];
    
    [_web loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.baidu.com"]]];
    
    [self.view addSubview:_web];
    
    
//    WKWebView * wk = [[WKWebView alloc]initWithFrame:(CGRectMake(0, 400, 375, 375))];
//
//    [wk loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.baidu.com"]]];
//
//    [self.view addSubview:wk];
    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [_web reload];
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
