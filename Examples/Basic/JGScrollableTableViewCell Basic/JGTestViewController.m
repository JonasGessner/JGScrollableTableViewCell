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

@interface JGTestViewController () <JGScrollableTableViewCellDelegate> {
    NSIndexPath *_openedIndexPath;
    BOOL _left;
}

@end

@implementation JGTestViewController

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        
        [self.tableView registerClass:[JGExampleScrollableTableViewCell class] forCellReuseIdentifier:@"ScrollCell"];
        
        UISwitch *s = [[UISwitch alloc] init];
        [s addTarget:self action:@selector(switched:) forControlEvents:UIControlEventValueChanged];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:s];
        
        self.title = @"Option view on the left->";
    }
    return self;
}


- (void)switched:(UISwitch *)sender {
    _left = sender.on;
    [self.tableView reloadData];
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
    
    [cell setOptionView:cell.optionView side:(_left ? JGScrollableTableViewCellSideLeft : JGScrollableTableViewCellSideRight)];
    
    cell.scrollDelegate = self;
    
    [cell setOptionViewVisible:[_openedIndexPath isEqual:indexPath]];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Selected Index Path %@", indexPath);
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
