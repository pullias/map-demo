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
#define SCREEN_MARGIN 10

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
    // make the annotation view big enough to position the callout above or below image and offset to the left or right
    self.bounds = CGRectMake(0, 0, CALLOUT_WIDTH*2, CALLOUT_HEIGHT*2 + IMAGE_HEIGHT);
    [_calloutView removeFromSuperview]; // don't access calloutView getter to avoid creating calloutview here
    self.calloutView = nil;
    self.showingCallout = NO;
}

- (MapDemoCalloutView *)calloutView {
    if (!_calloutView) {
        _calloutView = [[MapDemoCalloutView alloc] initWithFrame:CGRectMake(0, 0, CALLOUT_WIDTH, CALLOUT_HEIGHT)];
        [_calloutView setTitle:self.title andSubTitle:self.subtitle];
    }
    return _calloutView;
}

- (void)positionCallout:(MapDemoCalloutView *) calloutView {
    // default position would be centered horizontally above the image
    calloutView.center = CGPointMake(self.frame.size.width/2, self.imageView.frame.origin.y - calloutView.frame.size.height/2);
    // try to position callout so it appears on screen without scrolling
    CGPoint imageCenterInScreenCoords = [self convertPoint:self.imageView.center toView:self.superview];
    CGPoint calloutCenterInScreenCoords = [self convertPoint:calloutView.center toView:self.superview];
    CGFloat leftEdge = calloutCenterInScreenCoords.x - calloutView.bounds.size.width / 2;
    CGFloat rightEdge = calloutCenterInScreenCoords.x + calloutView.bounds.size.width / 2;
    CGFloat calloutWidth = calloutView.frame.size.width;
    CGFloat imageWidth = self.imageView.frame.size.width;
    CGFloat screenWidth = self.superview.bounds.size.width;
    // position horizontally
    CGFloat xOffset = 0;
    CGPoint mapScroll = CGPointZero;
    if (leftEdge < SCREEN_MARGIN) {
        if (imageCenterInScreenCoords.x - imageWidth/2 < 0) {
            // image is off the left edge
            // position callout so that the left edge aligns with the left edge of the image
            xOffset = (calloutWidth-imageWidth)/2;
            // scroll map horizontally so the left edge of the image aligns with the margin
            mapScroll.x = -1*(SCREEN_MARGIN + imageWidth/2 - imageCenterInScreenCoords.x);
        } else {
            // image is on screen, adjust callout to horizontally align with left margin
            xOffset = (SCREEN_MARGIN-leftEdge);
        }
    } else if (rightEdge > screenWidth-SCREEN_MARGIN) {
        if (imageCenterInScreenCoords.x + imageWidth/2 > screenWidth) {
            // image is off the right edge
            // position callout so that the right edge aligns with the right edge of the image
            xOffset = (calloutWidth-imageWidth)/-2;
            // scroll map horizontally so the left edge of the image aligns with the margin
            mapScroll.x = (imageWidth/2 + imageCenterInScreenCoords.x - screenWidth + SCREEN_MARGIN);
        } else {
            // image is on screen, adjust callout to horizontally align with right margin
            xOffset = (screenWidth-10) - rightEdge;
        }
    }
    CGFloat calloutHeight = calloutView.frame.size.height;
    calloutView.center = CGPointMake(calloutView.center.x + xOffset, calloutView.center.y);
    calloutView.anchorPoint = CGPointMake(calloutView.frame.size.width/2 - xOffset, calloutHeight);
    // position vertically
    CGFloat statusBarHeight = [self.delegate statusBarHeight];
    CGFloat screenHeight = self.superview.bounds.size.height;
    if (calloutCenterInScreenCoords.y -  calloutHeight/2 < statusBarHeight) {
        // top of callout is off screen
        CGFloat imageHeight = self.imageView.frame.size.height;
        if (imageCenterInScreenCoords.y + imageHeight/2 + calloutHeight < screenHeight) {
            // callout will fit below the image
            calloutView.center = CGPointMake(calloutView.center.x, self.imageView.center.y + (imageHeight + calloutHeight)/2);
            calloutView.anchorPoint = CGPointMake(calloutView.anchorPoint.x, 0);
        } else {
            // scroll map to fit callout above image
            mapScroll.y = -1*(statusBarHeight + SCREEN_MARGIN - (calloutCenterInScreenCoords.y - calloutHeight/2));
        }
    }
    if (mapScroll.x || mapScroll.y) {
        [self scrollMapView:mapScroll];
    }
    [calloutView setNeedsDisplay]; // redraw the triangle since the position may have changed
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    // [super setSelected] has the side effect of bringing this annotation to the front of all other annotations
    [super setSelected:selected animated:animated];
    if (selected) {
        self.showingCallout = YES;
        [self addSubview:self.calloutView];
        [self positionCallout:self.calloutView];
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
    self.imageView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    [self addSubview:self.imageView];
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

- (void)scrollMapView: (CGPoint) pointsToScroll {
    UIView * parentView = [self superview];
    while (parentView && ![parentView isKindOfClass:[MKMapView class]]) {
        parentView = [parentView superview];
    }
    MKMapView * mapView = (MKMapView *)parentView;
    CGPoint centerPoint = [mapView convertCoordinate:[mapView centerCoordinate] toPointToView:mapView];
    CGPoint newCenterPoint = CGPointMake(centerPoint.x + pointsToScroll.x, centerPoint.y + pointsToScroll.y);
    CLLocationCoordinate2D newCenterCoord = [mapView convertPoint:newCenterPoint toCoordinateFromView:mapView];
    [mapView setCenterCoordinate:newCenterCoord animated:YES];
}

@end
