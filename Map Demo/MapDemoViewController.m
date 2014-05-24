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

@interface MapDemoViewController ()
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

@end
