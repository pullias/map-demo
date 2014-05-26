//
//  MapDemoAnnotationView.m
//  Map Demo
//
//  Created by Jason Pullias on 5/26/14.
//  Copyright (c) 2014 pullias.com. All rights reserved.
//

#import "MapDemoAnnotationView.h"
#import "MapDemoCalloutView.h"

@interface MapDemoAnnotationView()
@property (nonatomic, strong) MapDemoCalloutView * calloutView;
@property (nonatomic) BOOL showingCallout;
@property (nonatomic, strong) UIImageView * imageView;
@end

#define CALLOUT_WIDTH 300
#define CALLOUT_HEIGHT 200
#define IMAGE_HEIGHT 44

@implementation MapDemoAnnotationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self prepareForReuse];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.bounds = CGRectMake(0, 0, CALLOUT_WIDTH, CALLOUT_HEIGHT + IMAGE_HEIGHT);
    [self.calloutView removeFromSuperview];
    self.calloutView = nil;
    self.showingCallout = NO;
}

- (MapDemoCalloutView *)calloutView {
    if (!_calloutView) {
        _calloutView = [[MapDemoCalloutView alloc] initWithFrame:CGRectMake(0, 0, CALLOUT_WIDTH, CALLOUT_HEIGHT)];
    }
    return _calloutView;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (selected) {
        self.showingCallout = YES;
        [self.calloutView setTitle:self.title andSubTitle:self.subtitle];
        [self addSubview:self.calloutView];
    } else {
        self.showingCallout = NO;
        [self.calloutView removeFromSuperview];
    }
}

- (void)setImage:(UIImage *)image {
    // override this so the bounds don't get set to the image bounds
    if (self.imageView) {
        [self.imageView removeFromSuperview];
    }
    self.imageView = [[UIImageView alloc] initWithImage:image];
    [self.imageView sizeToFit];
    // position the annotation image below the space for the callout
    self.imageView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height - IMAGE_HEIGHT/2);
    [self addSubview:self.imageView];
}

- (CGPoint)centerOffset {
    // normally the mapView centers the annotation view on the coordinate, but since the image is not in the center of the annotation view, we return an offset of the difference between the center of this view and the center of the image
    return CGPointMake(0, -1*(self.frame.size.height/2-self.imageView.frame.size.height/2));
}

// override hittest to ignore taps on the transparent area
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    for (UIView * subview in self.subviews) {
        if (CGRectContainsPoint(subview.frame, point)) {
            if ([subview isKindOfClass:[MapDemoCalloutView class]]) {
                // need to translate point into the subview's coordinate
                UIView * hitTestView = [subview hitTest:[self convertPoint:point toView:subview] withEvent:event];
                return hitTestView;
            } else {
                return self;
            }
        }
    }
    return nil; // point was probably in the empty area to the left and right of annotation
}

@end
