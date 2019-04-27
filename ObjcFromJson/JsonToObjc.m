//
//  JsonToObjc.m
//  ObjcFromJson
//
//  Created by Felipe Lobo on 26/04/19.
//  Copyright © 2019 Felipe Lobo. All rights reserved.
//

#import "JsonToObjc.h"
#import <objc/runtime.h>

Class registerDynamicClass(Class superclass,
                           const char *className,
                           NSDictionary *sample);

@implementation JsonToObjc {
    BOOL _creatingClass;
    __strong NSData *_data;
    __strong NSString *_name;
    __unsafe_unretained Class _superclass;
}

- (instancetype)initWithSuperclass:(Class)superclass name:(NSString *)name andData:(NSData *)data
{
    self = [super init];
    if (self)
    {
        _superclass = superclass;
        _name = name;
        _data = data;
        _creatingClass = NO;
        _creatingClass = YES;
    }
    
    return self;
}

- (id)getObject
{
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:_data options:0 error:nil];
    
    Class aClass = registerDynamicClass(_superclass, _name.UTF8String, dict);
    id obj = [[aClass alloc] init];

    for (NSString *key in dict.keyEnumerator) {
        id value = dict[key];
        
        const char *ivarName = [NSString stringWithFormat:@"_%@", key].UTF8String;
        Ivar ivar = class_getInstanceVariable(aClass, ivarName);
    
        object_setIvar(obj, ivar, value);
    }
    
    id sent = [obj performSelector:NSSelectorFromString(@"getSent")];
    
    return obj;
}

@end

// +++++++++++++

Class registerDynamicClass(Class superclass,
                           const char *className,
                           NSDictionary *sample) {
    
    Class Some = objc_allocateClassPair(superclass, className, 0);
    if (!Some)
        return objc_lookUpClass(className);
    
    for (NSString *key in sample.keyEnumerator) {
        id value = sample[key];
        
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
    
//    class_addIvar(Some, "_sample", sizeof(NSDictionary*), log2(sizeof(NSDictionary*)), @encode(NSDictionary*));
//
//    objc_property_attribute_t type = { "T", "@\"NSDictionary\"" };
//    objc_property_attribute_t backingivar  = { "V", "_sample" };
//    objc_property_attribute_t attrs[] = { type, backingivar };
//
//    class_addProperty(Some, "sample", attrs, 2);
    
    objc_registerClassPair(Some);
    
    return Some;
}
