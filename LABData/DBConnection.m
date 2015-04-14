//
//  DBConnection.m
//  ObjectiveCPersistanceAPI
//
//  Created by Adrian Johnson on 13/03/2012.
//  Copyright (c) 2012 Adrian Johnson Consultants Ltd. All rights reserved.
//

#import "DBConnection.h"

static DBConnection *sharedDBConnection;

@implementation DBConnection

sqlite3* database;
NSString * const BIND_BLOB = @"BLOB";
NSString * const BIND_TEXT = @"TEXT";
NSString * const BIND_INT = @"INT";
NSString * const BIND_DOUBLE = @"DOUBLE";
NSString * const BIND_INT64 = @"INT64";

/**
 * Called by the system before any instances of the class are created, this is used to set up the 
 * static sharedDBConncection variable.
 */
+ (void)initialize {
    sharedDBConnection = [DBConnection new];
}

/**
 * Initialise object with the sqlite database and return a DBConnection object that represents an
 * open database connection.
 */
+ (DBConnection*) initWith:(sqlite3*)theDatabase {
    database = theDatabase;
    return sharedDBConnection;
}

/**
 * Insert or create new data into the database. Execute sql insert/create statement. The main query is 
 * a char array (c type array) with placeholders (?) while the parameters passed in as varargs.
 *
 */
