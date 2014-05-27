//
//  MapDemoCalloutView.h
//  Map Demo
//
//  Created by Jason Pullias on 5/26/14.
//  Copyright (c) 2014 pullias.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MapDemoCalloutView : UIView

@property (nonatomic)CGPoint anchorPoint;
- (void)setTitle:(NSString *)title andSubTitle:(NSString *)subTitle;

@end
