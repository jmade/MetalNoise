//
//  MBEImageFilter.h
//  ImageProcessing
//
//  Created by Warren Moore on 10/8/14.
//  Copyright (c) 2014 Metal By Example. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBETextureProvider.h"
#import "MBETextureConsumer.h"
#import "MBEContext.h"

@protocol MTLTexture, MTLBuffer, MTLComputeCommandEncoder, MTLComputePipelineState;

@interface MBEImageFilter : NSObject <MBETextureProvider, MBETextureConsumer>

@property (nonatomic, strong) MBEContext *context;
@property (nonatomic, strong) id<MTLBuffer> uniformBuffer;
@property (nonatomic, strong) id<MTLComputePipelineState> pipeline;
@property (nonatomic, strong) id<MTLTexture> internalTexture;
@property (nonatomic, assign, getter=isDirty) BOOL dirty;

- (instancetype)initWithFunctionName:(NSString *)functionName context:(MBEContext *)context;

- (void)configureArgumentTableWithCommandEncoder:(id<MTLComputeCommandEncoder>)commandEncoder;

@end

