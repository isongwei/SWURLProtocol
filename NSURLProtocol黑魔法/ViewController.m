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
    
    
    

    

    
}

- (IBAction)getM:(id)sender {
    NSURL  *url= [NSURL URLWithString:@"https://www.hellosong.cc/test.php"];
    NSURLSession * session = [NSURLSession sharedSession];
    
    //创建请求
    //NSURLSessionDataTask 发送 GET 请求
    
    NSURLSessionDataTask * dataTask = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        //解析服务器返回的数据
        NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        //默认在子线程中解析数据
        NSLog(@"%@", [NSThread currentThread]);
        
    }];
    
    //发送请求（执行Task）
    [dataTask resume];
    
}


- (IBAction)postM:(id)sender {
    
    NSURL  *url= [NSURL URLWithString:@"https://www.hellosong.cc/test.php"];
    
    //创建可变请求对象
    NSMutableURLRequest *requestM = [NSMutableURLRequest requestWithURL:url];
    //修改请求方法
    requestM.HTTPMethod = @"POST";
    
    //设置请求体
    requestM.HTTPBody = [@"username=520&pwd=520&type=JSON" dataUsingEncoding:NSUTF8StringEncoding];
    //创建会话对象
    NSURLSession *session = [NSURLSession sharedSession];
    //创建请求 Task
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:requestM completionHandler:
                                      ^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                          
                                          //解析返回的数据
                                          NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                                          
                                          //默认在子线程中解析数据
                                          NSLog(@"%@", [NSThread currentThread]);
                                      }];
    //发送请求
    [dataTask resume];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
