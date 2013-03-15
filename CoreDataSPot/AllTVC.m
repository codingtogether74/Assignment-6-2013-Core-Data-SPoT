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
        self.title =[NSString stringWithFormat:@"All Photos by tag (%d)",[self.fetchedResultsController.fetchedObjects count]];
    } else {
        self.title =[NSString stringWithFormat:@"All Photos by tag (-)"];
    }
}

//----------------------------------------------------------------
# pragma mark   -   Table view data source
//----------------------------------------------------------------
/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // return the number of tags
    return [[self.fetchedResultsController fetchedObjects] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    // return the title of an individual tag
    return [[self.fetchedResultsController.fetchedObjects objectAtIndex:section] valueForKey:@"name"];
}
*/
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // return the number of photos in a tag
    Tag *tag = [self.fetchedResultsController.fetchedObjects objectAtIndex:section];
    
    return tag.photos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Flickr Photo Cell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell..
    //-------------Take tag from NSFetchedResultsController---
    Tag *tag = [self.fetchedResultsController.fetchedObjects objectAtIndex:indexPath.section];
     NSArray *descriptors =[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES]];
     NSArray *photos =[tag.photos sortedArrayUsingDescriptors:descriptors];
     Photo *photo = [photos objectAtIndex:indexPath.row];
    //--------------------------------
    cell.textLabel.text = photo.title;
    cell.detailTextLabel.text = photo.subtitle;
    //----Thumnail------------------
    dispatch_queue_t q = dispatch_queue_create("thumbnail download queue", 0);
    dispatch_async(q, ^{
        NSURL *thumbnailURL =  [NSURL URLWithString:photo.thumnailURL];
        NSData *imageData = [Thumnail  imageDataThumnailForPhoto:photo];
        if (!imageData){
            
            imageData = [[NSData alloc] initWithContentsOfURL:thumbnailURL];
        }
        UIImage *thumbnail =[[UIImage alloc] initWithData:imageData];
        dispatch_async(dispatch_get_main_queue(), ^{
            [photo.managedObjectContext performBlock:^{
                [Thumnail  insertThumnail:imageData forPhoto:photo];
            }];
            cell.imageView.image = thumbnail;
            [cell setNeedsLayout];
        });
    });
    //------------------------------
    
    return cell;
}
//----------------------------------------------------------------
# pragma mark   -    prepareForSegue
//----------------------------------------------------------------

//-----------iPhone-----------------------
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath;
        indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            //-------------Take tag from NSFetchedResultsController---
            Tag *tag = [self.fetchedResultsController.fetchedObjects objectAtIndex:indexPath.section];
            NSArray *descriptors =[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES]];
            NSArray *photos =[tag.photos sortedArrayUsingDescriptors:descriptors];
            Photo *photo = [photos objectAtIndex:indexPath.row];
            //--------------------------------------------------------
            if ([segue.identifier isEqualToString:@"Show image"]) {
                if ([segue.destinationViewController respondsToSelector:@selector(setImageURL:)]) {
                    [segue.destinationViewController performSelector:@selector(setImageURL:) withObject:[NSURL URLWithString:photo.imageURL]];
                    [segue.destinationViewController setTitle:photo.title];
                }
            }
        }
    }
}
//----------------------------------------------------------------
# pragma mark   -    Table view delegate
//----------------------------------------------------------------

//------------------ iPad ------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {  // only iPad
        //------ Take photo from NSFetchedResulsController----
        Tag *tag = [self.fetchedResultsController.fetchedObjects objectAtIndex:indexPath.section];
        NSArray *descriptors =[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES]];
        NSArray *photos =[tag.photos sortedArrayUsingDescriptors:descriptors];
        Photo *photo = [photos objectAtIndex:indexPath.row];
        //-----------------------------------------------
        ImageViewController *photoViewController =
        (ImageViewController *) [[self.splitViewController viewControllers] lastObject];
        if (photoViewController) {
            if ([photoViewController respondsToSelector:@selector(setImageURL:)]) {
                [photoViewController  performSelector:@selector(setImageURL:) withObject:[NSURL URLWithString:photo.imageURL]];
                [photoViewController  setTitle:photo.title];
            }
        }
    }
}


@end
