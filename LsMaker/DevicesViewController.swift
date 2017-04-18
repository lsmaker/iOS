//
//  DevicesViewController.swift
//  LsMaker
//
//  Created by Ramon Pans on 13/02/17.
//  Copyright © 2017 LaSalle. All rights reserved.
//

import UIKit
import CoreBluetooth

class DevicesViewController: UIViewController {
    
    var scannedDevices: [CBPeripheral] = []
    
    var btDiscover: BTDiscovery!

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Start the Bluetooth discovery process
        btDiscover = BTDiscovery(devicesVC: self)
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadDataNeeded), name: NSNotification.Name(rawValue: BLEServiceChangedStatusNotification), object: nil)
    }
    
    func reloadDataNeeded() {
        // Retrieve main queue after bluetoothQueue discovers a peripheral
        DispatchQueue.main.async(execute: {
            
            self.tableView.reloadData()
        });
    }
    
    @IBAction func drawerButtonPressed(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.centerContainer.toggle(.left, animated: true, completion: nil)
    }
}

extension DevicesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            
            if GlobalState.connectedLsMakerService != nil {
                return 1
            }
            else {
                return 0
            }
        case 1:
            
            return scannedDevices.count
        default:
            
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "basicCell")!
        
        switch indexPath.section {
        case 0:
            
            cell.textLabel?.text = GlobalState.connectedLsMakerService?.peripheral?.name ?? "No name"
        case 1:
            
            cell.textLabel?.text = scannedDevices[indexPath.row].name ?? "No name"
        default: break
        }
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch section {
        case 0:
            
            return "Dispositiu actual"
        case 1:
            
            return "Altres dispositius"
        default:
            
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 1 {

            btDiscover.connect(peripheral: self.scannedDevices[indexPath.row])
        }
        else {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}
