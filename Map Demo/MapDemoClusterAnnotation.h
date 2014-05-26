//
//  MapDemoClusterAnnotation.h
//  Map Demo
//
//  Created by Jason Pullias on 5/24/14.
//  Copyright (c) 2014 pullias.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MapDemoPermit.h"
@import MapKit;

@interface MapDemoClusterAnnotation : NSObject <MKAnnotation, NSCopying>

@property (nonatomic, readonly) MKMapPoint mapPoint;
@property (nonatomic, strong, readonly) MapDemoClusterAnnotation * parent;
@property (nonatomic) CLLocationCoordinate2D alternateLocation;

- (id)initWithPermit:(MapDemoPermit *)permit;
- (MapDemoClusterAnnotation *)newAnnotationByCombiningWith:(MapDemoClusterAnnotation *)otherAnnotation;
- (void)addPermitAtSameLocation:(MapDemoPermit *)permit;

- (double)mapPointDistanceFromAnnotation:(MapDemoClusterAnnotation *)otherAnnotation;
- (NSUInteger)countOfPermits;
- (MapDemoPermit *)permit;

- (void)moveToAlternateLocation;
- (void)moveToActualLocation;

@end
