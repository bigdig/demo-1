//
//  TTZMedia.m
//  video
//
//  Created by Jay on 4/5/18.
//  Copyright © 2018年 Jay. All rights reserved.
//

#import "TTZMedia.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>


@implementation TTZMedia

//FIXME:  -  添加背景音乐
+ (void)addBackgroundMiusicWithVideoURL:(NSString *)videoURL
                               audioURL:(NSString *)audioURL
                             completion:(CompletionBlock)completionHandle{
    
    CGFloat duration = [self durationWithResourceURL:videoURL];
    
    [self addBackgroundMiusicWithVideoUrlStr:videoURL audioUrl:audioURL andCaptureVideoWithRange:NSMakeRange(0, duration) completion:completionHandle];
}

//FIXME:  -  添加背景音乐

+ (void)addBackgroundMiusicWithVideoUrlStr:(NSString *)videoUrl
                                  audioUrl:(NSString *)audioUrl
                  andCaptureVideoWithRange:(NSRange)videoRange
                                completion:(CompletionBlock)completionHandle {
    
    //AVURLAsset此类主要用于获取媒体信息，包括视频、声音等
    AVURLAsset* audioAsset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:audioUrl] options:nil];
    AVURLAsset* videoAsset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:videoUrl] options:nil];
    
    //创建AVMutableComposition对象来添加视频音频资源的AVMutableCompositionTrack
    AVMutableComposition* mixComposition = [AVMutableComposition composition];
    
    //CMTimeRangeMake(start, duration),start起始时间，duration时长，都是CMTime类型
    //CMTimeMake(int64_t value, int32_t timescale)，返回CMTime，value视频的一个总帧数，timescale是指每秒视频播放的帧数，视频播放速率，（value / timescale）才是视频实际的秒数时长，timescale一般情况下不改变，截取视频长度通过改变value的值
    //CMTimeMakeWithSeconds(Float64 seconds, int32_t preferredTimeScale)，返回CMTime，seconds截取时长（单位秒），preferredTimeScale每秒帧数
    
    //开始位置startTime
    CMTime startTime = CMTimeMakeWithSeconds(videoRange.location, videoAsset.duration.timescale);
    //截取长度videoDuration
    CMTime videoDuration = CMTimeMakeWithSeconds(videoRange.length, videoAsset.duration.timescale);
    
    CMTimeRange videoTimeRange = CMTimeRangeMake(startTime, videoDuration);
    
    //视频采集compositionVideoTrack
    AVMutableCompositionTrack *compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
#warning 避免数组越界 tracksWithMediaType 找不到对应的文件时候返回空数组
    //TimeRange截取的范围长度
    //ofTrack来源
    //atTime插放在视频的时间位置
    [compositionVideoTrack insertTimeRange:videoTimeRange ofTrack:([videoAsset tracksWithMediaType:AVMediaTypeVideo].count>0) ? [videoAsset tracksWithMediaType:AVMediaTypeVideo].firstObject : nil atTime:kCMTimeZero error:nil];
    
    /*
     //视频声音采集(也可不执行这段代码不采集视频音轨，合并后的视频文件将没有视频原来的声音)
     
     AVMutableCompositionTrack *compositionVoiceTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
     
     [compositionVoiceTrack insertTimeRange:videoTimeRange ofTrack:([videoAsset tracksWithMediaType:AVMediaTypeAudio].count>0)?[videoAsset tracksWithMediaType:AVMediaTypeAudio].firstObject:nil atTime:kCMTimeZero error:nil];
     
     */
    
    
    //声音长度截取范围==视频长度
    CMTimeRange audioTimeRange = CMTimeRangeMake(kCMTimeZero, videoDuration);
    
    //音频采集compositionCommentaryTrack
    AVMutableCompositionTrack *compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    [compositionAudioTrack insertTimeRange:audioTimeRange ofTrack:([audioAsset tracksWithMediaType:AVMediaTypeAudio].count > 0) ? [audioAsset tracksWithMediaType:AVMediaTypeAudio].firstObject : nil atTime:kCMTimeZero error:nil];
    
    //AVAssetExportSession用于合并文件，导出合并后文件，presetName文件的输出类型
    AVAssetExportSession *assetExportSession = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetPassthrough];
    
    
    NSString *outPutPath = @"/Users/jay/Desktop/MixVideo.mov";//[NSHomeDirectory() stringByAppendingPathComponent:MediaFileName];
    //混合后的视频输出路径
    NSURL *outPutUrl = [NSURL fileURLWithPath:outPutPath];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:outPutPath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:outPutPath error:nil];
    }
    NSLog(@"%s-混合后的视频输出路径:%@", __func__,outPutUrl);
    
    //输出视频格式 AVFileTypeMPEG4 AVFileTypeQuickTimeMovie...
    assetExportSession.outputFileType = AVFileTypeQuickTimeMovie;
    //    NSArray *fileTypes = assetExportSession.
    
    assetExportSession.outputURL = outPutUrl;
    //输出文件是否网络优化
    assetExportSession.shouldOptimizeForNetworkUse = YES;
    
    [assetExportSession exportAsynchronouslyWithCompletionHandler:^{
        completionHandle(outPutPath);
    }];
}




