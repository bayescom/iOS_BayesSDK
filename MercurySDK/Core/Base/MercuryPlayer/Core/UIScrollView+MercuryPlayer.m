//
//  UIScrollView+MercuryPlayer.m
//  MercuryPlayer
//
// Copyright (c) 2020年 bayescom
//


#import "UIScrollView+MercuryPlayer.h"
#import <objc/runtime.h>
#import "MercuryReachabilityManager.h"
#import "MercuryPlayer.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"

@interface UIScrollView ()

@property (nonatomic) CGFloat mer_lastOffsetY;
@property (nonatomic) CGFloat mer_lastOffsetX;
@property (nonatomic) MercuryPlayerScrollDirection mer_scrollDirection;

@end

@implementation UIScrollView (MercuryPlayer)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL selectors[] = {
            @selector(setContentOffset:)
        };
        
        for (NSInteger index = 0; index < sizeof(selectors) / sizeof(SEL); ++index) {
            SEL originalSelector = selectors[index];
            SEL swizzledSelector = NSSelectorFromString([@"mer_" stringByAppendingString:NSStringFromSelector(originalSelector)]);
            Method originalMethod = class_getInstanceMethod(self, originalSelector);
            Method swizzledMethod = class_getInstanceMethod(self, swizzledSelector);
            if (class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))) {
                class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
            } else {
                method_exchangeImplementations(originalMethod, swizzledMethod);
            }
        }
    });
}

- (void)mer_setContentOffset:(CGPoint)contentOffset {
    if (self.mer_scrollViewDirection == MercuryPlayerScrollViewDirectionVertical) {
        [self _findCorrectCellWhenScrollViewDirectionVertical:nil];
    } else {
        [self _findCorrectCellWhenScrollViewDirectionHorizontal:nil];
    }
    [self mer_setContentOffset:contentOffset];
}

#pragma mark - private method

- (void)_scrollViewDidStopScroll {
    @weakify(self)
    [self mer_filterShouldPlayCellWhileScrolled:^(NSIndexPath * _Nonnull indexPath) {
        @strongify(self)
        if (self.mer_scrollViewDidStopScrollCallback) self.mer_scrollViewDidStopScrollCallback(indexPath);
        if (self.mer_scrollViewDidEndScrollingCallback) self.mer_scrollViewDidEndScrollingCallback(indexPath);
    }];
}

- (void)_scrollViewBeginDragging {
    if (self.mer_scrollViewDirection == MercuryPlayerScrollViewDirectionVertical) {
        self.mer_lastOffsetY = self.contentOffset.y;
    } else {
        self.mer_lastOffsetX = self.contentOffset.x;
    }
}

/**
  The percentage of scrolling processed in vertical scrolling.
 */
