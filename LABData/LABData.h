//
//  LABData.h
//  LABData
//
//  Created by Adrian Johnson on 15/01/2015.
//  Copyright (c) 2015 Adrian Johnson Consultants Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PCRUD.h"
#import "QueryParam.h"
#import <sqlite3.h>

typedef void (^blk_t)(void);

@interface LABData : NSObject <PCRUD> {
    dispatch_queue_t dataSerialQueue;
}

/**
 * Create a database table by the specified class.
 */
- (void) createTable:(Class)klass;

/**
 * Create a singleton of this object.
 */
+ (id<PCRUD>)sharedInstance;

@end
