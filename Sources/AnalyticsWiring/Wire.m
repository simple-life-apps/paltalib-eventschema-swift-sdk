//
//  Wire.m
//  
//
//  Created by Vyacheslav Beltyukov on 18/01/2023.
//

#import "Wire.h"
@import ObjectiveC;

@implementation PBWiringLauncher

+ (void)wire {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wundeclared-selector"
    Class class = objc_lookUpClass("PBEventsWiring");
    [[[class alloc] init] performSelector:@selector(wireStack)];
#pragma GCC diagnostic pop
}

@end
