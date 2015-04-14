//
//  PCRUD.h
//  Exercise7
//
//  Created by Adrian Johnson on 21/11/2014.
//  Copyright (c) 2014 Training Dragon. All rights reserved.
//

#ifndef Exercise7_PCRUD_h
#define Exercise7_PCRUD_h


#endif

@protocol PCRUD

/**
 * Generic insert of model object.
 */
- (long long) insert:(id) object;

/**
 * Generic select of Class object with a where clause and field(s) to specify the sorting condition.
 */
- (NSArray*) select:(Class)clazz where:(NSDictionary*)where andSortBy:(NSArray*)sort;

/**
 * Generic select of Class object with a where clause.
 */
- (NSArray*) select:(Class)clazz where:(NSDictionary*)where;

/**
 * Generic select all records from the table that corresponds with the given of model object.
 */
- (NSArray*) select:(Class)clazz;

/**
 * Generic select query with where clause, field(s) to sort the query by and whether to sort in ascending or descening order.
 */
- (NSArray*) select:(Class)clazz filter:(NSDictionary*)where sortBy:(NSArray*)sort inAsc:(BOOL)asc;

/**
 * A select query that includes tokens (?) as placeholders for parameters that are passed into the method as an array.
 */
- (NSArray*) select:(NSString*)sql selectionArgs:(NSArray*)selectionArgs;

/**
 * Generic update on all records with the specified object type and where clause.
 */
- (long long) update:(id)object where:(NSDictionary*)where;

/**
 * Generic update the record of the specified object according to its primary key.
 */
- (long long) update:(id)object;

/**
 * Generic delete of  all records that are of the specified class type and meet the conddition of the where clause.
 */
- (long long) delete:(Class)clazz where:(NSDictionary*)where;

/**
 * Delete the specified object from persistent storage.
 */
- (long long) delete:(id)object;

@end