//
//  DataAccess.h
//  Work Hard
//
//  Created by Adrian Johnson on 13/03/2012.
//  Copyright (c) 2012 Adrian Johnson Consultants Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "Database.h"


/**
 * Datatase access class for accessing the ios internal database. Conforms to the Database protocol.
 *
 */
@interface DataAccess : NSObject<Database>


@end
