//
//  StanfordTagsTVC.m
//  CoreDataSPot
//
//  Created by Tatiana Kornilova on 3/7/13.
//  Copyright (c) 2013 Tatiana Kornilova. All rights reserved.
//

#import "StanfordTagsTVC.h"
#import "Tag.h"
#import "Photo+flickr.h"
#import "NetworkIndicatorHelper.h"
#import "DBHelper.h"

@interface StanfordTagsTVC ()
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

@implementation StanfordTagsTVC

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    if (managedObjectContext) {
        [self setupFetchedResultsController];
    } else {
        self.fetchedResultsController = nil;
    }
}
- (void)setupFetchedResultsController
{
    NSFetchRequest *request       =    [NSFetchRequest fetchRequestWithEntityName:@"Tag"];
    request.sortDescriptors       =    [NSArray arrayWithObject:[NSSortDescriptor
                                                                 sortDescriptorWithKey:@"name"
                                                                 ascending:YES
                                                                 selector:@selector(localizedCaseInsensitiveCompare:)]];
    
    self.fetchedResultsController =    [[NSFetchedResultsController alloc]
                                        initWithFetchRequest:request
                                        managedObjectContext:self.managedObjectContext
                                        sectionNameKeyPath:nil cacheName:nil];
    
}
#pragma mark - Refreshing

// Fires off a block on a queue to fetch data from Flickr.
// When the data comes back, it is loaded into Core Data by posting a block to do so on
//   self.managedObjectContext's proper queue (using performBlock:).
// Data is loaded into Core Data by calling photoWithFlickrInfo:inManagedObjectContext: category method.

- (IBAction)refresh
{
//    [self.refreshControl beginRefreshing];
    [self startRefreshControl];
    [NetworkIndicatorHelper setNetworkActivityIndicatorVisible:YES];

    dispatch_queue_t fetchQ = dispatch_queue_create("Flickr Fetch", NULL);
    dispatch_async(fetchQ, ^{
        NSArray *photos = [FlickrFetcher stanfordPhotos];
        // put the photos in Core Data
        [self.managedObjectContext performBlock:^{
 //----remove deleted photos --
            NSArray *deletedPhotoID =[self deletedPhotosIDInManagedObjectContext:self.managedObjectContext];
            for (NSDictionary *photo in photos) {
                NSString *unique =[photo[FLICKR_PHOTO_ID] description];
                if ([deletedPhotoID containsObject:unique]) continue;
                [Photo photoWithFlickrInfo:photo inManagedObjectContext:self.managedObjectContext];
            }
            // should probably saveToURL:forSaveOperation:(UIDocumentSaveForOverwriting)completionHandler: here!
            // we could decide to rely on UIManagedDocument's autosaving, but explicit saving would be better
            // because if we quit the app before autosave happens, then it'll come up blank next time we run
            // this is what it would look like (ADDED AFTER LECTURE) ...
            [self.photoDatabase saveToURL:self.photoDatabase.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:NULL];
            // note that we don't do anything in the completion handler this time
            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.refreshControl endRefreshing];
                [NetworkIndicatorHelper setNetworkActivityIndicatorVisible:NO];
                [self stopRefreshing];
            });
        }];
    });
}
- (NSArray *)deletedPhotosIDInManagedObjectContext:(NSManagedObjectContext *)context
{
    NSMutableArray *deletedPhotoID =[[NSMutableArray alloc] init];
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"DeletedPhoto"];
    NSSortDescriptor *sortDesciptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    request.sortDescriptors =[NSArray arrayWithObject:sortDesciptor];
    
    NSError *error =nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || matches ==0) {
        //handl error
        return nil;
    } else {
        for (DeletedPhoto *deletedPhoto in matches) {
             [deletedPhotoID addObject:deletedPhoto.unique];
        }
    }
    return deletedPhotoID;
}

-(void)useDocument
{
    DBHelper *dbh =[DBHelper sharedManagedDocument];
    dbh.dbName =@"Stanford Photos Database";
    self.photoDatabase = dbh.database;
    
    if (![dbh.fileManager fileExistsAtPath:[dbh.database.fileURL path]]){
        [dbh.database saveToURL:dbh.database.fileURL
               forSaveOperation:UIDocumentSaveForCreating
              completionHandler:^(BOOL success) {
                  if (success) {
                      self.managedObjectContext = self.photoDatabase.managedObjectContext;
                      [self refresh];
                  }
              }];
    } else if (self.photoDatabase.documentState == UIDocumentStateClosed) {
        [self.photoDatabase openWithCompletionHandler:^(BOOL success) {
            if (success) {
                self.managedObjectContext = self.photoDatabase.managedObjectContext;
            }
        }];
    } else {
        self.managedObjectContext = self.photoDatabase.managedObjectContext;
    }    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.refreshControl addTarget:self
                            action:@selector(refresh)
                  forControlEvents:UIControlEventValueChanged];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.managedObjectContext) [self useDocument];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Tag Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    Tag *tag = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = tag.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d photos", [tag.photos count]];
    
    return cell;
}
#pragma mark - Segue

// Gets the NSIndexPath of the UITableViewCell which is sender.
// Then uses that NSIndexPath to find the Tag in question using NSFetchedResultsController.
// Prepares a destination view controller through the "Show Photos For Tag" segue by sending that to it.

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = nil;
    
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        indexPath = [self.tableView indexPathForCell:sender];
    }
    if (indexPath) {
        if ([segue.identifier isEqualToString:@"Show Photos For Tag"]) {
            Tag *tag = [self.fetchedResultsController objectAtIndexPath:indexPath];
            if ([segue.destinationViewController respondsToSelector:@selector(setTag:)]) {
                [segue.destinationViewController performSelector:@selector(setTag:) withObject:tag];
            }
        }
    }
}

- (void)startRefreshControl
{
    [self.refreshControl beginRefreshing];
    //--------------------
	//set the title while refreshing
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing the TableView"];
    //set the date and time of refreshing
    NSDateFormatter *formattedDate = [[NSDateFormatter alloc] init];
    [formattedDate setDateFormat:@"MMM d, h:mm a"];
    NSString *lastupdated = [NSString stringWithFormat:@"Last Updated on %@",[formattedDate stringFromDate:[NSDate date]]];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:lastupdated];
    //--------------------
}

- (void)stopRefreshing
{
	if (self.refreshControl.refreshing) {
		[self.refreshControl endRefreshing];
		[self.tableView setContentOffset:CGPointZero animated:YES];
	}
}

@end
