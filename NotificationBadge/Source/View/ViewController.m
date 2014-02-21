//
//  ViewController.m
//  NotificationBadge
//
//  Created by Jonah Grant on 2/21/14.
//  Copyright (c) 2014 Jonah Grant. All rights reserved.
//

#import "ViewController.h"

static NSString * const kNotificationIconImageName = @"icn_perch_notifications_default";
static NSString * const kBadgeImageName = @"bg_tab_bar_badge";

static NSString * const kScaleAnimationKeyPath = @"bounds";
static NSString * const kPathAnimationKeyPath = @"position";

static const CGFloat kScaleAnimationDuration = 0.2;

static const NSInteger kBadgeOriginXOffset = - 5;
static const NSInteger kBadgeOriginYOffset = 10;
static const NSInteger kBadgeDestinationXOffset = 17;
static const NSInteger kBadgeDestinationYOffset = - 15;

@interface ViewController ()

@property (strong, nonatomic) CALayer *notificationIconLayer, *badgeLayer;
@property (strong, nonatomic) UIImage *badgeImage;
@property (nonatomic) BOOL badgeVisible;

- (void)prepareInterface;
- (void)animate;
- (void)animateIn;
- (void)animateOut;

@end

@implementation ViewController

#pragma UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepareInterface];
}

#pragma Interface

- (void)prepareInterface {
    UIButton *animateButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    animateButton.frame = CGRectMake(CGRectGetWidth(self.view.frame) / 2 - 50, 100, 100, 50);
    [animateButton setTitle:@"Animate" forState:UIControlStateNormal];
    [animateButton addTarget:self action:@selector(animate) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:animateButton];
    
    UIImage *notificationIconImage = [UIImage imageNamed:kNotificationIconImageName];
    
    _notificationIconLayer = [CALayer layer];
    _notificationIconLayer.position = self.view.center;
    _notificationIconLayer.bounds = CGRectMake(0, 0, notificationIconImage.size.width, notificationIconImage.size.height);
    _notificationIconLayer.contents = (__bridge id)[notificationIconImage CGImage];
    
    [self.view.layer addSublayer:_notificationIconLayer];
    
    _badgeImage = [UIImage imageNamed:kBadgeImageName];
    
    _badgeLayer = [CALayer layer];
    _badgeLayer.position = CGPointMake(self.view.center.x + kBadgeOriginXOffset, self.view.center.y + kBadgeOriginYOffset);
    _badgeLayer.bounds = CGRectZero;
    _badgeLayer.contents = (__bridge id)[_badgeImage CGImage];
    
    [self.view.layer addSublayer:_badgeLayer];
}

#pragma Animations

- (void)animate {
    if (_badgeVisible) {
        [self animateOut];
    } else {
        [self animateIn];
    }
    
    _badgeVisible = !_badgeVisible;
}

- (void)animateIn {
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:kScaleAnimationKeyPath];
    scaleAnimation.fromValue = [NSValue valueWithCGRect:_badgeLayer.bounds];
    scaleAnimation.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, _badgeImage.size.width, _badgeImage.size.height)];
    scaleAnimation.autoreverses = NO;
    scaleAnimation.fillMode = kCAFillModeForwards;
    scaleAnimation.removedOnCompletion = NO;
    scaleAnimation.duration = kScaleAnimationDuration;
    scaleAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];

    CGPoint badgeOrigin = CGPointMake(_badgeLayer.frame.origin.x + _badgeLayer.bounds.size.width / 2.0f,
                                      _badgeLayer.frame.origin.y + _badgeLayer.bounds.size.height / 2.0f);
    
    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:kPathAnimationKeyPath];
    pathAnimation.calculationMode = kCAAnimationPaced;
    pathAnimation.fillMode = kCAFillModeForwards;
    pathAnimation.removedOnCompletion = NO;
    CGPoint endPoint = CGPointMake(_badgeLayer.position.x + kBadgeDestinationXOffset, _badgeLayer.position.y + kBadgeDestinationYOffset);
    CGMutablePathRef curvedPath = CGPathCreateMutable();
    CGPathMoveToPoint(curvedPath, NULL, badgeOrigin.x, badgeOrigin.y);
    CGPathAddCurveToPoint(curvedPath, NULL, endPoint.x, badgeOrigin.y, endPoint.x, badgeOrigin.y, endPoint.x, endPoint.y);
    pathAnimation.path = curvedPath;
    CGPathRelease(curvedPath);

    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = @[scaleAnimation, pathAnimation];
    group.duration = 0.2f;
    group.fillMode = kCAFillModeForwards;
    group.removedOnCompletion = NO;
    group.delegate = self;
    [group setValue:_badgeLayer forKey:@"animateInGroup"];
    
    [_badgeLayer addAnimation:group forKey:@"animateIn"];
}

- (void)animateOut {
    CGRect fromRect = CGRectMake(_badgeLayer.position.x + kBadgeDestinationXOffset,
                                 _badgeLayer.position.y + kBadgeDestinationYOffset,
                                 _badgeImage.size.width,
                                 _badgeImage.size.height);
    
    CGRect toRect = CGRectMake(_badgeLayer.position.x + kBadgeDestinationXOffset,
                               _badgeLayer.position.y + kBadgeDestinationYOffset,
                               0,
                               0);
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:kScaleAnimationKeyPath];
    scaleAnimation.fromValue = [NSValue valueWithCGRect:fromRect];
    scaleAnimation.toValue = [NSValue valueWithCGRect:toRect];
    scaleAnimation.autoreverses = NO;
    scaleAnimation.fillMode = kCAFillModeForwards;
    scaleAnimation.removedOnCompletion = NO;
    scaleAnimation.duration = kScaleAnimationDuration;
    scaleAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    [_badgeLayer addAnimation:scaleAnimation forKey:@"animateOut"];
}

@end
