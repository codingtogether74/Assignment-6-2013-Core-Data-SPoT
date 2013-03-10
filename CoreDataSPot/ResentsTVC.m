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


@interface ResentsTVC ()

@end

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

//-----------iPhone-----------------------
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
        if (indexPath) {
            if ([segue.identifier isEqualToString:@"Show image"]) {
                if ([segue.destinationViewController respondsToSelector:@selector(setImageURL:)]) {
                    [segue.destinationViewController performSelector:@selector(setImageURL:) withObject:[NSURL URLWithString:photo.imageURL]];
                    [segue.destinationViewController setTitle:photo.title];
                }
            }
        }
    }
}

//------------------ iPad ------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {  // only iPad
        Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
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
