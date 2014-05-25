//
//  MapDemoPermitAnnotation.m
//  Map Demo
//
//  Created by Jason Pullias on 5/24/14.
//  Copyright (c) 2014 pullias.com. All rights reserved.
//

#import "MapDemoPermitAnnotation.h"

@implementation MapDemoPermitAnnotation

// implement MKAnnotation protocol property
- (CLLocationCoordinate2D)coordinate {
    return CLLocationCoordinate2DMake([self.lat doubleValue], [self.lng doubleValue]);
}

// implement MKAnnotation protocol property
- (NSString *)title {
    return self.address;
}

// implement MKAnnotation protocol property
- (NSString *)subtitle {
    return ([[self currencyFormatter] stringFromNumber:self.valuation]);
}

- (NSNumberFormatter *)currencyFormatter {
    static NSNumberFormatter * formatter = nil;
    if (!formatter) {
            formatter = [[NSNumberFormatter alloc]init];
            [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
            [formatter setMaximumFractionDigits:0];
    }
    return formatter;
}

@end
