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
    
    func save(entities: [Base]) {
        let objectsToSave = try! entities
        .map(JSONEncoder().encode)
        .map { data -> Object in
            let toObjc: JsonToObjc<Object> = JsonToObjc(superclass: Object.self, name: String(describing: Base.self), andData: data)
            return toObjc.getObject()
        }
        
        let realm = try! Realm()
        try! realm.write {
            realm.add(objectsToSave)
        }
    }
    
}
