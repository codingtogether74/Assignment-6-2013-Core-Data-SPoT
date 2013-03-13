//
//  ResentsTVC.m
//  SPoT
//
//  Created by Tatiana Kornilova on 2/23/13.
//  Copyright (c) 2013 Tatiana Kornilova. All rights reserved.
//

#import "ResentsTVC.h"
#import "Photo.h"
#import "DBHelper.h"
#import "ImageViewController.h"


@implementation ResentsTVC

- (void)setupFetchedResultsControllerWithDocument:(UIManagedDocument *)document

{
    NSFetchRequest *request       =  [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.sortDescriptors       =  [NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"dateView" ascending:NO]];
    request.predicate             =  [NSPredicate predicateWithFormat:@"dateView!=nil"];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc]
                                     initWithFetchRequest:request
                                     managedObjectContext:document.managedObjectContext
                                     sectionNameKeyPath:nil cacheName:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.toResent = NO;
    [[DBHelper sharedManagedDocument] performWithDocument:
     ^(UIManagedDocument *document) {
         [self setupFetchedResultsControllerWithDocument:document];
     }];
}
 
 -(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.fetchedResultsController.fetchedObjects !=nil) {
          self.title =[NSString stringWithFormat:@"Photos (%d)",[self.fetchedResultsController.fetchedObjects count]];
    } else {
        self.title =[NSString stringWithFormat:@"Photos (-)"];
    }
}
@end
