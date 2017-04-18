//
//  BTDiscover.swift
//  LsMaker
//
//  Created by Ramon Pans on 15/03/17.
//  Copyright © 2017 LaSalle. All rights reserved.
//

import Foundation
import CoreBluetooth

class BTDiscovery: NSObject, CBCentralManagerDelegate {
    
    fileprivate var centralManager: CBCentralManager?
    fileprivate var peripheralBLE: CBPeripheral?
    
    var devicesViewController: DevicesViewController!
    
    convenience init(devicesVC: DevicesViewController) {
        self.init()
        
        self.devicesViewController = devicesVC
    }
    
    
    override init() {
        super.init()
        
        let centralQueue = DispatchQueue(label: "bluetoothQueue", attributes: [])
        centralManager = CBCentralManager(delegate: self, queue: centralQueue)
    }
    
    func startScanning() {
        if let central = centralManager {
            central.scanForPeripherals(withServices: [uartServiceUUIDString], options: nil)
        }
    }
    
    var bleService: BTService? {
        didSet {
            if let service = self.bleService {
                service.startDiscoveringServices()
            }
        }
    }
    
    // MARK: - CBCentralManagerDelegate
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // Be sure to retain the peripheral or it will fail during connection.
        
        print("Peripheral found")
        
        // Validate peripheral information
        if ((peripheral.name == nil) || (peripheral.name == "")) {
            return
        }
        
        if !(devicesViewController.scannedDevices.contains(peripheral)) {
            devicesViewController.scannedDevices.append(peripheral)
            devicesViewController.reloadDataNeeded()
        }
    }
    
    func connect(peripheral: CBPeripheral) {
        
        
        if peripheral.state == CBPeripheralState.disconnected {
            // Retain the peripheral before trying to connect
            self.peripheralBLE = peripheral
            
            // Reset service
            self.bleService = nil
            
            // Connect to peripheral
            print("Try to connect")
            centralManager?.connect(peripheral, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        // Create new service class
        if (peripheral == self.peripheralBLE) {
            print("We connected to the service!!")
            self.bleService = BTService(initWithPeripheral: peripheral)
        }
        
        // Stop scanning for new devices
        central.stopScan()
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
        // See if it was our peripheral that disconnected
        if (peripheral == self.peripheralBLE) {
            self.bleService = nil
            self.peripheralBLE = nil
            GlobalState.connectedLsMakerService = nil
            devicesViewController.reloadDataNeeded()
        }
        
        // Start scanning for new devices
        self.startScanning()
    }
    
    // MARK: - Private
    
    func clearDevices() {
        self.bleService = nil
        self.peripheralBLE = nil
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch (central.state) {
        case .poweredOff:
            self.clearDevices()
            
        case .unauthorized:
            // Indicate to user that the iOS device does not support BLE.
            break
            
        case .unknown:
            // Wait for another event
            break
            
        case .poweredOn:
            self.startScanning()
            
        case .resetting:
            self.clearDevices()
            
        case .unsupported:
            break
        }
    }
    
}
