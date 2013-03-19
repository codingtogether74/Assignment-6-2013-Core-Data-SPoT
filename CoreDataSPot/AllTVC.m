//
//  AllTVC.m
//  CoreDataSPot
//
//  Created by Tatiana Kornilova on 3/15/13.
//  Copyright (c) 2013 Tatiana Kornilova. All rights reserved.
//

#import "AllTVC.h"
#import "Photo.h"
#import "DBHelper.h"
#import "ImageViewController.h"
#import "Tag+Create.h"
#import "Thumnail+Create.h"

@interface AllTVC ()

@end

@implementation AllTVC

- (void)setupFetchedResultsControllerWithDocument:(UIManagedDocument *)document

{
    NSFetchRequest *request       =  [NSFetchRequest fetchRequestWithEntityName:@"Tag"];
    request.sortDescriptors       =  [NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES]];
    request.predicate             =   [NSPredicate predicateWithFormat:@"name!=%@",@"$$$$"];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc]
                                     initWithFetchRequest:request
                                     managedObjectContext:document.managedObjectContext
                                     sectionNameKeyPath:@"name"
                                     cacheName:nil];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.toResent = YES;
    [[DBHelper sharedManagedDocument] performWithDocument:
     ^(UIManagedDocument *document) {
         [self setupFetchedResultsControllerWithDocument:document];
     }];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.fetchedResultsController.fetchedObjects !=nil) {
        self.title =[NSString stringWithFormat:@"All Photos by tag (%d)",[self.fetchedResultsController.fetchedObjects count]];
    } else {
        self.title =[NSString stringWithFormat:@"All Photos by tag (-)"];
    }
}

//----------------------------------------------------------------
# pragma mark   -   Table view data source
//----------------------------------------------------------------
- (Photo *)photoForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Photo *photo = nil;
    //-------------Take tag from NSFetchedResultsController---
    Tag *tag = [self.fetchedResultsController.fetchedObjects objectAtIndex:indexPath.section];
    NSOrderedSet *photos =tag.photos;
    photo = [photos objectAtIndex:indexPath.row];
    //--------------------------------
    return photo;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // return the number of photos in a tag
    Tag *tag = [self.fetchedResultsController.fetchedObjects objectAtIndex:section];
    
    return [tag.photos count];
}

@end
