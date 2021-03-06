//
//  HJManger.m
//  HJManger
//
//  Created by xin on 2018/7/2.
//  Copyright © 2018年 sdl. All rights reserved.
//

#import "MeiJuApi.h"
//#import "TJData.h"
#include <ctype.h>


@implementation MeiJuApi



NSString * tohex(int tmpid)
{
    NSString *nLetterValue;
    NSString *str =@"";
    long long int ttmpig;
    for (int i = 0; i<9; i++) {
        ttmpig=tmpid%16;
        tmpid=tmpid/16;
        switch (ttmpig)
        {
            case 10:
                nLetterValue =@"A";break;
            case 11:
                nLetterValue =@"B";break;
            case 12:
                nLetterValue =@"C";break;
            case 13:
                nLetterValue =@"D";break;
            case 14:
                nLetterValue =@"E";break;
            case 15:
                nLetterValue =@"F";break;
            default:nLetterValue=[[NSString alloc]initWithFormat:@"%lli",ttmpig];
                
        }
        str = [nLetterValue stringByAppendingString:str];
        if (tmpid == 0) {
            break;
        }
        
    }
    return str;
}


NSString * esp(NSString * src){
    int i;
    
    
    NSString* tmp = @"";
    
    
    for (i=0; i<[src length]; i++) {
        unichar c  = [src characterAtIndex:(NSUInteger)i];
        
        
        if(isdigit(c)||isupper(c)|islower(c)){
            tmp = [NSString stringWithFormat:@"%@%c",tmp,c];
        }else if((int)c <256){
            tmp = [NSString stringWithFormat:@"%@%@",tmp,@"%"];
            if((int)c <16){
                tmp =[NSString stringWithFormat:@"%@%@",tmp,@"0"];
            }
            tmp = [NSString stringWithFormat:@"%@%@",tmp,tohex((int)c)];
            
        }else{
            tmp = [NSString stringWithFormat:@"%@%@",tmp,@"%u"];
            tmp = [NSString stringWithFormat:@"%@%@",tmp,tohex(c)];
            
        }
        
        
    }
    
    
    return tmp;
}
Byte getInt(char c){
    if(c>='0'&&c<='9'){
        return c-'0';
    }else if((c>='a'&&c<='f')){
        return 10+(c-'a');
    }else if((c>='A'&&c<='F')){
        return 10+(c-'A');
    }
    return c;
}
int  getIntStr(NSString *src,int len){
    if(len==2){
        Byte c1 = getInt([src characterAtIndex:(NSUInteger)0]);
        Byte c2 = getInt([src characterAtIndex:(NSUInteger)1]);
        return ((c1&0x0f)<<4)|(c2&0x0f);
    }else{
        
        Byte c1 = getInt([src characterAtIndex:(NSUInteger)0]);
        
        Byte c2 = getInt([src characterAtIndex:(NSUInteger)1]);
        Byte c3 = getInt([src characterAtIndex:(NSUInteger)2]);
        Byte c4 = getInt([src characterAtIndex:(NSUInteger)3]);
        return( ((c1&0x0f)<<12)
               |((c2&0x0f)<<8)
               |((c3&0x0f)<<4)
               |(c4&0x0f));
    }
    
}
NSString* unesp(NSString* src){
    int lastPos = 0;
    int pos=0;
    unichar ch;
    NSString * tmp = @"";
    while(lastPos<src.length){
        NSRange range;
        
        range = [src rangeOfString:@"%" options:NSLiteralSearch range:NSMakeRange(lastPos, src.length-lastPos)];
        if (range.location != NSNotFound) {
            pos = (int)range.location;
        }else{
            pos = -1;
        }
        
        if(pos == lastPos){
            
            if([src characterAtIndex:(NSUInteger)(pos+1)]=='u'){
                NSString* ts = [src substringWithRange:NSMakeRange(pos+2,4)];
                
                int d = getIntStr(ts,4);
                ch = (unichar)d;
                NSLog(@"%@%C",tohex(d),ch);
                tmp = [tmp stringByAppendingString:[NSString stringWithFormat:@"%C",ch]];
                
                lastPos = pos+6;
                
            }else{
                NSString* ts = [src substringWithRange:NSMakeRange(pos+1,2)];
                int d = getIntStr(ts,2);
                ch = (unichar)d;
                tmp = [tmp stringByAppendingString:[NSString stringWithFormat:@"%C",ch]];
                lastPos = pos+3;
            }
            
        }else{
            if(pos ==-1){
                NSString* ts = [src substringWithRange:NSMakeRange(lastPos,src.length-lastPos)];
                
                tmp = [tmp stringByAppendingString:[NSString stringWithFormat:@"%@",ts]];
                lastPos = (int)src.length;
            }else{
                NSString* ts = [src substringWithRange:NSMakeRange(lastPos,pos-lastPos)];
                
                tmp = [tmp stringByAppendingString:[NSString stringWithFormat:@"%@",ts]];
                lastPos  = pos;
            }
        }
    }
    
    return tmp;
}

