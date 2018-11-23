//
//  ViewController.m
//  VideoPlayer
//
//  Created by Jay on 12/5/18.
//  Copyright © 2018年 Jay. All rights reserved.
//

#import "ViewController.h"
#import "Player/PlayerView.h"
#import "SpeedMonitor.h"
#include <objc/runtime.h>


@interface ViewController ()
@property (nonatomic, weak) PlayerView *player;
@property (nonatomic, strong) SpeedMonitor *speeder;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    VideoModel *model = [VideoModel new];
    model.title = @"hello tv";
    model.url =
//    @"http://123.207.42.38/tvb.php?type=jade";
//    @"https://t.bwzybf.com/2018/10/25/oWEYZvMJUDeyxaWJ/playlist.m3u8";//
    //@"https://cdn.youku-letv.com/20181022/m4MlVDnt/index.m3u8";
    //@"http://stream1.grtn.cn/zjpd/sd/live.m3u8?ts";
    @"http://pullhls6.inke.cn/live/1542894701234427/playlist.m3u8";
    
    PlayerView *player = [PlayerView playerView];
    player.allowSafariPlay = YES;
    player.frame = CGRectMake(0, 88, self.view.bounds.size.width, 200);
    [player playWithModel:model];
    [self.view addSubview:player];
    _player = player;
    
//    self.speeder =  [[SpeedMonitor alloc] init];
//    [self.speeder startNetworkSpeedMonitor];
}
- (IBAction)living:(id)sender {
    VideoModel *model = [VideoModel new];
    model.title = @"hello tv";
    model.url =
    @"http://stream1.grtn.cn/zjpd/sd/live.m3u8?ts";
    //@"http://onair.onair.network:8068/listen.pls";
    //@"http://vip888.kuyun99.com/20180802/wcFfyu0v/index.m3u8?sign=9a2f77b13159249164e257ed7356dab84549a9f7b9a70e5509bc3e0359cdcfd7a258b5708ab7d87677196d08cb14c397bce8db18e488383ddf21376648d73e35";

    [_player playWithModel:model];
}

- (IBAction)video:(id)sender {
    VideoModel *model = [VideoModel new];
    model.title = @"hello tv";
    model.url =
    @"http://vip888.kuyun99.com/20180802/wcFfyu0v/index.m3u8?sign=9a2f77b13159249164e257ed7356dab84549a9f7b9a70e5509bc3e0359cdcfd7a258b5708ab7d87677196d08cb14c397bce8db18e488383ddf21376648d73e35";
    //@"http://e1.vdowowza.vip.hk1.tvb.com/tvblive/smil:mobilehd_financeintl.smil/playlist.m3u8";
    //@"http://onair.onair.network:8068/listen.pls";
    
    [_player playWithModel:model];
}


@end