static AVURLAsset* videoAsset = nil;

//FIXME:  -  截取视频
+ (void)importVideoWithURL:(NSString *)videoURL
                     range:(NSRange)videoRange
                completion:(CompletionBlock)completionHandle{
    
    //AVURLAsset此类主要用于获取媒体信息，包括视频、声音等
    videoAsset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:videoURL] options:nil];
    
    //创建AVMutableComposition对象来添加视频音频资源的AVMutableCompositionTrack
    AVMutableComposition* mixComposition = [AVMutableComposition composition];
    
    //CMTimeRangeMake(start, duration),start起始时间，duration时长，都是CMTime类型
    //CMTimeMake(int64_t value, int32_t timescale)，返回CMTime，value视频的一个总帧数，timescale是指每秒视频播放的帧数，视频播放速率，（value / timescale）才是视频实际的秒数时长，timescale一般情况下不改变，截取视频长度通过改变value的值
    //CMTimeMakeWithSeconds(Float64 seconds, int32_t preferredTimeScale)，返回CMTime，seconds截取时长（单位秒），preferredTimeScale每秒帧数
    
    //开始位置startTime
    CMTime startTime = CMTimeMakeWithSeconds(videoRange.location, videoAsset.duration.timescale);
    //截取长度videoDuration
    CMTime videoDuration = CMTimeMakeWithSeconds(videoRange.length, videoAsset.duration.timescale);
    
    CMTimeRange videoTimeRange = CMTimeRangeMake(startTime, videoDuration);
    
    //视频采集compositionVideoTrack
    AVMutableCompositionTrack *compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    
#warning 避免数组越界 tracksWithMediaType 找不到对应的文件时候返回空数组
    //TimeRange截取的范围长度
    //ofTrack来源
    //atTime插放在视频的时间位置
    [compositionVideoTrack insertTimeRange:videoTimeRange ofTrack:([videoAsset tracksWithMediaType:AVMediaTypeVideo].count>0) ? [videoAsset tracksWithMediaType:AVMediaTypeVideo].firstObject : nil atTime:kCMTimeZero error:nil];
    
    
    //视频声音采集(也可不执行这段代码不采集视频音轨，合并后的视频文件将没有视频原来的声音)
    
    AVMutableCompositionTrack *compositionVoiceTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    [compositionVoiceTrack insertTimeRange:videoTimeRange ofTrack:([videoAsset tracksWithMediaType:AVMediaTypeAudio].count>0)?[videoAsset tracksWithMediaType:AVMediaTypeAudio].firstObject:nil atTime:kCMTimeZero error:nil];
    
    
    
    
    //    //声音长度截取范围==视频长度
    //    CMTimeRange audioTimeRange = CMTimeRangeMake(kCMTimeZero, videoDuration);
    //
    //    //音频采集compositionCommentaryTrack
    //    AVMutableCompositionTrack *compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    //
    //    [compositionAudioTrack insertTimeRange:audioTimeRange ofTrack:([audioAsset tracksWithMediaType:AVMediaTypeAudio].count > 0) ? [audioAsset tracksWithMediaType:AVMediaTypeAudio].firstObject : nil atTime:kCMTimeZero error:nil];
    
    //AVAssetExportSession用于合并文件，导出合并后文件，presetName文件的输出类型
    AVAssetExportSession *assetExportSession = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetPassthrough];
    
    
    NSString *outPutPath = @"/Users/jay/Desktop/MixVideo.mov";//[NSHomeDirectory() stringByAppendingPathComponent:MediaFileName];
    //混合后的视频输出路径
    NSURL *outPutUrl = [NSURL fileURLWithPath:outPutPath];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:outPutPath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:outPutPath error:nil];
    }
    NSLog(@"%s-混合后的视频输出路径:%@", __func__,outPutUrl);
    
    //输出视频格式 AVFileTypeMPEG4 AVFileTypeQuickTimeMovie...
    assetExportSession.outputFileType = AVFileTypeQuickTimeMovie;
    //    NSArray *fileTypes = assetExportSession.
    
    assetExportSession.outputURL = outPutUrl;
    //输出文件是否网络优化
    assetExportSession.shouldOptimizeForNetworkUse = YES;
    
    [assetExportSession exportAsynchronouslyWithCompletionHandler:^{
        completionHandle(outPutPath);
    }];
}


