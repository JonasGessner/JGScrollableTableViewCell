//
//  JGScrollableTableViewCell.m
//  JGScrollableTableViewCell
//
//  Created by Jonas Gessner on 03.11.13.
//  Copyright (c) 2013 Jonas Gessner. All rights reserved.
//

#import "JGScrollableTableViewCell.h"

@protocol JGTouchForwarder <NSObject>

- (void)forwardTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)forwardTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)forwardTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)forwardTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;

@end

@protocol JGViewProvider <NSObject>

- (UIView *)scrollViewCoverView;
- (UITableView *)parentTableView;

@end


@interface JGScrollableTableViewCellScrollView : UIScrollView <UIGestureRecognizerDelegate>

@property (nonatomic, weak) JGScrollableTableViewCell <JGTouchForwarder, JGViewProvider> *parentCell;

@end

@implementation JGScrollableTableViewCellScrollView


- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hit = [super hitTest:point withEvent:event];
    if (hit == self) {
        if (CGRectContainsPoint(self.parentCell.optionView.frame, [self convertPoint:point toView:self.parentCell])) {
            return [self.parentCell.optionView hitTest:[self convertPoint:point toView:self.parentCell.optionView] withEvent:event];
        }
        else {
            return self;
        }
    }
    else {
        return hit;
    }
}

- (NSArray *)subviews {
    UIView *v = [self.parentCell scrollViewCoverView];
    if (v) {
        return @[v];
    }
    else {
        return nil;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.parentCell forwardTouchesBegan:touches withEvent:event];
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.parentCell forwardTouchesMoved:touches withEvent:event];
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.parentCell forwardTouchesEnded:touches withEvent:event];
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.parentCell forwardTouchesCancelled:touches withEvent:event];
    [super touchesCancelled:touches withEvent:event];
}

@end



@interface JGScrollableTableViewCellManager ()

+ (void)referenceCell:(JGScrollableTableViewCell *)cell inView:(UIView *)host;
+ (void)removeCellReference:(JGScrollableTableViewCell *)cell inView:(UIView *)host;

+ (NSSet *)allCellsInTableView:(UITableView *)host;


@end

@implementation JGScrollableTableViewCellManager

static NSMutableDictionary *_refs;

+ (void)closeAllCellsWithExceptionOf:(JGScrollableTableViewCell *)cell stopAfterFirst:(BOOL)stop {
    UITableView *host = (UITableView *)cell.superview;
    NSSet *cells = [self allCellsInTableView:host];
    
    for (JGScrollableTableViewCell *otherCell in cells) {
        if (otherCell != cell) {
            if (otherCell.isScrolling || otherCell.optionViewVisible) {
                [otherCell setOptionViewVisible:NO animated:YES];
                if (stop) {
                    break;
                }
            }
        }
    }
}

+ (void)removeCellReference:(JGScrollableTableViewCell *)cell inView:(UIView *)host {
    if (!host) {
        return;
    }
    NSAssert([NSThread isMainThread], @"JGScrollableTableViewCellManager should only be used on the main thread");
    
    NSValue *key = [NSValue valueWithNonretainedObject:host];
    
    NSMutableSet *hostCells = _refs[key];
    
    [hostCells removeObject:cell];
    
    if (hostCells.count) {
        _refs[key] = hostCells;
    }
    else {
        [_refs removeObjectForKey:key];
    }
}

+ (void)referenceCell:(JGScrollableTableViewCell *)cell inView:(UIView *)host {
    if (!host) {
        return;
    }
    NSAssert([NSThread isMainThread], @"JGScrollableTableViewCellManager should only be used on the main thread");
    
    if (!_refs) {
        _refs = [NSMutableDictionary dictionary];
    }
    
    NSValue *key = [NSValue valueWithNonretainedObject:host];
    
    NSMutableSet *hostCells = _refs[key];
    if (!hostCells) {
        hostCells = [NSMutableSet set];
    }
    
    [hostCells addObject:cell];
    
    _refs[key] = hostCells;
}

+ (NSSet *)allCellsInTableView:(UITableView *)host {
    NSAssert([NSThread isMainThread], @"JGScrollableTableViewCellManager should only be used on the main thread");
    NSValue *key = [NSValue valueWithNonretainedObject:host];
    return [_refs[key] copy];
}

@end


#define kJGScrollableTableViewCellAnimationDuration 0.3

@interface JGScrollableTableViewCell () <JGTouchForwarder, JGViewProvider, UIScrollViewDelegate> {
    BOOL _forceRelayout;
    BOOL _cancelCurrentForwardedGesture;
    
    BOOL _scrolling;
    BOOL _scrollingHasEnded;
    
    NSUInteger _ignoreScrollEvents;
    
    __weak UIView *_hostingView;
}

@property (nonatomic, strong, readonly) UIView *scrollViewCoverView;

@end

@implementation JGScrollableTableViewCell


