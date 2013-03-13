//
//  DeletedPhotoTVC.m
//  CoreDataSPot
//
//  Created by Tatiana Kornilova on 3/13/13.
//  Copyright (c) 2013 Tatiana Kornilova. All rights reserved.
//

#import "DeletedPhotoTVC.h"
#import "Photo.h"
#import "DBHelper.h"
#import "ImageViewController.h"
#import "DeletedPhoto+Create.h"


@interface DeletedPhotoTVC ()

@end

@implementation DeletedPhotoTVC
- (void)setupFetchedResultsControllerWithDocument:(UIManagedDocument *)document

{
    NSFetchRequest *request       =  [NSFetchRequest fetchRequestWithEntityName:@"DeletedPhoto"];
    request.sortDescriptors       =  [NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"dateDelete" ascending:NO]];
    request.predicate             =  [NSPredicate predicateWithFormat:@"dateDelete!=nil"];
    
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
        self.title =[NSString stringWithFormat:@"Deleted Photos (%d)",[self.fetchedResultsController.fetchedObjects count]];
    } else {
        self.title =[NSString stringWithFormat:@"Deleted Photos (-)"];
    }
}

@end
