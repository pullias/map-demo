//
//  MapDemoPermit.h
//  Map Demo
//
//  Created by Jason Pullias on 5/25/14.
//  Copyright (c) 2014 pullias.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MapDemoPermit : NSObject
@property (nonatomic, strong) NSNumber * lat;
@property (nonatomic, strong) NSNumber * lng;
@property (nonatomic, strong) NSString * address;
@property (nonatomic, strong) NSNumber * valuation;
@property (nonatomic, strong) NSNumber * permitType;

- (id)initWithDict:(NSDictionary*)permitDict;

@end
