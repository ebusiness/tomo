//
//  NSManagedObjectContext+Tomo.h
//  Tomo
//
//  Created by 張志華 on 2015/04/10.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (Tomo)
+ (void)MR_setRootSavingContext:(NSManagedObjectContext *)context;
+ (void)MR_setDefaultContext:(NSManagedObjectContext *)moc;
@end
