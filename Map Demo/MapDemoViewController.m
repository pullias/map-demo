//
//  MapDemoViewController.m
//  Map Demo
//
//  Created by Jason Pullias on 5/24/14.
//  Copyright (c) 2014 pullias.com. All rights reserved.
//

#import "MapDemoViewController.h"
@import MapKit;
#import "MapDemoColoredCircleMaker.h"
#import "MapDemoPermit.h"
#import "MapDemoClusterer.h"
#import "MapDemoClusterAnnotation.h"

@interface MapDemoViewController () <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) MapDemoClusterer * clusterer;
@property (strong, nonatomic) NSArray * permits;
@end

#define CLUSTER_DISTANCE_IN_SCREEN_POINTS 44

@implementation MapDemoViewController

- (void)setMapView:(MKMapView *)mapView {
    _mapView = mapView;
    _mapView.delegate = self;
    [self initializeMap];
}

- (void)initializeMap {
    // Set initial map region to Nashville
    [self.mapView setRegion:MKCoordinateRegionMake(CLLocationCoordinate2DMake(36.2, -86.8),
                                                   MKCoordinateSpanMake(0.3, 0.5))];
    MKMapView * mapView = self.mapView; // avoid referencing self in block
    [self.clusterer setPermitsAsync:self.permits andClusterToDistanceInMapPoints:[self clusterDistanceInMapPointsForCurrentZoom] andExecuteBlock:^(NSArray *clusters) {
        // update mapView on main Q
        dispatch_async(dispatch_get_main_queue(), ^{
            [mapView addAnnotations:clusters];
        });
    }];
}

- (NSArray *)permits {
    if (!_permits) {
        // Create Permit Annotation objects from JSON
        NSURL * permitsLocalUrl = [[NSBundle mainBundle] URLForResource:@"nashville-permits-2014" withExtension:@"json"];
        NSData * permitsJSON = [NSData dataWithContentsOfURL:permitsLocalUrl];
        NSError * error = nil;
        NSArray * permitsListOfDicts = [NSJSONSerialization JSONObjectWithData:permitsJSON options:0 error:&error];
        if (error) {
            NSLog(@"%@",[error localizedDescription]);
        }
        NSMutableArray * permits = [[NSMutableArray alloc] initWithCapacity:[permitsListOfDicts count]];
        for (NSDictionary * permitDict in permitsListOfDicts) {
            MapDemoPermit * permit = [[MapDemoPermit alloc] initWithDict:permitDict];
            [permits addObject:permit];
        }
        _permits = [NSArray arrayWithArray:permits];
    }
    return _permits;
}

- (MapDemoClusterer *)clusterer {
    if (!_clusterer) {
        _clusterer = [[MapDemoClusterer alloc] init];
    }
    return _clusterer;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    static CLLocationDegrees longitudeDeltaAtLastRecluster = DBL_MAX;
    CLLocationDegrees newLongitudeDelta = self.mapView.region.span.longitudeDelta;
    double percentChange = fabs(1-newLongitudeDelta / longitudeDeltaAtLastRecluster);
    NSLog(@"The region changed by %d%% %s",(int)(100*percentChange),animated?"animated":"non-animated");
    if (percentChange > 0.05) {
        longitudeDeltaAtLastRecluster = newLongitudeDelta;
        // recluster when zoom changes by more than 5%
        NSArray * newAnnotations = [self.clusterer annotationsFromCacheWithMinimumDistanceInMapPoints:[self clusterDistanceInMapPointsForCurrentZoom]];
        if (newAnnotations) {
            [self animateTransitionToNewClusters:newAnnotations];
        }
    }
}