+ (NSString *)replaceUnicode:(NSString *)unicodeStr {
    
    NSString *tempStr1 = [unicodeStr stringByReplacingOccurrencesOfString:@"\\u" withString:@"\\U"];
    NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *tempStr3 = [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString* returnStr = [NSPropertyListSerialization propertyListFromData:tempData
                                                           mutabilityOption:NSPropertyListImmutable
                                                                     format:NULL
                                                           errorDescription:NULL];
    
    //NSLog(@"Output = %@", returnStr);  
    
    return [returnStr stringByReplacingOccurrencesOfString:@"\\r\\n" withString:@"\n"];
}

//FIXME:  -
+ (void)test:(NSInteger)page
              completed: (void(^)(NSArray <NSDictionary *>*objs))block{
    
    
    if (self.isProtocolService) {
        !(block)? : block(@[]);
        return;
    }
    
    NSString *str =  @"http://m.qktsw.com/book/13-1.html";
    if (page > 1) {
        str = [NSString stringWithFormat:@"http://m.qktsw.com/book/13-%ld.html",(long)page];
    }
    
    NSURL * url = [NSURL URLWithString:str];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setTimeoutInterval:10.0];
    
    [request setValue:self.userAgent forHTTPHeaderField:@"User-Agent"];
    
    NSURLSession * session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask * task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSStringEncoding enc =CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        NSString *searchText = [[NSString alloc] initWithData:data encoding:enc];
        //        searchText = nil;
        if (!searchText || searchText.length < 10) {
            //            NSArray *array = [TJData hanjuArray];
            //            array = [self getRanArray:array];
            //            if(page != 1 || !([TJNetwork defaultNetwork].isReachable)) array = @[];
            dispatch_async(dispatch_get_main_queue(), ^{
                !(block)? : block(@[]);
            });
            return;
        }
        
        NSString *rString = @"<div class=\"bookbox\".*?</div></div></div>";
        
        NSArray *rs = [self matchString:searchText toRegexString:rString];
        NSLog(@"%s", __func__);
        
        //return;
        NSString *rS =  @"<div class=\"bookbox\" bookid=\"(.*?)\"><div class=\"bookimg\"><img src=\".*?\" orgsrc=\"(.*?)\"></div><div class=\"bookinfo\"><h4 class=\"bookname\">(.*?)</h4><div class=\"author\">作者：(.*?)&nbsp;&nbsp;&nbsp;播音:(.*?)</div><div class=\"cl0\"></div><div class=\"update\"><span>状态：</span>(.*?)</div><div class=\"intro_line\"><span>简介：</span>(.*?)</div></div></div>";
        
        
//        NSString *statusS = @"<dd class=\"new\">[\\w\\W]*?</dd>";
//        NSArray *statuss = [self matchString:searchText toRegexString:statusS];
        
        NSMutableArray *temps = [NSMutableArray array];
        
        
        for (NSString *r in rs) {
            NSArray *d = [self matchString:r toRegexString:rS];
            if (d.count < 8) {
                continue;
            }

            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            dict[@"img"] = d[2];
            
            dict[@"url"] = [NSString stringWithFormat:@"http://m.qktsw.com%@", d[1]];
            
            dict[@"title"] = d[3];
            dict[@"author"] = d[4];
            dict[@"announcer"] = d[5];
            dict[@"status"] = d[6];
            dict[@"desc"] = d[7];
            
            dict[@"type_name"] = @"笑话";
            dict[@"type_id"] = @(6);
            dict[@"cate_name"] = @"其他";
            dict[@"cate_id"] = @(5);


            NSInteger play_vid = [[[d[1] componentsSeparatedByString:@"/"].lastObject componentsSeparatedByString:@"."].firstObject integerValue];
            dict[@"vid"] = @(play_vid);

            
            NSString *js = [NSString stringWithFormat:@"http://www.qktsw.com/playdata/%ld/%ld.js",play_vid*1 % 256,(long)play_vid];
            sleep(0.1);
            
            NSString *html = [[NSString alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:js]] encoding:enc];
            html = [self replaceUnicode:html];
            //html = unesp(html);
            html = [html componentsSeparatedByString:@"'tudou',"].lastObject;
            
            
            NSString *statusS = @"'.*?\\$.*?\\$.*?',";
            NSArray *statuss = [self matchString:html toRegexString:statusS];
            NSMutableArray *list = [NSMutableArray array];
            
            [statuss enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                NSArray <NSString *>*dd = [obj componentsSeparatedByString:@"$"];
                dict[@"title"] = [dd.firstObject stringByReplacingOccurrencesOfString:@"'" withString:@""];
                dict[@"url"] = dd[1];
                dict[@"type"] = [dd.lastObject stringByReplacingOccurrencesOfString:@"'," withString:@""];
                dict[@"vid"] = @(play_vid);
                dict[@"vtitle"] = d[3];

                [list addObject:dict];
            }];

            dict[@"list"] = list;
            //            '第1集$yousheng/21656/0$tc'
            
            //www.qktsw.com/playdata/" + (play_vid*1 % 256) + "/" + play_vid + ".js
            [temps addObject:dict];
            
            
            
        }
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            !(block)? : block(temps);
        });
    }];
    //开启网络任务
    [task resume];
}


