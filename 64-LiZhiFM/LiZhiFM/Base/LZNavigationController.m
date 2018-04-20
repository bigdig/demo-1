//
//  LZNavigationController.m
//  LiZhiFM
//
//  Created by czljcb on 2018/4/18.
//  Copyright © 2018年 czljcb. All rights reserved.
//

#import "LZNavigationController.h"

@interface LZNavigationController ()

@end

@implementation LZNavigationController


-(void)setUI {
    self.view.backgroundColor = [UIColor whiteColor];
    [self.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont boldSystemFontOfSize:20]}];
    self.navigationBar.barTintColor = [UIColor orangeColor];
}


- (void)pop{
    [self popViewControllerAnimated:YES];
}



- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self setUI];
}


- (UIBarButtonItem *)backButtonItem{
    
    UIButton *yyzj_but = [UIButton buttonWithType:UIButtonTypeCustom];
    [yyzj_but addTarget:self action:@selector(pop) forControlEvents:UIControlEventTouchUpInside];
    [yyzj_but setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    yyzj_but.showsTouchWhenHighlighted = YES;
    [yyzj_but setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    yyzj_but.frame = CGRectMake(0, 0, 22, 44);
    //yyzj_but.backgroundColor = [UIColor blueColor];
    //[yyzj_but setImageEdgeInsets:UIEdgeInsetsMake(0, -5, 0, 0)];
    return [[UIBarButtonItem alloc] initWithCustomView:yyzj_but];
}


-(void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    if (self.childViewControllers.count >= 1){
        
        viewController.hidesBottomBarWhenPushed = YES;
        
        viewController.navigationItem.leftBarButtonItem = [self backButtonItem];
    }
    
    [super pushViewController:viewController animated:animated];
    
}


@end