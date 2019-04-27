//
//  RealmEntity.m
//  ObjcFromJson
//
//  Created by Felipe Lobo on 27/04/19.
//  Copyright © 2019 Felipe Lobo. All rights reserved.
//

#import "RealmProxy.h"

@implementation RealmProxy

- (void)save:(NSArray <RLMObject *> *)objectsToSave {
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm transactionWithBlock:^{
        [realm addObjects:objectsToSave];
    }];
}

- (NSArray <RLMObject *> *)fetch {
    
}

@end
