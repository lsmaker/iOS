//
//  BTService.swift
//  LsMaker
//
//  Created by Ramon Pans on 15/03/17.
//  Copyright © 2017 LaSalle. All rights reserved.
//

import Foundation
import CoreBluetooth

/* Services & Characteristics UUIDs */
let uartServiceUUIDString = CBUUID(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")
let uartTXCharacteristicUUIDString = CBUUID(string: "6E400003-B5A3-F393-E0A9-E50E24DCCA9E")
let uartRXCharacteristicUUIDString = CBUUID(string: "6E400002-B5A3-F393-E0A9-E50E24DCCA9E")

let BLEServiceChangedStatusNotification = "kBLEServiceChangedStatusNotification"

class BTService: NSObject, CBPeripheralDelegate {
    
    var peripheral: CBPeripheral?
    var recieverCharacteristic: CBCharacteristic?
    var transmitterCharacteristic: CBCharacteristic?
    var positionCharacteristic: CBCharacteristic?
    
    init(initWithPeripheral peripheral: CBPeripheral) {
        super.init()
        
        self.peripheral = peripheral
        self.peripheral?.delegate = self
    }
    
    deinit {
        self.reset()
    }
    
    func startDiscoveringServices() {
        self.peripheral?.discoverServices([uartServiceUUIDString])
    }

    
    func reset() {
        if peripheral != nil {
            peripheral = nil
        }
        
        // Deallocating therefore send notification
        self.sendBTServiceNotificationWithIsBluetoothConnected(false)
    }
    
    // Mark: - CBPeripheralDelegate
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        let uuidsForBTService: [CBUUID] = [uartTXCharacteristicUUIDString, uartRXCharacteristicUUIDString]
        
        if (peripheral != self.peripheral) {
            // Wrong Peripheral
            return
        }
        
        if (error != nil) {
            return
        }
        
        if ((peripheral.services == nil) || (peripheral.services!.count == 0)) {
            // No Services
            return
        }
        
        for service in peripheral.services! {
            if service.uuid == uartServiceUUIDString {
                print("We found the UART service")
                peripheral.discoverCharacteristics(uuidsForBTService, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if (peripheral != self.peripheral) {
            // Wrong Peripheral
            return
        }
        
        if (error != nil) {
            return
        }
        
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                
                if characteristic.uuid == uartRXCharacteristicUUIDString {
                    
                    print("Found reciever characteristic")
                    self.recieverCharacteristic = (characteristic)
                    peripheral.setNotifyValue(true, for: characteristic)
                    
                } else if characteristic.uuid == uartTXCharacteristicUUIDString {
                    
                    print("Found transmitter characteristic")
                    self.transmitterCharacteristic = (characteristic)
                    peripheral.setNotifyValue(true, for: characteristic)
                }
                
                if self.recieverCharacteristic != nil && self.transmitterCharacteristic != nil {
                    
                    // Send notification that Bluetooth is connected and all required characteristics are discovered
                    print("Fully connected")
                    GlobalState.connectedLsMakerService = self
                    self.sendBTServiceNotificationWithIsBluetoothConnected(true)
                }
            }
        }
    }
    
    func writeMessage(message: [UInt8]) {
        
        if let rx = recieverCharacteristic {
            
            self.peripheral?.writeValue(Data(message), for: rx, type: .withoutResponse)
            //print(Data(message))
            //print(message.asData())
        }
    }
    
    func sendBTServiceNotificationWithIsBluetoothConnected(_ isBluetoothConnected: Bool) {
        
        var connectionDetails = ["isConnected": isBluetoothConnected]  as [String : Any]
        
        if isBluetoothConnected {
            connectionDetails["peripheral"] = self.peripheral!
        }
        NotificationCenter.default.post(name: Notification.Name(rawValue: BLEServiceChangedStatusNotification), object: self, userInfo: connectionDetails)
    }
    
}

extension Array {
    func asData() -> NSData {
        return self.withUnsafeBufferPointer({
            NSData(bytes: $0.baseAddress, length: count * MemoryLayout<Element>.stride)
        })
    }
}