/////

+ (void)MeiJuSearch:(NSString *)kw
          pageNo:(NSInteger)page
         completed: (void(^)(NSArray <NSDictionary *>*objs,BOOL))block{
    
    if (self.isProtocolService){
        !(block)? : block(@[],NO);
        return;
    }//http://www.97pd.com/index.php?s=vod-search-wd-%E5%83%B5%E5%B0%B8%E5%9B%BD%E5%BA%A6-p-1.html
    page = page? page : 1;
    NSString* encodedString = [[NSString stringWithFormat:@"http://www.97pd.com/index.php?s=vod-search-wd-%@-p.html",kw] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    if (page>1) {
        encodedString = [[NSString stringWithFormat:@"http://www.97pd.com/index.php?s=vod-search-wd-%@-p-%ld.html",kw,(long)page] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    NSURL * url = [NSURL URLWithString:encodedString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setTimeoutInterval:10.0];
    [request setValue:self.userAgent forHTTPHeaderField:@"User-Agent"];
    [request setValue:@"http://www.97pd.com" forHTTPHeaderField:@"Origin"];
    //request.HTTPMethod = @"POST";
    
    //NSData *paramData = [[NSString stringWithFormat:@"keyword=%@",kw] dataUsingEncoding:NSUTF8StringEncoding];
    //request.HTTPBody = paramData;
    NSURLSession * session = [NSURLSession sharedSession];
    NSURLSessionDataTask * task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSString *searchText = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//                searchText = nil;

        if (!searchText || searchText.length < 5) {
//            NSArray *array = [TJData hanjuArray];
            
            //模糊查询
//            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title CONTAINS %@", kw]; //
//            NSArray <NSDictionary *>*results = [array filteredArrayUsingPredicate:predicate];
//            if(page != 1 || !([TJNetwork defaultNetwork].isReachable)) results = @[];
            dispatch_async(dispatch_get_main_queue(), ^{
                !(block)? : block(@[],NO);
            });
            return;
        }
        

        
        NSString *rString = @"<dt><a href=\".*?\" target=\"_blank\" title=\".*?\"><img src=\".*?\" onerror=\".*?\" alt=\".*?\"/></a></dt>";
        
        NSArray *rs = [self matchString:searchText toRegexString:rString];
        NSLog(@"%s", __func__);
        NSString *rS = @"<dt><a href=\"(.*?)\" target=\"_blank\" title=\"(.*?)\"><img src=\"(.*?)\" onerror=\".*?\" alt=\".*?\"/></a></dt>";
        
        NSString *pString = @".*?&nbsp;当前:.*?/(.*?)页&nbsp;";
        NSArray *ps = [self matchString:searchText toRegexString:pString];
        NSInteger totalPage = [ps.lastObject integerValue];
        
        
        NSMutableArray *temps = [NSMutableArray array];
        
        for (NSString *r in rs) {
            NSArray *d = [self matchString:r toRegexString:rS];
            if (d.count < 4) {
                continue;
            }
            NSLog(@"%s--%@", __func__,d);
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            dict[@"img"] = d[3];
            dict[@"url"] = [NSString stringWithFormat:@"http://www.97pd.com/%@", d[1]];
            dict[@"title"] = d[2];
            

            [temps addObject:dict];
        }

//        if (temps.count == 0 && ([TJNetwork defaultNetwork].isReachable) && page == 1) {
//            NSArray *array = [TJData hanjuArray];
//            //模糊查询
//            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title CONTAINS %@", kw]; //
//            temps = [array filteredArrayUsingPredicate:predicate].mutableCopy;
//        }

        dispatch_async(dispatch_get_main_queue(), ^{
            !(block)? : block(temps,page<totalPage);
        });
        
        
    }];
    //开启网络任务
    [task resume];
    
}





+ (void)MeiJuGetM3u8:(NSString *)urlStr
            completed: (void(^)(NSArray *objs))block{

    
    if ([self isProtocolService]) {
        !(block)? : block(@[]);
        return;
    }
    
    NSURL * url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setTimeoutInterval:10.0];
    [request setValue:self.userAgent forHTTPHeaderField:@"User-Agent"];
    
    NSURLSession * session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask * task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        NSStringEncoding gb2312 = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        
        NSString *searchText = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (!searchText) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                !(block)? : block(@[]);
            });
            
            return;
        }
        
        NSString *dataRegex = @"<div id=\".*?\"><script charset=\".*?\" src=\"(.*?)\"></script><script charset=\".*?\" src=\".*?\"></script><script charset=\".*?\" src=\".*?\"></script>";
        NSString *dataStr = [self matchString:searchText toRegexString:dataRegex].lastObject;
        NSString *url = [NSString stringWithFormat:@"http://www.97pd.com/%@", dataStr];
        NSString *jsContet = [[NSString alloc] initWithContentsOfURL:[NSURL URLWithString:url] encoding:NSUTF8StringEncoding error:NULL];
        NSString *jsonRegex = @"var ff_urls='(.*?)';";
        NSString *json = [self matchString:jsContet toRegexString:jsonRegex].lastObject;

        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:NULL];
        NSArray *Data = dict[@"Data"];
        NSMutableArray *hls = [NSMutableArray array];
        [Data enumerateObjectsUsingBlock:^(NSDictionary  * obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *playname = [obj valueForKey:@"playname"];
            NSArray <NSArray *>*playurls = obj[@"playurls"];
            [[[playurls reverseObjectEnumerator] allObjects] enumerateObjectsUsingBlock:^(NSArray * _Nonnull playurl, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([playname isEqualToString:@"yuku"]) {
                    [hls addObject:@{@"title":playurl[0],@"url":[NSString stringWithFormat:@"https://player.youku.com/embed/%@?&autoplay=true",playurl[1]]}];
                }else{
                    
                    [hls addObject:@{@"title":playurl[0],@"url":[playurl[1] stringByReplacingOccurrencesOfString:@"&type=free" withString:@""]}];
                }
            }];
            
        }];
        NSLog(@"%s", __func__);