- (BOOL) create:(const char*)query, ... {
    BOOL created = YES;
    NSLog(@"Creating data with ... %s", query);
    NSMutableArray *instructions = [self getDatabaseInstructions:query];
    NSString *queryString = [instructions lastObject];
    [instructions removeLastObject];
	sqlite3_stmt *statement;
	if(sqlite3_prepare_v2(database, [queryString UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(database));
	}
	va_list varList;
    va_start(varList, query);
    [self addQueryParams:instructions fromParams:varList toStatement:statement];
    va_end(varList);
    
	
	if(SQLITE_DONE != sqlite3_step(statement)) {
		//NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(database));
        created = NO;
	}
	else {
		NSLog(@"Created %llu", sqlite3_last_insert_rowid(database));
		sqlite3_reset(statement);
	}
	sqlite3_finalize(statement);
    return created;
}

/**
 * Execute select query against the database where no 'WHERE' clause is required.
 */
- (NSArray*) fastRead:(const char*)query {
	NSMutableArray *list = [[NSMutableArray alloc] init];
    
    
	sqlite3_stmt *statement;
	int sqlResult = sqlite3_prepare_v2(database, query, -1, &statement, NULL);
	
	if (sqlResult == SQLITE_OK) {
		
        int columnCount = sqlite3_column_count(statement);
		while (sqlite3_step(statement) == SQLITE_ROW) {
            NSMutableDictionary *row = [[NSMutableDictionary alloc] init];
            for (char i = 0; i < columnCount; i++) {
                const char* colName = sqlite3_column_name(statement, i);
                NSString *columnName = [NSString stringWithCString:colName encoding:NSUTF8StringEncoding];
                if (sqlite3_column_type(statement, i) == SQLITE_TEXT) {
                    char *characters = (char*)sqlite3_column_text(statement, i);
                    [row setObject:[NSString stringWithCString:characters encoding:NSUTF8StringEncoding] forKey:columnName];
                }
                if (sqlite3_column_type(statement, i) == SQLITE_INTEGER) {
                    sqlite3_int64 wholeNumber = sqlite3_column_int64(statement, i);
                    [row setValue:[NSNumber numberWithLongLong:wholeNumber] forKey:columnName];
                }
                if (sqlite3_column_type(statement, i) == SQLITE_BLOB) {
                    NSData *data = [[NSData alloc] initWithBytes:sqlite3_column_blob(statement, i) length: sqlite3_column_bytes(statement, i)];
                    // use the following to retrieve the nsdata object:-
                    // [NSKeyedArchiver archivedDataWithRootObject:value]
                    [row setObject:data forKey:columnName];
                    
                }
                if (sqlite3_column_type(statement, i) == SQLITE_FLOAT) {
                    double decimalNumber = sqlite3_column_double(statement, i);
                    [row setObject:[NSNumber numberWithDouble:decimalNumber] forKey:columnName];
                }
            }
            [list addObject:row];
		}
		NSLog(@"about to finalise:");
		sqlite3_finalize(statement);
		NSLog(@"finalised:");
	} else {
		NSLog(@"Problem with the database:");
		NSLog(@"%d",sqlResult);
	}
	//NSLog(@"returning: %i", [list count]);
	return list;
}

/**
 * Read data from the database via select queries. Execute sql select query statement. The main query is 
 * a char array (c type array) with placeholders (?) while the parameters passed in as varargs.
 *
 */
- (NSArray*) read:(const char*)query, ... {
	NSMutableArray *list = [[NSMutableArray alloc] init];
    NSMutableArray *instructions = [self getDatabaseInstructions:query];
    NSString *queryString = [instructions lastObject];
    [instructions removeLastObject];
	sqlite3_stmt *statement;
	int sqlResult = sqlite3_prepare_v2(database, [queryString UTF8String], -1, &statement, NULL);
	
	if (sqlResult == SQLITE_OK) {
		va_list varList;
        va_start(varList, query);
        [self addQueryParams:instructions fromParams:varList toStatement:statement];
        va_end(varList);
        int columnCount = sqlite3_column_count(statement);
		while (sqlite3_step(statement) == SQLITE_ROW) {
            NSMutableDictionary *row = [[NSMutableDictionary alloc] init];
            for (char i = 0; i < columnCount; i++) {
                const char* colName = sqlite3_column_name(statement, i);
                NSString *columnName = [NSString stringWithCString:colName encoding:NSUTF8StringEncoding];
                if (sqlite3_column_type(statement, i) == SQLITE_TEXT) {
                    char *characters = (char*)sqlite3_column_text(statement, i);
                    [row setObject:[NSString stringWithCString:characters encoding:NSUTF8StringEncoding] forKey:columnName];
                }
                if (sqlite3_column_type(statement, i) == SQLITE_INTEGER) {
                    sqlite3_int64 wholeNumber = sqlite3_column_int64(statement, i);
                    [row setValue:[NSNumber numberWithLongLong:wholeNumber] forKey:columnName];
                }
                if (sqlite3_column_type(statement, i) == SQLITE_BLOB) {
                    NSData *data = [[NSData alloc] initWithBytes:sqlite3_column_blob(statement, i) length: sqlite3_column_bytes(statement, i)];
                    // use the following to retrieve the nsdata object:- 
                    // [NSKeyedArchiver archivedDataWithRootObject:value]
                    [row setObject:data forKey:columnName];

                }
                if (sqlite3_column_type(statement, i) == SQLITE_FLOAT) {
                    double decimalNumber = sqlite3_column_double(statement, i);
                    [row setObject:[NSNumber numberWithDouble:decimalNumber] forKey:columnName];
                }
            }
            [list addObject:row];
		}
		NSLog(@"about to finalise:");		
		sqlite3_finalize(statement);
		NSLog(@"finalised:");		
	} else {
		NSLog(@"Problem with the database:");
		NSLog(@"%d",sqlResult);
	}
	//NSLog(@"returning: %i", [list count]);
	return list;
}

/**
 * Update data in the database. Execute sql update statement. The main query is a char array (c type
 * array) with placeholders (?) while the parameters passed in as varargs.
 *
 */
- (void) update:(const char*)query, ... {
    NSMutableArray *instructions = [self getDatabaseInstructions:query];
    NSString *queryString = [instructions lastObject];
    [instructions removeLastObject];
	sqlite3_stmt *statement;
	if(sqlite3_prepare_v2(database, [queryString UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(database));
	}
	va_list varList;
    va_start(varList, query);
    [self addQueryParams:instructions fromParams:varList toStatement:statement];
    va_end(varList);
    
	
	if(SQLITE_DONE != sqlite3_step(statement)) {
		NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(database));
	}
	else {
		NSLog(@"Updated %llu", sqlite3_last_insert_rowid(database));
		sqlite3_reset(statement);
	}
	sqlite3_finalize(statement);
}

/**
 * Delete data from the database. Execute sql delete statement. The main quey is a char array (c 
 * type array) with placeholders (?) while the parameters passed in as varargs.
 *
 */
- (void) delete:(const char*)query, ... {
    NSMutableArray *instructions = [self getDatabaseInstructions:query];
    NSString *queryString = [instructions lastObject];
    [instructions removeLastObject];
    sqlite3_stmt *statement;

	if(sqlite3_prepare_v2(database, [queryString UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		NSAssert1(0, @"Error while creating delete statement. '%s'", sqlite3_errmsg(database));
	}
    // Automatic variable containing a variable amount of arguments passed in with the query.
	va_list varList;
    // Pass in the last parameter of the argument list so that we know where to start searching
    // the list from.
    va_start(varList, query);
    // extract the parameters from the list (varList) and add them to the database statement.
    [self addQueryParams:instructions fromParams:varList toStatement:statement];
    // This list operates like a stream of data and therefore we need to tell it
    // that we need to stop.
    va_end(varList);
	if(SQLITE_DONE != sqlite3_step(statement)) {
		NSAssert1(0, @"Error while removing data. '%s'", sqlite3_errmsg(database));
	}
	else {
		NSLog(@"Removed %llu", sqlite3_last_insert_rowid(database));
		sqlite3_reset(statement);
	}
	sqlite3_finalize(statement);
}

/**
 * Close the database connection.
 *
 */
- (void) close {
	if (sqlite3_close(database) != SQLITE_OK) {
		NSAssert1(0, @"Error: failed to close database: '%s'.", sqlite3_errmsg(database));
	} else {
		NSLog(@"Closing Database");
	}
}

/**
 * Construct a list of instuctions to execute against the database by analysing the query string 
 * in order to identify if there are any parameters and of what type.
 * The string specifiers are replaced with '?'.
 *
 */
- (NSMutableArray*) getDatabaseInstructions:(const char*)characters {
    NSLog(@"RAW QUERY: %s", characters);
    int i = 0;
    NSMutableString *string = [NSMutableString stringWithCapacity:0];
    NSMutableArray *instructionArray = [NSMutableArray arrayWithCapacity:0];
    while(characters[i] != '\0'){
        if (characters[i] == '%' ) {
            if (characters[i+1] == '@') {
                NSLog(@"'@':");
                [string appendString:@"?"];
                i += 1;
                [instructionArray addObject:BIND_BLOB];
            } else if (characters[i+1] == 's') {
                NSLog(@"'s':");
                [string appendString:@"?"];
                i += 1;
                [instructionArray addObject:BIND_TEXT];
            } else if (characters[i+1] == 'i') {
                NSLog(@"'i':");
                [string appendString:@"?"];
                i += 1;
                [instructionArray addObject:BIND_INT];
            } else if (characters[i+1] == 'f') {
                [string appendString:@"?"];
                i+=1;
                [instructionArray addObject:BIND_DOUBLE];
            } else if (characters[i+1] == 'q' && characters[i+2] == 'i') {
                NSLog(@"'qi':");
                [string appendString:@"?"];
                i+=2;
                [instructionArray addObject:BIND_INT64];
            } 
        } else {
            [string appendString:[NSString stringWithFormat:@"%c" , characters[i]]];
        }
        i++;
    }
     NSLog(@"FINAL QUERY: %@", string);
    [instructionArray addObject:string];
    return instructionArray;
}

/**
 * Add the additional parameters to the database query.
 *
 */
- (void) addQueryParams:(NSArray*)instructions fromParams:(va_list)varList toStatement:(sqlite3_stmt*)statement {
    for (int i = 0; i < [instructions count]; i++) {
        NSString *instruction = [instructions objectAtIndex:i];
        if (instruction == BIND_BLOB) {
            NSData *data = va_arg(varList, NSData*);
            sqlite3_bind_blob(statement, i+1, [data bytes], (int)[data length], NULL);
        }
        if (instruction == BIND_INT) {
            int number = va_arg(varList, int);
            sqlite3_bind_int(statement, i+1, number);
        }
        if (instruction == BIND_TEXT) {
            const char *characters = va_arg(varList, const char*);
            sqlite3_bind_text(statement, i+1, characters, -1, SQLITE_TRANSIENT);
        }
        if (instruction == BIND_INT64) {
            sqlite3_int64 number = va_arg(varList, sqlite3_int64);
            sqlite3_bind_int64(statement, i+1, number);
        }
        if (instruction == BIND_DOUBLE) {
            double number = va_arg(varList, double);
            sqlite3_bind_double(statement, i+1, number);
        }
    }
}

@end
