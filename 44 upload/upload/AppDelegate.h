//
//  AppDelegate.h
//  upload
//
//  Created by Jay on 2018/2/28.
//  Copyright © 2018年 Jay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, copy) void(^handler)(void);

@end