#pragma mark - Initialization

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _scrollView = [[JGScrollableTableViewCellScrollView alloc] init];
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.showsHorizontalScrollIndicator = NO;
        ((JGScrollableTableViewCellScrollView *)_scrollView).parentCell = self;
        _scrollView.delegate = self;
        _scrollView.pagingEnabled = YES;
        _scrollView.scrollsToTop = NO;
        
        _scrollViewCoverView = [[UIView alloc] init];
        [_scrollView addSubview:_scrollViewCoverView];
        
        [self.contentView addSubview:_scrollView];
    }
    return self;
}

#pragma mark - Delegates

- (UITableView *)parentTableView {
    UIView *sup = self.superview;
    
    while (sup != nil && ![sup isKindOfClass:[UITableView class]]) {
        sup = sup.superview;
    }
    
    return (UITableView *)sup;
}

- (void)forwardTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.isScrolling && !self.optionViewVisible) {
        if (self.grabberView && CGRectContainsPoint(self.grabberView.bounds, [touches.anyObject locationInView:self.grabberView])) {
            _cancelCurrentForwardedGesture = YES;
        }
        else {
            _cancelCurrentForwardedGesture = NO;
            [self touchesBegan:touches withEvent:event];
        }
    }
}

- (void)forwardTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.isScrolling && !self.optionViewVisible && !_cancelCurrentForwardedGesture) {
        [self touchesCancelled:touches withEvent:event];
    }
}

- (void)forwardTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.isScrolling && !self.optionViewVisible && !_cancelCurrentForwardedGesture) {
        [self touchesEnded:touches withEvent:event];
    }
    else if (self.optionViewVisible) {
        __weak __typeof(self) weakSelf = self;
        
        [self setOptionViewVisible:NO animationDuration:kJGScrollableTableViewCellAnimationDuration completion:^{
            if ([weakSelf.scrollDelegate respondsToSelector:@selector(cellDidEndScrolling:)]) {
                [weakSelf.scrollDelegate cellDidEndScrolling:weakSelf];
            }
        }];
    }
}

