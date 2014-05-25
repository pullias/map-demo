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


@end
