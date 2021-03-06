//
//  Shell.swift
//  PowerEvents
//
//  Created by Hubert Andrzejewski on 03/10/2019.
//  Copyright © 2019 Hubert Andrzejewski. All rights reserved.
//

import Foundation
import PromiseKit

protocol ShellParsingModel {
    init?(_ line: String)
}

final class Shell {
    
    enum EOLSymbol: String {
        case lf = "\n"
        case crlf = "\r\n"
        case cr = "\r"
    }
    
    private let notificationQueue = OperationQueue()
    private var notificationObserver: NSObjectProtocol!
    private let eol: EOLSymbol
    
    init(eol: EOLSymbol = .lf) {
        self.eol = eol
    }    
    
    func execute<T: ShellParsingModel>(_ command: String) -> Guarantee<[T]> {
        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = ["-c", command]
        
        let pending = Guarantee<[T]>.pending()
        let pipe = setupReadingPipe(parsingCompletion: pending.resolve, on: notificationQueue)
        
        task.standardOutput = pipe
        task.launch()
        
        return pending.guarantee
    }
    
    private func setupReadingPipe<T: ShellParsingModel>(parsingCompletion resolve: @escaping ([T]) -> Void, on queue: OperationQueue?) -> Pipe {
        var unparsedLine: String = ""
        var processOutputs = [T]()
        
        let pipe = Pipe()
        let handle = pipe.fileHandleForReading
        let center = NotificationCenter.default
        
        handle.waitForDataInBackgroundAndNotify()
        
        notificationObserver = center.addObserver(forName: .NSFileHandleDataAvailable,
                                                  object: handle,
                                                  queue: queue,
                                                  using: { _ in
            let data = handle.availableData
            
            guard !data.isEmpty else {
                DispatchQueue.main.async {
                    center.removeObserver(self.notificationObserver!)
                    resolve(processOutputs)
                }
                return
            }
            
            guard let output = String(data: data, encoding: .utf8) else { return }
            
            var lines = unparsedLine.appending(output).components(separatedBy: self.eol.rawValue)
            
            if !output.hasSuffix(self.eol.rawValue), let lastLine = lines.popLast() {
                unparsedLine = lastLine
            } else {
                unparsedLine = ""
            }

            processOutputs.append(contentsOf: lines.compactMap(T.init))
            
            DispatchQueue.main.async {
                handle.waitForDataInBackgroundAndNotify()
            }
        })
        
        return pipe
    }
}
