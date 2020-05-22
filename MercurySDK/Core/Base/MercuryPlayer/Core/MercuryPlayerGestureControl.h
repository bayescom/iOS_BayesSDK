//
//  MercuryPlayerGestureControl.h
//  MercuryPlayer
//
// Copyright (c) 2020年 bayescom
//


#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, MercuryPlayerGestureType) {
    MercuryPlayerGestureTypeUnknown,
    MercuryPlayerGestureTypeSingleTap,
    MercuryPlayerGestureTypeDoubleTap,
    MercuryPlayerGestureTypePan,
    MercuryPlayerGestureTypePinch
};

typedef NS_ENUM(NSUInteger, MercuryPanDirection) {
    MercuryPanDirectionUnknown,
    MercuryPanDirectionV,
    MercuryPanDirectionH,
};

typedef NS_ENUM(NSUInteger, MercuryPanLocation) {
    MercuryPanLocationUnknown,
    MercuryPanLocationLeft,
    MercuryPanLocationRight,
};

typedef NS_ENUM(NSUInteger, MercuryPanMovingDirection) {
    MercuryPanMovingDirectionUnkown,
    MercuryPanMovingDirectionTop,
    MercuryPanMovingDirectionLeft,
    MercuryPanMovingDirectionBottom,
    MercuryPanMovingDirectionRight,
};

/// This enumeration lists some of the gesture types that the player has by default.
typedef NS_OPTIONS(NSUInteger, MercuryPlayerDisableGestureTypes) {
    MercuryPlayerDisableGestureTypesNone         = 0,
    MercuryPlayerDisableGestureTypesSingleTap    = 1 << 0,
    MercuryPlayerDisableGestureTypesDoubleTap    = 1 << 1,
    MercuryPlayerDisableGestureTypesPan          = 1 << 2,
    MercuryPlayerDisableGestureTypesPinch        = 1 << 3,
    MercuryPlayerDisableGestureTypesAll          = (MercuryPlayerDisableGestureTypesSingleTap | MercuryPlayerDisableGestureTypesDoubleTap | MercuryPlayerDisableGestureTypesPan | MercuryPlayerDisableGestureTypesPinch)
};

/// This enumeration lists some of the pan gesture moving direction that the player not support.
typedef NS_OPTIONS(NSUInteger, MercuryPlayerDisablePanMovingDirection) {
    MercuryPlayerDisablePanMovingDirectionNone         = 0,       /// Not disable pan moving direction.
    MercuryPlayerDisablePanMovingDirectionVertical     = 1 << 0,  /// Disable pan moving vertical direction.
    MercuryPlayerDisablePanMovingDirectionHorizontal   = 1 << 1,  /// Disable pan moving horizontal direction.
    MercuryPlayerDisablePanMovingDirectionAll          = (MercuryPlayerDisablePanMovingDirectionVertical | MercuryPlayerDisablePanMovingDirectionHorizontal)  /// Disable pan moving all direction.
};

@interface MercuryPlayerGestureControl : NSObject

/// Gesture condition callback.
@property (nonatomic, copy, nullable) BOOL(^triggerCondition)(MercuryPlayerGestureControl *control, MercuryPlayerGestureType type, UIGestureRecognizer *gesture, UITouch *touch);

/// Single tap gesture callback.
@property (nonatomic, copy, nullable) void(^singleTapped)(MercuryPlayerGestureControl *control);

/// Double tap gesture callback.
@property (nonatomic, copy, nullable) void(^doubleTapped)(MercuryPlayerGestureControl *control);

/// Begin pan gesture callback.
@property (nonatomic, copy, nullable) void(^beganPan)(MercuryPlayerGestureControl *control, MercuryPanDirection direction, MercuryPanLocation location);

/// Pan gesture changing callback.
@property (nonatomic, copy, nullable) void(^changedPan)(MercuryPlayerGestureControl *control, MercuryPanDirection direction, MercuryPanLocation location, CGPoint velocity);

/// End the Pan gesture callback.
@property (nonatomic, copy, nullable) void(^endedPan)(MercuryPlayerGestureControl *control, MercuryPanDirection direction, MercuryPanLocation location);

/// Pinch gesture callback.
@property (nonatomic, copy, nullable) void(^pinched)(MercuryPlayerGestureControl *control, float scale);

/// The single tap gesture.
@property (nonatomic, strong, readonly) UITapGestureRecognizer *singleTap;

/// The double tap gesture.
@property (nonatomic, strong, readonly) UITapGestureRecognizer *doubleTap;

/// The pan tap gesture.
@property (nonatomic, strong, readonly) UIPanGestureRecognizer *panGR;

/// The pinch tap gesture.
@property (nonatomic, strong, readonly) UIPinchGestureRecognizer *pinchGR;

/// The pan gesture direction.
@property (nonatomic, readonly) MercuryPanDirection panDirection;

/// The pan location.
@property (nonatomic, readonly) MercuryPanLocation panLocation;

/// The moving drection.
@property (nonatomic, readonly) MercuryPanMovingDirection panMovingDirection;

/// The gesture types that the player not support.
@property (nonatomic) MercuryPlayerDisableGestureTypes disableTypes;

/// The pan gesture moving direction that the player not support.
@property (nonatomic) MercuryPlayerDisablePanMovingDirection disablePanMovingDirection;

/**
 Add  all gestures(singleTap、doubleTap、panGR、pinchGR) to the view.
 */
- (void)addGestureToView:(UIView *)view;

/**
 Remove all gestures(singleTap、doubleTap、panGR、pinchGR) form the view.
 */
- (void)removeGestureToView:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
