//
//  JGTextViewController.m
//  JGScrollableTableViewCell Examples
//
//  Created by Jonas Gessner on 03.11.13.
//  Copyright (c) 2013 Jonas Gessner. All rights reserved.
//

#import "JGTextViewController.h"

#import "JGScrollableTableViewCell.h"
#import "JGScrollableTableViewCellAccessoryButton.h"

@interface JGTextViewController () <JGScrollableTableViewCellDelegate> {
    NSIndexPath *_openedIndexPath;
}

@end

@implementation JGTextViewController

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        [self.tableView registerClass:[JGScrollableTableViewCell class] forCellReuseIdentifier:@"ScrollCell"];
    }
    return self;
}



#pragma mark - JGScrollableTableViewCellDelegate

- (void)cellDidBeginScrolling:(JGScrollableTableViewCell *)cell {
    [JGScrollableTableViewCellManager closeAllCellsWithExceptionOf:cell];
}

- (void)cellDidScroll:(JGScrollableTableViewCell *)cell {
    [JGScrollableTableViewCellManager closeAllCellsWithExceptionOf:cell];
}

- (void)cellDidEndScrolling:(JGScrollableTableViewCell *)cell {
    if (cell.optionViewVisible) {
        _openedIndexPath = [self.tableView indexPathForCell:cell];
    }
    else {
        _openedIndexPath = nil;
    }
    
    [JGScrollableTableViewCellManager closeAllCellsWithExceptionOf:cell];
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
    JGScrollableTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    [cell setScrollViewBackgroundColor:[UIColor colorWithWhite:0.975f alpha:1.0f]];
    [cell setScrollViewInsets:UIEdgeInsetsMake(0.0f, 1.0f, 1.0f, 1.0f)];
    cell.contentView.backgroundColor = [UIColor colorWithWhite:0.7f alpha:1.0f];
    
    JGScrollableTableViewCellAccessoryButton *optionView = [JGScrollableTableViewCellAccessoryButton button];
    [optionView setButtonColor:[UIColor colorWithRed:0.975f green:0.0f blue:0.0f alpha:1.0f] forState:UIControlStateNormal];
    [optionView setButtonColor:[UIColor colorWithRed:0.8f green:0.1f blue:0.1f alpha:1.0f] forState:UIControlStateHighlighted];
    
    [optionView setTitle:@"Action" forState:UIControlStateNormal];
    
    optionView.frame = CGRectMake(0.0f, 0.0f, 80.0f, 0.0f); //width is the only frame parameter that needs to be set on the option view
    
    [cell setOptionView:optionView side:JGScrollableTableViewCellSideRight];
    
    cell.scrollDelegate = self;

    [cell setOptionViewVisible:[_openedIndexPath isEqual:indexPath]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Selected Index Path %@", indexPath);
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Deselected Index Path %@", indexPath);
}

@end
