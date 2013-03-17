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
#import "Tag+Create.h"
#import "PhotoTag+Insert.h"

@interface FlickrPhotoTVC () <UISearchDisplayDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (nonatomic, strong) NSArray *sortDescriptors; // array of NSSortDescriptor describing how photo been sorted
@property (nonatomic, strong) NSString *sectionKeyPath;
@property (nonatomic, strong) NSPredicate *mainPredicate;
@property (nonatomic, strong) NSString *entityName;

@property (nonatomic, strong) NSArray *searchSortDescriptors; 
@property (nonatomic, strong) NSString *searchSectionKeyPath;
@property (nonatomic, strong) NSPredicate *searchPredicate;

@end

@implementation FlickrPhotoTVC

//----------------------------------------------------------------
# pragma mark   -   MODEL
//----------------------------------------------------------------
-(void)setTag:(Tag *)tag
{
    _tag = tag;
    self.title =tag.name;
    [[DBHelper sharedManagedDocument] performWithDocument:^(UIManagedDocument *document) {
        [self setupFetchedResultsControllerWithDocument:document];
    }];
    self.toResent =YES;
    self.navigationItem.title = [self.tag.name isEqualToString:ALL_PHOTO_TAG_NAME] ? @"All" : [self.tag.name capitalizedString];

}
//----------------------------------------------------------------
# pragma mark   -   Accessors for main NSFetchedResultController
//----------------------------------------------------------------

- (NSPredicate *)mainPredicate{
    if(!_mainPredicate){
        if (![self.tag.name isEqualToString:ALL_PHOTO_TAG_NAME]) {
            _mainPredicate = [NSPredicate predicateWithFormat:@"(%@ in tags)", self.tag];
        }else{
            _mainPredicate = nil;//[NSPredicate predicateWithFormat:@""];
        }
    }
    return _mainPredicate;
}

- (NSString *)entityName{
    if(!_entityName){
        if (![self.tag.name isEqualToString:ALL_PHOTO_TAG_NAME]) {
            _entityName = @"Photo";
        }else{
            _entityName = @"PhotoTag";
        }
    }
    return _entityName;
}

- (NSArray*) sortDescriptors{
    if(!_sortDescriptors){
        if (![self.tag.name isEqualToString:ALL_PHOTO_TAG_NAME]) {
            _sortDescriptors = @[[NSSortDescriptor
                                  sortDescriptorWithKey:@"title"
                                  ascending:YES
                                  selector:@selector(localizedCaseInsensitiveCompare:)]];
        } else {
            _sortDescriptors = @[[NSSortDescriptor
                                  sortDescriptorWithKey:@"nameTag"
                                  ascending:YES
                                  selector:@selector(localizedCaseInsensitiveCompare:)]];
        }
    }
    return _sortDescriptors;
}

- (NSString *)sectionKeyPath
{
    if(!_sectionKeyPath){
        if (![self.tag.name isEqualToString:ALL_PHOTO_TAG_NAME]) {
            _sectionKeyPath = @"title.stringGroupByFirstLetter";
        }else{
            _sectionKeyPath = @"nameTag";
        }
    }
    return _sectionKeyPath;
}

//----------------------------------------------------------------
# pragma mark   -   Accessors for search NSFetchedResultController
//----------------------------------------------------------------

- (NSArray*) searchSortDescriptors{
    if(!_searchSortDescriptors){
        if (![self.tag.name isEqualToString:ALL_PHOTO_TAG_NAME]) {
            _searchSortDescriptors = @[[NSSortDescriptor
                                  sortDescriptorWithKey:@"title"
                                  ascending:YES
                                  selector:@selector(localizedCaseInsensitiveCompare:)]];
        } else {
            _searchSortDescriptors = @[[NSSortDescriptor
                                        sortDescriptorWithKey: @"nameTag"
                                        ascending:YES
                                        selector:@selector(localizedCaseInsensitiveCompare:)]];
        }
    }
    return _searchSortDescriptors;
}

- (NSString *)searchSectionKeyPath
{
    if(!_searchSectionKeyPath){
        if (![self.tag.name isEqualToString:ALL_PHOTO_TAG_NAME]) {
            _searchSectionKeyPath = @"title.stringGroupByFirstLetter";
        }else{
            _searchSectionKeyPath =  @"nameTag";
        }
    }
    return _searchSectionKeyPath;
}

//----------------------------------------------------------------
# pragma mark   -   main NSFetchedResultController
//----------------------------------------------------------------
- (void)setupFetchedResultsControllerWithDocument:(UIManagedDocument *)document
{
        
        NSFetchRequest *request       =   [NSFetchRequest fetchRequestWithEntityName:self.entityName];
        request.sortDescriptors       =   self.sortDescriptors;
        request.predicate             =   self.mainPredicate;
        
        self.fetchedResultsController =   [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                              managedObjectContext:document.managedObjectContext
                                                                            sectionNameKeyPath:self.sectionKeyPath
                                                                                        cacheName:nil];
}

//----------------------------------------------------------------
# pragma mark   -   search NSFetchedResultController
//----------------------------------------------------------------

