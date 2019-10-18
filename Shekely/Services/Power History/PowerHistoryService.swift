//
//  PowerHistoryService.swift
//  Shekely
//
//  Created by Hubert Andrzejewski on 03/10/2019.
//  Copyright © 2019 Hubert Andrzejewski. All rights reserved.
//

import Foundation
import PromiseKit
import AppKit

protocol PowerEventDescribing {
    var isUserCaused: Bool { get }
    var isPowerOn: Bool { get }
    var timestamp: Date { get }
}

protocol PowserHistoryServiceDelegate: class {
    func powerHistoryUpdated(with events: [PowerEventDescribing])
}

//class let willPowerOffNotification: NSNotification.Name
//
//Posted when the user has requested a logout or that the machine be powered off.
//class let willSleepNotification: NSNotification.Name
//
//Posted before the machine goes to sleep.
//class let screensDidSleepNotification: NSNotification.Name
//
//Posted when the machine’s screen goes to sleep.
//class let screensDidWakeNotification: NSNotification.Name
//
//Posted when the machine’s screens wake.

final class PowerHistoryService {
    
    var events: [PowerEventDescribing] = []
    weak var delegate: PowserHistoryServiceDelegate?
    
    private var notificationsObservers: [Any]?
    
    init() {
        fetchHistory()
        
        let center = NotificationCenter.default
        
        let wakeObserver = center.addObserver(forName: NSWorkspace.didWakeNotification, object: nil, queue: nil) { [weak self] _ in
            self?.fetchHistory()
        }
        
        notificationsObservers = [wakeObserver]
    }
    
    deinit {
        notificationsObservers?.forEach { observer in
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    private func fetchHistory() {
        let pmset: Guarantee<[PMSetParsingModel]> = Shell().execute("pmset -g log|grep -e \" Sleep  \" -e \" Wake  \"")
        let last: Guarantee<[LastParsingModel]> = Shell().execute("last reboot shutdown")
        
        when(fulfilled: [
            pmset.mapValues { $0 as PowerEventDescribing },
            last.mapValues { $0 as PowerEventDescribing }
        ])
        .map { outs in
            return outs.joined().sorted(by: { (lhs, rhs) in
                return lhs.timestamp < rhs.timestamp
            })
        }
        .done(on: .main) { (out) in
            self.updateHistory(with: out)
        }
        .catch { error in
            print("Fetch history error: \(error)")
        }
    }
    
    private func updateHistory(with events: [PowerEventDescribing]) {
        self.events = events
        let f = self.events.first { (event) -> Bool in
            return Calendar.current.isDateInToday(event.timestamp)
        }
        
        print(f?.timestamp.timeIntervalSinceNow)
        
        delegate?.powerHistoryUpdated(with: self.events)
    }
    
    // MARK: Notifications
    
//    private func
    
}
