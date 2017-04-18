//
//  BluetoothMessageFormatter.swift
//  LsMaker
//
//  Created by Ramon Pans on 25/03/17.
//  Copyright © 2017 LaSalle. All rights reserved.
//

import Foundation

class BluetoothMessageFormatter {
    
    static let TCP_PROTOCOL_MASK: UInt8 = 0b1000000
    static let ACK_MASK: UInt8 = 0b01000000
    static let SYS_USR_MASK: UInt8 = 0b00000001
    
    static let MOVEMENT_OPCODE: UInt8 = 0x00
    
    
    static func generateMovementFrame(speed: Int, acceleration: Int, rotation: Int) -> [UInt8] {
        
        var byteBuffer = [UInt8]()
        
        let speedFinal = correctData(value: speed, maxValue: 100, minValue: -100)
        let accelerationFinal = correctData(value: acceleration, maxValue: 100, minValue: -100)
        let rotationFinal = correctData(value: rotation, maxValue: 100, minValue: -100)
        
        
        byteBuffer.append(generateHeader(reqAck: false, ack: false, sysUsr: false))
        byteBuffer.append(MOVEMENT_OPCODE)
        
        // 3 bytes del payload
        byteBuffer.append(UInt8(truncatingBitPattern: speedFinal))
        byteBuffer.append(UInt8(truncatingBitPattern: accelerationFinal))
        byteBuffer.append(UInt8(truncatingBitPattern: rotationFinal))
        
        return byteBuffer
    }
    
    static func correctData(value: Int, maxValue: Int, minValue: Int) -> Int {
        
        var returnValue = value
        if value > maxValue {
            returnValue = maxValue
        }
        else if value < minValue {
            returnValue = minValue
        }
        
        return returnValue
    }
    
    static func generateHeader(reqAck: Bool, ack: Bool, sysUsr: Bool) -> UInt8 {
    
        var header: UInt8 = 0x00
        
        if reqAck {
            header = header | TCP_PROTOCOL_MASK
        }
        if ack {
            header = header | ACK_MASK
        }
        if sysUsr {
            header = header | SYS_USR_MASK
        }
    
        return header
    }
}
