//
//  NSString+FetchedGroupByString.m
//  CoreDataSPot
//
//  Created by Tatiana Kornilova on 3/9/13.
//  Copyright (c) 2013 Tatiana Kornilova. All rights reserved.
//

#import "NSString+FetchedGroupByString.h"

@implementation NSString (FetchedGroupByString)
-(NSString *)stringGroupByFirstLetter{
    if (!self.length || self.length ==1) return self;
    return [[self substringToIndex:1] capitalizedString];
    
}
@end