- (void)setupSearchFetchedResultsControllerWithDocument:(UIManagedDocument *)document
{
        
        NSFetchRequest *request       =   [NSFetchRequest fetchRequestWithEntityName:self.entityName];
        request.sortDescriptors       =    self.searchSortDescriptors;
        request.predicate             =    self.searchPredicate;
        
        self.fetchedResultsController =    [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                              managedObjectContext: document.managedObjectContext
                                                                                sectionNameKeyPath:self.searchSectionKeyPath 
                                                                                         cacheName:nil];
}

//----------------------------------------------------------------
# pragma mark   -   Table view data source
//----------------------------------------------------------------

- (Photo *)photoForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //-------------Take photo from NSFetchedResultsController---
    Photo *photo = nil;
    if ([self.tag.name isEqualToString:ALL_PHOTO_TAG_NAME]){
        PhotoTag *photoTag = [self.fetchedResultsController objectAtIndexPath:indexPath];
        photo = photoTag.photo;
    }else {
        photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    }
    //---------------------------------------------------------
    return photo;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Flickr Photo Cell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell..
    Photo *photo = [self photoForRowAtIndexPath:indexPath];
    cell.textLabel.text = photo.title;
    cell.detailTextLabel.text = photo.subtitle;
    //----Thumnail------------------
    NSURL *thumbnailURL =  [NSURL URLWithString:photo.thumnailURL];
    NSData *imageData = photo.thumbnailData;
    if (!imageData){
        dispatch_queue_t q = dispatch_queue_create("thumbnail download queue", 0);
        dispatch_async(q, ^{
            NSData *imageData = [[NSData alloc] initWithContentsOfURL:thumbnailURL];
            UIImage *thumbnail =[[UIImage alloc] initWithData:imageData];
            dispatch_async(dispatch_get_main_queue(), ^{
                [photo.managedObjectContext performBlock:^{
                    photo.thumbnailData = imageData;
                }];
                cell.imageView.image = thumbnail;
                [cell setNeedsLayout];
            });
        });
    } else {
        UIImage *thumbnail =[[UIImage alloc] initWithData:imageData];
        cell.imageView.image = thumbnail;
        [cell setNeedsLayout];
    }
    //------------------------------
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete){
//        Photo *photo = [self photoForRowAtIndexPath:indexPath];
            Photo *photo = [self photoForRowAtIndexPath:indexPath];
         [photo.managedObjectContext performBlock:^{
            [Photo removePhoto:photo];
        }];
    }
}
//----------------------------------------------------------------
# pragma mark   -    prepareForSegue
//----------------------------------------------------------------

//-----------iPhone-----------------------
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        //=============================================
        NSIndexPath *indexPath;
        
        if (self.searchDisplayController.active) {
            indexPath = [self.searchDisplayController.searchResultsTableView indexPathForCell:sender];
        } else {
            indexPath = [self.tableView indexPathForCell:sender];
        }
        //===============================================
        Photo *photo = [self photoForRowAtIndexPath:indexPath];
        if (indexPath) {
            if ([segue.identifier isEqualToString:@"Show image"]) {
                if ([segue.destinationViewController respondsToSelector:@selector(setImageURL:)]) {
                    [segue.destinationViewController performSelector:@selector(setImageURL:) withObject:[NSURL URLWithString:photo.imageURL]];
                    [segue.destinationViewController setTitle:photo.title];
                    ///--To Resents----
                    if (self.toResent) {
                        [photo.managedObjectContext performBlock:^{
                            [Photo putToResents:photo];
                        }];
                    }
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
        Photo *photo = [self photoForRowAtIndexPath:indexPath];
        ImageViewController *photoViewController =
        (ImageViewController *) [[self.splitViewController viewControllers] lastObject];
        if (photoViewController) {
            if ([photoViewController respondsToSelector:@selector(setImageURL:)]) {
                [photoViewController  performSelector:@selector(setImageURL:) withObject:[NSURL URLWithString:photo.imageURL]];
                [photoViewController  setTitle:photo.title];
                ///--To Resents----
                if (self.toResent) {
                    [photo.managedObjectContext performBlock:^{
                        [Photo putToResents:photo];
                    }];
                }
            }
        }
    }
}

//----------------------------------------------------------------
# pragma mark   -    SearchViewControl Delegate
//----------------------------------------------------------------
- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    [[DBHelper sharedManagedDocument] performWithDocument:^(UIManagedDocument *document) {
        [self setupFetchedResultsControllerWithDocument:document];
        [self performFetch];
    }];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString*)searchString  {
    NSPredicate *predicate = nil;
    if ([searchString length]){// typing
        
        if (![self.tag.name isEqualToString:ALL_PHOTO_TAG_NAME]) {
            predicate = [NSPredicate predicateWithFormat:@"(title contains[cd] %@)", searchString];
        }else{
            predicate = [NSPredicate predicateWithFormat:@"(photo.subtitle contains[cd] %@) OR (photo.title contains[cd] %@)", searchString , searchString];
        }
            predicate = self.mainPredicate ? [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, self.mainPredicate]] :predicate;        
    }
    //-------------Search NSFetchedController-----
    self.searchPredicate=predicate;
    [[DBHelper sharedManagedDocument] performWithDocument:^(UIManagedDocument *document) {
        [self setupSearchFetchedResultsControllerWithDocument:document];
        [self performFetch];
    }];
    //---------------------------------------------
    return YES;
}

@end