//FIXME:  -  导出背景音乐
+ (void)importMP3WithURL:(NSString *)videoURL
                   range:(NSRange)videoRange
              completion:(CompletionBlock)completionHandle{
    
    if(!videoRange.length) videoRange.length = [self durationWithResourceURL:videoURL];
    //AVURLAsset此类主要用于获取媒体信息，包括视频、声音等
    AVURLAsset* videoAsset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:videoURL] options:nil];
    
    //创建AVMutableComposition对象来添加视频音频资源的AVMutableCompositionTrack
    AVMutableComposition* mixComposition = [AVMutableComposition composition];
    
    //CMTimeRangeMake(start, duration),start起始时间，duration时长，都是CMTime类型
    //CMTimeMake(int64_t value, int32_t timescale)，返回CMTime，value视频的一个总帧数，timescale是指每秒视频播放的帧数，视频播放速率，（value / timescale）才是视频实际的秒数时长，timescale一般情况下不改变，截取视频长度通过改变value的值
    //CMTimeMakeWithSeconds(Float64 seconds, int32_t preferredTimeScale)，返回CMTime，seconds截取时长（单位秒），preferredTimeScale每秒帧数
    
    //开始位置startTime
    CMTime startTime = CMTimeMakeWithSeconds(videoRange.location, videoAsset.duration.timescale);
    //截取长度videoDuration
    CMTime videoDuration = CMTimeMakeWithSeconds(videoRange.length, videoAsset.duration.timescale);
    
    CMTimeRange videoTimeRange = CMTimeRangeMake(startTime, videoDuration);
    
    //视频采集compositionVideoTrack
    //AVMutableCompositionTrack *compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    
#warning 避免数组越界 tracksWithMediaType 找不到对应的文件时候返回空数组
    //TimeRange截取的范围长度
    //ofTrack来源
    //atTime插放在视频的时间位置
    //    [compositionVideoTrack insertTimeRange:videoTimeRange ofTrack:([videoAsset tracksWithMediaType:AVMediaTypeVideo].count>0) ? [videoAsset tracksWithMediaType:AVMediaTypeVideo].firstObject : nil atTime:kCMTimeZero error:nil];
    
    
    //视频声音采集(也可不执行这段代码不采集视频音轨，合并后的视频文件将没有视频原来的声音)
    
    AVMutableCompositionTrack *compositionVoiceTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    [compositionVoiceTrack insertTimeRange:videoTimeRange ofTrack:([videoAsset tracksWithMediaType:AVMediaTypeAudio].count>0)?[videoAsset tracksWithMediaType:AVMediaTypeAudio].firstObject:nil atTime:kCMTimeZero error:nil];
    
    
    
    
    //    //声音长度截取范围==视频长度
    //    CMTimeRange audioTimeRange = CMTimeRangeMake(kCMTimeZero, videoDuration);
    //
    //    //音频采集compositionCommentaryTrack
    //    AVMutableCompositionTrack *compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    //
    //    [compositionAudioTrack insertTimeRange:audioTimeRange ofTrack:([audioAsset tracksWithMediaType:AVMediaTypeAudio].count > 0) ? [audioAsset tracksWithMediaType:AVMediaTypeAudio].firstObject : nil atTime:kCMTimeZero error:nil];
    
    //AVAssetExportSession用于合并文件，导出合并后文件，presetName文件的输出类型
    AVAssetExportSession *assetExportSession = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetPassthrough];
    
    
    NSString *outPutPath = @"/Users/xin/Desktop/MixVideo.mov";//[NSHomeDirectory() stringByAppendingPathComponent:MediaFileName];
    //混合后的视频输出路径
    NSURL *outPutUrl = [NSURL fileURLWithPath:outPutPath];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:outPutPath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:outPutPath error:nil];
    }
    NSLog(@"%s-混合后的视频输出路径:%@", __func__,outPutUrl);
    
    //输出视频格式 AVFileTypeMPEG4 AVFileTypeQuickTimeMovie...
    assetExportSession.outputFileType = AVFileTypeQuickTimeMovie;
    //    NSArray *fileTypes = assetExportSession.
    
    assetExportSession.outputURL = outPutUrl;
    //输出文件是否网络优化
    assetExportSession.shouldOptimizeForNetworkUse = YES;
    
    [assetExportSession exportAsynchronouslyWithCompletionHandler:^{
        completionHandle(outPutPath);
    }];
}