// MKMapView delegate method
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    MKAnnotationView * annotationView = [self.mapView dequeueReusableAnnotationViewWithIdentifier:@"myAnnotationViewId"];
    if (!annotationView) {
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"myAnnotationViewId"];
    }
    if ([annotation isKindOfClass:[MapDemoClusterAnnotation class]]) {
        MapDemoClusterAnnotation * cluster = (MapDemoClusterAnnotation*)annotation;
        if ([cluster countOfPermits] == 1) {
            MapDemoPermit * permit = [cluster permit];
            annotationView.canShowCallout = YES;
            annotationView.image = [MapDemoColoredCircleMaker circleWithDiameter:44 andColor:[self colorForPermitType:[permit.permitType intValue]]];
        } else {
            annotationView.canShowCallout = NO;
            annotationView.image = [MapDemoColoredCircleMaker circleWithColor:[UIColor brownColor] andNumber:[cluster countOfPermits]];
        }
    }
    return annotationView;
}

- (UIColor *)colorForPermitType:(int)permitType {
    switch(permitType) {
        case 0:
            return [UIColor redColor];
        case 1:
            return [UIColor greenColor];
        case 2:
            return [UIColor blueColor];
        case 3:
            return [UIColor purpleColor];
        default:
            break;
    }
    return [UIColor magentaColor];
}

// Return the distance in mapPoints between the center of the map and a point 44px to the right of center
- (double)clusterDistanceInMapPointsForCurrentZoom {
    CLLocationCoordinate2D centerCoordinate = [self.mapView centerCoordinate];
    CGPoint centerOfMapView = [self.mapView convertCoordinate:centerCoordinate toPointToView:self.mapView];
    CGPoint referencePointInMapView = CGPointMake(centerOfMapView.x + CLUSTER_DISTANCE_IN_SCREEN_POINTS, centerOfMapView.y);
    CLLocationCoordinate2D referenceCoordinate = [self.mapView convertPoint:referencePointInMapView toCoordinateFromView:self.mapView];
    MKMapPoint centerMapPoint = MKMapPointForCoordinate(centerCoordinate);
    MKMapPoint referenceMapPoint = MKMapPointForCoordinate(referenceCoordinate);
    return referenceMapPoint.x-centerMapPoint.x;
}

