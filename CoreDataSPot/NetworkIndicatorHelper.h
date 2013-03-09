//
//  NetworkIndicatorHelper.h
//  SPoT
//
//  Created by Daniela on 2/28/13.
//  Copyright (c) 2013 Pyrogusto Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkIndicatorHelper : NSObject

+ (void) setNetworkActivityIndicatorVisible:(BOOL) visible;
+ (BOOL) networkActivityIndicatorVisible;

@end
