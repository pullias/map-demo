//
//  MapDemoClusterGrid.m
//  Map Demo
//
//  Created by Jason Pullias on 5/25/14.
//  Copyright (c) 2014 pullias.com. All rights reserved.
//

#import "MapDemoClusterGrid.h"

@interface MapDemoClusterGrid()
@property (nonatomic, strong) NSMutableDictionary * gridDict;
@property (nonatomic) double gridSize;
@end

@implementation MapDemoClusterGrid

- (id)initWithGridSize:(double)gridSize {
    self = [super init];
    self.gridSize = gridSize;
    return self;
}

- (NSMutableDictionary *)gridDict {
    if (!_gridDict) {
        _gridDict = [[NSMutableDictionary alloc] init];
    }
    return _gridDict;
}

- (void)addObject:(NSObject *)objectToAdd toGridAtMapPoint:(MKMapPoint)mapPoint {
    NSString * key = [self keyForMapPoint:mapPoint];
    NSMutableArray * objectsInGridCell = [self.gridDict objectForKey:key];
    if (!objectsInGridCell) {
        // add new mutable array with the new object
        [self.gridDict setValue:[[NSMutableArray alloc] initWithArray:@[objectToAdd]] forKey:key];
    } else {
        // add new object to array of objects at this grid cell
        [objectsInGridCell addObject:objectToAdd];
    }
}

- (void)removeObject:(NSObject*)objectToRemove fromGridAtMapPoint:(MKMapPoint)mapPoint {
    NSString * key = [self keyForMapPoint:mapPoint];
    NSMutableArray * objectsInGridCell = [self.gridDict objectForKey:key];
    [objectsInGridCell removeObject:objectToRemove];
    if ([objectsInGridCell count] == 0) {
        [self.gridDict removeObjectForKey:key];
    }
}

// returns all objects within the grid cell of mapPoint, and all objects in the 8 surrounding cells
- (NSArray *)objectsNearMapPoint:(MKMapPoint)mapPoint {
    NSMutableArray * nearbyObjects = [[NSMutableArray alloc] init];
    int x = (mapPoint.x / self.gridSize);
    int y = (mapPoint.y / self.gridSize);
    NSArray * nearbyClusterCellKeys = @[[NSString stringWithFormat:@"%d,%d",x-1,y-1],
                                        [NSString stringWithFormat:@"%d,%d",x-1,y],
                                        [NSString stringWithFormat:@"%d,%d",x-1,y+1],
                                        [NSString stringWithFormat:@"%d,%d",x,y-1],
                                        [NSString stringWithFormat:@"%d,%d",x,y],
                                        [NSString stringWithFormat:@"%d,%d",x,y+1],
                                        [NSString stringWithFormat:@"%d,%d",x+1,y-1],
                                        [NSString stringWithFormat:@"%d,%d",x+1,y],
                                        [NSString stringWithFormat:@"%d,%d",x+1,y+1]];
    for (NSString * key in nearbyClusterCellKeys) {
        NSArray * objectsInGridCell = [self.gridDict objectForKey:key];
        if (objectsInGridCell) {
            [nearbyObjects addObjectsFromArray:objectsInGridCell];
        }
    }
    return nearbyObjects;
}

// A List of Close Objects contains every object in a grid cell, the cell above it, the cell directly to the right,
// and the two cells diagonally adjacent to on the right
// Therefore, even though an object can appear in multiple lists, a pair of objects will only appear in a single list
// By pairing the items in each list, the caller knows all pairs of objects within one grid cell
// (note the distance of the pair may exceed the width of a single cell)
- (NSArray *)listsOfCloseObjects {
    NSMutableArray * results = [[NSMutableArray alloc] init];
    for (NSString * key in [self.gridDict allKeys]) {
        NSArray * closeObjects = [self neighborObjectsAboveAndToRightOfCellWithKey:key];
        if ([closeObjects count] > 1) {
            [results addObject:closeObjects];
        }
    }
    return results;
}

// Return all objects in the grid
- (NSArray *)allObjects {
    NSMutableArray * allObjects = [[NSMutableArray alloc] init];
    for (NSString * key in [self.gridDict allKeys]) {
        [allObjects addObjectsFromArray:[self.gridDict valueForKey:key]];
    }
    return allObjects;
}

// Return all the objects in the target cell, the cell above, the cell to the right, and the two cells diagonally to the right
- (NSArray *)neighborObjectsAboveAndToRightOfCellWithKey:(NSString *)key {
    NSArray * components = [key componentsSeparatedByString:@","];
    int x = [components[0] intValue];
    int y = [components[1] intValue];
    NSArray * neighborClusterKeys = @[[NSString stringWithFormat:@"%d,%d",x,y],
                                      [NSString stringWithFormat:@"%d,%d",x,y+1],
                                      [NSString stringWithFormat:@"%d,%d",x+1,y+1],
                                      [NSString stringWithFormat:@"%d,%d",x+1,y],
                                      [NSString stringWithFormat:@"%d,%d",x+1,y-1]];
    NSMutableArray * neighborObjects = [[NSMutableArray alloc] init];
    for (NSString * key in neighborClusterKeys) {
        NSArray * clustersInCell = [self.gridDict valueForKey:key];
        if (clustersInCell) {
            [neighborObjects addObjectsFromArray:clustersInCell];
        }
    }
    return neighborObjects;
}

// Dictionary key represents a grid cell
- (NSString *)keyForMapPoint:(MKMapPoint)mapPoint {
    return [NSString stringWithFormat:@"%d,%d",(int)(mapPoint.x / self.gridSize),(int)(mapPoint.y / self.gridSize)];
}

// Returns a list of lists of objects that occupy the same grid cell
- (NSArray *)listsOfObjectsInGridCells {
    return [self.gridDict allValues];
}

@end
