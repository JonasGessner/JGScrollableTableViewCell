//
//  JGExampleScrollableTableViewCell.h
//  JGScrollableTableViewCell Basic
//
//  Created by Jonas Gessner on 21.12.13.
//  Copyright (c) 2013 Jonas Gessner. All rights reserved.
//

#import "JGScrollableTableViewCell.h"

@protocol IPQJGScrollableTableViewCellDelegate <NSObject>
@optional
-(void)swipTableViewCellLeftButton:(JGScrollableTableViewCell*)swipeTableViewCell;
-(void)swipTableViewCellRightButton:(JGScrollableTableViewCell*)swipeTableViewCell;
@end

@interface JGExampleScrollableTableViewCell : JGScrollableTableViewCell

- (void)setGrabberVisible:(BOOL)visible;

@property (nonatomic, assign) id <IPQJGScrollableTableViewCellDelegate> ipqDelegate;

@end