- (void)forwardTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.isScrolling && !self.optionViewVisible && !_cancelCurrentForwardedGesture) {
        [self touchesCancelled:touches withEvent:event];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (_ignoreScrollEvents) {
        return;
    }
    
    if (!_scrolling) {
        if (!_scrollingHasEnded && (self.selected || self.highlighted || (self.grabberView && !self.optionViewVisible && !CGRectContainsPoint(self.grabberView.bounds, [_scrollView.panGestureRecognizer locationInView:self.grabberView])))) {
            _scrollView.panGestureRecognizer.enabled = NO;
            _scrollView.panGestureRecognizer.enabled = YES;
        }
        else {
            _scrolling = YES;
            if ([self.scrollDelegate respondsToSelector:@selector(cellDidBeginScrolling:)]) {
                [self.scrollDelegate cellDidBeginScrolling:self];
            }
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)__unused scrollView {
    if (_ignoreScrollEvents) {
        return;
    }
    
    if (_scrolling) {
        if ([self.scrollDelegate respondsToSelector:@selector(cellDidScroll:)]) {
            [self.scrollDelegate cellDidScroll:self];
        }
        
        if (self.scrollViewDidScrollBlock) {
            self.scrollViewDidScrollBlock(self, _scrollView);
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (_ignoreScrollEvents) {
        return;
    }
    
    _scrollingHasEnded = decelerate;
    _scrolling = NO;
    
    if (!decelerate) {
        _optionViewVisible = (_scrollView.contentOffset.x != 0.0f);
        
        if ([self.scrollDelegate respondsToSelector:@selector(cellDidEndScrolling:)]) {
            [self.scrollDelegate cellDidEndScrolling:self];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)__unused scrollView {
    if (_ignoreScrollEvents) {
        return;
    }
    
    _scrolling = NO;
    _scrollingHasEnded = NO;
    
    _optionViewVisible = (_scrollView.contentOffset.x != 0.0f);
    
    if ([self.scrollDelegate respondsToSelector:@selector(cellDidEndScrolling:)]) {
        [self.scrollDelegate cellDidEndScrolling:self];
    }
}


#pragma mark - Overrides

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    
    if (newSuperview) {
        _hostingView = newSuperview;
        
        [JGScrollableTableViewCellManager referenceCell:self inView:_hostingView];
    }
    else if (_hostingView) {
        [JGScrollableTableViewCellManager removeCellReference:self inView:_hostingView];
    }
}

- (CGRect)contentBounds {
    return self.contentView.bounds;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (!self.isScrolling) {
        CGRect scrollViewFrame = UIEdgeInsetsInsetRect(self.contentBounds, self.scrollViewInsets);
        
        _ignoreScrollEvents++;
        
        _scrollView.frame = scrollViewFrame;
        
        _scrollView.contentSize = (CGSize){scrollViewFrame.size.width+self.optionView.frame.size.width, scrollViewFrame.size.height};
        
        _scrollViewCoverView.frame = (CGRect){CGPointZero, scrollViewFrame.size};
        
        if (self.grabberView) {
            CGSize grabberSize = self.grabberView.frame.size;
            
            self.grabberView.frame = (CGRect){{scrollViewFrame.size.width-grabberSize.width, (scrollViewFrame.size.height-grabberSize.height)/2.0f}, grabberSize};
        }
        
        CGSize size = (CGSize){self.optionView.frame.size.width, scrollViewFrame.size.height};
        
        self.optionView.frame = (CGRect){{CGRectGetMaxX(scrollViewFrame)-self.optionView.frame.size.width, 0.0f}, size};
        
        
        _forceRelayout = YES; //enusres that next call is actually executed
        [self setOptionViewVisible:self.optionViewVisible]; //sets correct contentOffset
        _forceRelayout = NO;
        
        _ignoreScrollEvents--;
    }
}

#pragma mark - Getters

- (BOOL)isScrolling {
    return (_scrolling || _scrollingHasEnded);
}

#pragma mark - Setters

- (void)setOptionViewVisible:(BOOL)optionViewVisible animated:(BOOL)animated {
    [self setOptionViewVisible:optionViewVisible animationDuration:(animated ? kJGScrollableTableViewCellAnimationDuration : 0.0) completion:NULL];
}

- (void)setOptionViewVisible:(BOOL)optionViewVisible animationDuration:(NSTimeInterval)duration completion:(void (^)(void))completion {
    if (!_forceRelayout && _optionViewVisible == optionViewVisible && !self.isScrolling) {
        return;
    }
    
    _scrolling = NO;
    _scrollingHasEnded = NO;
    
    _optionViewVisible = optionViewVisible;
    
    _ignoreScrollEvents++;
    
    CGPoint scrollDestination;
    
    scrollDestination = (CGPoint){(_optionViewVisible ? _scrollView.contentSize.width-1.0f : 0.0f), 0.0f};
    
    [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState animations:^{
        [_scrollView.panGestureRecognizer setEnabled:NO];
        [_scrollView scrollRectToVisible:(CGRect){scrollDestination, {1.0f, 1.0f}} animated:NO];
    } completion:^(__unused BOOL finished) {
        [_scrollView.panGestureRecognizer setEnabled:YES];
        _ignoreScrollEvents--;
        
        if (completion) {
            completion();
        }
    }];
}

- (void)setOptionViewVisible:(BOOL)optionViewVisible {
    [self setOptionViewVisible:optionViewVisible animated:NO];
}

- (void)setGrabberView:(UIView *)grabberView {
    [self.grabberView removeFromSuperview];
    
    _grabberView = grabberView;
    
    if (self.grabberView) {
        [_scrollView addSubview:self.grabberView];
        
        [self setNeedsLayout];
        [self layoutIfNeeded];
    }
}

- (void)setOptionView:(UIView *)view {
    [self.optionView removeFromSuperview];
    
    _optionView = view;
    
    [self.contentView insertSubview:self.optionView belowSubview:_scrollView];
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)setScrollViewBackgroundColor:(UIColor *)scrollViewBackgroundColor {
    _scrollViewBackgroundColor = scrollViewBackgroundColor;
    
    _scrollViewCoverView.backgroundColor = scrollViewBackgroundColor;
    self.backgroundColor = scrollViewBackgroundColor;
}

- (void)setScrollViewInsets:(UIEdgeInsets)scrollViewInsets {
    _scrollViewInsets = scrollViewInsets;
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)addContentView:(UIView *)view {
    [_scrollViewCoverView addSubview:view];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    void (^actions)(BOOL select) = ^(BOOL select) {
        _optionView.hidden = select;
        _scrollView.scrollEnabled = !select;
    };
    
    if (highlighted) {
        actions(highlighted);
    }
    
    id previousBlock = [CATransaction completionBlock];
    
    [CATransaction setCompletionBlock:^{
        actions(highlighted);
    }];
    
    [super setHighlighted:highlighted animated:animated];
    
    self.backgroundColor = self.scrollViewBackgroundColor;
    
    [CATransaction setCompletionBlock:previousBlock];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    void (^actions)(BOOL select) = ^(BOOL select) {
        _optionView.hidden = select;
        _scrollView.scrollEnabled = !select;
    };
    
    if (selected) {
        actions(selected);
    }
    
    id previousBlock = [CATransaction completionBlock];
    
    [CATransaction setCompletionBlock:^{
        actions(selected);
    }];
    
    [super setSelected:selected animated:animated];
    
    self.backgroundColor = self.scrollViewBackgroundColor;
    
    [CATransaction setCompletionBlock:previousBlock];
}

#pragma mark - Dealloc

- (void)dealloc {
    [JGScrollableTableViewCellManager removeCellReference:self inView:_hostingView];
}

@end
