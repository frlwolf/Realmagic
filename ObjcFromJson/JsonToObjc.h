//
//  JsonToObjc.h
//  ObjcFromJson
//
//  Created by Felipe Lobo on 26/04/19.
//  Copyright © 2019 Felipe Lobo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>

NS_ASSUME_NONNULL_BEGIN

@interface JsonToObjc<ObjectType> : NSObject

- (instancetype)initWithSuperclass:(Class)superclass
                              name:(NSString *)name
                           andData:(NSData *)data;

- (ObjectType)getObject;

@end

NS_ASSUME_NONNULL_END
