//
//  Database.h
//  ObjectiveCPersistanceAPI
//
//  Created by Adrian Johnson on 13/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LABData.h"

@protocol Database <NSObject>

/**
 * Class method for opening a connection to the database.
 */
+ (sqlite3*) openConnection;

@end
