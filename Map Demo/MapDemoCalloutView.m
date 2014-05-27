//
//  MapDemoCalloutView.m
//  Map Demo
//
//  Created by Jason Pullias on 5/26/14.
//  Copyright (c) 2014 pullias.com. All rights reserved.
//

#import "MapDemoCalloutView.h"
#import "MapDemoTextViewWithGradient.h"

@interface MapDemoCalloutView()
@property (nonatomic, strong) MapDemoTextViewWithGradient * textView;
@end

#define TRIANGLE_HEIGHT 8

@implementation MapDemoCalloutView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.textView];
    }
    return self;
}

- (MapDemoTextViewWithGradient *)textView {
    if (!_textView) {
        _textView = [[MapDemoTextViewWithGradient alloc] initWithFrame:self.bounds];
        _textView.scrollEnabled = YES;
        _textView.userInteractionEnabled = YES;
        _textView.editable = NO;
    }
    return _textView;
}

- (void)setAnchorPoint:(CGPoint)anchorPoint {
    _anchorPoint = anchorPoint;
    if (anchorPoint.y == 0) {
        // when the callout is below the annotation image, move textview down to make room for the triangle
        if (self.textView.frame.origin.y == 0) {
            self.textView.center = CGPointMake(self.textView.center.x, self.textView.center.y + TRIANGLE_HEIGHT);
        }
    } else {
        // textview should be aligned to top of callout view to make room for triangle below
        self.textView.frame = CGRectMake(0, 0, self.textView.frame.size.width, self.textView.frame.size.height);
    }
}

- (void)setTitle:(NSString *)title andSubTitle:(NSString *)subTitle {
    NSAttributedString * attributedTitle = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n",title] attributes:@{NSFontAttributeName:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]}];
    NSAttributedString * attributedSubtitle = [[NSAttributedString alloc] initWithString:subTitle attributes:@{NSFontAttributeName:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]}];
    
    NSMutableAttributedString * finalString = [[NSMutableAttributedString alloc] initWithAttributedString:attributedTitle];
    [finalString appendAttributedString:attributedSubtitle];

    // add line spacing between paragraphs
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.paragraphSpacing = 10;
    NSRange wholeRange = {0,[finalString length]};
    [finalString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:wholeRange];

    self.textView.attributedText = finalString;
    [self resizeToFitText];
}

- (void)resizeToFitText {
    CGSize textSize = [self.textView sizeThatFits:self.bounds.size];
    self.textView.finalContentHeight = textSize.height;
    textSize.height = MIN(textSize.height, self.bounds.size.height - TRIANGLE_HEIGHT); // crop height to fit the callout
    self.bounds = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, textSize.height + TRIANGLE_HEIGHT);
    self.textView.frame = CGRectMake(0, 0, self.bounds.size.width, textSize.height);
    [self.textView setNeedsDisplay];
}

// draw a triangle at the anchor point, pointing to the annotation image
// triangle width is twice the height
- (void)drawTriangle {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    
    CGRect rect = CGRectMake(self.anchorPoint.x, self.anchorPoint.y, TRIANGLE_HEIGHT*2, TRIANGLE_HEIGHT);
    CGContextClearRect(ctx, rect);
    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
    CGContextSetLineWidth(ctx, 0.5);
    if (self.anchorPoint.y == 0) {
        // triangle at the top of the frame, pointing up
        CGContextMoveToPoint(ctx, self.anchorPoint.x - TRIANGLE_HEIGHT, self.anchorPoint.y + TRIANGLE_HEIGHT);
        CGContextAddLineToPoint(ctx, self.anchorPoint.x + TRIANGLE_HEIGHT, self.anchorPoint.y + TRIANGLE_HEIGHT);
        CGContextAddLineToPoint(ctx, self.anchorPoint.x, self.anchorPoint.y);
    } else {
        // triangle at the bottom of the frame, pointing down
        CGContextMoveToPoint(ctx, self.anchorPoint.x - TRIANGLE_HEIGHT, self.anchorPoint.y - TRIANGLE_HEIGHT);
        CGContextAddLineToPoint(ctx, self.anchorPoint.x + TRIANGLE_HEIGHT, self.anchorPoint.y - TRIANGLE_HEIGHT);
        CGContextAddLineToPoint(ctx, self.anchorPoint.x, self.anchorPoint.y);
    }
    CGContextClosePath(ctx);
    CGContextDrawPath(ctx, kCGPathFillStroke);
}

- (void)drawRect:(CGRect)rect {
    [self drawTriangle];
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    // scroll textview to top
    [self.textView setContentOffset:CGPointMake(0, 0)];
}

@end
