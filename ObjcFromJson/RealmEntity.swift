//
//  JsonToObjc.swift
//  ObjcFromJson
//
//  Created by Felipe Lobo on 26/04/19.
//  Copyright © 2019 Felipe Lobo. All rights reserved.
//

import Foundation
import RealmSwift

struct RealmEntity<Base: Codable> {
    
    private let objcProxy: RealmProxy
    
    init() {
        objcProxy = RealmProxy()
    }
    
    func save(entities: [Base]) {
        objcProxy.save(entities.map { entity in
            return try! JSONEncoder().encode(entity)
        }.map { data in
            let toObjc = JsonToObjc(superclass: Object.self, name: String(describing: Base.self), andData: data)
            return toObjc.getObject()
        })
    }
    
}