- (void)_scrollViewScrollingDirectionVertical {
    CGFloat offsetY = self.contentOffset.y;
    self.mer_scrollDirection = (offsetY - self.mer_lastOffsetY > 0) ? MercuryPlayerScrollDirectionUp : MercuryPlayerScrollDirectionDown;
    self.mer_lastOffsetY = offsetY;
    if (self.mer_stopPlay) return;
    
    UIView *playerView;
    if (self.mer_containerType == MercuryPlayerContainerTypeCell) {
        // Avoid being paused the first time you play it.
        if (self.contentOffset.y < 0) return;
        if (!self.mer_playingIndexPath) return;
        
        UIView *cell = [self mer_getCellForIndexPath:self.mer_playingIndexPath];
        if (!cell) {
            if (self.mer_playerDidDisappearInScrollView) self.mer_playerDidDisappearInScrollView(self.mer_playingIndexPath);
            return;
        }
        playerView = [cell viewWithTag:self.mer_containerViewTag];
    } else if (self.mer_containerType == MercuryPlayerContainerTypeView) {
        if (!self.mer_containerView) return;
        playerView = self.mer_containerView;
    }
    
    CGRect rect1 = [playerView convertRect:playerView.frame toView:self];
    CGRect rect = [self convertRect:rect1 toView:self.superview];
    /// playerView top to scrollView top space.
    CGFloat topSpacing = CGRectGetMinY(rect) - CGRectGetMinY(self.frame) - CGRectGetMinY(playerView.frame);
    /// playerView bottom to scrollView bottom space.
    CGFloat bottomSpacing = CGRectGetMaxY(self.frame) - CGRectGetMaxY(rect) + CGRectGetMinY(playerView.frame);
    /// The height of the content area.
    CGFloat contentInsetHeight = CGRectGetMaxY(self.frame) - CGRectGetMinY(self.frame);
    
    CGFloat playerDisapperaPercent = 0;
    CGFloat playerApperaPercent = 0;
    
    if (self.mer_scrollDirection == MercuryPlayerScrollDirectionUp) { /// Scroll up
        /// Player is disappearing.
        if (topSpacing <= 0 && CGRectGetHeight(rect) != 0) {
            playerDisapperaPercent = -topSpacing/CGRectGetHeight(rect);
            if (playerDisapperaPercent > 1.0) playerDisapperaPercent = 1.0;
            if (self.mer_playerDisappearingInScrollView) self.mer_playerDisappearingInScrollView(self.mer_playingIndexPath, playerDisapperaPercent);
        }
        
        /// Top area
        if (topSpacing <= 0 && topSpacing > -CGRectGetHeight(rect)/2) {
            /// When the player will disappear.
            if (self.mer_playerWillDisappearInScrollView) self.mer_playerWillDisappearInScrollView(self.mer_playingIndexPath);
        } else if (topSpacing <= -CGRectGetHeight(rect)) {
            /// When the player did disappeared.
            if (self.mer_playerDidDisappearInScrollView) self.mer_playerDidDisappearInScrollView(self.mer_playingIndexPath);
        } else if (topSpacing > 0 && topSpacing <= contentInsetHeight) {
            /// Player is appearing.
            if (CGRectGetHeight(rect) != 0) {
                playerApperaPercent = -(topSpacing-contentInsetHeight)/CGRectGetHeight(rect);
                if (playerApperaPercent > 1.0) playerApperaPercent = 1.0;
                if (self.mer_playerAppearingInScrollView) self.mer_playerAppearingInScrollView(self.mer_playingIndexPath, playerApperaPercent);
            }
            /// In visable area
            if (topSpacing <= contentInsetHeight && topSpacing > contentInsetHeight-CGRectGetHeight(rect)/2) {
                /// When the player will appear.
                if (self.mer_playerWillAppearInScrollView) self.mer_playerWillAppearInScrollView(self.mer_playingIndexPath);
            } else {
                /// When the player did appeared.
                if (self.mer_playerDidAppearInScrollView) self.mer_playerDidAppearInScrollView(self.mer_playingIndexPath);
            }
        }
        
    } else if (self.mer_scrollDirection == MercuryPlayerScrollDirectionDown) { /// Scroll Down
        /// Player is disappearing.
        if (bottomSpacing <= 0 && CGRectGetHeight(rect) != 0) {
            playerDisapperaPercent = -bottomSpacing/CGRectGetHeight(rect);
            if (playerDisapperaPercent > 1.0) playerDisapperaPercent = 1.0;
            if (self.mer_playerDisappearingInScrollView) self.mer_playerDisappearingInScrollView(self.mer_playingIndexPath, playerDisapperaPercent);
        }
        
        /// Bottom area
        if (bottomSpacing <= 0 && bottomSpacing > -CGRectGetHeight(rect)/2) {
            /// When the player will disappear.
            if (self.mer_playerWillDisappearInScrollView) self.mer_playerWillDisappearInScrollView(self.mer_playingIndexPath);
        } else if (bottomSpacing <= -CGRectGetHeight(rect)) {
            /// When the player did disappeared.
            if (self.mer_playerDidDisappearInScrollView) self.mer_playerDidDisappearInScrollView(self.mer_playingIndexPath);
        } else if (bottomSpacing > 0 && bottomSpacing <= contentInsetHeight) {
            /// Player is appearing.
            if (CGRectGetHeight(rect) != 0) {
                playerApperaPercent = -(bottomSpacing-contentInsetHeight)/CGRectGetHeight(rect);
                if (playerApperaPercent > 1.0) playerApperaPercent = 1.0;
                if (self.mer_playerAppearingInScrollView) self.mer_playerAppearingInScrollView(self.mer_playingIndexPath, playerApperaPercent);
            }
            /// In visable area
            if (bottomSpacing <= contentInsetHeight && bottomSpacing > contentInsetHeight-CGRectGetHeight(rect)/2) {
                /// When the player will appear.
                if (self.mer_playerWillAppearInScrollView) self.mer_playerWillAppearInScrollView(self.mer_playingIndexPath);
            } else {
                /// When the player did appeared.
                if (self.mer_playerDidAppearInScrollView) self.mer_playerDidAppearInScrollView(self.mer_playingIndexPath);
            }
        }
    }
}

/**
 The percentage of scrolling processed in horizontal scrolling.
 */
