//
//  MapDemoColoredCircleMaker.m
//  Map Demo
//
//  Created by Jason Pullias on 5/24/14.
//  Copyright (c) 2014 pullias.com. All rights reserved.
//

#import "MapDemoColoredCircleMaker.h"

@implementation MapDemoColoredCircleMaker

+ (UIImage *)circleWithDiameter:(CGFloat)diameter andColor:(UIColor*)color {
    // Use CoreGraphics to draw a circle
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(diameter, diameter), NO, 0.0f);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    
    CGRect rect = CGRectMake(0, 0, diameter, diameter);
    CGContextClearRect(ctx, rect);
    CGContextSetFillColorWithColor(ctx, color.CGColor);
    CGContextFillEllipseInRect(ctx, rect);
    
    CGContextRestoreGState(ctx);
    UIImage * circle = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return circle;
}

@end
