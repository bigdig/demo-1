//
//  HybridNSURLProtocol.m
//  WKWebVIewHybridDemo
//
//  Created by shuoyu liu on 2017/1/16.
//  Copyright © 2017年 shuoyu liu. All rights reserved.
//

#import "HybridNSURLProtocol.h"
#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
static NSString*const sourUrl  = @"https://m.baidu.com/static/index/plus/plus_logo.png";
static NSString*const sourIconUrl  = @"http://m.baidu.com/static/search/baiduapp_icon.png";
static NSString*const localUrl = @"http://mecrm.qa.medlinker.net/public/image?id=57026794&certType=workCertPicUrl&time=1484625241";

static NSString* const KHybridNSURLProtocolHKey = @"KHybridNSURLProtocol";
@interface HybridNSURLProtocol ()<NSURLSessionDelegate>
@property (nonnull,strong) NSURLSessionDataTask *task;

@end


@implementation HybridNSURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    NSString *scheme = [[request URL] scheme];
    if ( ([scheme caseInsensitiveCompare:@"http"]  == NSOrderedSame ||
          [scheme caseInsensitiveCompare:@"https"] == NSOrderedSame ))
    {
        //看看是否已经处理过了，防止无限循环
        if ([NSURLProtocol propertyForKey:KHybridNSURLProtocolHKey inRequest:request])
            return NO;
        return YES;
    }
    return NO;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    NSMutableURLRequest *mutableReqeust = [request mutableCopy];
    NSString *requestUrl = request.URL.absoluteString;

    //request截取重定向
    if ([requestUrl isEqualToString:sourUrl])
    {
        NSURL* url1 = [NSURL URLWithString:localUrl];
        mutableReqeust = [NSMutableURLRequest requestWithURL:url1];
    }
    if([requestUrl containsString:@".m3u8"]
       //       ||[requestUrl.pathExtension hasPrefix:@"mp4"]
       )
    {
        
        NSLog(@"%s--并提供相关证-%@", __func__,request);
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if([self.topViewController isKindOfClass:[MPMoviePlayerViewController class]]) return ;
            
            MPMoviePlayerViewController *playVC = [[MPMoviePlayerViewController alloc]initWithContentURL:request.URL];
            playVC.view.frame = CGRectMake(0, 100, 414, 300);
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:playVC animated:YES completion:nil];
        });
    }
    NSLog(@"request.URL.absoluteString = %@\r\n-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------\r\n",request.URL.absoluteString);

    return mutableReqeust;
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b
{
    return [super requestIsCacheEquivalent:a toRequest:b];
}

- (void)startLoading
{
    NSMutableURLRequest *mutableReqeust = [[self request] mutableCopy];
    //给我们处理过的请求设置一个标识符, 防止无限循环,
    [NSURLProtocol setProperty:@YES forKey:KHybridNSURLProtocolHKey inRequest:mutableReqeust];
    
    //这里最好加上缓存判断，加载本地离线文件， 这个直接简单的例子。
    if ([mutableReqeust.URL.absoluteString isEqualToString:sourIconUrl])
    {
            NSData* data = UIImagePNGRepresentation([UIImage imageNamed:@"medlinker"]);
            NSURLResponse* response = [[NSURLResponse alloc] initWithURL:self.request.URL MIMEType:@"image/png" expectedContentLength:data.length textEncodingName:nil];
            [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
            [self.client URLProtocol:self didLoadData:data];
            [self.client URLProtocolDidFinishLoading:self];
    }
    else
    {
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
        self.task = [session dataTaskWithRequest:self.request];
        [self.task resume];
    }
}
- (void)stopLoading
{
    if (self.task != nil)
    {
        [self.task  cancel];
    }
}


- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
    
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [[self client] URLProtocol:self didLoadData:data];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error {
    [self.client URLProtocolDidFinishLoading:self];
}

//FIXME:  -  自定义方法
+ (UIViewController *)topViewController {
    UIViewController *resultVC;
    resultVC = [self _topViewController:[[UIApplication sharedApplication].keyWindow rootViewController]];
    while (resultVC.presentedViewController) {
        resultVC = [self _topViewController:resultVC.presentedViewController];
        
    }
    return resultVC;
}
+ (UIViewController *)_topViewController:(UIViewController *)vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self _topViewController:[(UINavigationController *)vc topViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self _topViewController:[(UITabBarController *)vc selectedViewController]];
    } else {
        return vc;
    }
    return nil;
}

@end