- (void)_scrollViewScrollingDirectionHorizontal {
    CGFloat offsetX = self.contentOffset.x;
    self.mer_scrollDirection = (offsetX - self.mer_lastOffsetX > 0) ? MercuryPlayerScrollDirectionLeft : MercuryPlayerScrollDirectionRight;
    self.mer_lastOffsetX = offsetX;
    if (self.mer_stopPlay) return;
    
    UIView *playerView;
    if (self.mer_containerType == MercuryPlayerContainerTypeCell) {
        // Avoid being paused the first time you play it.
        if (self.contentOffset.x < 0) return;
        if (!self.mer_playingIndexPath) return;
        
        UIView *cell = [self mer_getCellForIndexPath:self.mer_playingIndexPath];
        if (!cell) {
            if (self.mer_playerDidDisappearInScrollView) self.mer_playerDidDisappearInScrollView(self.mer_playingIndexPath);
            return;
        }
       playerView = [cell viewWithTag:self.mer_containerViewTag];
    } else if (self.mer_containerType == MercuryPlayerContainerTypeView) {
        if (!self.mer_containerView) return;
        playerView = self.mer_containerView;
    }
    
    CGRect rect1 = [playerView convertRect:playerView.frame toView:self];
    CGRect rect = [self convertRect:rect1 toView:self.superview];
    /// playerView left to scrollView left space.
    CGFloat leftSpacing = CGRectGetMinX(rect) - CGRectGetMinX(self.frame) - CGRectGetMinX(playerView.frame);
    /// playerView bottom to scrollView right space.
    CGFloat rightSpacing = CGRectGetMaxX(self.frame) - CGRectGetMaxX(rect) + CGRectGetMinX(playerView.frame);
    /// The height of the content area.
    CGFloat contentInsetWidth = CGRectGetMaxX(self.frame) - CGRectGetMinX(self.frame);
    
    CGFloat playerDisapperaPercent = 0;
    CGFloat playerApperaPercent = 0;
    
    if (self.mer_scrollDirection == MercuryPlayerScrollDirectionLeft) { /// Scroll left
        /// Player is disappearing.
        if (leftSpacing <= 0 && CGRectGetWidth(rect) != 0) {
            playerDisapperaPercent = -leftSpacing/CGRectGetWidth(rect);
            if (playerDisapperaPercent > 1.0) playerDisapperaPercent = 1.0;
            if (self.mer_playerDisappearingInScrollView) self.mer_playerDisappearingInScrollView(self.mer_playingIndexPath, playerDisapperaPercent);
        }
        
        /// Top area
        if (leftSpacing <= 0 && leftSpacing > -CGRectGetWidth(rect)/2) {
            /// When the player will disappear.
            if (self.mer_playerWillDisappearInScrollView) self.mer_playerWillDisappearInScrollView(self.mer_playingIndexPath);
        } else if (leftSpacing <= -CGRectGetWidth(rect)) {
            /// When the player did disappeared.
            if (self.mer_playerDidDisappearInScrollView) self.mer_playerDidDisappearInScrollView(self.mer_playingIndexPath);
        } else if (leftSpacing > 0 && leftSpacing <= contentInsetWidth) {
            /// Player is appearing.
            if (CGRectGetWidth(rect) != 0) {
                playerApperaPercent = -(leftSpacing-contentInsetWidth)/CGRectGetWidth(rect);
                if (playerApperaPercent > 1.0) playerApperaPercent = 1.0;
                if (self.mer_playerAppearingInScrollView) self.mer_playerAppearingInScrollView(self.mer_playingIndexPath, playerApperaPercent);
            }
            /// In visable area
            if (leftSpacing <= contentInsetWidth && leftSpacing > contentInsetWidth-CGRectGetWidth(rect)/2) {
                /// When the player will appear.
                if (self.mer_playerWillAppearInScrollView) self.mer_playerWillAppearInScrollView(self.mer_playingIndexPath);
            } else {
                /// When the player did appeared.
                if (self.mer_playerDidAppearInScrollView) self.mer_playerDidAppearInScrollView(self.mer_playingIndexPath);
            }
        }
        
    } else if (self.mer_scrollDirection == MercuryPlayerScrollDirectionRight) { /// Scroll right
        /// Player is disappearing.
        if (rightSpacing <= 0 && CGRectGetWidth(rect) != 0) {
            playerDisapperaPercent = -rightSpacing/CGRectGetWidth(rect);
            if (playerDisapperaPercent > 1.0) playerDisapperaPercent = 1.0;
            if (self.mer_playerDisappearingInScrollView) self.mer_playerDisappearingInScrollView(self.mer_playingIndexPath, playerDisapperaPercent);
        }
        
        /// Bottom area
        if (rightSpacing <= 0 && rightSpacing > -CGRectGetWidth(rect)/2) {
            /// When the player will disappear.
            if (self.mer_playerWillDisappearInScrollView) self.mer_playerWillDisappearInScrollView(self.mer_playingIndexPath);
        } else if (rightSpacing <= -CGRectGetWidth(rect)) {
            /// When the player did disappeared.
            if (self.mer_playerDidDisappearInScrollView) self.mer_playerDidDisappearInScrollView(self.mer_playingIndexPath);
        } else if (rightSpacing > 0 && rightSpacing <= contentInsetWidth) {
            /// Player is appearing.
            if (CGRectGetWidth(rect) != 0) {
                playerApperaPercent = -(rightSpacing-contentInsetWidth)/CGRectGetWidth(rect);
                if (playerApperaPercent > 1.0) playerApperaPercent = 1.0;
                if (self.mer_playerAppearingInScrollView) self.mer_playerAppearingInScrollView(self.mer_playingIndexPath, playerApperaPercent);
            }
            /// In visable area
            if (rightSpacing <= contentInsetWidth && rightSpacing > contentInsetWidth-CGRectGetWidth(rect)/2) {
                /// When the player will appear.
                if (self.mer_playerWillAppearInScrollView) self.mer_playerWillAppearInScrollView(self.mer_playingIndexPath);
            } else {
                /// When the player did appeared.
                if (self.mer_playerDidAppearInScrollView) self.mer_playerDidAppearInScrollView(self.mer_playingIndexPath);
            }
        }
    }
}

/**
 Find the playing cell while the scrollDirection is vertical.
 */
