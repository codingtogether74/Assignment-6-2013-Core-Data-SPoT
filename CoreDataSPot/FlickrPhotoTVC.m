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

@property (nonatomic, strong) NSArray *searchSortDescriptors; // array of NSSortDescriptor describing how photo been sorted
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
}

//----------------------------------------------------------------
# pragma mark   -   Accessors for main NSFetchedResultController
//----------------------------------------------------------------

- (NSPredicate *)mainPredicate{
    if(!_mainPredicate){
        if (![self.tag.name isEqualToString:@"All"]) {
            _mainPredicate = [NSPredicate predicateWithFormat:@"(%@ in tags)", self.tag];
        }else{
            _mainPredicate = nil;//[NSPredicate predicateWithFormat:@""];
        }
    }
    return _mainPredicate;
}

- (NSString *)entityName{
    if(!_entityName){
        if (![self.tag.name isEqualToString:@"All"]) {
            _entityName = @"Photo";
        }else{
            _entityName = @"PhotoTag";
        }
    }
    return _entityName;
}

- (NSArray*) sortDescriptors{
    if(!_sortDescriptors){
        if (![self.tag.name isEqualToString:@"All"]) {        
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
          if (![self.tag.name isEqualToString:@"All"]) {
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
        if (![self.tag.name isEqualToString:@"All"]) {
            _searchSortDescriptors = @[[NSSortDescriptor
                                  sortDescriptorWithKey:@"title"
                                  ascending:YES
                                  selector:@selector(localizedCaseInsensitiveCompare:)]];
        } else {
            _searchSortDescriptors = @[[NSSortDescriptor
                                        sortDescriptorWithKey:@"photo.title"
                                        ascending:YES
                                        selector:@selector(localizedCaseInsensitiveCompare:)]];
        }
    }
    return _searchSortDescriptors;
}

- (NSString *)searchSectionKeyPath
{
    if(!_searchSectionKeyPath){
        if (![self.tag.name isEqualToString:@"All"]) {
            _searchSectionKeyPath = @"title.stringGroupByFirstLetter";
        }else{
            _searchSectionKeyPath = nil;
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
        request.predicate             =   self.searchPredicate;
        
        self.fetchedResultsController =    [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                              managedObjectContext: document.managedObjectContext
                                                                                sectionNameKeyPath:self.searchSectionKeyPath 
                                                                                         cacheName:nil];
}



//----------------------------------------------------------------
# pragma mark   -   Table view data source
//----------------------------------------------------------------


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Flickr Photo Cell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell..
//-------------Take photo from NSFetchedResultsController---
    Photo *photo = nil;
    if ([self.tag.name isEqualToString:@"All"]){
        PhotoTag *photoTag = [self.fetchedResultsController objectAtIndexPath:indexPath];
        photo = photoTag.photo;
    }else {
        photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    }
//--------------------------- NSFetchedresultController-----
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
# pragma mark   -    View lifecycle
//----------------------------------------------------------------

- (void)viewDidLoad
{
    [super viewDidLoad];
//        self.navigationItem.rightBarButtonItem = self.searchButton;
    [[DBHelper sharedManagedDocument] performWithDocument:
     ^(UIManagedDocument *document) {
         [self setupFetchedResultsControllerWithDocument:document];
     }];

//    self.debug =YES;

}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    DBHelper *dbh =[DBHelper sharedManagedDocument];
    dbh.dbName =@"Stanford Photos Database";
    [[DBHelper sharedManagedDocument] performWithDocument:
     ^(UIManagedDocument *document) {
         [self setupFetchedResultsControllerWithDocument:document];
     }];
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
        Photo *photo = nil;
        if ([self.tag.name isEqualToString:@"All"]){
            PhotoTag *photoTag = [self.fetchedResultsController objectAtIndexPath:indexPath];
            photo = photoTag.photo;
        }else {
            photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
        }
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

//----------------------------------------------------------------
# pragma mark   -    Table view delegate
//----------------------------------------------------------------

//------------------ iPad ------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {  // only iPad
//------ Take photo from NSFetchedResulsController----
        
        Photo *photo = nil;
        if ([self.tag.name isEqualToString:@"All"]){
            PhotoTag *photoTag = [self.fetchedResultsController objectAtIndexPath:indexPath];
            photo = photoTag.photo;
        }else {
            photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
        }
//---------------------------------------------------
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

#pragma mark - Search delegate

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
//    self.tableView.tableHeaderView = nil;
    [[DBHelper sharedManagedDocument] performWithDocument:^(UIManagedDocument *document) {
        [self setupFetchedResultsControllerWithDocument:document];
        [self performFetch];
    }];

}


//----------------------------------------------------------------
# pragma mark   -    SearchViewControl Delegate
//----------------------------------------------------------------

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    NSInteger searchOption = controller.searchBar.selectedScopeButtonIndex;
    return [self searchDisplayController:controller shouldReloadTableForSearchString:searchString searchScope:searchOption];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    NSString* searchString = controller.searchBar.text;
    return [self searchDisplayController:controller shouldReloadTableForSearchString:searchString searchScope:searchOption];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView{
    [self.fetchedResultsController.fetchRequest setPredicate:self.mainPredicate];
    [self performFetch];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString*)searchString searchScope:(NSInteger)searchOption {
    NSPredicate *predicate = nil;
    if ([searchString length]){
//---------------length
        if (searchOption == 0){ // typing
            if (![self.tag.name isEqualToString:@"All"]) {
                predicate = [NSPredicate predicateWithFormat:@"(title contains[cd] %@)", searchString];
            }else{
                predicate = [NSPredicate predicateWithFormat:@"photo.title like[cd] %@", [@"*" stringByAppendingString:[searchString stringByAppendingString:@"*"]]];
            }
            
            if (predicate) {
                predicate = self.mainPredicate ? [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, self.mainPredicate]]
                :predicate;
            }else{
                predicate =self.mainPredicate;
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
//-----------------length
    }    
    [[DBHelper sharedManagedDocument] performWithDocument:^(UIManagedDocument *document) {
    [self setupFetchedResultsControllerWithDocument:document];
    [self performFetch];
    }];
    return YES;
}

@end
