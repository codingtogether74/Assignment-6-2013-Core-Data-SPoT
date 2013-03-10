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

@end

@implementation StanfordTagsTVC

- (void) fetchFlickrDataIntoDocument:(UIManagedDocument *)document
{
    [self startRefreshControl];
    
    dispatch_queue_t fetchQ = dispatch_queue_create("Flickr fetcher", NULL);
    dispatch_async(fetchQ, ^{
        [NetworkIndicatorHelper setNetworkActivityIndicatorVisible:YES];
        NSArray *photos = [FlickrFetcher stanfordPhotos];
        [NetworkIndicatorHelper setNetworkActivityIndicatorVisible:NO];
        
        [document.managedObjectContext performBlock:^{
            for (NSDictionary *flickrInfo in photos) {
                [Photo photoWithFlickrInfo:flickrInfo inManagedObjectContext:document.managedObjectContext];
            }
            // should probably saveToURL:forSaveOperation:(UIDocumentSaveForOverwriting)completionHandler: here!
            // we could decide to rely on UIManagedDocument's autosaving, but explicit saving would be better
            // because if we quit the app before autosave happens, then it'll come up blank next time we run
            // this is what it would look like (ADDED AFTER LECTURE) ...
            [document saveToURL:document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:NULL];
            // note that we don't do anything in the completion handler this time
            [self stopRefreshing];
        }];
    });
}

- (void)setupFetchedResultsControllerWithDocument:(UIManagedDocument *)document
{
    NSFetchRequest *request       =    [NSFetchRequest fetchRequestWithEntityName:@"Tag"];
    request.sortDescriptors       =    [NSArray arrayWithObject:[NSSortDescriptor
                                                                 sortDescriptorWithKey:@"name"
                                                                 ascending:YES
                                                                 selector:@selector(localizedCaseInsensitiveCompare:)]];
    
    self.fetchedResultsController =    [[NSFetchedResultsController alloc]
                                        initWithFetchRequest:request
                                        managedObjectContext:document.managedObjectContext
                                        sectionNameKeyPath:nil cacheName:nil];
    
}
-(void)useDocument
{
    DBHelper *dbh =[DBHelper sharedManagedDocument];
    dbh.dbName =@"Stanford Photos Database";
    
    if (![dbh.fileManager fileExistsAtPath:[dbh.database.fileURL path]]){
        [dbh.database saveToURL:dbh.database.fileURL
               forSaveOperation:UIDocumentSaveForCreating
              completionHandler:^(BOOL success) {
                  [self loadStanfordPhotos];
                  [self setupFetchedResultsControllerWithDocument:dbh.database];
              }];
    };
    
}
- (void)loadStanfordPhotos
{
    UIManagedDocument *document =[DBHelper sharedManagedDocument].database;
    [self fetchFlickrDataIntoDocument:document];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self useDocument];
    
    // a UIRefreshControl inherits from UIControl, so we can use normal target/action
    // this is the first time you’ve seen this done without ctrl-dragging in Xcode
    [self.refreshControl addTarget:self
                            action:@selector(loadStanfordPhotos)
                  forControlEvents:UIControlEventValueChanged];
    
    
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Tag Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    Tag *tag = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = tag.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ photos", tag.count];
    
    return cell;
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    Tag *tag = [self.fetchedResultsController objectAtIndexPath:indexPath];
    // be somewhat generic here (slightly advanced usage)
    // we'll segue to ANY view controller that has a tag @property
    if ([segue.destinationViewController respondsToSelector:@selector(setTag:)]) {
        // use performSelector:withObject: to send without compiler checking
        // (which is acceptable here because we used introspection to be sure this is okay)
        [segue.destinationViewController performSelector:@selector(setTag:) withObject:tag];
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
