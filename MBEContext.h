//
//  MBEContext.h
//  ImageProcessing
//
//  Created by Warren Moore on 10/8/14.
//  Copyright (c) 2014 Metal By Example. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MTLDevice, MTLLibrary, MTLCommandQueue;

@interface MBEContext : NSObject

@property (strong) id<MTLDevice> device;
@property (strong) id<MTLLibrary> library;
@property (strong) id<MTLCommandQueue> commandQueue;

+ (instancetype)newContext;

@end
