//
//  UIScrollView+MercuryPlayer.h
//  MercuryPlayer
//
// Copyright (c) 2020年 bayescom
//


#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/*
 * The scroll direction of scrollView.
 */
typedef NS_ENUM(NSUInteger, MercuryPlayerScrollDirection) {
    MercuryPlayerScrollDirectionNone,
    MercuryPlayerScrollDirectionUp,         // Scroll up
    MercuryPlayerScrollDirectionDown,       // Scroll Down
    MercuryPlayerScrollDirectionLeft,       // Scroll left
    MercuryPlayerScrollDirectionRight       // Scroll right
};

/*
 * The scrollView direction.
 */
typedef NS_ENUM(NSInteger, MercuryPlayerScrollViewDirection) {
    MercuryPlayerScrollViewDirectionVertical,
    MercuryPlayerScrollViewDirectionHorizontal
};

/*
 * The player container type
 */
typedef NS_ENUM(NSInteger, MercuryPlayerContainerType) {
    MercuryPlayerContainerTypeView,
    MercuryPlayerContainerTypeCell
};

@interface UIScrollView (MercuryPlayer)

/// When the MercuryPlayerScrollViewDirection is MercuryPlayerScrollViewDirectionVertical,the property has value.
@property (nonatomic, readonly) CGFloat mer_lastOffsetY;

/// When the MercuryPlayerScrollViewDirection is MercuryPlayerScrollViewDirectionHorizontal,the property has value.
@property (nonatomic, readonly) CGFloat mer_lastOffsetX;

/// The scrollView scroll direction, default is MercuryPlayerScrollViewDirectionVertical.
@property (nonatomic) MercuryPlayerScrollViewDirection mer_scrollViewDirection;

/// The scroll direction of scrollView while scrolling.
/// When the MercuryPlayerScrollViewDirection is MercuryPlayerScrollViewDirectionVertical，this value can only be MercuryPlayerScrollDirectionUp or MercuryPlayerScrollDirectionDown.
/// When the MercuryPlayerScrollViewDirection is MercuryPlayerScrollViewDirectionVertical，this value can only be MercuryPlayerScrollDirectionLeft or MercuryPlayerScrollDirectionRight.
@property (nonatomic, readonly) MercuryPlayerScrollDirection mer_scrollDirection;

/// Get the cell according to indexPath.
- (UIView *)mer_getCellForIndexPath:(NSIndexPath *)indexPath;

/// Get the indexPath for cell.
- (NSIndexPath *)mer_getIndexPathForCell:(UIView *)cell;

/// Scroll to indexPath with animations.
- (void)mer_scrollToRowAtIndexPath:(NSIndexPath *)indexPath completionHandler:(void (^ __nullable)(void))completionHandler;

/// add in 3.2.4 version.
/// Scroll to indexPath with animations.
- (void)mer_scrollToRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated completionHandler:(void (^ __nullable)(void))completionHandler;

/// add in 3.2.8 version.
/// Scroll to indexPath with animations duration.
- (void)mer_scrollToRowAtIndexPath:(NSIndexPath *)indexPath animateWithDuration:(NSTimeInterval)duration completionHandler:(void (^ __nullable)(void))completionHandler;

///------------------------------------
/// The following method must be implemented in UIScrollViewDelegate.
///------------------------------------

- (void)mer_scrollViewDidEndDecelerating;

- (void)mer_scrollViewDidEndDraggingWillDecelerate:(BOOL)decelerate;

- (void)mer_scrollViewDidScrollToTop;

- (void)mer_scrollViewDidScroll;

- (void)mer_scrollViewWillBeginDragging;

///------------------------------------
/// end
///------------------------------------


@end

@interface UIScrollView (MercuryPlayerCannotCalled)

/// The block invoked When the player appearing.
@property (nonatomic, copy, nullable) void(^mer_playerAppearingInScrollView)(NSIndexPath *indexPath, CGFloat playerApperaPercent);

/// The block invoked When the player disappearing.
@property (nonatomic, copy, nullable) void(^mer_playerDisappearingInScrollView)(NSIndexPath *indexPath, CGFloat playerDisapperaPercent);