//FIXME:  -  获取多媒体时长
+ (CGFloat)durationWithResourceURL:(NSString *)url{
    
    NSURL *mediaURL = [NSURL fileURLWithPath:url];
    AVURLAsset *mediaAsset = [[AVURLAsset alloc] initWithURL:mediaURL options:nil];
    CMTime duration = mediaAsset.duration;
    
    return duration.value / duration.timescale;
}

//FIXME:  -  视频帧图片集
+ (NSArray <UIImage *>*)thumbnailImageForVideo:(NSString *)videoURL
//                                        atTime:(NSTimeInterval)time
{
    
    NSMutableArray * returnArr = [NSMutableArray array];
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:videoURL] options:nil] ;
    NSParameterAssert(asset);
    AVAssetImageGenerator *assetImageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset] ;
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    
    NSInteger alltime = [self durationWithResourceURL:videoURL];
    NSLog(@"%ld",(long)alltime);
    for (int i = 0; i < alltime * 2; i++) {
        CGImageRef thumbnailImageRef = NULL;
        CFTimeInterval thumbnailImageTime = i * 60 / 2;
        CMTime resultTime = CMTimeMake(thumbnailImageTime, 60);
        CMTimeShow(resultTime);
        NSError *thumbnailImageGenerationError = nil;
        thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:resultTime actualTime:NULL error:&thumbnailImageGenerationError];
        
        if (!thumbnailImageRef)
            NSLog(@"thumbnailImageGenerationError %@", thumbnailImageGenerationError);
        
        UIImage *thumbnailImage = thumbnailImageRef ? [[UIImage alloc] initWithCGImage:thumbnailImageRef]  : nil;
        if (thumbnailImage) {
            [returnArr addObject:thumbnailImage];
        }
        
    }
    /*
     这个方法原本是要传一个 time 值，根据 time 返回该时间的图片
     CGImageRef thumbnailImageRef = NULL;
     CFTimeInterval thumbnailImageTime = time * 60;
     CMTime resultTime = CMTimeMake(thumbnailImageTime, 60);
     CMTimeShow(resultTime);
     
     NSError *thumbnailImageGenerationError = nil;
     thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:resultTime actualTime:NULL error:&thumbnailImageGenerationError];
     
     if (!thumbnailImageRef)
     NSLog(@"thumbnailImageGenerationError %@", thumbnailImageGenerationError);
     
     UIImage *thumbnailImage = thumbnailImageRef ? [[UIImage alloc] initWithCGImage:thumbnailImageRef]  : nil;
     if (thumbnailImage) {
     [returnArr addObject:thumbnailImage];
     }
     */
    
    return returnArr;
}