//        NSString *url = [NSString stringWithFormat:@"http://m.yueyuwz.com%@", dataStr];
//
//        NSString *m3u8 = [NSString stringWithContentsOfURL:[NSURL URLWithString:url] encoding:gb2312 error:NULL];
//        m3u8 = [self replaceUnicode:m3u8];
//
//        NSString *hlsRegex = [NSString stringWithFormat:@"%@\\$.*?\\$",title];
//        NSArray *hls = [self matchString:m3u8 toRegexString:hlsRegex];
//        NSString *hlssRegex = @"\\$(.*?)\\$";
//
//        NSMutableArray *temp = [NSMutableArray array];
//        for (NSString *string in hls) {
//            NSString *hlsString = [self matchString:string toRegexString:hlssRegex].lastObject;
//            [temp addObject:hlsString];
//        }
//
//        NSArray *lists = [temp sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
//
//            BOOL b1 = [obj1 containsString:@"m3u8"];
//            BOOL b2 = [obj2 containsString:@"m3u8"];
//
//            return b1 < b2;
//        }];
//
//        NSMutableArray *live_streams = [NSMutableArray array];
//        [lists enumerateObjectsUsingBlock:^(NSString *   obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            [live_streams addObject:@{@"name":title,@"live_stream":obj}];
//        }];
//
        dispatch_async(dispatch_get_main_queue(), ^{
            !(block)? : block(hls);
        });
        
    }];
    //开启网络任务
    [task resume];
}