- (void)_findCorrectCellWhenScrollViewDirectionVertical:(void (^ __nullable)(NSIndexPath *indexPath))handler {
    if (!self.mer_shouldAutoPlay) return;
    if (self.mer_containerType == MercuryPlayerContainerTypeView) return;

    NSArray *visiableCells = nil;
    NSIndexPath *indexPath = nil;
    if ([self _isTableView]) {
        UITableView *tableView = (UITableView *)self;
        visiableCells = [tableView visibleCells];
        // First visible cell indexPath
        indexPath = tableView.indexPathsForVisibleRows.firstObject;
        if (self.contentOffset.y <= 0 && (!self.mer_playingIndexPath || [indexPath compare:self.mer_playingIndexPath] == NSOrderedSame)) {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            UIView *playerView = [cell viewWithTag:self.mer_containerViewTag];
            if (playerView) {
                if (self.mer_scrollViewDidScrollCallback) self.mer_scrollViewDidScrollCallback(indexPath);
                if (handler) handler(indexPath);
                self.mer_shouldPlayIndexPath = indexPath;
                return;
            }
        }
        
        // Last visible cell indexPath
        indexPath = tableView.indexPathsForVisibleRows.lastObject;
        if (self.contentOffset.y + self.frame.size.height >= self.contentSize.height && (!self.mer_playingIndexPath || [indexPath compare:self.mer_playingIndexPath] == NSOrderedSame)) {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            UIView *playerView = [cell viewWithTag:self.mer_containerViewTag];
            if (playerView) {
                if (self.mer_scrollViewDidScrollCallback) self.mer_scrollViewDidScrollCallback(indexPath);
                if (handler) handler(indexPath);
                self.mer_shouldPlayIndexPath = indexPath;
                return;
            }
        }
    } else if ([self _isCollectionView]) {
        UICollectionView *collectionView = (UICollectionView *)self;
        visiableCells = [collectionView visibleCells];
        NSArray *sortedIndexPaths = [collectionView.indexPathsForVisibleItems sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [obj1 compare:obj2];
        }];
        
        visiableCells = [visiableCells sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSIndexPath *path1 = (NSIndexPath *)[collectionView indexPathForCell:obj1];
            NSIndexPath *path2 = (NSIndexPath *)[collectionView indexPathForCell:obj2];
            return [path1 compare:path2];
        }];
        
        // First visible cell indexPath
        indexPath = sortedIndexPaths.firstObject;
        if (self.contentOffset.y <= 0 && (!self.mer_playingIndexPath || [indexPath compare:self.mer_playingIndexPath] == NSOrderedSame)) {
            UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
            UIView *playerView = [cell viewWithTag:self.mer_containerViewTag];
            if (playerView) {
                if (self.mer_scrollViewDidScrollCallback) self.mer_scrollViewDidScrollCallback(indexPath);
                if (handler) handler(indexPath);
                self.mer_shouldPlayIndexPath = indexPath;
                return;
            }
        }
        
        // Last visible cell indexPath
        indexPath = sortedIndexPaths.lastObject;
        if (self.contentOffset.y + self.frame.size.height >= self.contentSize.height && (!self.mer_playingIndexPath || [indexPath compare:self.mer_playingIndexPath] == NSOrderedSame)) {
            UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
            UIView *playerView = [cell viewWithTag:self.mer_containerViewTag];
            if (playerView) {
                if (self.mer_scrollViewDidScrollCallback) self.mer_scrollViewDidScrollCallback(indexPath);
                if (handler) handler(indexPath);
                self.mer_shouldPlayIndexPath = indexPath;
                return;
            }
        }
    }
    
    NSArray *cells = nil;
    if (self.mer_scrollDirection == MercuryPlayerScrollDirectionUp) {
        cells = visiableCells;
    } else {
        cells = [visiableCells reverseObjectEnumerator].allObjects;
    }
    
    /// Mid line.
    CGFloat scrollViewMidY = CGRectGetHeight(self.frame)/2;
    /// The final playing indexPath.
    __block NSIndexPath *finalIndexPath = nil;
    /// The final distance from the center line.
    __block CGFloat finalSpace = 0;
    @weakify(self)
    [cells enumerateObjectsUsingBlock:^(UIView *cell, NSUInteger idx, BOOL * _Nonnull stop) {
        @strongify(self)
        UIView *playerView = [cell viewWithTag:self.mer_containerViewTag];
        if (!playerView) return;
        CGRect rect1 = [playerView convertRect:playerView.frame toView:self];
        CGRect rect = [self convertRect:rect1 toView:self.superview];
        /// playerView top to scrollView top space.
        CGFloat topSpacing = CGRectGetMinY(rect) - CGRectGetMinY(self.frame) - CGRectGetMinY(playerView.frame);
        /// playerView bottom to scrollView bottom space.
        CGFloat bottomSpacing = CGRectGetMaxY(self.frame) - CGRectGetMaxY(rect) + CGRectGetMinY(playerView.frame);
        CGFloat centerSpacing = ABS(scrollViewMidY - CGRectGetMidY(rect));
        NSIndexPath *indexPath = [self mer_getIndexPathForCell:cell];
        
        /// Play when the video playback section is visible.
        if ((topSpacing >= -(1 - self.mer_playerApperaPercent) * CGRectGetHeight(rect)) && (bottomSpacing >= -(1 - self.mer_playerApperaPercent) * CGRectGetHeight(rect))) {
            /// If you have a cell that is playing, stop the traversal.
            if (self.mer_playingIndexPath) {
                indexPath = self.mer_playingIndexPath;
                finalIndexPath = indexPath;
                *stop = YES;
                return;
            }
            if (!finalIndexPath || centerSpacing < finalSpace) {
                finalIndexPath = indexPath;
                finalSpace = centerSpacing;
            }
        }
    }];
    /// if find the playing indexPath.
    if (finalIndexPath) {
        if (self.mer_scrollViewDidScrollCallback) self.mer_scrollViewDidScrollCallback(indexPath);
        if (handler) handler(finalIndexPath);
    }
    self.mer_shouldPlayIndexPath = finalIndexPath;
}