//FIXME:  -  获得视频的某个时间点的帧图片
+ (UIImage *)thumbnailImageForVideo:(NSString *)videoURL
                             atTime:(CGFloat)timeBySecond{
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:videoURL] options:nil] ;
    NSParameterAssert(asset);
    AVAssetImageGenerator *assetImageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset] ;
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    
    
     //这个方法原本是要传一个 time 值，根据 time 返回该时间的图片
     CGImageRef thumbnailImageRef = NULL;
     CFTimeInterval thumbnailImageTime = timeBySecond * 60;
     CMTime resultTime = CMTimeMake(thumbnailImageTime, 60);
     CMTimeShow(resultTime);
     
     NSError *thumbnailImageGenerationError = nil;
     thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:resultTime actualTime:NULL error:&thumbnailImageGenerationError];
     
     if (!thumbnailImageRef)
     NSLog(@"thumbnailImageGenerationError %@", thumbnailImageGenerationError);
     
     UIImage *thumbnailImage = thumbnailImageRef ? [[UIImage alloc] initWithCGImage:thumbnailImageRef]  : nil;
    
    return thumbnailImage;
}


//FIXME:  -  多张图片合成视频

+ (void)compressImages:(NSArray <UIImage *> *)images
            completion:(void(^)(NSURL *outurl))block;
{
    
    //先裁剪图片
    NSMutableArray *imageArray = [NSMutableArray array];
    for (UIImage *image in images)
    {
        CGRect rect = CGRectMake(0, 0,image.size.width, image.size.height);
        if (rect.size.width < rect.size.height)
        {
            rect.origin.y = (rect.size.height - rect.size.width)/2;
            rect.size.height = rect.size.width;
        }else
        {
            rect.origin.x = (rect.size.width - rect.size.height)/2;
            rect.size.width = rect.size.height;
        }
        //裁剪
        UIImage *newImage = [self croppedImage:image bounds:rect];
        /**
         *  缩放
         */
        UIImage *finalImage = [self clipImage:newImage ScaleWithsize:CGSizeMake(640, 640)];
        [imageArray addObject:finalImage];
    }
    
    NSDate *date = [NSDate date];
    NSString *string = [NSString stringWithFormat:@"%ld.mov",(unsigned long)(date.timeIntervalSince1970 * 1000)];
    NSString *cachePath = [NSTemporaryDirectory() stringByAppendingPathComponent:string];
    if ([[NSFileManager defaultManager] fileExistsAtPath:cachePath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:cachePath error:nil];
    }
    NSURL    *exportUrl = [NSURL fileURLWithPath:cachePath];
    CGSize size = CGSizeMake(640,640);//定义视频的大小
    __block AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:exportUrl
                                                                   fileType:AVFileTypeQuickTimeMovie
                                                                      error:nil];
    
    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:AVVideoCodecH264, AVVideoCodecKey,
                                   [NSNumber numberWithInt:size.width], AVVideoWidthKey,
                                   [NSNumber numberWithInt:size.height], AVVideoHeightKey, nil];
    AVAssetWriterInput *writerInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
    
    NSDictionary *sourcePixelBufferAttributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kCVPixelFormatType_32ARGB], kCVPixelBufferPixelFormatTypeKey, nil];
    
    AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor
                                                     assetWriterInputPixelBufferAdaptorWithAssetWriterInput:writerInput sourcePixelBufferAttributes:sourcePixelBufferAttributesDictionary];
    NSParameterAssert(writerInput);
    NSParameterAssert([videoWriter canAddInput:writerInput]);
    
    if ([videoWriter canAddInput:writerInput])
        NSLog(@"");
    else
        NSLog(@"");
    
    [videoWriter addInput:writerInput];
    
    [videoWriter startWriting];
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
    
    //合成多张图片为一个视频文件
    dispatch_queue_t dispatchQueue = dispatch_queue_create("mediaInputQueue", NULL);
    int __block frame = 0;
    __weak typeof(self) ws = self;
    
    [writerInput requestMediaDataWhenReadyOnQueue:dispatchQueue usingBlock:^{
        while ([writerInput isReadyForMoreMediaData])
        {
            if(++frame > 8 * 30)
            {
                [writerInput markAsFinished];
                //[videoWriter_ finishWriting];
                if(videoWriter.status == AVAssetWriterStatusWriting){
                    NSCondition *cond = [[NSCondition alloc] init];
                    [cond lock];
                    [videoWriter finishWritingWithCompletionHandler:^{
                        [cond lock];
                        [cond signal];
                        [cond unlock];
                    }];
                    [cond wait];
                    [cond unlock];
                    !block?:block(exportUrl);
                }
                break;
            }
            CVPixelBufferRef buffer = NULL;
            
            int idx = frame/30 * images.count/8;
            if (idx >= images.count) {
                idx = images.count - 1;
            }
            buffer = (CVPixelBufferRef)[self pixelBufferFromCGImage:[[imageArray objectAtIndex:idx] CGImage] size:size];
            if (buffer)
            {
                if(![adaptor appendPixelBuffer:buffer withPresentationTime:CMTimeMake(frame, 30)])
                {
                    NSLog(@"fail");
                }else
                {
                    NSLog(@"success:%d",frame);
                }
                CFRelease(buffer);
            }
        }
    }];
    
}


