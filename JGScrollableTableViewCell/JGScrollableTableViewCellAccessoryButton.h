//
//  JGScrollableTableViewCellAccessoryButton.h
//  JGScrollableTableViewCell Examples
//
//  Created by Jonas Gessner on 03.11.13.
//  Copyright (c) 2013 Jonas Gessner. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface JGScrollableTableViewCellAccessoryButton : UIButton

+ (instancetype)button;

- (void)setButtonColor:(UIColor *)buttonColor forState:(UIControlState)state;

@end
