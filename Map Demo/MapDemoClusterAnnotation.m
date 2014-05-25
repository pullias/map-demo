//
//  MapDemoClusterAnnotation.m
//  Map Demo
//
//  Created by Jason Pullias on 5/24/14.
//  Copyright (c) 2014 pullias.com. All rights reserved.
//

#import "MapDemoClusterAnnotation.h"

@interface MapDemoClusterAnnotation()
@property (nonatomic) CLLocationCoordinate2D actualLocation;
@property (nonatomic, readwrite) MKMapPoint mapPoint;
@property (nonatomic, strong) NSMutableArray * permits;
@end

@implementation MapDemoClusterAnnotation

//#define REFERENCE_LATITUDE 36.5 /* Used to convert meters to grid points, since a map grid gets smaller at higher latitudes */

- (id)initWithPermit:(MapDemoPermit *)permit {
    self = [super init];
    self.permits = [[NSMutableArray alloc] initWithObjects:permit, nil];
    self.actualLocation = CLLocationCoordinate2DMake([permit.lat doubleValue], [permit.lng doubleValue]);
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    MapDemoClusterAnnotation * copy = [[MapDemoClusterAnnotation allocWithZone:zone] init];
    copy.actualLocation = self.actualLocation; // sets self.mapPoint
    copy.permits = [self.permits mutableCopy];
    return copy;
}

- (void)addPermitAtSameLocation:(MapDemoPermit *)permit {
    [self.permits addObject:permit];
}

// Implement MKAnnotation protocol
- (CLLocationCoordinate2D)coordinate {
    return self.actualLocation;
}

- (void)setActualLocation:(CLLocationCoordinate2D)actualLocation {
    // update self.mapPoint when location is set
    _actualLocation = actualLocation;
    self.mapPoint = MKMapPointForCoordinate(actualLocation);
}

- (MapDemoClusterAnnotation *)newAnnotationByCombiningWith:(MapDemoClusterAnnotation *)otherAnnotation {
    MapDemoClusterAnnotation * newAnnotation = [self copy];
    // add permits in other annotation
    [newAnnotation.permits addObjectsFromArray:otherAnnotation.permits];
    // set coordinate of the new annotation as weighted average
    double myWeight = ((double)[self.permits count]) / ([self.permits count] + [otherAnnotation.permits count]);
    double otherWeight = ((double)[otherAnnotation.permits count]) / ([self.permits count] + [otherAnnotation.permits count]);
    newAnnotation.actualLocation = CLLocationCoordinate2DMake(self.actualLocation.latitude * myWeight + otherAnnotation.actualLocation.latitude * otherWeight,
                                                          self.actualLocation.longitude * myWeight + otherAnnotation.actualLocation.longitude * otherWeight);
    return newAnnotation;
}

- (double)mapPointDistanceFromAnnotation:(MapDemoClusterAnnotation *)otherAnnotation {
    MKMapPoint a = self.mapPoint;
    MKMapPoint b = otherAnnotation.mapPoint;
    double dx = a.x-b.x;
    double dy = a.y-b.y;
    // Yay, Pythagoras!
    return sqrt((dx*dx)+(dy*dy));
}

@end
