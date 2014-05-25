//
//  MapDemoClusterer.m
//  Map Demo
//
//  Created by Jason Pullias on 5/24/14.
//  Copyright (c) 2014 pullias.com. All rights reserved.
//

#import "MapDemoClusterer.h"
#import "MapDemoPermit.h"
#import "MapDemoClusterAnnotation.h"
#import "MapDemoClusterGrid.h"
@import MapKit;

// Object to store the distance between two points
@interface DistanceBetweenPoints : NSObject
@property (nonatomic) double distance;
@property (nonatomic, strong) NSArray * pair;
@end
@implementation DistanceBetweenPoints
@end

@interface MapDemoClusterer()
@end

@implementation MapDemoClusterer

// Public API
- (void)setPermitsAsync:(NSArray *)permits andClusterToDistanceInMapPoints:(double)distance andExecuteBlock:(void (^)(NSArray * clusters)) block {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSArray * clusters = [self setPermits:permits andClusterToDistanceInMapPoints:distance];
        block(clusters);
    });
}

// This call can take a few seconds
- (NSArray *)setPermits:(NSArray *)permits andClusterToDistanceInMapPoints:(double)distance {
    NSDate * start = [NSDate dateWithTimeIntervalSinceNow:0];
    
    // Create list of MapDemoClusterAnnotations, combining permits at the same location
    NSArray * clusters = [self clusterToOneMapPoint:permits];
    NSLog(@"after combining permits at same location, there are %lu annotations",[clusters count]);
    
    // Combine annotations at increasing grid size
    // Increasing the grid size too quickly results in more distance comparisons
    // Increasing the grid size too slowly will waste overhead creating the grid, but this is less of a problem
    double clusterDistanceInMapPoints = 200;
    while (clusterDistanceInMapPoints < distance) {
        clusters = [self annotationsAfterCombiningAnnotations:clusters withinDistanceInMapPoints:clusterDistanceInMapPoints];
        NSLog(@"at %f mapPoints, there are %lu annotations",clusterDistanceInMapPoints,[clusters count]);
        // for this data set, it's best to increase the grid size slowly at first
        if (clusterDistanceInMapPoints < 10000) {
            clusterDistanceInMapPoints += 200;
        } else if (clusterDistanceInMapPoints < 20000) {
            clusterDistanceInMapPoints += 500;
        } else {
            clusterDistanceInMapPoints += 1000;
        }
    }
    // Finally, cluster to the requested distance
    clusters = [self annotationsAfterCombiningAnnotations:clusters withinDistanceInMapPoints:distance];
    NSLog(@"clustering to requested distance took %f seconds",-1*[start timeIntervalSinceNow]);
    return clusters;
}



// Cluster permits that are located at the exact same point on the map
// (this reduces the amount of distance calculations and comparisons later)
// one mappoint is approximately 4 inches
- (NSArray *)clusterToOneMapPoint:(NSArray *)permits {
    NSMutableArray * clusterAnnotations = [[NSMutableArray alloc] init];
    // Create grid of permit objects with grid size 1
    MapDemoClusterGrid * grid = [[MapDemoClusterGrid alloc] initWithGridSize:1];
    for (MapDemoPermit * permit in permits) {
        [grid addObject:permit toGridAtMapPoint:MKMapPointForCoordinate(CLLocationCoordinate2DMake([permit.lat doubleValue], [permit.lng doubleValue]))];
    }
    // For each list of permits at a location represented by a grid cell
    for (NSArray * permitsAtSameLocation in [grid listsOfObjectsInGridCells]) {
        // Combine one or more permits into a cluster
        MapDemoPermit * firstPermit = [permitsAtSameLocation firstObject];
        MapDemoClusterAnnotation * clusterAnnotation = [[MapDemoClusterAnnotation alloc] initWithPermit:firstPermit];
        for (int i = 1; i < [permitsAtSameLocation count]; i++) {
            MapDemoPermit * nextPermit = permitsAtSameLocation[i];
            [clusterAnnotation addPermitAtSameLocation:nextPermit];
        }
        [clusterAnnotations addObject:clusterAnnotation];
    }
    return clusterAnnotations;
}



