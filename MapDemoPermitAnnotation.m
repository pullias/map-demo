//
//  MapDemoPermitAnnotation.m
//  Map Demo
//
//  Created by Jason Pullias on 5/24/14.
//  Copyright (c) 2014 pullias.com. All rights reserved.
//

#import "MapDemoPermitAnnotation.h"

@interface MapDemoPermitAnnotation()
@property (nonatomic, strong) NSNumber * lat;
@property (nonatomic, strong) NSNumber * lng;
@property (nonatomic, strong) NSString * address;
@property (nonatomic, strong) NSNumber * valuation;
@end

@implementation MapDemoPermitAnnotation

- (id)initWithDict:(NSDictionary*)permitDict {
    self = [super init];
    // should check that valueForKey actually returns the expected types
    self.lat = [permitDict valueForKey:@"lat"];
    self.lng = [permitDict valueForKey:@"lng"];
    self.address = [permitDict valueForKey:@"address"];
    self.valuation = [permitDict valueForKey:@"valuation"];
    return self;
}

- (CLLocationCoordinate2D)coordinate {
    return CLLocationCoordinate2DMake([self.lat doubleValue], [self.lng doubleValue]);
}

@end
