//
//  MapDemoAnnotationView.h
//  Map Demo
//
//  Created by Jason Pullias on 5/26/14.
//  Copyright (c) 2014 pullias.com. All rights reserved.
//

#import <MapKit/MapKit.h>

@class MapDemoAnnotationView;
@protocol MapDemoAnnotationViewDelegate <NSObject>
@required
- (CGFloat) statusBarHeight;
@end

@interface MapDemoAnnotationView : MKAnnotationView
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSString * subtitle;
@property (nonatomic, weak) id <MapDemoAnnotationViewDelegate> delegate;
@end
