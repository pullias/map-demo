//
//  MapDemoTextViewWithGradient.m
//  Map Demo
//
//  Created by Jason Pullias on 5/27/14.
//  Copyright (c) 2014 pullias.com. All rights reserved.
//

#import "MapDemoTextViewWithGradient.h"

@implementation MapDemoTextViewWithGradient

#define GRADIENT_HEIGHT 20

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = self;
        self.layer.cornerRadius = 5;
        [self.layer setBorderColor:[UIColor grayColor].CGColor];
        [self.layer setBorderWidth:0.5];
    }
    return self;
}

- (void)drawBottomGradient {
    // increase gradient height closer to edge of scrollView
    CGFloat gradientHeight = MIN(self.finalContentHeight - self.contentOffset.y - self.bounds.size.height, GRADIENT_HEIGHT);
    CGRect rect = CGRectMake(self.bounds.origin.x, self.bounds.origin.y + self.bounds.size.height - gradientHeight, self.bounds.size.width, gradientHeight);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    NSArray *gradientColors = [NSArray arrayWithObjects:(id) [UIColor whiteColor].CGColor, [UIColor grayColor].CGColor, nil];
    
    CGFloat gradientLocations[] = {0, 1};
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) gradientColors, gradientLocations);
    
    CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
    
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
}

- (void)drawTopGradient {
    CGFloat gradientHeight = MIN(self.contentOffset.y, GRADIENT_HEIGHT);
    CGRect rect = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, gradientHeight);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    NSArray *gradientColors = [NSArray arrayWithObjects:(id) [UIColor grayColor].CGColor, [UIColor whiteColor].CGColor, nil];
    
    CGFloat gradientLocations[] = {0, 1};
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) gradientColors, gradientLocations);
    
    CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
    
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
}

- (void)drawRect:(CGRect)rect
{
    if (self.finalContentHeight > self.bounds.size.height) {
        if (self.contentOffset.y > 0) {
            [self drawTopGradient];
        }
        if (self.contentOffset.y + self.bounds.size.height < self.finalContentHeight) {
            [self drawBottomGradient];
        }
    }
}

- (void)invalidateGradientRectIfNeeded {
    if (self.contentOffset.y < GRADIENT_HEIGHT) {
        [self setNeedsDisplay];
    } else if (self.finalContentHeight - self.contentOffset.y - self.bounds.size.height < GRADIENT_HEIGHT) {
        [self setNeedsDisplay];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self invalidateGradientRectIfNeeded];
}

@end