//FIXME:  -  水印
+ (void)AVsaveVideoPath:(NSString*)videoURL
           waterImg:(UIImage*)img
           imagePonit:(CGRect)iFrame
            qustion:(NSString*)question
            qustionPonit:(CGRect)qFrame{

    
    
    //1 创建AVAsset实例 AVAsset包含了video的所有信息 self.videoUrl输入视频的路径
    AVAsset *videoAsset = [AVAsset assetWithURL:[NSURL fileURLWithPath:videoURL]];
    //2 创建AVMutableComposition实例. apple developer 里边的解释 【AVMutableComposition is a mutable subclass of AVComposition you use when you want to create a new composition from existing assets. You can add and remove tracks, and you can add, remove, and scale time ranges.】
    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
    
    //3 视频通道  工程文件中的轨道，有音频轨、视频轨等，里面可以插入各种对应的素材
    AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                        preferredTrackID:kCMPersistentTrackID_Invalid];
    //把视频轨道数据加入到可变轨道中 这部分可以做视频裁剪TimeRange
    [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
                        ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0]
                         atTime:kCMTimeZero error:nil];
    
    AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                        preferredTrackID:kCMPersistentTrackID_Invalid];
    //把视频轨道数据加入到可变轨道中 这部分可以做视频裁剪TimeRange
    [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
                        ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0]
                         atTime:kCMTimeZero error:nil];
    
    
    //3.1 AVMutableVideoCompositionInstruction 视频轨道中的一个视频，可以缩放、旋转等
    AVMutableVideoCompositionInstruction *mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration);
    
    // 3.2 AVMutableVideoCompositionLayerInstruction 一个视频轨道，包含了这个轨道上的所有视频素材
    AVMutableVideoCompositionLayerInstruction *videolayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
    
    AVAssetTrack *videoAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    UIImageOrientation videoAssetOrientation_  = UIImageOrientationUp;
    BOOL isVideoAssetPortrait_  = NO;
    CGAffineTransform videoTransform = videoAssetTrack.preferredTransform;
    if (videoTransform.a == 0 && videoTransform.b == 1.0 && videoTransform.c == -1.0 && videoTransform.d == 0) {
        videoAssetOrientation_ = UIImageOrientationRight;
        isVideoAssetPortrait_ = YES;
    }
    if (videoTransform.a == 0 && videoTransform.b == -1.0 && videoTransform.c == 1.0 && videoTransform.d == 0) {
        videoAssetOrientation_ =  UIImageOrientationLeft;
        isVideoAssetPortrait_ = YES;
    }
    if (videoTransform.a == 1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == 1.0) {
        videoAssetOrientation_ =  UIImageOrientationUp;
    }
    if (videoTransform.a == -1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == -1.0) {
        videoAssetOrientation_ = UIImageOrientationDown;
    }
    [videolayerInstruction setTransform:videoAssetTrack.preferredTransform atTime:kCMTimeZero];
    [videolayerInstruction setOpacity:0.0 atTime:videoAsset.duration];
    
    // 3.3 - Add instructions
    mainInstruction.layerInstructions = [NSArray arrayWithObjects:videolayerInstruction,nil];
    //AVMutableVideoComposition：管理所有视频轨道，可以决定最终视频的尺寸，裁剪需要在这里进行
    AVMutableVideoComposition *mainCompositionInst = [AVMutableVideoComposition videoComposition];
    
    CGSize naturalSize;
    if(isVideoAssetPortrait_){
        naturalSize = CGSizeMake(videoAssetTrack.naturalSize.height, videoAssetTrack.naturalSize.width);
    } else {
        naturalSize = videoAssetTrack.naturalSize;
    }
    
    float renderWidth, renderHeight;
    renderWidth = naturalSize.width;
    renderHeight = naturalSize.height;
    mainCompositionInst.renderSize = CGSizeMake(renderWidth, renderHeight);
    mainCompositionInst.instructions = [NSArray arrayWithObject:mainInstruction];
    mainCompositionInst.frameDuration = CMTimeMake(1, 30);
    [self applyVideoEffectsToComposition:mainCompositionInst
                                    size:naturalSize
                                waterImg:img
                              imageFrame:iFrame
                                 qustion:question
                            qustionFrame:qFrame];
    
    // 4 - 输出路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = @"/Users/xin/Desktop";//[paths objectAtIndex:0];
    NSString *myPathDocs =  [documentsDirectory stringByAppendingPathComponent:
                             [NSString stringWithFormat:@"FinalVideo-%d.mov",arc4random() % 1000]];
    
    // 5 - 视频文件输出
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition
                                                                      presetName:AVAssetExportPresetMediumQuality];
    exporter.outputURL=[NSURL fileURLWithPath:myPathDocs];
    exporter.outputFileType = AVFileTypeQuickTimeMovie;
    exporter.shouldOptimizeForNetworkUse = YES;
    exporter.videoComposition = mainCompositionInst;
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            //这里是输出视频之后的操作，做你想做的
            [self exportDidFinish:exporter];
        });
    }];

}

