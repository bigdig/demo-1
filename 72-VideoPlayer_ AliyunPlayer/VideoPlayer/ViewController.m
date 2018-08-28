//
//  ViewController.m
//  VideoPlayer
//
//  Created by Jay on 12/5/18.
//  Copyright © 2018年 Jay. All rights reserved.
//

#import "ViewController.h"
#import "Player/PlayerView.h"

@interface ViewController ()
@property (nonatomic, weak) PlayerView *player;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    VideoModel *model = [VideoModel new];
    model.title = @"hello tv";
//    model.live_stream = [NSURL fileURLWithPath:@"/Users/jay/Downloads/20180503102411_460.mp4"];
    model.url = @"http://vip888.kuyun99.com/20180802/wcFfyu0v/index.m3u8?sign=9a2f77b13159249164e257ed7356dab84549a9f7b9a70e5509bc3e0359cdcfd7a258b5708ab7d87677196d08cb14c397bce8db18e488383ddf21376648d73e35";
//    model.live_stream = @"http://e1.vdowowza.vip.hk1.tvb.com/tvblive/smil:mobilehd_financeintl.smil/playlist.m3u8";
//    model.live_stream = @"http://onair.onair.network:8068/listen.pls";
    
    PlayerView *player = [PlayerView playerView];
    player.allowSafariPlay = YES;
    player.frame = CGRectMake(0, 64, 320, 200);
    [player playWithModel:model];
    [self.view addSubview:player];
    _player = player;
}
- (IBAction)living:(id)sender {
    VideoModel *model = [VideoModel new];
    model.title = @"hello tv";
    //    model.live_stream = [NSURL fileURLWithPath:@"/Users/jay/Downloads/20180503102411_460.mp4"];
    //model.url = @"http://vip888.kuyun99.com/20180802/wcFfyu0v/index.m3u8?sign=9a2f77b13159249164e257ed7356dab84549a9f7b9a70e5509bc3e0359cdcfd7a258b5708ab7d87677196d08cb14c397bce8db18e488383ddf21376648d73e35";
    model.url = @"http://210.210.155.35/session/1e5fe170-829b-11e8-9d75-c81f66f89318/qwr9ew/s/s33/02.m3u8";
    //    model.live_stream = @"http://onair.onair.network:8068/listen.pls";
    
    [_player playWithModel:model];
}

- (IBAction)video:(id)sender {
    VideoModel *model = [VideoModel new];
    model.title = @"hello tv";
    //    model.live_stream = [NSURL fileURLWithPath:@"/Users/jay/Downloads/20180503102411_460.mp4"];
    model.url = @"http://vip888.kuyun99.com/20180802/wcFfyu0v/index.m3u8?sign=9a2f77b13159249164e257ed7356dab84549a9f7b9a70e5509bc3e0359cdcfd7a258b5708ab7d87677196d08cb14c397bce8db18e488383ddf21376648d73e35";
    //    model.live_stream = @"http://e1.vdowowza.vip.hk1.tvb.com/tvblive/smil:mobilehd_financeintl.smil/playlist.m3u8";
    //    model.live_stream = @"http://onair.onair.network:8068/listen.pls";
    
    [_player playWithModel:model];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
