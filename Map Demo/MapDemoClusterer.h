//
//  MapDemoClusterer.h
//  Map Demo
//
//  Created by Jason Pullias on 5/24/14.
//  Copyright (c) 2014 pullias.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MapDemoClusterer : NSObject

- (void)setPermitsAsync:(NSArray *)permits andClusterToDistanceInMapPoints:(double)distance andExecuteBlock:(void (^)(NSArray * clusters)) block;

//- (NSArray *)setPermits:(NSArray *)permits andClusterToDistanceInMapPoints:(double)distance;

@end
