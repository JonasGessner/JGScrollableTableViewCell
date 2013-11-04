//
//  JGScrollableTableViewCell.h
//  ProTube 2
//
//  Created by Jonas Gessner on 03.11.13.
//  Copyright (c) 2013 Jonas Gessner. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JGScrollableTableViewCell;

@protocol JGScrollableTableViewCellDelegate <NSObject>

@optional
- (void)cellDidBeginScrolling:(JGScrollableTableViewCell *)cell;
- (void)cellDidScroll:(JGScrollableTableViewCell *)cell;
- (void)cellDidEndScrolling:(JGScrollableTableViewCell *)cell;

@end

typedef NS_ENUM(BOOL, JGScrollableTableViewCellSide) {
    JGScrollableTableViewCellSideLeft = NO,
    JGScrollableTableViewCellSideRight = YES
};

@interface JGScrollableTableViewCell : UITableViewCell

//scroll view peoperties
/**
 Insets the scroll view. Useful for displaying a border around the scroll area (when also setting \c contentView.backgroundColor)
 */
@property (nonatomic, assign) UIEdgeInsets scrollViewInsets;


/**
 Sets the background color of the visible scroll area.
 */
- (void)setScrollViewBackgroundColor:(UIColor *)scrollViewBackgroundColor;


/**
 An instance conforming to the \c JGScrollableTableViewCellDelegate protocol.
 */
@property (nonatomic, weak) id <JGScrollableTableViewCellDelegate> scrollDelegate;


/**
 @warning When the cell is selected or highlighted the scroll view won't be able to scroll. (This shouldn't be a problem anyway)
 @return If the user is currently dragging the scroll view.
 */
@property (nonatomic, assign, readonly) BOOL scrolling;


//opened sides
/**
 The current state of the option view.
 @return If the option view is visible.
 */
@property (nonatomic, assign) BOOL optionViewVisible;


/**
 Sets the current state of the option view with an optional animation of 0.3 seconds.
 */
- (void)setOptionViewVisible:(BOOL)optionViewVisible animated:(BOOL)animated;


//views
/**
 @return The option view.
 */
@property (nonatomic, strong, readonly) UIView *optionView;


/**
 Sets & removes the old option view.
 @param view The option view to add. The view's width should be set, all ofther frame paramaters are ignored.
 @param side The side on which the view should be placed. Either left or right.
 */
- (void)setOptionView:(UIView *)view side:(JGScrollableTableViewCellSide)side;


/**
 Add a view to the scrolling area of the cell.
 @param view The view to add.
 */
- (void)addContentView:(UIView *)view;

@end


@interface JGScrollableTableViewCellManager : NSObject

/**
 Closes all optin views in \c Cell's UITableView.
 @param cell The cell that should not be closed.
 */
+ (void)closeAllCellsWithExceptionOf:(JGScrollableTableViewCell *)cell;

@end