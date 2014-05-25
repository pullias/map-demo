//
//  MapDemoClusterGrid.h
//  Map Demo
//
//  Created by Jason Pullias on 5/25/14.
//  Copyright (c) 2014 pullias.com. All rights reserved.
//

#import <Foundation/Foundation.h>
@import MapKit;

@interface MapDemoClusterGrid : NSObject

- (id)initWithGridSize:(double)gridSize;
- (void)addObject:(NSObject *)objectToAdd toGridAtMapPoint:(MKMapPoint)mapPoint;
- (void)removeObject:(NSObject*)objectToRemove fromGridAtMapPoint:(MKMapPoint)mapPoint;
- (NSArray *)objectsNearMapPoint:(MKMapPoint)mapPoint;
- (NSArray *)listsOfCloseObjects;
- (NSArray *)allObjects;
- (NSArray *)listsOfObjectsInGridCells;

@end
