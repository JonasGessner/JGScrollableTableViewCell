//
//  JGScrollableTableViewCellAccessoryButton.h
//  JGScrollableTableViewCell
//
//  Created by Jonas Gessner on 03.11.13.
//  Copyright (c) 2013 Jonas Gessner. All rights reserved.
//

#import <UIKit/UIKit.h>


/**
 An iOS 7 mail app inspired button. This class is \b not required when using \c JGScrollableTableViewCell.
 */
@interface JGScrollableTableViewCellAccessoryButton : UIButton

/**
 Convenience method for +alloc -init.
 @warning Always initialize \c JGScrollableTableViewCellAccessoryButton using +alloc -init, or this convenience method.
 */
+ (instancetype)button;


/**
 Sets the button's background color for a given state. This is different from \c backgroundColor because \c backgroundColor is constant and doesn't change for different selection states.
 
 @discussion Internally this uses the \c -setBackgroundImage:forState: method of \c UIButton so that should not be set manually after calling this method. To display an image use the \c -setImage:forState: method
 
 @param buttonColor The color of the button. This color fills the entire rect of the button.
 @param state The state for which to set the button's color.
 */
- (void)setButtonColor:(UIColor *)buttonColor forState:(UIControlState)state;

@end
