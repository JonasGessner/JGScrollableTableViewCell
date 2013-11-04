//
//  JGScrollableTableViewCellAccessoryButton.m
//  JGScrollableTableViewCell Examples
//
//  Created by Jonas Gessner on 03.11.13.
//  Copyright (c) 2013 Jonas Gessner. All rights reserved.
//

#import "JGScrollableTableViewCellAccessoryButton.h"

@implementation JGScrollableTableViewCellAccessoryButton

+ (instancetype)button {
    return [[self alloc] init];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.titleLabel.shadowColor = [UIColor clearColor];
        self.titleLabel.shadowOffset = CGSizeZero;
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:17.0f];
    }
    return self;
}

- (void)setButtonColor:(UIColor *)buttonColor forState:(UIControlState)state {
    CGSize size = (CGSize){1.0f, 1.0f};
    
    UIGraphicsBeginImageContextWithOptions(size, YES, 0.0f);
    
    [buttonColor setFill];
    
    [[UIBezierPath bezierPathWithRect:(CGRect){CGPointZero, size}] fill];
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    [self setBackgroundImage:img forState:state];
}

@end
