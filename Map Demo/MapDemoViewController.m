//
//  MapDemoViewController.m
//  Map Demo
//
//  Created by Jason Pullias on 5/24/14.
//  Copyright (c) 2014 pullias.com. All rights reserved.
//

#import "MapDemoViewController.h"
@import MapKit;
//#import "MapDemoColoredCircleMaker.h"
#import "MapDemoPermit.h"
#import "MapDemoClusterer.h"

@interface MapDemoViewController () <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) MapDemoClusterer * clusterer;
@property (strong, nonatomic) NSArray * permits;
@end

#define CLUSTER_DISTANCE_IN_SCREEN_POINTS 20

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
    [self.mapView removeAnnotations:[self.mapView annotations]];
    
    [self.clusterer setPermitsAsync:self.permits andClusterToDistanceInMapPoints:[self clusterDistanceInMapPointsForCurrentZoom] andExecuteBlock:^(NSArray *clusters) {
        // update mapView on main Q
        dispatch_async(dispatch_get_main_queue(), ^{
            [mapView addAnnotations:clusters];
        });
    }];
}

/*
// MKMapView delegate method
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    MKAnnotationView * annotationView = [self.mapView dequeueReusableAnnotationViewWithIdentifier:@"myAnnotationViewId"];
    if (!annotationView) {
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"myAnnotationViewId"];
    }
    if ([annotation isKindOfClass:[MapDemoPermitAnnotation class]]) {
        MapDemoPermitAnnotation * permitAnnotation = (MapDemoPermitAnnotation*)annotation;
        UIColor * colorForPermitAnnotation = [self colorForPermitType:[permitAnnotation.permitType intValue]];
        annotationView.image = [MapDemoColoredCircleMaker circleWithDiameter:10 andColor:colorForPermitAnnotation];
        annotationView.canShowCallout = YES;
        annotationView.leftCalloutAccessoryView = [[UIImageView alloc] initWithImage:[MapDemoColoredCircleMaker circleWithDiameter:40 andColor:[UIColor blackColor]]];
        annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:
                                                    UIButtonTypeDetailDisclosure];
    }
    return annotationView;
}
*/

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
