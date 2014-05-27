//
//  MapDemoColoredCircleMaker.m
//  Map Demo
//
//  Created by Jason Pullias on 5/24/14.
//  Copyright (c) 2014 pullias.com. All rights reserved.
//

#import "MapDemoColoredCircleMaker.h"
@import CoreText;

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

+ (UIImage *)circleWithColor:(UIColor*)color andNumber:(NSUInteger)number {
    CGFloat diameter = 44.f;
    // Use CoreGraphics to draw a circle
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(diameter, diameter), NO, 0.0f);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    
    CGRect rect = CGRectMake(0, 0, diameter, diameter);
    CGContextClearRect(ctx, rect);
    CGContextSetFillColorWithColor(ctx, color.CGColor);
    CGContextFillEllipseInRect(ctx, rect);
    
    [self addNumber:number inContext:ctx];
    
    CGContextRestoreGState(ctx);
    UIImage * circle = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return circle;
}

+ (CTFontRef) font {
    static CTFontRef font = nil;
    if (!font) {
        font = CTFontCreateUIFontForLanguage(kCTFontSystemFontType, 20.0, NULL);
    }
    return font;
}

+ (void) addNumber:(NSUInteger)number inContext:(CGContextRef) ctx {
    // add text
    CTFontRef font = [MapDemoColoredCircleMaker font];
    CFStringRef string = (__bridge CFStringRef)([NSString stringWithFormat:@"%lu",number]);
    CFStringRef keys[] = { kCTFontAttributeName, kCTForegroundColorAttributeName };
    CFTypeRef values[] = { font , [UIColor whiteColor].CGColor};
    
    CFDictionaryRef attributes = CFDictionaryCreate(kCFAllocatorDefault, (const void**)&keys,
                                                    (const void**)&values, sizeof(keys) / sizeof(keys[0]),
                                                    &kCFTypeDictionaryKeyCallBacks,
                                                    &kCFTypeDictionaryValueCallBacks);
    CFAttributedStringRef attrString = CFAttributedStringCreate(kCFAllocatorDefault, string, attributes);
    CFRelease(string);
    CFRelease(attributes);
    CTLineRef line = CTLineCreateWithAttributedString(attrString);
    CGRect textRect = CTLineGetImageBounds(line, ctx);
    if (textRect.size.width > 38.f) {
        // do it again with smaller font
        CTFontRef smallerFont = CTFontCreateUIFontForLanguage(kCTFontSystemFontType, 18.0, NULL);
        CFTypeRef values[] = { smallerFont , [UIColor whiteColor].CGColor};
        CFDictionaryRef attributes = CFDictionaryCreate(kCFAllocatorDefault, (const void**)&keys,
                                                        (const void**)&values, sizeof(keys) / sizeof(keys[0]),
                                                        &kCFTypeDictionaryKeyCallBacks,
                                                        &kCFTypeDictionaryValueCallBacks);
        attrString = CFAttributedStringCreate(kCFAllocatorDefault, string, attributes);
        CFRelease(string);
        CFRelease(attributes);
        line = CTLineCreateWithAttributedString(attrString);
        textRect = CTLineGetImageBounds(line, ctx);
    }
    CGContextSetTextMatrix(ctx, CGAffineTransformMakeScale(1.0f, -1.0f)); // flip text right side up
    float x = (44.f-textRect.size.width-textRect.origin.x)/2;
    float y = (44.f-textRect.size.height-textRect.origin.y)/2+textRect.size.height;
    CGContextSetTextPosition(ctx, x, y);
    CTLineDraw(line, ctx);
    CFRelease(line);
    //CFRelease(attrString); // It crashes when I release this, why?
}

+ (UIImage *)pieChartWithProportions:(NSArray *)proportions andColors:(NSArray *)colors andNumber:(NSUInteger)number {
    // make a pie chart with diameter 44
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(44.f, 44.f), NO, 0.0f);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    
    CGRect rect = CGRectMake(0, 0, 44.f, 44.f);
    CGContextClearRect(ctx, rect);
    
    double radialPosition = 0;
    
    for (int i = 0; i < [proportions count]; i++) {
        NSNumber * proportion = [proportions objectAtIndex:i];
        UIColor * color = [colors objectAtIndex:i];
        if ([proportion doubleValue] == 1.0) {
            CGContextSetFillColorWithColor(ctx, color.CGColor);
            CGContextFillEllipseInRect(ctx, rect);
        }
        else if ([proportion doubleValue] > 0.00001) {
            // move pen to center of circle
            CGContextMoveToPoint(ctx, 22.f, 22.f);
            // draw arc from 0 to pi/2 radians, clockwise
            double proportionInRadians = (2*M_PI) * [proportion doubleValue];
            CGContextAddArc(ctx, 22.f, 22.f, 22.f, radialPosition, radialPosition + proportionInRadians, 0);
            radialPosition += proportionInRadians;
            // move pen back to center of circle
            CGContextClosePath(ctx);
            // fill slice with the color
            CGContextSetFillColorWithColor(ctx, color.CGColor);
            CGContextFillPath(ctx);
        }
    }
    
    if (number > 0) {
        [self addNumber:number inContext:ctx];
    }

    CGContextRestoreGState(ctx);
    UIImage * circle = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return circle;
}

@end