+ (void)MeiJuGetDetail:(NSString *)urlStr
           completed: (void(^)(NSDictionary *obj))block{
    
    if (self.isProtocolService) {
        !(block)? : block(@{});
        return;
    }
    
    NSURL * url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:self.userAgent forHTTPHeaderField:@"User-Agent"];
    [request setTimeoutInterval:10.0];

    NSURLSession * session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask * task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        //NSStringEncoding enc =CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        NSString *searchText = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        if (searchText.length==0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                !(block)? : block(@{});
                
            });
            return;
        }
        NSString *iconRegex = @"<P><IMG class=lazy alt=.*? onerror=\"javascript:this.src=.*?;\" src=\".*?\" data-original=\"(.*?)\"></P>";
        NSString *icon = [self matchString:searchText toRegexString:iconRegex].lastObject;
        icon =  [icon containsString:@"noimg.gif"]?@"":icon;
        
        NSString *nameRegex = @"<SPAN class=title>(.*?)</SPAN>";
        NSString *name = [self matchString:searchText toRegexString:nameRegex].lastObject;
        
        NSString *mainShow = @"<DD>主演：.*?</DD>";
        NSArray *mains = [self matchString:searchText toRegexString:mainShow];
        mainShow = @"<a href=\".*?\" target=\"_blank\">(.*?)</a>";
        mains = [self matchString:mains.lastObject toRegexString:mainShow];
        
        NSMutableString *main = [NSMutableString string];
        for (NSInteger i = 1;i < mains.count; i+=2) {
            [main appendString:mains[i]];
            [main appendString:@" "];
        }
        
        NSString *statusRegex = @"<DD>状态：<span class=\".*?\">(.*?)</span></DD>";
        NSString *status = [self matchString:searchText toRegexString:statusRegex].lastObject;
        
        NSString *typeRegex = @"<DD class=left>类型：<a href=\".*?\">(.*?)</a></DD>";
        NSString *type = [self matchString:searchText toRegexString:typeRegex].lastObject;
        
        NSString *yearRegex = @"<DD class=right>年份：<span class=\".*?\">(.*?)</span></DD>";
        NSString *year = [self matchString:searchText toRegexString:yearRegex].lastObject;
        
        NSString *languageRegex = @"<DD class=left>语言：<span class=\".*?\">(.*?)</span></DD>";
        NSString *language = [self matchString:searchText toRegexString:languageRegex].lastObject;
        
        NSString *desRegex = @"<div class=\".*?\"> <p>(.*?)</div>";
        NSString *des = [self matchString:searchText toRegexString:desRegex].lastObject;
        des = [self flattenHTML:des];
        des = [des stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        NSString *hlsRegex = @"<li><a href=\".*?\" target=\"_blank\" >.*?</a></li>";
        NSString *m3u8Regex = @"<li><a href=\"(.*?)\" target=\"_blank\" >(.*?)</a></li>";
        NSArray *hlss = [self matchString:searchText toRegexString:hlsRegex];
        
        NSMutableArray *m3u8s = [NSMutableArray array];
        for (NSString *hlsHtml in hlss) {
            NSArray *urls = [self matchString:hlsHtml toRegexString:m3u8Regex];
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            dict[@"title"] = urls[2];
            dict[@"url"] = [NSString stringWithFormat:@"http://www.97pd.com/%@", urls[1]];
            [m3u8s addObject:dict];
        }
        
//        des = (des.length < (iPad?120 : 80))? des : [NSString stringWithFormat:@"%@...",[des substringToIndex:(iPad? 119 : 79)]];
        

        
        NSDictionary *obj = @{
                              @"img":icon.length?icon : @"",
                              @"title":name.length?name : @"未知",
                              @"status":status.length? status : @"未知",
                              @"type":type.length?type : @"未知",
                              @"year":year.length?year : @"未知",
                              @"des":des.length? des : @"暂无介绍",
                              @"vlist":m3u8s.count? m3u8s : @[],
                              @"main" : main.length? main:@"未知",
                              @"url":urlStr,
                              @"language" : language.length?language:@"未知"
                              };
        dispatch_async(dispatch_get_main_queue(), ^{
            !(block)? : block(obj);
        });
    }];
    //开启网络任务
    [task resume];
}


