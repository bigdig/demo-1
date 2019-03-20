//
//  ViewController.m
//  11
//
//  Created by Jay on 20/3/2019.
//  Copyright © 2019 AA. All rights reserved.
//

#import "ViewController.h"

#import <Api.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [Api registerAppKey:@"mcdfdgq4363731453637"];

}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [[Api shareApi] postRequest:@"http://127.0.0.1/app/public/api/send" parameters:@{@"debug5":@(99),@"email":@"970151336@qq.com",@"json8":@"55"} success:^(id respones) {
        NSLog(@"%s", __func__);
    } failure:^(NSError *error) {
       NSLog(@"%s", __func__);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
