//
//  PowerEventView.swift
//  PowerEvents
//
//  Created by Hubert Andrzejewski on 08/12/2020.
//  Copyright © 2020 Hubert Andrzejewski. All rights reserved.
//

import SwiftUI

struct PowerEventView: View {
    
    static let eventDateFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .long
        return formatter
    }()
    
    var event: PowerEventDescribing
    
    var body: some View {
        HStack(alignment: .center) {
            Text("\(event.timestamp, formatter: Self.eventDateFormat)")
                .frame(width: 200, height: nil, alignment: .leading)
                .padding(.trailing, 10)
            
            Toggle("isOn", isOn: .constant(event.isPowerOn))
            Toggle("isUserCaused", isOn: .constant(event.isUserCaused))
                .padding(.trailing, 20)
            
            switch event {
            case is PMSetParsingModel:
                Text((event as! PMSetParsingModel).reason.rawValue)
                    .frame(width: 150, height: nil, alignment: .leading)
            case is LastParsingModel:
                Text((event as! LastParsingModel).pseudoUser.rawValue)
                    .frame(width: 150, height: nil, alignment: .leading)
            default:
                EmptyView()
            }
        }
    }
}

struct PowerEventView_Previews: PreviewProvider {
    static var previews: some View {
        PowerEventView(event: PMSetParsingModel(timestamp: Date(),
                                                state: .wake,
                                                reason: .lidOpen))
    }
}
