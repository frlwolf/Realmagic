//
//  RealmEntity.h
//  ObjcFromJson
//
//  Created by Felipe Lobo on 27/04/19.
//  Copyright © 2019 Felipe Lobo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>

NS_ASSUME_NONNULL_BEGIN

@interface RealmProxy : NSObject

- (void)save:(NSArray <RLMObject *> *)objectsToSave;

- (NSArray <RLMObject *> *)fetch;

@end

NS_ASSUME_NONNULL_END
