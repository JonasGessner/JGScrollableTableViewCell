//
//  JGTestViewController.m
//  JGScrollableTableViewCell Examples
//
//  Created by Jonas Gessner on 03.11.13.
//  Copyright (c) 2013 Jonas Gessner. All rights reserved.
//

#import "JGTestViewController.h"

#import "JGScrollableTableViewCell.h"
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
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        [self.tableView registerClass:[JGScrollableTableViewCell class] forCellReuseIdentifier:@"ScrollCell"];
        
        UISwitch *s = [[UISwitch alloc] init];
        [s addTarget:self action:@selector(switched:) forControlEvents:UIControlEventValueChanged];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:s];
        
        self.title = @"Option view on the left->";
        
        printf("NOTE: Real world implementations should use subclasses of JGScrollableTableViewCell to manage and display more content in the cell\n");
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
    
    JGScrollableTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    //this is actually a terrible implementation of JGScrollableTableViewCell, it kills performance. But it shows nicely how to use the class. In real implementations use custom subclasses of JGScrollableTableViewCell that handle content views & properties internally.
    
    [cell setScrollViewBackgroundColor:[UIColor colorWithWhite:0.975f alpha:1.0f]];
    [cell setScrollViewInsets:UIEdgeInsetsMake(0.0f, 1.0f, 1.0f, 1.0f)];
    cell.contentView.backgroundColor = [UIColor colorWithWhite:0.7f alpha:1.0f];
    
    JGScrollableTableViewCellAccessoryButton *actionView = [JGScrollableTableViewCellAccessoryButton button];
    
    [actionView setButtonColor:[UIColor colorWithRed:0.975f green:0.0f blue:0.0f alpha:1.0f] forState:UIControlStateNormal];
    [actionView setButtonColor:[UIColor colorWithRed:0.8f green:0.1f blue:0.1f alpha:1.0f] forState:UIControlStateHighlighted];
    
    [actionView setTitle:@"Sample" forState:UIControlStateNormal];
    
    actionView.frame = CGRectMake(80.0f, 0.0f, 80.0f, 0.0f); //width is the only frame parameter that needs to be set on the option view
    actionView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
    
    JGScrollableTableViewCellAccessoryButton *moreView = [JGScrollableTableViewCellAccessoryButton button];
    
    [moreView setButtonColor:[UIColor colorWithWhite:0.8f alpha:1.0f] forState:UIControlStateNormal];
    [moreView setButtonColor:[UIColor colorWithWhite:0.65f alpha:1.0f] forState:UIControlStateHighlighted];
    
    [moreView setTitle:@"Sample" forState:UIControlStateNormal];
    
    moreView.frame = CGRectMake(0.0f, 0.0f, 80.0f, 0.0f); //width is the only frame parameter that needs to be set on the option view
    moreView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
    
    UIView *optionView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 160.0f, 0.0f)];
    
    [optionView addSubview:moreView];
    [optionView addSubview:actionView];
    
    if ((indexPath.row % 3) == 0) {
        UIView *grabber = [[UIView alloc] initWithFrame:(CGRect){CGPointZero, {20.0f, 35.0f}}];
        
        UIView *dot1 = [[UIView alloc] initWithFrame:(CGRect){{10.0f, 5.0f}, {5.0f, 5.0f}}];
        
        UIView *dot2 = [[UIView alloc] initWithFrame:(CGRect){{10.0f, 15.0f}, {5.0f, 5.0f}}];
        
        UIView *dot3 = [[UIView alloc] initWithFrame:(CGRect){{10.0f, 25.0f}, {5.0f, 5.0f}}];
        
        dot1.backgroundColor = [UIColor colorWithWhite:0.6f alpha:1.0f];
        dot2.backgroundColor = [UIColor colorWithWhite:0.6f alpha:1.0f];
        dot3.backgroundColor = [UIColor colorWithWhite:0.6f alpha:1.0f];
        
        [grabber addSubview:dot1];
        [grabber addSubview:dot2];
        [grabber addSubview:dot3];
        
        [cell setGrabberView:grabber];
    }
    else {
        [cell setGrabberView:nil];
    }
    
    [cell setOptionView:optionView side:(_left ? JGScrollableTableViewCellSideLeft : JGScrollableTableViewCellSideRight)];
    
    cell.scrollDelegate = self;

    [cell setOptionViewVisible:[_openedIndexPath isEqual:indexPath]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Selected Index Path %@", indexPath);
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
