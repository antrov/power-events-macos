//
//  ViewController.swift
//  Shekely
//
//  Created by Hubert Andrzejewski on 03/10/2019.
//  Copyright © 2019 Hubert Andrzejewski. All rights reserved.
//

import Cocoa
import PromiseKit

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        Shell().execute("ls -al")
        let pmset: Guarantee<[PMSetParsingModel]> = Shell().execute("pmset -g log|grep -e \" Sleep  \" -e \" Wake  \"")
        
        pmset.done { (out) in
            out.forEach { (model) in
                print("\(model.timestamp) - \(model.powerState) -\t\(model.reason)")
            }
        }

        
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

