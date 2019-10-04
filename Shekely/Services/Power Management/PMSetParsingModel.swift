//
//  PMSetParsingModel.swift
//  Shekely
//
//  Created by Hubert Andrzejewski on 04/10/2019.
//  Copyright © 2019 Hubert Andrzejewski. All rights reserved.
//

import Foundation

class PMSetParsingModel: ShellParsingModel {
    
    private static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZZZ"
        return formatter
    }()
    
    enum PowerState: String {
        case wake = "Wake"
        case sleep = "Sleep"
    }
    
    enum Reason: String, CaseIterable {
        case idleSleep = "Idle Sleep"
        case maintenanceSleep = "Maintenance Sleep"
        case clamshellSleep = "Clamshell Sleep"
        case softwareSleep = "Software Sleep"
        case powerButton = "EC.PowerButton"
        case lidOpen = "EC.LidOpen"
        case notification = "Notification"
        case hidActivity = "HID Activity"
        case userActivity = "UserActivity"
        case other = "com.antrov.undefinedreason"
    }
    
    let timestamp: Date
    let powerState: PowerState
    let reason: Reason
    
    required init?(_ line: Substring) {
        let columns = line.split(separator: "\t")
        
        guard columns.count > 1 else { return nil }
        let headers = columns[0].split(separator: " ")
        let description = columns[1]
        
        guard headers.count == 4 else { return nil }
        let dateRaw = headers[0...2].joined(separator: " ")
        let stateRaw = headers[3].trimmingCharacters(in: .whitespacesAndNewlines)

        guard let state = PowerState(rawValue: stateRaw), let date = PMSetParsingModel.dateFormatter.date(from: dateRaw) else { return nil }

        self.powerState = state
        self.timestamp = date
        self.reason = Reason.allCases.first { description.contains($0.rawValue) } ?? .other
    }
    
}
