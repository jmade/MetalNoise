//
//  JDMNoiseAdjustmentFilter.h
//  ImageProcessing
//
//  Created by Justin Madewell on 8/10/15.
//  Copyright © 2015 Metal By Example. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "MBEContext.h"
#import "MBEImageFilter.h"

@interface JDMNoiseAdjustmentFilter : MBEImageFilter

@property (nonatomic, assign) float turbulencePower;
@property (nonatomic, assign) float turbulenceSize;
@property (nonatomic, assign) float xPeriod;
@property (nonatomic, assign) float yPeriod;
@property (nonatomic, assign) float xyPeriod;
@property (nonatomic, assign) int noiseType;
@property (nonatomic, assign) float zoomAmount;
@property (nonatomic, assign) bool isSmooth;
@property (nonatomic, assign) bool isSpecial;

@property (nonatomic, assign) float color1;
@property (nonatomic, assign) float color2;
@property (nonatomic, assign) float color3;

@property (nonatomic, assign) bool hasTurb;


+ (instancetype)filterWithTurbulencePower:(float)turbulencePower context:(MBEContext *)context;

@end
