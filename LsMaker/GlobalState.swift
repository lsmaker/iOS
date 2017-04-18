//
//  GlobalState.swift
//  LsMaker
//
//  Created by Ramon Pans on 13/02/17.
//  Copyright © 2017 LaSalle. All rights reserved.
//

import Foundation
import CoreBluetooth

class GlobalState {
    
    static var invertedControls: Bool = false
    
    static var selectedDrivingState: drivingStates = .fullAccel
    
    enum drivingStates: Int {
        
        case semiAccel = 0
        case fullAccel = 1
    }
        
    static var connectedLsMakerService: BTService?
}
