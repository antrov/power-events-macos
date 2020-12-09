//
//  LastParsingModel.swift
//  PowerEvents
//
//  Created by Hubert Andrzejewski on 04/10/2019.
//  Copyright © 2019 Hubert Andrzejewski. All rights reserved.
//

import Foundation

final class LastParsingModel: ShellParsingModel, PowerEventDescribing {
    
    private static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "E MMM d HH:mm"
        formatter.defaultDate = Date()
        return formatter
    }()
    
    enum PseudoUser: String {
        case shutdown
        case reboot
    }
    
    let pseudoUser: PseudoUser
    
    // MARK: - <PowerEventDescribing>
    
    let timestamp: Date
    
    var isUserCaused: Bool {
        return true
    }
    
    var isPowerOn: Bool {
        switch pseudoUser {
        case .reboot:
            return true
            
        case .shutdown:
            return false
        }
    }
    
    init?(_ line: String) {
        let columns = line.split(separator: " ")
        
        guard columns.count == 6 else { return nil }
        
        let userRaw = String(columns[0])
        let dateRaw = columns.suffix(4).joined(separator: " ")
        
        guard
            let user = PseudoUser(rawValue: userRaw),
            let date = LastParsingModel.dateFormatter.date(from: dateRaw) else { return nil }
        
        self.pseudoUser = user
        self.timestamp = date
    }
}
