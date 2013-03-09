//
//  NetworkIndicatorHelper.m
//  SPoT
//
//  Created by Daniela on 2/28/13.
//  Copyright (c) 2013 Pyrogusto Studio. All rights reserved.
//

#import "NetworkIndicatorHelper.h"
@interface NetworkIndicatorHelper()
@property (readwrite, atomic) NSUInteger count; // use atomic to make sure thread safe since photo fethcing could be in another queue.
@end
@implementation NetworkIndicatorHelper

static NetworkIndicatorHelper *networkIndicatorHelper;

+ (void) setNetworkActivityIndicatorVisible:(BOOL) visible{
    if(!networkIndicatorHelper){
        networkIndicatorHelper = [[NetworkIndicatorHelper alloc]init];
    }
    if(visible){
        networkIndicatorHelper.count++;
    }else{
        networkIndicatorHelper.count--;
        networkIndicatorHelper.count= networkIndicatorHelper.count<0 ? 0:networkIndicatorHelper.count;
    }
    if(networkIndicatorHelper.count > 0){
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    }else{
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
}

+ (BOOL) networkActivityIndicatorVisible{
    return networkIndicatorHelper.count > 0 ? YES : NO;
}

@end
