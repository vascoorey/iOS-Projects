//
//  CMMotionManager+Shared.h
//  Kitchen-Sink
//
//  Created by Vasco Orey on 3/22/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import <CoreMotion/CoreMotion.h>

@interface CMMotionManager (Shared)

+(CMMotionManager *)sharedMotionManager;

@end