- (void)animateTransitionToNewClusters:(NSArray *)newClusters {
    if ([newClusters count] == 0) {
        return;
    }
    NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];
    NSArray * oldClusters = [self.mapView annotations];
    NSSet * visibleClusters = [self.mapView annotationsInMapRect:self.mapView.visibleMapRect];
    if ([oldClusters count] == 0) {
        // add initial clusters without animation
        [self.mapView addAnnotations:newClusters];
        return;
    }
    if ([newClusters isEqualToArray:oldClusters]) {
        return;
    }
    else if ([newClusters count] > [oldClusters count]) {
        // Zoom in, adding new children with animation from parent location
        NSMutableArray * childrenToAddWithAnimation = [[NSMutableArray alloc] init];
        NSMutableArray * childrenToAddWithoutAnimation = [[NSMutableArray alloc] init];
        
        NSMutableSet * unchangedClusters = [NSMutableSet setWithArray:oldClusters];
        NSMutableSet * parentsToRemove = [NSMutableSet setWithSet:unchangedClusters];
        [unchangedClusters intersectSet:[NSSet setWithArray:newClusters]];
        // now we know which clusters are unchanged
        [parentsToRemove minusSet:unchangedClusters];
        // get set of children
        NSMutableSet * childrenToAdd = [NSMutableSet setWithArray:newClusters];
        [childrenToAdd minusSet:unchangedClusters];
        MKMapRect visibleMapRect = [self.mapView visibleMapRect];
        for (MapDemoClusterAnnotation * newChild in childrenToAdd) {
            MapDemoClusterAnnotation * newChildsParent = newChild.parent;
            // find the new child's ancestor that is in the annotation set
            while ((newChildsParent) && (![parentsToRemove containsObject:newChildsParent])) {
                newChildsParent = newChildsParent.parent;
            }
            if (newChildsParent) {
                // child has parent which may or may not be visible
                if ([visibleClusters containsObject:newChildsParent]) {
                    // prepare to add child with animation from parent location on screen
                    [newChild setAlternateLocation:newChildsParent.coordinate];
                    [newChild moveToAlternateLocation];
                    [childrenToAddWithAnimation addObject:newChild];
                } else {
                    // if the parent if offscreen but the child is onscreen, try to animate
                    MKMapPoint newChildPoint = MKMapPointForCoordinate(newChild.coordinate);
                    if (MKMapRectContainsPoint(visibleMapRect, newChildPoint)) {
                        [newChild setAlternateLocation:newChildsParent.coordinate];
                        [newChild moveToAlternateLocation];
                        [childrenToAddWithAnimation addObject:newChild];
                    } else {
                        // if parent and child are off screen, don't animate
                        [childrenToAddWithoutAnimation addObject:newChild];
                    }
                }
            }
        }
        NSLog(@"calculating animations took %f seconds",[NSDate timeIntervalSinceReferenceDate]-start);
        NSLog(@"there are %lu clusters currently, and there will be %lu after animation",[oldClusters count],[newClusters count]);
        NSLog(@"there are %lu new children to animate",[childrenToAddWithAnimation count]);
        // add new on-screen children at parent location, and remove parents before animating
        [self.mapView addAnnotations:childrenToAddWithAnimation];
        [self.mapView removeAnnotations:[parentsToRemove allObjects]];
        
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [childrenToAddWithAnimation makeObjectsPerformSelector:@selector(moveToActualLocation)];
        }completion:^(BOOL finished) {
            // add new children off screen after the animation is completed
            [self.mapView addAnnotations:childrenToAddWithoutAnimation];
        }];
    } else {
        // zoom out: animate clustered children to parent location, then remove children and add parent
        NSMutableArray * childrenToRemoveWithAnimation = [[NSMutableArray alloc] init];
        // note, the newClusters array likely contains many annotations outside the map rect
        // (1) identify unchanged clusters
        // the remaining clusters in the previous set must be children of the new clusters in the new set
        // (2) for the child clusters in the visible rect, animate to parent location, then add parents
        // (3) for the child clusters outside the visible rect, remove them and add parent without animation
        for (MapDemoClusterAnnotation * visibleChild in visibleClusters) {
            if ([newClusters containsObject:visibleChild]) {
                // the cluster is unchanged
            } else {
                // traverse child's ancestry until we get the parent that is being added
                MapDemoClusterAnnotation * newParent = visibleChild.parent;
                while ((newParent) && ![newClusters containsObject:newParent]) {
                    newParent = newParent.parent;
                }
                if (newParent) {
                    [visibleChild setAlternateLocation:newParent.coordinate];
                    [childrenToRemoveWithAnimation addObject:visibleChild];
                }
            }
        }
        // parentsToAdd should be all the new clusters not in old clusters
        NSSet * oldClusterSet = [NSSet setWithArray:oldClusters];
        NSMutableSet * parentsToAdd = [[NSMutableSet alloc] initWithArray:newClusters];
        [parentsToAdd minusSet:oldClusterSet];
        // children to remove without animation should be all the old clusters, minus the unchanged ones, minus the ones being animated
        NSMutableSet * childrenToRemoveWithoutAnimation = [[NSMutableSet alloc] initWithSet:oldClusterSet];
        [childrenToRemoveWithoutAnimation minusSet:[NSSet setWithArray:newClusters]];
        [childrenToRemoveWithoutAnimation minusSet:[NSSet setWithArray:childrenToRemoveWithAnimation]];
        NSLog(@"calculating animations took %f seconds",[NSDate timeIntervalSinceReferenceDate]-start);
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            for (MapDemoClusterAnnotation * cluster in childrenToRemoveWithAnimation) {
                // animate visible children to parent location
                [cluster moveToAlternateLocation];
            }
        }completion:^(BOOL finished) {
            // remove children and add off-screen parents
            [self.mapView addAnnotations:[parentsToAdd allObjects]];
            [self.mapView removeAnnotations:childrenToRemoveWithAnimation];
            [self.mapView removeAnnotations:[childrenToRemoveWithoutAnimation allObjects]];
            // reset removed children to actual location
            [childrenToRemoveWithAnimation makeObjectsPerformSelector:@selector(moveToActualLocation)];
        }];
        
    }
}


@end