+(void)exportDidFinish:(AVAssetExportSession*)session {
    
    NSLog(@"exportDidFinish");
    
    NSLog(@"session = %d",(int)session.status);
    if (session.status == AVAssetExportSessionStatusCompleted) {
        
        NSURL *outputURL = session.outputURL;
        
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        
        if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:outputURL])  {
            
            [library writeVideoAtPathToSavedPhotosAlbum:outputURL completionBlock:^(NSURL *assetURL, NSError *error) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if (error) {
                        
                        
                        
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                        message:@"存档失败"
                                                                       delegate:nil
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil];
                        [alert show];
                        
                    }else {
                        
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success"
                                                                        message:@"存档成功"
                                                                       delegate:self
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil];
                        
                        [alert show];
                        
                        
                        
                    }
                    
                    
                });
            }];
            
        }
        
    }else {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"存档失败"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
}


+ (void)applyVideoEffectsToComposition:(AVMutableVideoComposition *)composition
                                  size:(CGSize)size
                              waterImg:(UIImage*)img
                            imageFrame:(CGRect)iFrame
                               qustion:(NSString*)question
                          qustionFrame:(CGRect)qFrame{

    // 1 - Set up the text layer
    CATextLayer *subtitle1Text = [[CATextLayer alloc] init];
    [subtitle1Text setFont:@"Helvetica-Bold"];
    [subtitle1Text setFontSize:36];
    //subtitle1Text.bounds = CGRectMake(0, 0, qFrame.size.width, qFrame.size.height);
    //subtitle1Text.position= qFrame.origin;
    subtitle1Text.frame = CGRectMake(qFrame.origin.x,size.height - qFrame.size.height - qFrame.origin.y, qFrame.size.width, qFrame.size.height);
    [subtitle1Text setString:question];
    //    [subtitle1Text setAlignmentMode:kCAAlignmentCenter];
    [subtitle1Text setForegroundColor:[[UIColor redColor] CGColor]];
    
    
    
    CALayer *imgLayer = [CALayer layer];
    UIImage *overlayImage  = img;
    [imgLayer setContents:(id)[overlayImage CGImage]];
    //imgLayer.bounds = CGRectMake(0, 0, iFrame.size.width, iFrame.size.height);
    //imgLayer.position= iFrame.origin;
    imgLayer.frame = CGRectMake(iFrame.origin.x,size.height - iFrame.size.height - iFrame.origin.y, iFrame.size.width, iFrame.size.height);

    
    // 2 - The usual overlay
    CALayer *overlayLayer = [CALayer layer];
    [overlayLayer addSublayer:subtitle1Text];
    [overlayLayer addSublayer:imgLayer];
    
    overlayLayer.frame = CGRectMake(0, 0, size.width, size.height);
    [overlayLayer setMasksToBounds:YES];
    
    

    
    
    CALayer *parentLayer = [CALayer layer];
    
    CALayer *videoLayer = [CALayer layer];
    
    parentLayer.frame = CGRectMake(0, 0, size.width, size.height);
    
    videoLayer.frame = CGRectMake(0, 0, size.width, size.height);
    
    [parentLayer addSublayer:videoLayer];
    [parentLayer addSublayer:overlayLayer];
    
    //*********** For A Special Time
//    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
//    [animation setDuration:0];
//    [animation setFromValue:[NSNumber numberWithFloat:1.0]];
//    [animation setToValue:[NSNumber numberWithFloat:0.0]];
//    [animation setBeginTime:5];
//
//    [animation setRemovedOnCompletion:NO];
//    [animation setFillMode:kCAFillModeForwards];
//    [overlayLayer addAnimation:animation forKey:@"animateOpacity"];

//    [self teset:5 duration:3 layer:overlayLayer];

    
    composition.animationTool = [AVVideoCompositionCoreAnimationTool
                                 videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];


}



