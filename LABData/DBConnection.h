//
//  DBConnection.h
//  ObjectiveCPersistanceAPI
//
//  Created by Adrian Johnson on 13/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface DBConnection : NSObject {
    NSString * const BLOB;
    NSString * const TEXT;
    NSString * const INT;
    NSString * const INT64;
    NSString * const DOUBLE;
}

/**
 * Execute sql insert/create statement. The main query is a char array (c type array) with placeholders
 * (?) while the parameters passed in as varargs.
 */
- (BOOL) create:(const char*)query, ...;

/**
 * Execute sql select query statement. The main query is a char array (c type array) with placeholders
 * (?) while the parameters passed in as varargs.
 */
- (NSArray*) read:(const char*)query, ...;

/**
 * Execute sql update statement. The main query is a char array (c type array) with placeholders
 * (?) while the parameters passed in as varargs.
 */
- (void) update:(const char*)query, ...;

/**
 * Execute sql delete statement. The main quey is a char array (c type array) with placeholders
 * (?) while the parameters passed in as varargs.
 */
- (void) delete:(const char*)query, ...;

/**
 * close the database connection and free the resources.
 */
- (void) close;

/**
 * Construct a list of instuctions to execute against the database.
 */
- (NSMutableArray*) getDatabaseInstructions:(const char*)characters;

/**
 * Execute select query against the database where no 'WHERE' clause is required.
 */
- (NSArray*) fastRead:(const char*)query;

/**
 * Initialise object with the sqlite database and return a DBConnection object that represents an 
 * open database connection.
 */
+ (DBConnection*) initWith:(sqlite3*)theDatabase;

@end
