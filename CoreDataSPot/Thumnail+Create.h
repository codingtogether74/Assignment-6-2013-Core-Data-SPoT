//
//  Thumnail+Create.h
//  CoreDataSPot
//
//  Created by Tatiana Kornilova on 3/9/13.
//  Copyright (c) 2013 Tatiana Kornilova. All rights reserved.
//

#import "Thumnail.h"

@interface Thumnail (Create)
+ (void)insertThumnail:(NSData *)imageData forPhoto:(Photo *)photo;
+ (NSData *)imageDataThumnailForPhoto:(Photo *)photo;
@end
