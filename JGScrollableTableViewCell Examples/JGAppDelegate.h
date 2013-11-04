//
//  JGAppDelegate.h
//  JGScrollableTableViewCell Examples
//
//  Created by Jonas Gessner on 03.11.13.
//  Copyright (c) 2013 Jonas Gessner. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JGTextViewController;

@interface JGAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) JGTextViewController *mainViewController;
@property (nonatomic, strong) UINavigationController *mainNavigationController;

@end
