//
//  JGAppDelegate.h
//  JGScrollableTableViewCell Advanced
//
//  Created by Jonas Gessner on 21.12.13.
//  Copyright (c) 2013 Jonas Gessner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMDrawerController.h"

@interface JGAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) MMDrawerController *drawerController;

@end
