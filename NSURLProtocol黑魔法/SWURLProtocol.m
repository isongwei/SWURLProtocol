//
//  SWURLProtocol.m
//  NSURLProtocol黑魔法
//
//  Created by iSongWei on 2017/8/8.
//  Copyright © 2017年 iSong. All rights reserved.
//

#import "SWURLProtocol.h"


#define ProtocolKey @"SWURLProtocolKey"

@interface SWURLProtocol ()<NSURLSessionDataDelegate>
//NSURLSessionDelegate

@property (nonatomic, strong) NSURLSession * session;


@end



@implementation SWURLProtocol


/**
 这个方法主要是说明你是否打算处理对应的request，是否进入这个自定义的Protocol
 如果不打算处理，返回NO，URL Loading System会使用系统默认的行为去处理；
 如果打算处理，返回YES，然后你就需要处理该请求的所有东西，包括获取请求数据并返回给 URL Loading System。
 网络数据可以简单的通过NSURLConnection去获取，而且每个NSURLProtocol对象都有一个NSURLProtocolClient实例，可以通过该client将获取到的数据返回给URL Loading System。
 
 
 
 
 这里有个需要注意的地方，想象一下，当你去加载一个URL资源的时候，URL Loading System会询问CustomURLProtocol是否能处理该请求，你返回YES，然后URL Loading System会创建一个CustomURLProtocol实例然后调用NSURLConnection去获取数据，然而这也会调用URL Loading System，而你在+canInitWithRequest:中又总是返回YES，这样URL Loading System又会创建一个CustomURLProtocol实例导致无限循环。我们应该保证每个request只被处理一次，可以通过+setProperty:forKey:inRequest:标示那些已经处理过的request，然后在+canInitWithRequest:中查询该request是否已经处理过了，如果是则返回NO。
 
 
 
 
 */
+(BOOL)canInitWithRequest:(NSURLRequest *)request{
    
    
//    return  NO;
    //看看是否处理过了
    if ([NSURLProtocol propertyForKey:ProtocolKey inRequest:request]) {
        return  NO;
    }
    
    //只处理http  https
    NSString * scheme = [[request URL] scheme];
    if ([scheme caseInsensitiveCompare:@"http"] == NSOrderedSame
        || [scheme caseInsensitiveCompare:@"https"] == NSOrderedSame
        ) {
        
        return YES;
    }
    return NO;
}



/**
 重定向
 通常该方法你可以简单的直接返回request，但也可以在这里修改request，比如添加header，修改host等，并返回一个新的request，这是一个抽象方法，子类必须实现。

 */
+(NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    
    NSMutableURLRequest *mutableReqeust = [request mutableCopy];
    mutableReqeust = [self redirectHostInRequset:mutableReqeust];
//    [NSURLProtocol setProperty:@(YES) forKey:ProtocolKey inRequest:mutableReqeust];
    return mutableReqeust;

}
+(NSMutableURLRequest*)redirectHostInRequset:(NSMutableURLRequest*)request
{
    
    
    if ([request.URL host].length == 0) {
        return request;
    }
    
    NSString * originUrlString = [request.URL absoluteString];
    NSString * originHostString = [request.URL host];
    NSRange hostRange =  [originUrlString rangeOfString:originHostString];
    if (hostRange.location == NSNotFound) {
        return request;
    }
    
    //采取定向
    //替换成需要的ip
//    return request;
    NSString * ip = @"www.hellosong.cc";
    NSString * urlString = [originUrlString stringByReplacingCharactersInRange:hostRange withString:ip];
    request.URL = [NSURL URLWithString:urlString];
    return  request;
    
}



/**
 主要判断两个request是否相同，如果相同的话可以使用缓存数据，
 通常只需要调用父类的实现。

 */
//+(BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b{
//
//    return [super requestIsCacheEquivalent:a toRequest:b];
//
//}




/**
 拦截的请求开始执行的地方
 在这里开始重定向

 这两个方法主要是开始和取消相应的request，而且需要标示那些已经处理过的request。
 */


/*
 你也可以选择在+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request替换request。效果都是一样的。
 

 */
-(void)startLoading{
    NSMutableURLRequest * mRequest = [[self request]mutableCopy];
    //表示request已经处理过了 防止无限循环
    [NSURLProtocol setProperty:@(YES) forKey:ProtocolKey inRequest:mRequest];
    

    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
//    configuration.protocolClasses = @[ [SWURLProtocol class] ];
    self.session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionTask *task = [self.session dataTaskWithRequest:mRequest];
    [task resume];
    
    
}

-(void)stopLoading{
    
    [self.session invalidateAndCancel];
    self.session = nil;
    
}

#pragma mark - ===============NSURLSessionDataDelegate===============
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler{
    
    
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    
    completionHandler(NSURLSessionResponseAllow);
    
    
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didBecomeDownloadTask:(NSURLSessionDownloadTask *)downloadTask{
    
}

//- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
//didBecomeStreamTask:(NSURLSessionStreamTask *)streamTask{
//
//}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data{
    
    [self.client URLProtocol:self didLoadData:data];
    
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
 willCacheResponse:(NSCachedURLResponse *)proposedResponse
 completionHandler:(void (^)(NSCachedURLResponse * _Nullable cachedResponse))completionHandler{
    
    completionHandler(proposedResponse);
    
}


#pragma mark - ==============================
//- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
//willPerformHTTPRedirection:(NSHTTPURLResponse *)response
//        newRequest:(NSURLRequest *)request
// completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler{
//    
//    
//    
//}

//- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
//didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
// completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler{
//    
//}


//- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
// needNewBodyStream:(void (^)(NSInputStream * _Nullable bodyStream))completionHandler{
//    
//}

//- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
//   didSendBodyData:(int64_t)bytesSent
//    totalBytesSent:(int64_t)totalBytesSent
//totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend{
//    
//}

//- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didFinishCollectingMetrics:(NSURLSessionTaskMetrics *)metrics API_AVAILABLE(macosx(10.12), ios(10.0), watchos(3.0), tvos(10.0)){
//    
//}


- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error{
    if (error) {
        [self.client URLProtocol:self didFailWithError:error];
    } else {
        [self.client URLProtocolDidFinishLoading:self];
    }
}




@end
