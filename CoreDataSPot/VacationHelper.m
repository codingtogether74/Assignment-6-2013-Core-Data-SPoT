//
//  VacationHelper.m
//  VirtualVacation
//
//  Created by Tatiana Kornilova on 8/13/12.
//
//
#import "VacationHelper.h"
#import "FlickrFetcher.h"
#import "Photo+Flickr.h"

#define DEBUG_VACATION_NAME @"Debug Vacation"

@interface VacationHelper ()

@property (nonatomic, strong) NSURL *baseDir;

@end

@implementation VacationHelper

@synthesize database = _database;
@synthesize fileManager=_fileManager;
@synthesize baseDir=_baseDir;
@synthesize vacation=_vacation;

- (NSFileManager *)fileManager
{
    if (!_fileManager) _fileManager = [[NSFileManager alloc] init];
    return _fileManager;
}

- (NSURL *)baseDir
{
// Get documents directory and path.
    if (!_baseDir)
    {
        NSFileManager *fm = self.fileManager;
        NSURL *url=[[fm URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        _baseDir = [url URLByAppendingPathComponent:DEFAULT_DATABASE_FOLDER isDirectory:YES];
        BOOL isDir = NO;
        NSError *error;
        if (![fm fileExistsAtPath:[_baseDir path] isDirectory:&isDir] || !isDir)
            [fm createDirectoryAtURL:_baseDir withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) return nil;
    }

    return _baseDir;
}

- (UIManagedDocument *)database
{
    if (!_database) {
        _database = [[UIManagedDocument alloc] initWithFileURL:
                     [self.baseDir URLByAppendingPathComponent:self.vacation]];
    }
    return _database;
}

+ (NSArray *)getVacations
{
    VacationHelper *vh = [VacationHelper sharedVacation:nil];
    
    NSFileManager *fm = vh.fileManager;
    if (!vh.baseDir) return nil;
    
    NSError *error;
    NSArray *files = [fm contentsOfDirectoryAtURL:vh.baseDir
                       includingPropertiesForKeys:[NSArray arrayWithObject:NSURLNameKey]
                                          options:NSDirectoryEnumerationSkipsHiddenFiles
                                            error:&error];
    if (error) return nil;
    
    NSString *name;
    NSMutableArray *vacations = [NSMutableArray arrayWithCapacity:[files count]];
    for (NSURL *url in files) {
        [url getResourceValue:&name forKey:NSURLNameKey error:&error];
        if (error) continue;
        [vacations addObject:name];
    }
    
    if ([vacations count]) return vacations;
    
    return [NSArray arrayWithObject:DEFAULT_VACATION_NAME];;
}

+ (VacationHelper *)sharedVacation:(NSString *)vacationName
{
//----- It's a singleton --------------------------------------------
    static dispatch_once_t pred = 0;
    __strong static VacationHelper *_sharedVacation = nil;
    dispatch_once(&pred, ^{
        _sharedVacation = [[self alloc] init];
    });
//------prev vacation is not equal to new vacation name-------
    if (vacationName && ![vacationName isEqualToString:_sharedVacation.vacation]) {
        if (_sharedVacation.vacation)
            _sharedVacation.database = nil;
        _sharedVacation.vacation = vacationName;
    }
    return _sharedVacation;
}

+ (void)openVacation:(NSString *)vacationName usingBlock:(void (^)(BOOL))block
{
    VacationHelper *vh = [VacationHelper sharedVacation:vacationName];
    if (!vacationName && !vh.vacation) vh.vacation = DEFAULT_VACATION_NAME;
    if (![vh.fileManager fileExistsAtPath:[vh.database.fileURL path]]) {
        [vh.database saveToURL:vh.database.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:block];
    } else if (vh.database.documentState == UIDocumentStateClosed) {
        [vh.database openWithCompletionHandler:block];
    } else {
        BOOL success = YES;
        block(success);
    }
}

+ (void)createTestDatabase {
    VacationHelper *vh = [VacationHelper sharedVacation:DEBUG_VACATION_NAME];
    if ([vh.fileManager fileExistsAtPath:[vh.database.fileURL path]]) {
        vh.database = nil;
        return;
    }
    NSArray *photos = [FlickrFetcher recentGeoreferencedPhotos];
    //NSLog(@"%@", photos);
    [VacationHelper openVacation:DEBUG_VACATION_NAME usingBlock:^(BOOL success) {
        for (NSMutableDictionary *photo in photos) {
            [photo setObject:[photo objectForKey:@"place_id"] forKey:FLICKR_PHOTO_PLACE_NAME];
            [Photo photoFromFlickrInfo:photo inManagedObjectContext:vh.database.managedObjectContext];
        }
        [vh.database saveToURL:vh.database.fileURL
              forSaveOperation:UIDocumentSaveForOverwriting
             completionHandler:NULL];
    }];
}

@end