/// The block invoked When the player will appeared.
@property (nonatomic, copy, nullable) void(^mer_playerWillAppearInScrollView)(NSIndexPath *indexPath);

/// The block invoked When the player did appeared.
@property (nonatomic, copy, nullable) void(^mer_playerDidAppearInScrollView)(NSIndexPath *indexPath);

/// The block invoked When the player will disappear.
@property (nonatomic, copy, nullable) void(^mer_playerWillDisappearInScrollView)(NSIndexPath *indexPath);

/// The block invoked When the player did disappeared.
@property (nonatomic, copy, nullable) void(^mer_playerDidDisappearInScrollView)(NSIndexPath *indexPath);

/// The block invoked When the player did stop scroll.
@property (nonatomic, copy, nullable) void(^mer_scrollViewDidEndScrollingCallback)(NSIndexPath *indexPath);

/// The block invoked When the player did  scroll.
@property (nonatomic, copy, nullable) void(^mer_scrollViewDidScrollCallback)(NSIndexPath *indexPath);

/// The block invoked When the player should play.
@property (nonatomic, copy, nullable) void(^mer_playerShouldPlayInScrollView)(NSIndexPath *indexPath);

/// The current player scroll slides off the screen percent.
/// the property used when the `stopWhileNotVisible` is YES, stop the current playing player.
/// the property used when the `stopWhileNotVisible` is NO, the current playing player add to small container view.
/// 0.0~1.0, defalut is 0.5.
/// 0.0 is the player will disappear.
/// 1.0 is the player did disappear.
@property (nonatomic) CGFloat mer_playerDisapperaPercent;

/// The current player scroll to the screen percent to play the video.
/// 0.0~1.0, defalut is 0.0.
/// 0.0 is the player will appear.
/// 1.0 is the player did appear.
@property (nonatomic) CGFloat mer_playerApperaPercent;

/// The current player controller is disappear, not dealloc
@property (nonatomic) BOOL mer_viewControllerDisappear;

/// Has stopped playing
@property (nonatomic, assign) BOOL mer_stopPlay;

/// The currently playing cell stop playing when the cell has out off the screen，defalut is YES.
@property (nonatomic, assign) BOOL mer_stopWhileNotVisible;

/// The indexPath is playing.
@property (nonatomic, nullable) NSIndexPath *mer_playingIndexPath;

/// The indexPath should be play while scrolling.
@property (nonatomic, nullable) NSIndexPath *mer_shouldPlayIndexPath;

/// WWANA networks play automatically,default NO.
@property (nonatomic, getter=mer_isWWANAutoPlay) BOOL mer_WWANAutoPlay;

/// The player should auto player,default is YES.
@property (nonatomic) BOOL mer_shouldAutoPlay;

/// The view tag that the player display in scrollView.
@property (nonatomic) NSInteger mer_containerViewTag;

/// The video contrainerView in normal model.
@property (nonatomic, strong) UIView *mer_containerView;


/// The video contrainerView type.
@property (nonatomic, assign) MercuryPlayerContainerType mer_containerType;


/// Filter the cell that should be played when the scroll is stopped (to play when the scroll is stopped).
- (void)mer_filterShouldPlayCellWhileScrolled:(void (^ __nullable)(NSIndexPath *indexPath))handler;

/// Filter the cell that should be played while scrolling (you can use this to filter the highlighted cell).
- (void)mer_filterShouldPlayCellWhileScrolling:(void (^ __nullable)(NSIndexPath *indexPath))handler;

@end

@interface UIScrollView (MercuryPlayerDeprecated)

/// The block invoked When the player did stop scroll.
@property (nonatomic, copy, nullable) void(^mer_scrollViewDidStopScrollCallback)(NSIndexPath *indexPath) __attribute__((deprecated("use `MercuryPlayerController.mer_scrollViewDidEndScrollingCallback` instead.")));

/// The block invoked When the player should play.
@property (nonatomic, copy, nullable) void(^mer_shouldPlayIndexPathCallback)(NSIndexPath *indexPath) __attribute__((deprecated("use `MercuryPlayerController.mer_playerShouldPlayInScrollView` instead.")));

@end

NS_ASSUME_NONNULL_END