+ (void)teset:(NSTimeInterval )start
     duration:(NSTimeInterval )duration
        layer:(CALayer *)overlayLayer{
    
    [self hide:0.000001 duration:start layer:overlayLayer];
    //*********** For A Special Time
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    [animation setFromValue:[NSNumber numberWithFloat:1.0]];
    [animation setToValue:[NSNumber numberWithFloat:1.0]];
    [animation setBeginTime:CACurrentMediaTime()+ start];
    [animation setDuration:duration];

    [animation setRemovedOnCompletion:YES];
    [animation setFillMode:kCAFillModeForwards];
    [overlayLayer addAnimation:animation forKey:@"animateOpacity22"];

    [self hide:start + duration duration:CGFLOAT_MAX layer:overlayLayer];

    
}

+ (void)hide:(NSTimeInterval )start
     duration:(NSTimeInterval )duration
        layer:(CALayer *)overlayLayer{
    
    //*********** For A Special Time
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    [animation setFromValue:[NSNumber numberWithFloat:0.0]];
    [animation setToValue:[NSNumber numberWithFloat:0.0]];
    [animation setBeginTime:CACurrentMediaTime() + start];
    [animation setDuration:duration];
    
    [animation setRemovedOnCompletion:NO];
    [animation setFillMode:kCAFillModeForwards];
    [overlayLayer addAnimation:animation forKey:@"animateOpacity22r"];
    
    
}



+ (UIImage *)croppedImage:(UIImage *)image bounds:(CGRect)bounds
{
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], bounds);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return croppedImage;
}

+ (UIImage *)clipImage:(UIImage *)image ScaleWithsize:(CGSize)asize
{
    UIImage *newimage;
    if (nil == image) {
        newimage = nil;
    }
    else{
        CGSize oldsize = image.size;
        CGRect rect;
        if (asize.width/asize.height > oldsize.width/oldsize.height) {
            rect.size.width = asize.width;
            rect.size.height = asize.width*oldsize.height/oldsize.width;
            rect.origin.x = 0;
            rect.origin.y = (asize.height - rect.size.height)/2;
        }
        else{
            rect.size.width = asize.height*oldsize.width/oldsize.height;
            rect.size.height = asize.height;
            rect.origin.x = (asize.width - rect.size.width)/2;
            rect.origin.y = 0;
        }
        UIGraphicsBeginImageContext(asize);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextClipToRect(context, CGRectMake(0, 0, asize.width, asize.height));
        CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
        UIRectFill(CGRectMake(0, 0, asize.width, asize.height));//clear background
        [image drawInRect:rect];
        newimage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return newimage;
}

+ (CVPixelBufferRef )pixelBufferFromCGImage:(CGImageRef)image size:(CGSize)size
{
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey, nil];
    CVPixelBufferRef pxbuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, size.width, size.height, kCVPixelFormatType_32ARGB, (__bridge CFDictionaryRef) options, &pxbuffer);
    
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, size.width, size.height, 8, 4*size.width, rgbColorSpace, kCGImageAlphaPremultipliedFirst);
    NSParameterAssert(context);
    //CGSize drawSize = CGSizeMake(CGImageGetWidth(image), CGImageGetHeight(image));
    //BOOL baseW = drawSize.width < drawSize.height;
    
    
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image), CGImageGetHeight(image)), image);
    
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}




@end