/**
 Find the playing cell while the scrollDirection is horizontal.
 */
- (void)_findCorrectCellWhenScrollViewDirectionHorizontal:(void (^ __nullable)(NSIndexPath *indexPath))handler {
    if (!self.mer_shouldAutoPlay) return;
    if (self.mer_containerType == MercuryPlayerContainerTypeView) return;
    
    NSArray *visiableCells = nil;
    NSIndexPath *indexPath = nil;
    if ([self _isTableView]) {
        UITableView *tableView = (UITableView *)self;
        visiableCells = [tableView visibleCells];
        // First visible cell indexPath
        indexPath = tableView.indexPathsForVisibleRows.firstObject;
        if (self.contentOffset.x <= 0 && (!self.mer_playingIndexPath || [indexPath compare:self.mer_playingIndexPath] == NSOrderedSame)) {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            UIView *playerView = [cell viewWithTag:self.mer_containerViewTag];
            if (playerView) {
                if (self.mer_scrollViewDidScrollCallback) self.mer_scrollViewDidScrollCallback(indexPath);
                if (handler) handler(indexPath);
                self.mer_shouldPlayIndexPath = indexPath;
                return;
            }
        }
        
        // Last visible cell indexPath
        indexPath = tableView.indexPathsForVisibleRows.lastObject;
        if (self.contentOffset.x + self.frame.size.width >= self.contentSize.width && (!self.mer_playingIndexPath || [indexPath compare:self.mer_playingIndexPath] == NSOrderedSame)) {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            UIView *playerView = [cell viewWithTag:self.mer_containerViewTag];
            if (playerView) {
                if (self.mer_scrollViewDidScrollCallback) self.mer_scrollViewDidScrollCallback(indexPath);
                if (handler) handler(indexPath);
                self.mer_shouldPlayIndexPath = indexPath;
                return;
            }
        }
    } else if ([self _isCollectionView]) {
        UICollectionView *collectionView = (UICollectionView *)self;
        visiableCells = [collectionView visibleCells];
        NSArray *sortedIndexPaths = [collectionView.indexPathsForVisibleItems sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [obj1 compare:obj2];
        }];
        
        visiableCells = [visiableCells sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSIndexPath *path1 = (NSIndexPath *)[collectionView indexPathForCell:obj1];
            NSIndexPath *path2 = (NSIndexPath *)[collectionView indexPathForCell:obj2];
            return [path1 compare:path2];
        }];
        
        // First visible cell indexPath
        indexPath = sortedIndexPaths.firstObject;
        if (self.contentOffset.x <= 0 && (!self.mer_playingIndexPath || [indexPath compare:self.mer_playingIndexPath] == NSOrderedSame)) {
            UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
            UIView *playerView = [cell viewWithTag:self.mer_containerViewTag];
            if (playerView) {
                if (self.mer_scrollViewDidScrollCallback) self.mer_scrollViewDidScrollCallback(indexPath);
                if (handler) handler(indexPath);
                self.mer_shouldPlayIndexPath = indexPath;
                return;
            }
        }
        
        // Last visible cell indexPath
        indexPath = sortedIndexPaths.lastObject;
        if (self.contentOffset.x + self.frame.size.width >= self.contentSize.width && (!self.mer_playingIndexPath || [indexPath compare:self.mer_playingIndexPath] == NSOrderedSame)) {
            UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
            UIView *playerView = [cell viewWithTag:self.mer_containerViewTag];
            if (playerView) {
                if (self.mer_scrollViewDidScrollCallback) self.mer_scrollViewDidScrollCallback(indexPath);
                if (handler) handler(indexPath);
                self.mer_shouldPlayIndexPath = indexPath;
                return;
            }
        }
    }
    
    NSArray *cells = nil;
    if (self.mer_scrollDirection == MercuryPlayerScrollDirectionUp) {
        cells = visiableCells;
    } else {
        cells = [visiableCells reverseObjectEnumerator].allObjects;
    }
    
    /// Mid line.
    CGFloat scrollViewMidX = CGRectGetWidth(self.frame)/2;
    /// The final playing indexPath.
    __block NSIndexPath *finalIndexPath = nil;
    /// The final distance from the center line.
    __block CGFloat finalSpace = 0;
    @weakify(self)
    [cells enumerateObjectsUsingBlock:^(UIView *cell, NSUInteger idx, BOOL * _Nonnull stop) {
        @strongify(self)
        UIView *playerView = [cell viewWithTag:self.mer_containerViewTag];
        if (!playerView) return;
        CGRect rect1 = [playerView convertRect:playerView.frame toView:self];
        CGRect rect = [self convertRect:rect1 toView:self.superview];
        /// playerView left to scrollView top space.
        CGFloat leftSpacing = CGRectGetMinX(rect) - CGRectGetMinX(self.frame) - CGRectGetMinX(playerView.frame);
        /// playerView right to scrollView top space.
        CGFloat rightSpacing = CGRectGetMaxX(self.frame) - CGRectGetMaxX(rect) + CGRectGetMinX(playerView.frame);
        CGFloat centerSpacing = ABS(scrollViewMidX - CGRectGetMidX(rect));
        NSIndexPath *indexPath = [self mer_getIndexPathForCell:cell];
        
        /// Play when the video playback section is visible.
        if ((leftSpacing >= -(1 - self.mer_playerApperaPercent) * CGRectGetWidth(rect)) && (rightSpacing >= -(1 - self.mer_playerApperaPercent) * CGRectGetWidth(rect))) {
            /// If you have a cell that is playing, stop the traversal.
            if (self.mer_playingIndexPath) {
                indexPath = self.mer_playingIndexPath;
                finalIndexPath = indexPath;
                *stop = YES;
                return;
            }
            if (!finalIndexPath || centerSpacing < finalSpace) {
                finalIndexPath = indexPath;
                finalSpace = centerSpacing;
            }
        }
    }];
    /// if find the playing indexPath.
    if (finalIndexPath) {
        if (self.mer_scrollViewDidScrollCallback) self.mer_scrollViewDidScrollCallback(indexPath);
        if (handler) handler(finalIndexPath);
        self.mer_shouldPlayIndexPath = finalIndexPath;
    }
}

