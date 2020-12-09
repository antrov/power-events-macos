//
//  PowerHistoryService.swift
//  PowerEvents
//
//  Created by Hubert Andrzejewski on 03/10/2019.
//  Copyright © 2019 Hubert Andrzejewski. All rights reserved.
//

import Foundation
import PromiseKit
import AppKit
import Combine

protocol PowerEventDescribing {
    var isUserCaused: Bool { get }
    var isPowerOn: Bool { get }
    var timestamp: Date { get }
}

protocol PowserHistoryServiceDelegate: class {
    func powerHistoryUpdated(with events: [PowerEventDescribing])
}

final class PowerHistoryService: ObservableObject {
    
    @Published var events: [PowerEventDescribing] = []
    
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
        
        delegate?.powerHistoryUpdated(with: self.events)
    }
    
}
