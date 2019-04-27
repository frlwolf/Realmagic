//
//  JsonToObjc.m
//  ObjcFromJson
//
//  Created by Felipe Lobo on 26/04/19.
//  Copyright © 2019 Felipe Lobo. All rights reserved.
//

#import "JsonToObjc.h"
#import <objc/runtime.h>

Class Some;

@implementation JsonToObjc {
    BOOL _creatingClass;
    __strong NSData *_data;
    __strong NSString *_name;
    __unsafe_unretained Class _superclass;
}

- (instancetype)initWithSuperclass:(Class)superclass name:(NSString *)name andData:(NSDictionary *)data
{
    self = [super init];
    if (self)
    {
        _superclass = superclass;
        _name = name;
        _data = data;
        _creatingClass = NO;
        
        if (!(Some = objc_lookUpClass(_name.UTF8String)))
        {
            Some = objc_allocateClassPair([RLMObject class], _name.UTF8String, 0);
            _creatingClass = YES;
        }
    }
    
    return self;
}

- (RLMObject *)getObject
{
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:_data options:0 error:nil];
    
    if (_creatingClass)
    {
        for (NSString *key in dict.keyEnumerator) {
            id value = dict[key];
            
            const char *typeName;
            
            if ([value isKindOfClass:[NSNumber class]])
                typeName = [value objCType];
            else
                typeName = [NSString stringWithFormat:@"@\"NSString\""].UTF8String;
            
            const char *ivarName = [NSString stringWithFormat:@"_%@", key].UTF8String;
            
            class_addIvar(Some, ivarName, sizeof(typeof(value)), log2(sizeof(typeof(value))), @encode(typeof(value)));
            
            objc_property_attribute_t type = { "T", typeName };
            objc_property_attribute_t backingivar  = { "V", ivarName };
            objc_property_attribute_t attrs[] = { type, backingivar };
            
            class_addProperty(Some, key.UTF8String, attrs, 2);
            
            void (^setter)(id, id) = ^(id _self, id new) {
                Ivar ivar = class_getInstanceVariable(Some, ivarName);
                id old = object_getIvar(_self, ivar);
                if (old != new)
                    object_setIvar(_self, ivar, [new copy]);
            };
            
            IMP setterImpl = imp_implementationWithBlock(setter);
            NSString *setterName = [NSString stringWithFormat:@"set%@:", [key capitalizedString]];
            
            class_addMethod(Some, NSSelectorFromString(setterName), setterImpl, "v@:@");
            
            id (^getter)(id) = ^(id _self) {
                Ivar ivar = class_getInstanceVariable(Some, ivarName);
                return object_getIvar(_self, ivar);
            };
            
            IMP getterImpl = imp_implementationWithBlock(getter);
            NSString *getterName = [NSString stringWithFormat:@"get%@", [key capitalizedString]];
            
            class_addMethod(Some, NSSelectorFromString(getterName), getterImpl, "@@:");
        }
        
        objc_registerClassPair(Some);
        
        _creatingClass = NO;
    }
    
    id some = [[Some alloc] init];

    for (NSString *key in dict.keyEnumerator) {
        id value = dict[key];
        
        const char *ivarName = [NSString stringWithFormat:@"_%@", key].UTF8String;
        Ivar ivar = class_getInstanceVariable(Some, ivarName);
    
        object_setIvar(some, ivar, value);
    }
    
    id sent = [some performSelector:NSSelectorFromString(@"getSent")];
    
    return some;
}

@end
