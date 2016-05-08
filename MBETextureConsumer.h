//
//  MBETextureConsumer.h
//  ImageProcessing
//
//  Created by Warren Moore on 10/8/14.
//  Copyright (c) 2014 Metal By Example. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MBETextureProvider;

@protocol MBETextureConsumer <NSObject>

@property (nonatomic, strong) id<MBETextureProvider> provider;

@end
