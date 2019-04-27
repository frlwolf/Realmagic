//
//  Timeline.swift
//  ObjcFromJson
//
//  Created by Felipe Lobo on 26/04/19.
//  Copyright © 2019 Felipe Lobo. All rights reserved.
//

struct Timeline: Codable {

    let id: Int
    let name: String
    let sent: Int
    
    init(id: Int, name: String, sent: Int) {
        self.id = id
        self.name = name
        self.sent = sent
    }
    
}
