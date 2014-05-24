//
//  MapDemoViewController.m
//  Map Demo
//
//  Created by Jason Pullias on 5/24/14.
//  Copyright (c) 2014 pullias.com. All rights reserved.
//

#import "MapDemoViewController.h"
@import MapKit;
#import "MapDemoPermitAnnotation.h"
#import "MapDemoColoredCircleMaker.h"

@interface MapDemoViewController () <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation MapDemoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)setMapView:(MKMapView *)mapView {
    _mapView = mapView;
    _mapView.delegate = self;
    [self initializeMap];
}

- (void)initializeMap {
    // Set initial map region to Nashville
    [self.mapView setRegion:MKCoordinateRegionMake(CLLocationCoordinate2DMake(36.2, -86.8),
                                                   MKCoordinateSpanMake(0.3, 0.5))];
    [self loadPermits];
}

- (void)loadPermits {
    // Create Permit Annotation objects from JSON
    NSURL * permitsLocalUrl = [[NSBundle mainBundle] URLForResource:@"nashville-permits-2014" withExtension:@"json"];
    NSData * permitsJSON = [NSData dataWithContentsOfURL:permitsLocalUrl];
    NSError * error = nil;
    NSArray * permitsListOfDicts = [NSJSONSerialization JSONObjectWithData:permitsJSON options:0 error:&error];
    if (error) {
        NSLog(@"%@",[error localizedDescription]);
    }
    NSMutableArray * annotations = [[NSMutableArray alloc] initWithCapacity:[permitsListOfDicts count]];
    for (NSDictionary * permitDict in permitsListOfDicts) {
        MapDemoPermitAnnotation * permitAnnotation = [[MapDemoPermitAnnotation alloc] initWithDict:permitDict];
        [annotations addObject:permitAnnotation];
    }
    // I could add annotations individually in the loop instead. Performance is basically the same
    [self.mapView addAnnotations:annotations];
}

// MKMapView delegate method
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    MKAnnotationView * annotationView = [self.mapView dequeueReusableAnnotationViewWithIdentifier:@"myAnnotationViewId"];
    if (!annotationView) {
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"myAnnotationViewId"];
    }
    if ([annotation isKindOfClass:[MapDemoPermitAnnotation class]]) {
        MapDemoPermitAnnotation * permitAnnotation = (MapDemoPermitAnnotation*)annotation;
        UIColor * colorForPermitAnnotation = [self colorForPermitType:[permitAnnotation getPermitType]];
        annotationView.image = [MapDemoColoredCircleMaker circleWithDiameter:10 andColor:colorForPermitAnnotation];
        annotationView.canShowCallout = YES;
        annotationView.leftCalloutAccessoryView = [[UIImageView alloc] initWithImage:[MapDemoColoredCircleMaker circleWithDiameter:40 andColor:[UIColor blackColor]]];
        annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:
                                                    UIButtonTypeDetailDisclosure];
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

@end