- (BOOL)_isTableView {
    return [self isKindOfClass:[UITableView class]];
}

- (BOOL)_isCollectionView {
    return [self isKindOfClass:[UICollectionView class]];
}

#pragma mark - public method

- (UIView *)mer_getCellForIndexPath:(NSIndexPath *)indexPath {
    if ([self _isTableView]) {
        UITableView *tableView = (UITableView *)self;
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        return cell;
    } else if ([self _isCollectionView]) {
        UICollectionView *collectionView = (UICollectionView *)self;
        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
        return cell;
    }
    return nil;
}

- (NSIndexPath *)mer_getIndexPathForCell:(UIView *)cell {
    if ([self _isTableView]) {
        UITableView *tableView = (UITableView *)self;
        NSIndexPath *indexPath = [tableView indexPathForCell:(UITableViewCell *)cell];
        return indexPath;
    } else if ([self _isCollectionView]) {
        UICollectionView *collectionView = (UICollectionView *)self;
        NSIndexPath *indexPath = [collectionView indexPathForCell:(UICollectionViewCell *)cell];
        return indexPath;
    }
    return nil;
}

- (void)mer_scrollToRowAtIndexPath:(NSIndexPath *)indexPath completionHandler:(void (^ __nullable)(void))completionHandler {
    [self mer_scrollToRowAtIndexPath:indexPath animated:YES completionHandler:completionHandler];
}

- (void)mer_scrollToRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated completionHandler:(void (^ __nullable)(void))completionHandler {
    [self mer_scrollToRowAtIndexPath:indexPath animateWithDuration:animated ? 0.4 : 0.0 completionHandler:completionHandler];
}

/// Scroll to indexPath with animations duration.
- (void)mer_scrollToRowAtIndexPath:(NSIndexPath *)indexPath animateWithDuration:(NSTimeInterval)duration completionHandler:(void (^ __nullable)(void))completionHandler {
    BOOL animated = duration > 0.0;
    if ([self _isTableView]) {
        UITableView *tableView = (UITableView *)self;
        [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:animated];
    } else if ([self _isCollectionView]) {
        UICollectionView *collectionView = (UICollectionView *)self;
        [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionTop animated:animated];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (completionHandler) completionHandler();
    });
}

- (void)mer_scrollViewDidEndDecelerating {
    BOOL scrollToScrollStop = !self.tracking && !self.dragging && !self.decelerating;
    if (scrollToScrollStop) {
        [self _scrollViewDidStopScroll];
    }
}

- (void)mer_scrollViewDidEndDraggingWillDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        BOOL dragToDragStop = self.tracking && !self.dragging && !self.decelerating;
        if (dragToDragStop) {
            [self _scrollViewDidStopScroll];
        }
    }
}

- (void)mer_scrollViewDidScrollToTop {
    [self _scrollViewDidStopScroll];
}

- (void)mer_scrollViewDidScroll {
    if (self.mer_scrollViewDirection == MercuryPlayerScrollViewDirectionVertical) {
        [self _scrollViewScrollingDirectionVertical];
    } else {
        [self _scrollViewScrollingDirectionHorizontal];
    }
}

- (void)mer_scrollViewWillBeginDragging {
    [self _scrollViewBeginDragging];
}

#pragma mark - getter

