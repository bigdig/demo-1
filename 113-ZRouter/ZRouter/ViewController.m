//
//  ViewController.m
//  ZRouter
//
//  Created by Jay on 7/12/2018.
//  Copyright © 2018 ZZ. All rights reserved.
//

#import "ViewController.h"

#import "ZRouter.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    [[ZRouter sharedRouter] registerPath:@"home/messagelist" actionBlock:^(ZRouterActionCallbackModel * _Nonnull callbackModel) {
//        
//    }];
    
    ZRouterURL *url = [[ZRouterURL alloc] initWithPath:@"home/messagelist" params:@{@"name":@"ca"}];
    
    ZRouterActionCallbackModel *m = [ZRouterActionCallbackModel new];
    m.url = url;

    [m setActionCallbackBlock:^(id result) {
        NSLog(@"%s", __func__);
    }];
    [[ZRouter sharedRouter] runWithActionCallbackObject:m];

}
@end