+ (NSArray *)getRanArray:(NSArray *)array{
    
    
    
    NSMutableArray *shuffleArray = array.mutableCopy;
    for (int i =0; i < shuffleArray.count; i++) {
        
        int n = (arc4random() % (shuffleArray.count - i)) + i;
        
        [shuffleArray exchangeObjectAtIndex:i withObjectAtIndex:n];
        
    }
    
    return [shuffleArray subarrayWithRange:NSMakeRange(0,shuffleArray.count-1)];
}

//FIXME:  -  泰剧列表
+ (void)MeiJuListPageNo:(NSInteger)page
                 completed: (void(^)(NSArray <NSDictionary *>*objs))block{

    
    if (self.isProtocolService) {
        !(block)? : block(@[]);
        return;
    }
    
    NSString *str =  @"http://www.97pd.com/list/meiju/index.html";
    if (page > 1) {
        str = [NSString stringWithFormat:@"http://www.97pd.com/list/meiju/index-%ld.html",(long)page];
    }
    
    NSURL * url = [NSURL URLWithString:str];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setTimeoutInterval:10.0];

    [request setValue:self.userAgent forHTTPHeaderField:@"User-Agent"];
    
    NSURLSession * session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask * task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        //NSStringEncoding enc =CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        NSString *searchText = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        searchText = nil;
        if (!searchText || searchText.length < 10) {
//            NSArray *array = [TJData hanjuArray];
//            array = [self getRanArray:array];
//            if(page != 1 || !([TJNetwork defaultNetwork].isReachable)) array = @[];
            dispatch_async(dispatch_get_main_queue(), ^{
                !(block)? : block(@[]);
            });
            return;
        }
        
        NSString *rString = @"<dt><a href=\".*?\" title=\".*?\" target=\"_blank\"><img src=\".*?\"";
                  rString = @"<dt><a href=\".*?\" target=\"_blank\"><img src=\".*?\"";
        
        NSArray *rs = [self matchString:searchText toRegexString:rString];
        NSLog(@"%s", __func__);
        NSString *rS = @"<dt><a href=\"(.*?)\" title=\"(.*?)\" target=\"_blank\"><img src=\"(.*?)\"";
        rS = @"<dt><a href=\"(.*?)\" target=\"_blank\"><img src=\"(.*?)\"";

        
        NSString *statusS = @"<dd class=\"new\">[\\w\\W]*?</dd>";
        NSArray *statuss = [self matchString:searchText toRegexString:statusS];

        NSMutableArray *temps = [NSMutableArray array];
        
    
        for (NSString *r in rs) {
            NSArray *d = [self matchString:r toRegexString:rS];
            if (d.count < 3) {
                continue;
            }
//            NSLog(@"%s--%@", __func__,d);
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            dict[@"img"] = d[2];
            NSArray *urltitle = [d[1] componentsSeparatedByString:@"\" title=\""];

            dict[@"url"] = [NSString stringWithFormat:@"http://www.97pd.com/%@", urltitle.firstObject];
            dict[@"title"] = (urltitle.count < 2)?@"":urltitle.lastObject;
            if(statuss.count == rs.count){
                NSString * des = [[self flattenHTML:statuss[[rs indexOfObject:r]]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                dict[@"status"] = des;//[NSString stringWithFormat:@" %@    \b",des];

            }
            [temps addObject:dict];
            
        }

//        if (temps.count == 0 && ([TJNetwork defaultNetwork].isReachable) && page == 1) {
//            NSArray *array = [TJData hanjuArray];
//            temps = [self getRanArray:array].mutableCopy;
//        }

        
        dispatch_async(dispatch_get_main_queue(), ^{
            !(block)? : block(temps);
        });
    }];
    //开启网络任务
    [task resume];
}


