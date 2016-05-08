//
//  MBESaturationAdjustmentFilter.h
//  ImageProcessing
//
//  Created by Warren Moore on 10/8/14.
//  Copyright (c) 2014 Metal By Example. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBEContext.h"
#import "MBEImageFilter.h"

@interface MBESaturationAdjustmentFilter : MBEImageFilter

@property (nonatomic, assign) float saturationFactor;

+ (instancetype)filterWithSaturationFactor:(float)saturation context:(MBEContext *)context;

@end

