//
//  MapDemoPermit.m
//  Map Demo
//
//  Created by Jason Pullias on 5/25/14.
//  Copyright (c) 2014 pullias.com. All rights reserved.
//

#import "MapDemoPermit.h"

@interface MapDemoPermit()

@end

@implementation MapDemoPermit

- (id)initWithDict:(NSDictionary*)permitDict {
    self = [super init];
    // should check that valueForKey actually returns the expected types
    self.lat = [permitDict valueForKey:@"lat"];
    self.lng = [permitDict valueForKey:@"lng"];
    self.address = [permitDict valueForKey:@"address"];
    self.valuation = [permitDict valueForKey:@"valuation"];
    self.permitType = [permitDict valueForKey:@"permitType"];
    return self;
}



@end