+ (BOOL)isProtocolService{
    
#ifdef DEBUG
    return NO;
#else
    NSDictionary *proxySettings = (__bridge NSDictionary *)(CFNetworkCopySystemProxySettings());
    NSArray *proxies = (__bridge NSArray *)(CFNetworkCopyProxiesForURL((__bridge CFURLRef _Nonnull)([NSURL URLWithString:@"http://www.baidu.com"]), (__bridge CFDictionaryRef _Nonnull)(proxySettings)));
    //NSLog(@"\n%@",proxies);
    
    NSDictionary *settings = proxies[0];
    //NSLog(@"%@",[settings objectForKey:(NSString *)kCFProxyHostNameKey]);
    //NSLog(@"%@",[settings objectForKey:(NSString *)kCFProxyPortNumberKey]);
    //NSLog(@"%@",[settings objectForKey:(NSString *)kCFProxyTypeKey]);
    
    if ([[settings objectForKey:(NSString *)kCFProxyTypeKey] isEqualToString:@"kCFProxyTypeNone"])
    {
        //NSLog(@"没代理");
        return NO;
    }
    else
    {
        NSLog(@"设置了代理");
        return YES;
    }
#endif

}

+ (NSString *)userAgent{
    
    
    NSArray *userAgents = @[
                            @"Mozilla/5.0 (Linux; Android 4.4.4; HTC D820u Build/KTU84P) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/40.0.2214.89 Mobile Safari/537.36",
                            @"Mozilla/5.0 (Linux; U; Android 4.4.4; zh-cn; HTC_D820u Build/KTU84P) AppleWebKit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30",
                            @"Mozilla/5.0 (Linux; Android 4.4.4; HTC D820u Build/KTU84P) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/33.0.0.0 Mobile Safari/537.36 ACHEETAHI/2100501044",
                            @"Mozilla/5.0 (Linux; Android 4.4.4; HTC D820u Build/KTU84P) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/33.0.0.0 Mobile Safari/537.36 bdbrowser_i18n/4.6.0.7",
                            @"Mozilla/5.0 (Linux; U; Android 4.4.4; zh-CN; HTC D820u Build/KTU84P) AppleWebKit/534.30 (KHTML, like Gecko) Version/4.0 UCBrowser/10.1.0.527 U3/0.8.0 Mobile Safari/534.30",
                            @"Mozilla/5.0 (Android; Mobile; rv:35.0) Gecko/35.0 Firefox/35.0",
                            @"Mozilla/5.0 (Linux; U; Android 4.4.4; zh-cn; HTC D820u Build/KTU84P) AppleWebKit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30 SogouMSE,SogouMobileBrowser/3.5.1",
                            @"Mozilla/5.0 (Linux; U; Android 4.4.4; zh-CN; HTC D820u Build/KTU84P) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Oupeng/10.2.3.88150 Mobile Safari/537.36",
                            @"Mozilla/5.0 (Linux; U; Android 4.4.4; zh-cn; HTC D820u Build/KTU84P) AppleWebKit/537.36 (KHTML, like Gecko)Version/4.0 MQQBrowser/5.6 Mobile Safari/537.36",
                            @"Mozilla/5.0 (Linux; U; Android 4.4.4; zh-cn; HTC D820u Build/KTU84P) AppleWebKit/534.24 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.24 T5/2.0 baidubrowser/5.3.4.0 (Baidu; P1 4.4.4)",
                            @"Mozilla/5.0 (Linux; U; Android 4.4.4; zh-cn; HTC D820u Build/KTU84P) AppleWebKit/535.19 (KHTML, like Gecko) Version/4.0 LieBaoFast/2.28.1 Mobile Safari/535.19",
                            @"Mozilla/5.0 (iPhone; CPU iPhone OS 8_0 like Mac OS X) AppleWebKit/600.1.4 (KHTML, like Gecko) Version/8.0 Mobile/12A365 Safari/600.1.4",
                            @"Mozilla/5.0 (iPhone; CPU iPhone OS 8_0 like Mac OS X; zh-CN) AppleWebKit/537.51.1 (KHTML, like Gecko) Mobile/12A365 UCBrowser/10.2.5.551 Mobile",
                            @"Mozilla/5.0 (iPhone 5SGLOBAL; CPU iPhone OS 8_0 like Mac OS X) AppleWebKit/600.1.4 (KHTML, like Gecko) Version/6.0 MQQBrowser/5.6 Mobile/12A365 Safari/8536.25",
                            @"Mozilla/5.0 (iPhone; CPU iPhone OS 8_0 like Mac OS X) AppleWebKit/600.1.4 (KHTML, like Gecko) Version/7.0 Mobile/12A365 Safari/9537.53",
                            @"Mozilla/5.0 (iPhone; CPU iPhone OS 8_0 like Mac OS X) AppleWebKit/600.1.4.9 (KHTML, like Gecko) Version/6.0 Mobile/10A523 Safari/8536.25",
                            @"Mozilla/5.0 (iPhone; CPU iPhone OS 7_0_4 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Mercury/8.9.4 Mobile/11B554a Safari/9537.53",
                            @"Mozilla/5.0 (iPhone; CPU iPhone OS 8_0 like Mac OS X) AppleWebKit/600.1.4 (KHTML, like Gecko) Mobile/12A365 SogouMobileBrowser/3.5.1",
                            @"Mozilla/5.0 (iPhone; CPU iPhone OS 7_1 like Mac OS X) AppleWebKit/537.51.2 (KHTML, like Gecko) Version/7.0 Mobile/11D167 Safari/9537.53",
                            @"Mozilla/5.0 (iPhone; CPU iPhone OS 8_0 like Mac OS X) AppleWebKit/600.1.4 (KHTML, like Gecko) Coast/4.01.88243 Mobile/12A365 Safari/7534.48.3",
                            @"Mozilla/5.0 (iPhone; CPU iPhone OS 8_0 like Mac OS X) AppleWebKit/600.1.4 (KHTML, like Gecko) CriOS/40.0.2214.69 Mobile/12A365 Safari/600.1.4",
                            @"Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_2 like Mac OS X) AppleWebKit/603.2.4 (KHTML, like Gecko) Version/10.0 Mobile/14F89 Safari/602.1",
                            @"Mozilla/5.0 (iPhone; CPU iPhone OS 11_1_1 like Mac OS X) AppleWebKit/603.2.4 (KHTML, like Gecko) Version/10.0 Mobile/15F89 Safari/602.1",
                            ];
    
    NSInteger index = arc4random() % userAgents.count;
    return  userAgents[index];
}


+ (NSArray *)matchString:(NSString *)string toRegexString:(NSString *)regexStr
{
    
    if(!string) return @[];
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexStr options:NSRegularExpressionCaseInsensitive error:nil];
    
    NSArray * matches = [regex matchesInString:string options:0 range:NSMakeRange(0, [string length])];
    
    NSMutableArray *array = [NSMutableArray array];
    
    for (NSTextCheckingResult *match in matches) {
        
        for (int i = 0; i < [match numberOfRanges]; i++) {
            //以正则中的(),划分成不同的匹配部分
            NSString *component = [string substringWithRange:[match rangeAtIndex:i]];
            
            [array addObject:component];
            
        }
        
    }
    
    return array;
}

+(NSString *)flattenHTML:(NSString *)html {
    
    if(!html) return @"";
    NSScanner *theScanner;
    NSString *text = nil;
    theScanner = [NSScanner scannerWithString:html];
    while ([theScanner isAtEnd] == NO) {
        
        [theScanner scanUpToString:@"<" intoString:NULL] ;
        
        [theScanner scanUpToString:@">" intoString:&text] ;
        
        html=[html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>", text] withString:@""];
    }
    return html;
}



@end
