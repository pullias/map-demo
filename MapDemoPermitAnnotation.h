//
//  MapDemoPermitAnnotation.h
//  Map Demo
//
//  Created by Jason Pullias on 5/24/14.
//  Copyright (c) 2014 pullias.com. All rights reserved.
//

#import <Foundation/Foundation.h>
@import MapKit;

@interface MapDemoPermitAnnotation : NSObject <MKAnnotation>

- (id)initWithDict:(NSDictionary*)permitDict;
- (int)getPermitType;

@end
