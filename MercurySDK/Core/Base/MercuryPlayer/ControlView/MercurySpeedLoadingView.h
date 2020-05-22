//
//  MercurySpeedLoadingView.h
//  Pods-MercuryPlayer_Example
//
//  Created by 紫枫 on 2018/6/27.
//

#import <UIKit/UIKit.h>
#import "MercuryLoadingView.h"

@interface MercurySpeedLoadingView : UIView

@property (nonatomic, strong) MercuryLoadingView *loadingView;

@property (nonatomic, strong) UILabel *speedTextLabel;

/**
 *  Starts animation of the spinner.
 */
- (void)startAnimating;

/**
 *  Stops animation of the spinnner.
 */
- (void)stopAnimating;

@end
