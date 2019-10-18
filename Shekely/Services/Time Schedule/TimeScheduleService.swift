//
//  TimeScheduleService.swift
//  Shekely
//
//  Created by Hubert Andrzejewski on 14/10/2019.
//  Copyright © 2019 Hubert Andrzejewski. All rights reserved.
//

import Foundation

struct TimeEntity {
    let timestamp: Date
    let isOn: Bool
    
//    init(timestamp: Date) {
//        self.timestamp = timestamp
//    }
}

class TimeRange {

    var entities: [TimeEntity]
    
    var begin: TimeEntity {
        return entities.first!
    }
    
    var end: TimeEntity {
        return entities.last!
    }
    
    init(entities: [TimeEntity]) {
        self.entities = entities
    }
}

final class TimeScheduleService {
    
    private var entities: [TimeEntity] = []
    
    func loadEntities(_ entities: [TimeEntity]) {
        self.entities = entities
        
        
    }
    
}
