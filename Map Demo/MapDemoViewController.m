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
        [self.mapView removeAnnotations:[self.mapView annotations]];
        [self.clusterer setPermitsAsync:self.permits andClusterToDistanceInMapPoints:[self clusterDistanceInMapPointsForCurrentZoom] andExecuteBlock:^(NSArray *clusters) {
            // update mapView on main Q
            dispatch_async(dispatch_get_main_queue(), ^{
                [mapView addAnnotations:clusters];
            });
        }];
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

@end
