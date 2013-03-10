//
//  FlickrPhotoTVC.m
//  CoreDataSPot
//
//  Created by Tatiana Kornilova on 3/7/13.
//  Copyright (c) 2013 Tatiana Kornilova. All rights reserved.
//

#import "FlickrPhotoTVC.h"
#import "Photo+flickr.h"
#import "DBHelper.h"
#import "FlickrFetcher.h"
#import "Thumnail+Create.h"
#import "ImageViewController.h"

@implementation FlickrPhotoTVC

- (void)setupFetchedResultsController
{
    if (![self.tag.name isEqualToString:@"All"]) {
        
        NSFetchRequest *request       =   [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
        request.sortDescriptors       =   [NSArray arrayWithObject:[NSSortDescriptor
                                                                    sortDescriptorWithKey:@"title"
                                                                    ascending:YES
                                                                    selector:@selector(localizedCaseInsensitiveCompare:)]];
        request.predicate             =   [NSPredicate predicateWithFormat:@"%@ in tags",self.tag];
        
        self.fetchedResultsController =   [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                              managedObjectContext:self.tag.managedObjectContext
                                                                                sectionNameKeyPath:@"title.stringGroupByFirstLetter"
                                                                                         cacheName:nil];
    } else{
        
        NSFetchRequest *request       =   [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
        request.sortDescriptors       =   [NSArray arrayWithObject:[NSSortDescriptor
                                                                    sortDescriptorWithKey:@"title"
                                                                    ascending:YES
                                                                    selector:@selector(localizedCaseInsensitiveCompare:)]];
        //        request.predicate             =   [NSPredicate predicateWithFormat:@"%@ in tags",self.tag];
        
        self.fetchedResultsController =   [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                              managedObjectContext:self.tag.managedObjectContext
                                                                                sectionNameKeyPath:nil
                                                                                         cacheName:nil];
    }
    
}

-(void)setTag:(Tag *)tag
{
    _tag = tag;
    self.title =tag.name;
    [self setupFetchedResultsController];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Flickr Photo Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath]; // ask NSFRC for the NSMO at the row in question
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
                    ///--To Resents----
                    [photo.managedObjectContext performBlock:^{
                        [Photo putToResents:photo];
                    }];
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
                ///--To Resents----
                [photo.managedObjectContext performBlock:^{
                    [Photo putToResents:photo];
                }];
                
            }
        }
    }
}
@end
