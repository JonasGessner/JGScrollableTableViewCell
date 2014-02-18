//
//  JGTestViewController.m
//  JGScrollableTableViewCell Examples
//
//  Created by Jonas Gessner on 03.11.13.
//  Copyright (c) 2013 Jonas Gessner. All rights reserved.
//

#import "JGTestViewController.h"

#import "JGExampleScrollableTableViewCell.h"

#import "JGScrollableTableViewCellAccessoryButton.h"

@interface JGTestViewController () <JGScrollableTableViewCellDelegate,IPQJGScrollableTableViewCellDelegate> {
    NSIndexPath *_openedIndexPath;
}

@end

@implementation JGTestViewController

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        
        [self.tableView registerClass:[JGExampleScrollableTableViewCell class] forCellReuseIdentifier:@"ScrollCell"];
        
        self.title = @"-> Slide to reveal side menu";
    }
    return self;
}

#pragma mark - IPQJGScrollableTableViewCellDelegate
-(void)swipTableViewCellLeftButton:(JGScrollableTableViewCell*)swipeTableViewCell{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:swipeTableViewCell];
    NSLog(@"indexpath = %d",indexPath.row);
    NSLog(@"Left Button is pressed");
}
-(void)swipTableViewCellRightButton:(JGScrollableTableViewCell*)swipeTableViewCell{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:swipeTableViewCell];
    NSLog(@"indexpath = %d",indexPath.row);
    NSLog(@"Right Button is pressed");
}

#pragma mark - JGScrollableTableViewCellDelegate

- (void)cellDidBeginScrolling:(JGScrollableTableViewCell *)cell {
    [JGScrollableTableViewCellManager closeAllCellsWithExceptionOf:cell stopAfterFirst:YES];
}

- (void)cellDidScroll:(JGScrollableTableViewCell *)cell {
    [JGScrollableTableViewCellManager closeAllCellsWithExceptionOf:cell stopAfterFirst:YES];
}

- (void)cellDidEndScrolling:(JGScrollableTableViewCell *)cell {
    if (cell.optionViewVisible) {
        _openedIndexPath = [self.tableView indexPathForCell:cell];
    }
    else {
        _openedIndexPath = nil;
    }
    
    [JGScrollableTableViewCellManager closeAllCellsWithExceptionOf:cell stopAfterFirst:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 99;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *const CellIdentifier = @"ScrollCell";
    
    JGExampleScrollableTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    [cell setGrabberVisible:((indexPath.row % 3) == 0)];
    
    cell.scrollDelegate = self;
    
    cell.ipqDelegate = self;
    
    [cell setOptionViewVisible:[_openedIndexPath isEqual:indexPath]];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Selected Index Path %@", indexPath);
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