- (MercuryPlayerScrollDirection)mer_scrollDirection {
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

- (MercuryPlayerScrollViewDirection)mer_scrollViewDirection {
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

- (CGFloat)mer_lastOffsetY {
    return [objc_getAssociatedObject(self, _cmd) floatValue];
}

- (CGFloat)mer_lastOffsetX {
    return [objc_getAssociatedObject(self, _cmd) floatValue];
}

#pragma mark - setter

- (void)setMer_scrollDirection:(MercuryPlayerScrollDirection)mer_scrollDirection {
    objc_setAssociatedObject(self, @selector(mer_scrollDirection), @(mer_scrollDirection), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setMer_scrollViewDirection:(MercuryPlayerScrollViewDirection)mer_scrollViewDirection {
    objc_setAssociatedObject(self, @selector(mer_scrollViewDirection), @(mer_scrollViewDirection), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setMer_lastOffsetY:(CGFloat)mer_lastOffsetY {
    objc_setAssociatedObject(self, @selector(mer_lastOffsetY), @(mer_lastOffsetY), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setMer_lastOffsetX:(CGFloat)mer_lastOffsetX {
    objc_setAssociatedObject(self, @selector(mer_lastOffsetX), @(mer_lastOffsetX), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@implementation UIScrollView (MercuryPlayerCannotCalled)

- (void)mer_filterShouldPlayCellWhileScrolling:(void (^ __nullable)(NSIndexPath *indexPath))handler {
    if (self.mer_scrollViewDirection == MercuryPlayerScrollViewDirectionVertical) {
        [self _findCorrectCellWhenScrollViewDirectionVertical:handler];
    } else {
        [self _findCorrectCellWhenScrollViewDirectionHorizontal:handler];
    }
}

- (void)mer_filterShouldPlayCellWhileScrolled:(void (^ __nullable)(NSIndexPath *indexPath))handler {
    if (!self.mer_shouldAutoPlay) return;
    @weakify(self)
    [self mer_filterShouldPlayCellWhileScrolling:^(NSIndexPath *indexPath) {
        @strongify(self)
        /// 如果当前控制器已经消失，直接return
        if (self.mer_viewControllerDisappear) return;
        if ([MercuryReachabilityManager sharedManager].isReachableViaWWAN && !self.mer_WWANAutoPlay) {
            /// 移动网络
            self.mer_shouldPlayIndexPath = indexPath;
            return;
        }
        if (handler) handler(indexPath);
        self.mer_playingIndexPath = indexPath;
    }];
}

#pragma mark - getter

- (void (^)(NSIndexPath * _Nonnull, CGFloat))mer_playerDisappearingInScrollView {
    return objc_getAssociatedObject(self, _cmd);
}

- (void (^)(NSIndexPath * _Nonnull, CGFloat))mer_playerAppearingInScrollView {
    return objc_getAssociatedObject(self, _cmd);
}

- (void (^)(NSIndexPath * _Nonnull))mer_playerDidAppearInScrollView {
    return objc_getAssociatedObject(self, _cmd);
}

- (void (^)(NSIndexPath * _Nonnull))mer_playerWillDisappearInScrollView {
    return objc_getAssociatedObject(self, _cmd);
}

- (void (^)(NSIndexPath * _Nonnull))mer_playerWillAppearInScrollView {
    return objc_getAssociatedObject(self, _cmd);
}

- (void (^)(NSIndexPath * _Nonnull))mer_playerDidDisappearInScrollView {
    return objc_getAssociatedObject(self, _cmd);
}

- (void (^)(NSIndexPath * _Nonnull))mer_scrollViewDidEndScrollingCallback {
    return objc_getAssociatedObject(self, _cmd);
}

- (void (^)(NSIndexPath * _Nonnull))mer_scrollViewDidScrollCallback {
    return objc_getAssociatedObject(self, _cmd);
}

- (void (^)(NSIndexPath * _Nonnull))mer_playerShouldPlayInScrollView {
    return objc_getAssociatedObject(self, _cmd);
}

- (CGFloat)mer_playerApperaPercent {
    return [objc_getAssociatedObject(self, _cmd) floatValue];
}

- (CGFloat)mer_playerDisapperaPercent {
    return [objc_getAssociatedObject(self, _cmd) floatValue];
}

- (BOOL)mer_viewControllerDisappear {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (BOOL)mer_stopPlay {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (BOOL)mer_stopWhileNotVisible {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (NSIndexPath *)mer_playingIndexPath {
    return objc_getAssociatedObject(self, _cmd);
}

- (NSIndexPath *)mer_shouldPlayIndexPath {
    return objc_getAssociatedObject(self, _cmd);
}

- (NSInteger)mer_containerViewTag {
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

- (BOOL)mer_isWWANAutoPlay {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (BOOL)mer_shouldAutoPlay {
    NSNumber *number = objc_getAssociatedObject(self, _cmd);
    if (number) return number.boolValue;
    self.mer_shouldAutoPlay = YES;
    return YES;
}

- (MercuryPlayerContainerType)mer_containerType {
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

- (UIView *)mer_containerView {
    return objc_getAssociatedObject(self, _cmd);
}

#pragma mark - setter

- (void)setMer_playerDisappearingInScrollView:(void (^)(NSIndexPath * _Nonnull, CGFloat))mer_playerDisappearingInScrollView {
    objc_setAssociatedObject(self, @selector(mer_playerDisappearingInScrollView), mer_playerDisappearingInScrollView, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setMer_playerAppearingInScrollView:(void (^)(NSIndexPath * _Nonnull, CGFloat))mer_playerAppearingInScrollView {
    objc_setAssociatedObject(self, @selector(mer_playerAppearingInScrollView), mer_playerAppearingInScrollView, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setMer_playerDidAppearInScrollView:(void (^)(NSIndexPath * _Nonnull))mer_playerDidAppearInScrollView {
    objc_setAssociatedObject(self, @selector(mer_playerDidAppearInScrollView), mer_playerDidAppearInScrollView, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setMer_playerWillDisappearInScrollView:(void (^)(NSIndexPath * _Nonnull))mer_playerWillDisappearInScrollView {
    objc_setAssociatedObject(self, @selector(mer_playerWillDisappearInScrollView), mer_playerWillDisappearInScrollView, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setMer_playerWillAppearInScrollView:(void (^)(NSIndexPath * _Nonnull))mer_playerWillAppearInScrollView {
    objc_setAssociatedObject(self, @selector(mer_playerWillAppearInScrollView), mer_playerWillAppearInScrollView, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setMer_playerDidDisappearInScrollView:(void (^)(NSIndexPath * _Nonnull))mer_playerDidDisappearInScrollView {
    objc_setAssociatedObject(self, @selector(mer_playerDidDisappearInScrollView), mer_playerDidDisappearInScrollView, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setMer_scrollViewDidEndScrollingCallback:(void (^)(NSIndexPath * _Nonnull))mer_scrollViewDidEndScrollingCallback {
    objc_setAssociatedObject(self, @selector(mer_scrollViewDidEndScrollingCallback), mer_scrollViewDidEndScrollingCallback, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setMer_scrollViewDidScrollCallback:(void (^)(NSIndexPath * _Nonnull))mer_scrollViewDidScrollCallback {
    objc_setAssociatedObject(self, @selector(mer_scrollViewDidScrollCallback), mer_scrollViewDidScrollCallback, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setMer_playerShouldPlayInScrollView:(void (^)(NSIndexPath * _Nonnull))mer_playerShouldPlayInScrollView {
    objc_setAssociatedObject(self, @selector(mer_playerShouldPlayInScrollView), mer_playerShouldPlayInScrollView, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setMer_playerApperaPercent:(CGFloat)mer_playerApperaPercent {
    objc_setAssociatedObject(self, @selector(mer_playerApperaPercent), @(mer_playerApperaPercent), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setMer_playerDisapperaPercent:(CGFloat)mer_playerDisapperaPercent {
    objc_setAssociatedObject(self, @selector(mer_playerDisapperaPercent), @(mer_playerDisapperaPercent), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setMer_viewControllerDisappear:(BOOL)mer_viewControllerDisappear {
    objc_setAssociatedObject(self, @selector(mer_viewControllerDisappear), @(mer_viewControllerDisappear), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setMer_stopPlay:(BOOL)mer_stopPlay {
    objc_setAssociatedObject(self, @selector(mer_stopPlay), @(mer_stopPlay), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setMer_stopWhileNotVisible:(BOOL)mer_stopWhileNotVisible {
    objc_setAssociatedObject(self, @selector(mer_stopWhileNotVisible), @(mer_stopWhileNotVisible), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setMer_playingIndexPath:(NSIndexPath *)mer_playingIndexPath {
    objc_setAssociatedObject(self, @selector(mer_playingIndexPath), mer_playingIndexPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (mer_playingIndexPath && [mer_playingIndexPath compare:self.mer_shouldPlayIndexPath] != NSOrderedSame) {
        self.mer_shouldPlayIndexPath = mer_playingIndexPath;
    }
}

- (void)setMer_shouldPlayIndexPath:(NSIndexPath *)mer_shouldPlayIndexPath {
    if (self.mer_playerShouldPlayInScrollView) self.mer_playerShouldPlayInScrollView(mer_shouldPlayIndexPath);
    if (self.mer_shouldPlayIndexPathCallback) self.mer_shouldPlayIndexPathCallback(mer_shouldPlayIndexPath);
    objc_setAssociatedObject(self, @selector(mer_shouldPlayIndexPath), mer_shouldPlayIndexPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setMer_containerViewTag:(NSInteger)mer_containerViewTag {
    objc_setAssociatedObject(self, @selector(mer_containerViewTag), @(mer_containerViewTag), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setMer_containerType:(MercuryPlayerContainerType)mer_containerType {
    objc_setAssociatedObject(self, @selector(mer_containerType), @(mer_containerType), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setMer_containerView:(UIView *)mer_containerView {
    objc_setAssociatedObject(self, @selector(mer_containerView), mer_containerView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setMer_shouldAutoPlay:(BOOL)mer_shouldAutoPlay {
    objc_setAssociatedObject(self, @selector(mer_shouldAutoPlay), @(mer_shouldAutoPlay), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setMer_WWANAutoPlay:(BOOL)mer_WWANAutoPlay {
    objc_setAssociatedObject(self, @selector(mer_isWWANAutoPlay), @(mer_WWANAutoPlay), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end


@implementation UIScrollView (MercuryPlayerDeprecated)

#pragma mark - getter

- (void (^)(NSIndexPath * _Nonnull))mer_scrollViewDidStopScrollCallback {
    return objc_getAssociatedObject(self, _cmd);
}

- (void (^)(NSIndexPath * _Nonnull))mer_shouldPlayIndexPathCallback {
    return objc_getAssociatedObject(self, _cmd);
}

#pragma mark - setter

- (void)setMer_scrollViewDidStopScrollCallback:(void (^)(NSIndexPath * _Nonnull))mer_scrollViewDidStopScrollCallback {
    objc_setAssociatedObject(self, @selector(mer_scrollViewDidStopScrollCallback), mer_scrollViewDidStopScrollCallback, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setMer_shouldPlayIndexPathCallback:(void (^)(NSIndexPath * _Nonnull))mer_shouldPlayIndexPathCallback {
    objc_setAssociatedObject(self, @selector(mer_shouldPlayIndexPathCallback), mer_shouldPlayIndexPathCallback, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end

#pragma clang diagnostic pop
