//
//  JGScrollableTableViewCell.h
//  JGScrollableTableViewCell
//
//  Created by Jonas Gessner on 03.11.13.
//  Copyright (c) 2013 Jonas Gessner. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kJGScrollableTableViewCellVersion @"1.0"

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

/**
 Cell with scrollable content and an option view that is revealed when scrolling on the cell.
 */
@interface JGScrollableTableViewCell : UITableViewCell


//Scroll view properties

/**
 Insets the scroll view. Useful for displaying a border around the scroll area (when also setting \c contentView.backgroundColor)
 */
@property (nonatomic, assign) UIEdgeInsets scrollViewInsets;


/**
 Sets the background color of the visible scroll area.
 */
@property (nonatomic, strong) UIColor *scrollViewBackgroundColor;


/**
 Sets the bouncing behaviour of the scroll area.
 */
@property (nonatomic, assign) BOOL scrollViewBounces;


/**
 An instance conforming to the \c JGScrollableTableViewCellDelegate protocol.
 */
@property (nonatomic, weak) id <JGScrollableTableViewCellDelegate> scrollDelegate;


/**
 @warning When the cell is selected or highlighted the scroll view won't be able to scroll. (This shouldn't be a problem anyway)
 @return If the user is currently dragging the scroll view.
 */
@property (nonatomic, assign, readonly) BOOL scrolling;



//Opened sides

/**
 @return The current visible state of the option view.
 */
@property (nonatomic, assign) BOOL optionViewVisible;


/**
 Sets the current state of the option view with an optional animation of 0.3 seconds.
 */
- (void)setOptionViewVisible:(BOOL)optionViewVisible animated:(BOOL)animated;



//Views

/**
 The option view is set with the \c setOptionView:side: method.
 @return The option view.
 */
@property (nonatomic, strong, readonly) UIView *optionView;


/**
 A view to use as a grabber for the scroll view. This view is static, so it won't be resized at all by the cell. If this view is \c nil then the entire area of the scroll view is scrollable, if this view is set then scrolling can only be performed on this view.
 */
@property (nonatomic, strong) UIView *grabberView;


/**
 Sets a new option view & removes the old option view.
 @param view The option view to add. The view's width should be set, all ofther frame paramaters are ignored.
 @param side The side on which the view should be placed. Either left or right.
 */
- (void)setOptionView:(UIView *)view side:(JGScrollableTableViewCellSide)side;


/**
 Adds a view to the scrolling area of the cell.
 @param view The view to add.
 */
- (void)addContentView:(UIView *)view;



//Custom touch handling


/**
 Invoked when the scroll view scrolls. Can be used to add custom behavior to the scroll view.
 */
 @property (nonatomic, copy) void (^scrollViewDidScrollBlock)(JGScrollableTableViewCell *cell, UIScrollView *scrollView);


/**
 Custom handling of other gesture recognizers. The block should return whether the scroll view should scroll while another gesture recognizer is recognized.
 */
 @property (nonatomic, copy) BOOL (^shouldRecognizeSimultaneouslyWithGestureRecognizerBlock)(JGScrollableTableViewCell *cell, UIGestureRecognizer *otherGestureRecognizer, UIScrollView *scrollView);

@end



/**
 Manage the state of all \c JGScrollableTableViewCells in a \c UITableView
 */
@interface JGScrollableTableViewCellManager : NSObject

/**
 Closes all option views in the \c UITableView containing \c cell.
 @param cell The cell that should not be closed.
 @param stop A flag that can increase performance by stopping the enumeration of cells after the first cell with an opened option view has been found. Set this flag to \c YES when you have set up the \c JGScrollableTableViewCellDelegate to only allow one opened option view at a time.
 */
+ (void)closeAllCellsWithExceptionOf:(JGScrollableTableViewCell *)cell stopAfterFirst:(BOOL)stop;

@end
