//
//  LastParsingModel.swift
//  Shekely
//
//  Created by Hubert Andrzejewski on 04/10/2019.
//  Copyright © 2019 Hubert Andrzejewski. All rights reserved.
//

import Foundation

final class LastParsingModel: ShellParsingModel {
    
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
    let timestamp: Date
    
    init?(_ line: Substring) {
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