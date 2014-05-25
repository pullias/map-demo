//
//  MapDemoColoredCircleMaker.h
//  Map Demo
//
//  Created by Jason Pullias on 5/24/14.
//  Copyright (c) 2014 pullias.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MapDemoColoredCircleMaker : NSObject

+ (UIImage *)circleWithDiameter:(CGFloat)diameter andColor:(UIColor*)color;
+ (UIImage *)circleWithColor:(UIColor*)color andNumber:(NSUInteger)number;

@end
