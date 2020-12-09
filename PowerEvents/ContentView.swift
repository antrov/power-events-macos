//
//  ContentView.swift
//  PowerEvents
//
//  Created by Hubert Andrzejewski on 18/10/2019.
//  Copyright © 2019 Hubert Andrzejewski. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var powerHistoryService: PowerHistoryService
    
    var body: some View {
        ZStack{
            List(powerHistoryService.events, id: \.timestamp) { event in
                PowerEventView(event: event)
            }
            
            if powerHistoryService.events.isEmpty {
                ProgressView()
            }
        }
        
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(powerHistoryService: .init())
    }
}
