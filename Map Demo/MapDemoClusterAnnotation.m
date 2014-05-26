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
@property (nonatomic, strong, readwrite) MapDemoClusterAnnotation * parent;
@property (nonatomic) CLLocationCoordinate2D coordinate;
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

- (NSString *)title {
    return [self permit].address;
}

- (NSString *)subtitle {
    return [[self currencyFormatter] stringFromNumber:[self permit].valuation];
}

- (NSNumberFormatter *)currencyFormatter {
    static NSNumberFormatter * formatter = nil;
    if (!formatter) {
        formatter = [[NSNumberFormatter alloc]init];
        [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [formatter setMaximumFractionDigits:0];
    }
    return formatter;
}

- (void)setActualLocation:(CLLocationCoordinate2D)actualLocation {
    // update self.mapPoint when location is set
    _actualLocation = actualLocation;
    self.mapPoint = MKMapPointForCoordinate(actualLocation);
    self.coordinate = self.actualLocation;
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
    self.parent = newAnnotation;
    otherAnnotation.parent = newAnnotation;
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

- (NSUInteger)countOfPermits {
    return [self.permits count];
}

- (MapDemoPermit *)permit {
    return [self.permits firstObject];
}

- (void)moveToAlternateLocation {
    self.coordinate = self.alternateLocation;
}

- (void)moveToActualLocation {
    self.coordinate = self.actualLocation;
}

@end
