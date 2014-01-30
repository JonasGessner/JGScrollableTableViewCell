//
//  JGExampleScrollableTableViewCell.m
//  JGScrollableTableViewCell Basic
//
//  Created by Jonas Gessner on 21.12.13.
//  Copyright (c) 2013 Jonas Gessner. All rights reserved.
//

#import "JGExampleScrollableTableViewCell.h"
#import "JGScrollableTableViewCellAccessoryButton.h"

@implementation JGExampleScrollableTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setScrollViewBackgroundColor:[UIColor colorWithWhite:0.975f alpha:1.0f]];
        self.contentView.backgroundColor = [UIColor grayColor];
        
        JGScrollableTableViewCellAccessoryButton *actionView = [JGScrollableTableViewCellAccessoryButton button];
        
        [actionView setButtonColor:[UIColor colorWithRed:0.975f green:0.0f blue:0.0f alpha:1.0f] forState:UIControlStateNormal];
        [actionView setButtonColor:[UIColor colorWithRed:0.8f green:0.1f blue:0.1f alpha:1.0f] forState:UIControlStateHighlighted];
        
        [actionView setTitle:@"Sample" forState:UIControlStateNormal];
        
        CGFloat width = 80.0f;
        
        actionView.frame = CGRectMake(width, 0.0f, width, 0.0f); //width is the only frame parameter that needs to be set on the option view
        actionView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        
        
        JGScrollableTableViewCellAccessoryButton *moreView = [JGScrollableTableViewCellAccessoryButton button];
        
        [moreView setButtonColor:[UIColor colorWithWhite:0.8f alpha:1.0f] forState:UIControlStateNormal];
        [moreView setButtonColor:[UIColor colorWithWhite:0.65f alpha:1.0f] forState:UIControlStateHighlighted];
        
        [moreView setTitle:@"Sample" forState:UIControlStateNormal];
        
        moreView.frame = CGRectMake(0.0f, 0.0f, width, 0.0f); //width is the only frame parameter that needs to be set on the option view
        moreView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        
        
        UIView *optionView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, width*2.0f, 0.0f)];
        optionView.clipsToBounds = YES;
        
        [optionView addSubview:moreView];
        [optionView addSubview:actionView];
        
        [self setOptionView:optionView];
        
        
        //Custom Touch handling:
        [self setShouldRecognizeSimultaneouslyWithGestureRecognizerBlock:^BOOL (JGScrollableTableViewCell *cell, UIGestureRecognizer *gesture, UIScrollView *scrollView) {
            if ([cell optionViewVisible]) {
                return NO;
            }
            else {
                return YES;
            }
        }];
        
        [self setScrollViewDidScrollBlock:^(JGScrollableTableViewCell *cell, UIScrollView *scrollView) {
            if (scrollView.contentOffset.x < 0.0f) {
                scrollView.panGestureRecognizer.enabled = NO;
                scrollView.panGestureRecognizer.enabled = YES;
            }
        }];
        
    }
    return self;
}

- (void)setGrabberVisible:(BOOL)visible {
    if (visible) {
        UIView *grabber = [[UIView alloc] initWithFrame:(CGRect){CGPointZero, {30.0f, 40.0f}}];
        
        UIView *dot1 = [[UIView alloc] initWithFrame:(CGRect){{15.0f, 7.5f}, {5.0f, 5.0f}}];
        
        UIView *dot2 = [[UIView alloc] initWithFrame:(CGRect){{15.0f, 17.5f}, {5.0f, 5.0f}}];
        
        UIView *dot3 = [[UIView alloc] initWithFrame:(CGRect){{15.0f, 27.5f}, {5.0f, 5.0f}}];
        
        dot1.backgroundColor = [UIColor colorWithWhite:0.6f alpha:1.0f];
        dot2.backgroundColor = [UIColor colorWithWhite:0.6f alpha:1.0f];
        dot3.backgroundColor = [UIColor colorWithWhite:0.6f alpha:1.0f];
        
        [grabber addSubview:dot1];
        [grabber addSubview:dot2];
        [grabber addSubview:dot3];
        
        [self setGrabberView:grabber];
    }
    else {
        [self setGrabberView:nil];
    }
}

@end
