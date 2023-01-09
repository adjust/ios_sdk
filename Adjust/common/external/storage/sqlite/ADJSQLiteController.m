//
//  ADJSQLiteController.m
//  Adjust
//
//  Created by Aditi Agrawal on 19/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJSQLiteController.h"


#import "ADJPublisherBase.h"
#import "ADJUtilSys.h"
#import "ADJUtilF.h"
#import "ADJV4RestMigration.h"
#import "ADJV4FilesData.h"
#import "ADJV4UserDefaultsData.h"
#import "ADJConstants.h"

#pragma mark Private class
@interface ADJSQLiteStorageAggregator : ADJPublisherBase<id<ADJSQLiteStorage>> @end
@implementation ADJSQLiteStorageAggregator @end

#pragma mark Fields
#pragma mark - ADJSQLiteDatabaseProvider
/* ADJSQLiteDatabaseProvider.h
 @property (nonnull, readonly, strong, nonatomic) ADJSQLiteDb *sqliteDb;
 */
#pragma mark - Private constants
static int const kDatabaseVersion = 5000; // v5.00.0

@interface ADJSQLiteController ()
#pragma mark - Internal variables
@property (nonnull, readonly, strong, nonatomic) ADJSQLiteStorageAggregator *sqliteStorageAggregator;
@property (nonnull, readonly, strong, nonatomic) ADJV4RestMigration *v4RestMigration;

@end

@implementation ADJSQLiteController
#pragma mark Instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory {
    self = [super initWithLoggerFactory:loggerFactory source:@"SQLiteController"];
    
    _sqliteStorageAggregator = [[ADJSQLiteStorageAggregator alloc] init];
    
    _v4RestMigration = [[ADJV4RestMigration alloc] initWithLoggerFactory:loggerFactory];
    
    _sqliteDb = [[ADJSQLiteDb alloc]
                 initWithLoggerFactory:loggerFactory
                 databasePath:[ADJUtilSys getFilePathInDocumentsDir:ADJDatabaseName]];
    
    return self;
}

#pragma mark Public API
- (void)addSqlStorage:(nonnull id<ADJSQLiteStorage>)sqlStorage {
    [self.sqliteStorageAggregator addSubscriber:sqlStorage];
}

- (void)readAllIntoMemorySync {
    [self.logger debugDev:@"Trying to read all database tables into memory"];
    
    if (self.sqliteDb.databasePath == nil) {
        [self.logger debugDev:@"Cannot read into memory without a sqlite file path"
                    issueType:ADJIssueStorageIo];
        return;
    }
    
    NSFileManager *_Nonnull fileManager = [NSFileManager defaultManager];
    BOOL didDbExisted = [fileManager fileExistsAtPath:self.sqliteDb.databasePath];
    
    [self.logger debugDev:@"Db file found?"
                      key:@"didDbExisted"
                    value:[ADJUtilF boolFormat:didDbExisted].description];
    
    BOOL openSuccess = [self.sqliteDb openDb];
    
    if (! openSuccess) {
        [self.logger debugDev:@"Cannot read into memory without being able to open the db"
                    issueType:ADJIssueStorageIo];
        return;
    }
    
    int dbVersion = [self.sqliteDb dbVersion];
    
    BOOL migrateFromV4 = NO;
    BOOL upgradeVersion = NO;
    
    if (dbVersion != kDatabaseVersion) {
        [self.sqliteDb setDbVersion:kDatabaseVersion];
        
        if (dbVersion == 0) {
            //[self didCreateDb];
            [self createTables];
            
            migrateFromV4 = YES;
        } else {
            //[self didUpgradeWithOldVersion:dbVersion];
            upgradeVersion = YES;
        }
    }
    
    [self.sqliteStorageAggregator notifySubscribersWithSubscriberBlock:
     ^(id<ADJSQLiteStorage> _Nonnull sqliteStorage)
     {
        [sqliteStorage readIntoMemorySync:self.sqliteDb];
    }];
    
    if (migrateFromV4) {
        [self migrateFromV4];
    }
    
    if (upgradeVersion) {
        [self didUpgradeWithOldVersion:dbVersion];
    }
}

#pragma mark Internal Methods
- (void)didCreateDb {
    [self createTables];
    [self migrateFromV4];
}

- (void)createTables {
    [self.logger debugDev:@"Creating database tables"];
    
    [self.sqliteStorageAggregator notifySubscribersWithSubscriberBlock:
     ^(id<ADJSQLiteStorage> _Nonnull sqliteStorage)
     {
        [self.sqliteDb executeStatements:[sqliteStorage sqlStringForOnCreate]];
    }];
    
    [self.logger debugDev:@"All database tables created"];
}

- (void)migrateFromV4 {
    ADJV4FilesData *_Nonnull v4FilesData = [[ADJV4FilesData alloc] initWithLogger:self.logger];
    ADJV4UserDefaultsData *_Nonnull v4UserDefaultsData =
        [[ADJV4UserDefaultsData alloc] initWithLogger:self.logger];
    
    [self.logger debugDev:@"Migrating data from v4 to database"];
    
    [self.sqliteStorageAggregator notifySubscribersWithSubscriberBlock:
     ^(id<ADJSQLiteStorage> _Nonnull sqliteStorage)
     {
        [sqliteStorage migrateFromV4WithV4FilesData:v4FilesData
                                v4UserDefaultsData:v4UserDefaultsData];
    }];
    
    [self.v4RestMigration migrateFromV4WithV4FilesData:v4FilesData
                                    v4UserDefaultsData:v4UserDefaultsData];
    
    [self.logger debugDev:@"All data migrated from v4 to database"];
}

- (void)didUpgradeWithOldVersion:(int)oldDbVersion {
    [self.logger debugDev:@"Upgrading database"
                     key1:@"old version"
                   value1:[ADJUtilF integerFormat:oldDbVersion]
                     key2:@"new version"
                   value2:[ADJUtilF integerFormat:kDatabaseVersion]];
    
    [self.sqliteStorageAggregator notifySubscribersWithSubscriberBlock:
     ^(id<ADJSQLiteStorage> _Nonnull sqliteStorage)
     {
        NSString *_Nullable sqlStringForOnUpgrade =
            [sqliteStorage sqlStringForOnUpgrade:oldDbVersion];
        
        if (sqlStringForOnUpgrade == nil) {
            [self.logger debugDev:@"Not upgrading sqlite storage"
                        issueType:ADJIssueStorageIo];
            return;
        }
        
        [self.logger debugDev:@"Upgrading sqlite storage"
                          key:@"sqlStringForOnUpgrade"
                        value:sqlStringForOnUpgrade];
        
        [self.sqliteDb executeStatements:sqlStringForOnUpgrade];
    }];
}

@end