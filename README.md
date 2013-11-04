JGScrollableTableViewCell
=========================

JGScrollableTableViewCell is a simple and easy to use UITableViewCell subclass with a scrollable content view that exposes an accessory view when scrolled. The behavior is inspired by the iOS 7 mail app.

<p align="center"><img src="Demo.gif"/></p>

##Requirements

• iOS 5 or higher
• Built with <b>ARC</b> (If your Xcode project doesn't use ARC then set the `-fobjc-arc` compiler flag)
• Foundation, UIKit and CoreGraphics frameworks


##Getting started

`JGScrollableTableViewCell` works just like any other `UITableViewCell`: Highlighting, selection, and `UITableViewDelegate` calls all work like usual. The only difference is that the cell's `contentView` is covered by a `UIScrollView` which basically becomes the new content view – which is scrollable.

An "option view" can be assigned to the cell, which effectively places that view behind the scroll view, making it possible to scroll on the cell to reveal the option view behind it. This option view can be displayed on the right side of the cell or on the left side of the cell.

<b>Note:</b> You should always use custom subclasses of `JGScrollableTableViewCell` that add your custom content to the cell (ex labels & image views).

##Usage

By default `JGScrollableTableViewCell` has an empty scroll area, and no option view. Here's a guide through the entire `JGScrollableTableViewCell` class:

####The scroll view

```objc
- (void)setScrollViewInsets:(UIEdgeInsets)scrollViewInsets;
```
Insets the scroll view. Useful for displaying a border around the scroll area (when also setting `contentView.backgroundColor`)


```objc
- (void)setScrollViewBackgroundColor:(UIColor *)scrollViewBackgroundColor;
```
Sets the background color of the scroll view. Equivalent to `contentView.backgroundColor` on a regular `UITableViewCell`.


```objc
- (BOOL)scrolling;
```
Returns `YES`if the cell is being scrolled by the user.


####The option view

```objc
- (void)setOptionView:(UIView *)view side:(JGScrollableTableViewCellSide)side;
```
Sets a new option view & removes the old option view. `side` is the side on which the option view will appear (left or right).
The option view will be dynamically resized to fit the cell's contents and the scroll view's insets. The only parameter that is not changed is the view's width. The width should be set before passing the view to this method.


```objc
- (UIView *)optionView;
```
Returns the current option view.

```objc
- (void)setOptionViewVisible:(BOOL)optionViewVisible animated:(BOOL)animated;
```
Opens or closes the option view with an optional 0.3 second animation.


####Scrollable content

```objc
- (void)addContentView:(UIView *)view;
```
You should at no point add a view to the cell's directly or to its `contentView`. Instead, pass views that should be displayed on the cell to this method. Views passed to this method will appear in the scrollable area of the cell.


###Delegation
`JGScrollableTableViewCell` has a delegate that conforms to the `JGScrollableTableViewCellDelegate` protocol. It is used for handling scroll events.
```objc
@property (nonatomic, weak) id <JGScrollableTableViewCellDelegate> scrollDelegate;
```

The `JGScrollableTableViewCellDelegate` protocol declares three optional (self explaining) methods:
```objc
- (void)cellDidBeginScrolling:(JGScrollableTableViewCell *)cell;
- (void)cellDidScroll:(JGScrollableTableViewCell *)cell;
- (void)cellDidEndScrolling:(JGScrollableTableViewCell *)cell;
```
Ideally, your `UITableViewDelegate` should also be your `JGScrollableTableViewCellDelegate`.

##Advanced usage

####Management of opened option views
```objc
JGScrollableTableViewCellManager
+ (void)closeAllCellsWithExceptionOf:(JGScrollableTableViewCell *)cell stopAfterFirst:(BOOL)stop;
```
This closes all option views in the table view that contains `cell`. `stop` flag that can increase performance by stopping the enumeration of cells after the first cell with an opened option view has been found. Set this flag to `YES` when you have set up the `JGScrollableTableViewCellDelegate` to only allow one opened option view at a time.


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


The `tableView:cellForRowAtIndexPath:` method should contain this code:

```objc
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *const CellIdentifier = @"ScrollCell";
    
    JGScrollableTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    [cell setOptionViewVisible:[_openedIndexPath isEqual:indexPath]]; //this correctly sets the opened state of the cell's option view.
    
    return cell;
}
```


##Examples

The `JGScrollableTableViewCell Examples` sample Xcode project contains implementations of all the discussed functionality.


##Credits

Created by Jonas Gessner.

##Contribution

You are welcome to contribute to the project by forking the repo, modifying the code and opening issues or pull requests.

##License

Licensed under the MIT license.