// Given a list of MapDemoClusterAnnotations, combine the closest pairs until the closest pair exceeds the specified distance
// Then return the resulting list of MapDemoClusterAnnotations
- (NSArray *)annotationsAfterCombiningAnnotations:(NSArray *)annotations withinDistanceInMapPoints:(double) distance {
    MapDemoClusterGrid * grid = [[MapDemoClusterGrid alloc] initWithGridSize:distance];
    // Create grid of clusters
    for (MapDemoClusterAnnotation * annotation in annotations) {
        [grid addObject:annotation toGridAtMapPoint:annotation.mapPoint];
    }
    // Create list of DistanceBetweenPoints for all pairs within the grid distance
    NSMutableArray * distanceBetweenPointsList = [[NSMutableArray alloc] init];
    NSArray * listsOfCloseObjects = [grid listsOfCloseObjects];
    for (NSArray * listToFromPairs in listsOfCloseObjects) {
        for (int i = 0; i < [listToFromPairs count]; i++) {
            MapDemoClusterAnnotation * firstCluster = [listToFromPairs objectAtIndex:i];
            for (int j = i+1; j < [listToFromPairs count]; j++) {
                MapDemoClusterAnnotation * secondCluster = [listToFromPairs objectAtIndex:j];
                double distanceInMapPoints = [firstCluster mapPointDistanceFromAnnotation:secondCluster];
                if (distanceInMapPoints < distance) {
                    DistanceBetweenPoints * dbpObject = [[DistanceBetweenPoints alloc] init];
                    dbpObject.pair = @[firstCluster,secondCluster];
                    dbpObject.distance = distanceInMapPoints;
                    [distanceBetweenPointsList addObject: dbpObject];
                }
            }
        }
    }
    // sort list ascending by distance
    [distanceBetweenPointsList sortUsingComparator:^NSComparisonResult(DistanceBetweenPoints * obj1, DistanceBetweenPoints * obj2) {
        if (obj1.distance < obj2.distance) {
            return NSOrderedDescending;
        } else if (obj1.distance > obj2.distance) {
            return NSOrderedAscending;
        }
        return NSOrderedSame;
    }];
    // combine all clusters within the grid distance
    //  - after a pair of clusters is combined, we add both clusters to a NSMutableSet
    //  - because there will still be pairs in the distanceBetweenPointsList that we should ignore (when the cluster has already been paired)
    NSMutableSet * combinedClusterSet = [[NSMutableSet alloc] init]; // set of MapDemoClusterAnnotations that have already been combined
    DistanceBetweenPoints * closestPair = [distanceBetweenPointsList lastObject];
    while ((closestPair) && (closestPair.distance < distance)) {
        MapDemoClusterAnnotation * firstCluster = closestPair.pair[0];
        MapDemoClusterAnnotation * secondCluster = closestPair.pair[1];
        if ((![combinedClusterSet containsObject:firstCluster]) && (![combinedClusterSet containsObject:secondCluster])) {
            [distanceBetweenPointsList removeLastObject];
            // make a new cluster that combines these
            MapDemoClusterAnnotation * firstCluster = closestPair.pair[0];
            MapDemoClusterAnnotation * secondCluster = closestPair.pair[1];
            MapDemoClusterAnnotation * combinedCluster = [firstCluster newAnnotationByCombiningWith:secondCluster];
            
            // remove the clusters from the grid and mark as combined
            [grid removeObject:firstCluster fromGridAtMapPoint:firstCluster.mapPoint];
            [grid removeObject:secondCluster fromGridAtMapPoint:secondCluster.mapPoint];
            [combinedClusterSet addObject:firstCluster];
            [combinedClusterSet addObject:secondCluster];
            
            // add new cluster to the grid and pair with all neighboring cells
            NSArray * newPairs = [self pairsWithinDistance:distance ofNewAnnotation:combinedCluster inGrid:grid];
            [grid addObject:combinedCluster toGridAtMapPoint:combinedCluster.mapPoint];

            [distanceBetweenPointsList addObjectsFromArray:newPairs];
            // sort list by distance, increasing (because it's more efficient to remove the last object than the first)
            [distanceBetweenPointsList sortUsingComparator:^NSComparisonResult(DistanceBetweenPoints * obj1, DistanceBetweenPoints * obj2) {
                if (obj1.distance < obj2.distance) {
                    return NSOrderedDescending;
                } else if (obj1.distance > obj2.distance) {
                    return NSOrderedAscending;
                }
                return NSOrderedSame;
            }];
        } else {
            // the closest pair in the list contains a cluster that was already paired
            [distanceBetweenPointsList removeLastObject];
        }
        closestPair = [distanceBetweenPointsList lastObject];
    }
    return [grid allObjects];
}


// When a pair of clusters is combined, we use this method to get a list of pairs containing the new cluster and the clusters within grid size
- (NSArray *)pairsWithinDistance:(double) maxDistance ofNewAnnotation:(MapDemoClusterAnnotation *)annotation inGrid:(MapDemoClusterGrid *)grid{
    NSMutableArray * pairs = [[NSMutableArray alloc] init];
    NSArray * closeObjects = [grid objectsNearMapPoint:annotation.mapPoint];
    for (MapDemoClusterAnnotation * nearbyAnnotation in closeObjects) {
        double distanceInMapPoints = [annotation mapPointDistanceFromAnnotation:nearbyAnnotation];
        if (distanceInMapPoints < maxDistance) {
            DistanceBetweenPoints * dbpObject = [[DistanceBetweenPoints alloc] init];
            dbpObject.pair = @[annotation,nearbyAnnotation];
            dbpObject.distance = distanceInMapPoints;
            [pairs addObject: dbpObject];
        }
    }
    return pairs;
}


@end
