//
//  JDMNoiseAdjustmentFilter.m
//  ImageProcessing
//
//  Created by Justin Madewell on 8/10/15.
//  Copyright © 2015 Metal By Example. All rights reserved.
//

#import "JDMNoiseAdjustmentFilter.h"
#import <Metal/Metal.h>


struct NoiseUniforms
{
    float turbulencePower;
    float turbulenceSize;
    float xPeriod;
    float yPeriod;
    float xyPeriod;
    int noiseType;
    float zoomAmount;
    bool isSmooth;
    bool isSpecial;
    float color1;
    float color2;
    float color3;
    bool hasTurb;
};



@implementation JDMNoiseAdjustmentFilter

@synthesize turbulencePower=_turbulencePower,turbulenceSize=_turbulenceSize,xPeriod=_xPeriod,yPeriod=_yPeriod,xyPeriod=_xyPeriod,noiseType=_noiseType,zoomAmount=_zoomAmount,isSmooth=_isSmooth,isSpecial=_isSpecial,color1=_color1,color2=_color2,color3=_color3,hasTurb=_hasTurb;

+ (instancetype)filterWithTurbulencePower:(float)turbulencePower context:(MBEContext *)context
{
    return [[self alloc] initWithTurbulencePower:turbulencePower context:context];
}

- (instancetype)initWithTurbulencePower:(float)turbulencePower context:(MBEContext *)context
{
    if ((self = [super initWithFunctionName:@"adjust_noise" context:context]))
    {
        _turbulencePower = turbulencePower;
    }
    return self;
}


// Setters for ivars


-(void)setHasTurb:(bool)hasTurb
{
    self.dirty = YES;
    _hasTurb = hasTurb;
}

-(void)setColor1:(float)color1
{
    self.dirty = YES;
    _color1 = color1;
}

-(void)setColor2:(float)color2
{
    self.dirty = YES;
    _color2 = color2;
}


-(void)setColor3:(float)color3
{
    self.dirty = YES;
    _color3 = color3;
    
}




-(void)setIsSpecial:(bool)isSpecial
{
    self.dirty = YES;
    _isSpecial = isSpecial;
}

-(void)setIsSmooth:(bool)isSmooth
{
    self.dirty = YES;
    _isSmooth=isSmooth;
    
}

-(void)setZoomAmount:(float)zoomAmount
{
    self.dirty = YES;
    _zoomAmount = zoomAmount;
    
}

-(void)setNoiseType:(int)noiseType
{
    self.dirty = YES;
    _noiseType = noiseType;
}




-(void)setXyPeriod:(float)xyPeriod
{
    self.dirty = YES;
    _xyPeriod = xyPeriod;

}


-(void)setXPeriod:(float)xPeriod
{
    self.dirty = YES;
    _xPeriod = xPeriod;
}

-(void)setYPeriod:(float)yPeriod
{
    self.dirty = YES;
    _yPeriod = yPeriod;
}

-(void)setTurbulenceSize:(float)turbulenceSize
{
    self.dirty = YES;
    _turbulenceSize = turbulenceSize;
}


- (void)setTurbulencePower:(float)turbulencePower
{
    self.dirty = YES;
    _turbulencePower = turbulencePower;
}

- (void)configureArgumentTableWithCommandEncoder:(id<MTLComputeCommandEncoder>)commandEncoder
{
    struct NoiseUniforms uniforms;
    uniforms.turbulencePower = self.turbulencePower;
    uniforms.turbulenceSize = self.turbulenceSize;
    uniforms.xPeriod = self.xPeriod;
    uniforms.yPeriod = self.yPeriod;
    uniforms.noiseType = self.noiseType;
    uniforms.xyPeriod = self.xyPeriod;
    uniforms.zoomAmount = self.zoomAmount;
    uniforms.isSmooth = self.isSmooth;
    uniforms.isSpecial = self.isSpecial;
    uniforms.color1 = self.color1;
    uniforms.color2 = self.color2;
    uniforms.color3 = self.color3;
    uniforms.hasTurb = self.hasTurb;
    
    if (!self.uniformBuffer)
    {
        self.uniformBuffer = [self.context.device newBufferWithLength:sizeof(uniforms)
                                                              options:MTLResourceOptionCPUCacheModeDefault];
    }
    
    memcpy([self.uniformBuffer contents], &uniforms, sizeof(uniforms));
    
    [commandEncoder setBuffer:self.uniformBuffer offset:0 atIndex:0];
}





@end
