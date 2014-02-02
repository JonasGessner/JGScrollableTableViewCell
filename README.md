<h1>JGScrollableTableViewCell</h1><h6>© 2013-2014 Jonas Gessner</h6>

----------------
<br>

JGScrollableTableViewCell is a simple and easy to use UITableViewCell subclass with a scrollable content view that exposes an accessory view when scrolled. The behavior is inspired by the iOS 7 mail app.
<br>
<br>
<b>Current Version:<b> 1.0.3
<br>
<br>
<p align="center"><img src="Demo.gif"/></p>

##Requirements

• iOS 5 or higher<br>
• Built with <b>ARC</b> (If your Xcode project doesn't use ARC then set the `-fobjc-arc` compiler flag)<br>
• Foundation, UIKit and CoreGraphics frameworks<br>


##Getting started

`JGScrollableTableViewCell` works just like any other `UITableViewCell`: Highlighting, selection, and `UITableViewDelegate` calls all work like normal. The only difference is that the cell's `contentView` is covered by a `UIScrollView` that basically becomes the new content view – which is scrollable.

An "option view" can be assigned to the cell, which is placed behind the scroll view, making it possible to scroll on the cell to reveal the option view behind it.

<b>Note:</b> You should always use custom subclasses of `JGScrollableTableViewCell` that add your custom content to the cell (ex labels & image views).

##Usage

By default `JGScrollableTableViewCell` has an empty scroll area, and no option view. Here's a guide through the entire `JGScrollableTableViewCell` class:

####The scroll view

```objc
- (UIScrollView *)scrollView;
```
Returns the scroll view used in the cell. Do not add any subviews to the scrollview or modify its frame, bounds, contentOffset or contentInset.
<br>
<br>

```objc
- (void)setScrollViewInsets:(UIEdgeInsets)scrollViewInsets;
```
Insets the scroll view. Useful for displaying a border around the scroll area (when also setting `contentView.backgroundColor`)
<br>
<br>

```objc
- (void)setScrollViewBackgroundColor:(UIColor *)scrollViewBackgroundColor;
```
Sets the background color of the scroll view. Equivalent to `contentView.backgroundColor` on a regular `UITableViewCell`.
<br>
<br>

```objc
- (BOOL)isScrolling;
```
Returns `YES` if the user is currently dragging the scroll view or if the scroll view is decelerating.
<br>
<br>

- (void)setGrabberView:(UIView *)grabberView;
```objc
 Sets a view to use as a grabber for the scroll view. This view is static, so it won't be resized at all by the cell. If this view is \c nil then the entire area of the scroll view is scrollable, if this view is set then scrolling can only be performed on this view.
```
<br>
<br>

####The option view

```objc
- (void)setOptionView:(UIView *)view ;
```
Sets a new option view & removes the old option view. The option view will be dynamically resized to fit the cell's size and the scroll view's insets. The only parameter of the option view's `frame` that is not changed is the width. The width should be set before passing the view to this method and should not be changed afterwards.
<br>
<br>

```objc
- (UIView *)optionView;
```
Returns the current option view.
<br>
<br>

```objc
- (void)setOptionViewVisible:(BOOL)optionViewVisible animated:(BOOL)animated;
```
Opens or closes the option view with an optional 0.3 second animation.
<br>
<br>

####Scrollable content

```objc
- (void)addContentView:(UIView *)view;
```
You should at no point add a view to the cell's directly or to its `contentView`. Instead, pass views that should be displayed on the cell to this method. Views passed to this method will appear in the scrollable area of the cell.
<br>
<br>

###Delegate
`JGScrollableTableViewCell` has a delegate that conforms to the `JGScrollableTableViewCellDelegate` protocol. It is used for handling scroll events.
```objc
@property (nonatomic, weak) id <JGScrollableTableViewCellDelegate> scrollDelegate;
```
<br>
<br>

The `JGScrollableTableViewCellDelegate` protocol declares three optional (self explaining) methods:
```objc
- (void)cellDidBeginScrolling:(JGScrollableTableViewCell *)cell;
- (void)cellDidScroll:(JGScrollableTableViewCell *)cell;
- (void)cellDidEndScrolling:(JGScrollableTableViewCell *)cell;
```
Ideally, your `UITableViewDelegate` should also be your `JGScrollableTableViewCellDelegate`.
<br>
<br>

##Custom Touch handling

In some special cases custom touch handling may be needed (see `Advanced` example project). There are two blocks that can be used for customizing the scrolling behavior.
<br>
<br>

```objc
 @property (nonatomic, copy) void (^scrollViewDidScrollBlock)(JGScrollableTableViewCell *cell, UIScrollView *scrollView);
```
 This block is invoked when the scroll view scrolls. Can be used to add custom behavior to the scroll view.
<br>
<br>


```objc
 @property (nonatomic, copy) BOOL (^shouldRecognizeSimultaneouslyWithGestureRecognizerBlock)(JGScrollableTableViewCell *cell, UIGestureRecognizer *otherGestureRecognizer, UIScrollView *scrollView);
```
This block allows custom handling of other gesture recognizers. The block should return whether the scroll view should scroll while another gesture recognizer is recognized.
<br>
<br>

##Advanced usage

####Management of opened option views
```objc
JGScrollableTableViewCellManager
+ (void)closeAllCellsWithExceptionOf:(JGScrollableTableViewCell *)cell stopAfterFirst:(BOOL)stop;
```
This closes all option views in the table view that contains `cell`. `stop` is a flag that can increase performance by stopping the enumeration of cells after the first cell with an opened option view has been found and closed. Set this flag to `YES` when you have set up a `JGScrollableTableViewCellDelegate` to only allow one opened option view at a time (like in the following example).
<br>

Using this method call we can set up our table view to only allow one option view to be opened at at time:
```objc
- (void)cellDidBeginScrolling:(JGScrollableTableViewCell *)cell {
    [JGScrollableTableViewCellManager closeAllCellsWithExceptionOf:cell stopAfterFirst:YES];
}

- (void)cellDidScroll:(JGScrollableTableViewCell *)cell {
    [JGScrollableTableViewCellManager closeAllCellsWithExceptionOf:cell stopAfterFirst:YES];
}

- (void)cellDidEndScrolling:(JGScrollableTableViewCell *)cell {
    [JGScrollableTableViewCellManager closeAllCellsWithExceptionOf:cell stopAfterFirst:YES];
}
```


####Surviving UITableView's cell reuse
Because `UITableView` reuses cells it is important to set the opened state of each cell when the `UITableViewDataSource` loads its data. To remember which cell was opened you can modify the `cellDidEndScrolling:` method to take note of the cell with the currently opened option view:


```objc
- (void)cellDidEndScrolling:(JGScrollableTableViewCell *)cell {
    if (cell.optionViewVisible) {
        _openedIndexPath = [self.tableView indexPathForCell:cell];
    }
    else {
        _openedIndexPath = nil;
    }

    [JGScrollableTableViewCellManager closeAllCellsWithExceptionOf:cell stopAfterFirst:YES];
}
```
(`_openedIndexPath` is an instance variable)
<br>
<br>

The `tableView:cellForRowAtIndexPath:` method should contain this code to update each cell's `optionViewVisible` state:

```objc
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *const CellIdentifier = @"ScrollCell";
    
    JGScrollableTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    [cell setOptionViewVisible:[_openedIndexPath isEqual:indexPath]]; //this correctly sets the opened state of the cell's option view.
    
    return cell;
}
```
<br>
<br>

##Examples

There are two example projects located in the `Examples` folder.

##Credits

Created by Jonas Gessner.

##Contribution

You are welcome to contribute to the project by forking the repo, modifying the code and opening issues or pull requests.

##License

Licensed under the MIT license.
