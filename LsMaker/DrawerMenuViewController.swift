//
//  DrawerMenuViewController.swift
//  LsMaker
//
//  Created by Ramon Pans on 06/02/17.
//  Copyright © 2017 LaSalle. All rights reserved.
//

import UIKit
import MMDrawerController

class DrawerMenuViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.tableFooterView = UIView()
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(red:0.42, green:0.68, blue:0.89, alpha:1.0)]
        
        // Since this view controller is never reInstanciated, it's a good idea to have it manage the alerts
        NotificationCenter.default.addObserver(self, selector: #selector(self.connectionChanged(_:)), name: NSNotification.Name(rawValue: BLEServiceChangedStatusNotification), object: nil)
    }
    
    func connectionChanged(_ notification: Notification) {
        
        let userInfo = (notification as NSNotification).userInfo as! [String: Any]
        
        DispatchQueue.main.async(execute: {
            
            if let isConnected: Bool = userInfo["isConnected"] as? Bool {
                if isConnected {
                    
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    
                    let alert = UIAlertController(title: "Connexió", message: "El dispositiu s'ha connectat correctament", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Conduir", style: .default, handler: { (action) in
                        
                        let centerViewController = appDelegate.mainStoryboard.instantiateViewController(withIdentifier: "DrivingViewController") as! DrivingViewController
                        
                        appDelegate.centerContainer.setCenterView(UINavigationController(rootViewController: centerViewController), withCloseAnimation: true, completion: nil)
                    }))
                    alert.addAction(UIAlertAction(title: "Acceptar", style: .cancel, handler: nil))
                    
                    self.present(alert, animated: true, completion: nil)
                    
                } else {
                    print("Disconnected")
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    
                    let alert = UIAlertController(title: "Desconnexió", message: "El dispositiu s'ha desconnectat", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Connectar", style: UIAlertActionStyle.default, handler:  { (action) in
                        
                        let centerViewController = appDelegate.mainStoryboard.instantiateViewController(withIdentifier: "DevicesViewController") as! DevicesViewController
                        
                        appDelegate.centerContainer.setCenterView(UINavigationController(rootViewController: centerViewController), withCloseAnimation: true, completion: nil)
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                }
            }
        });
    }
    
}

extension DrawerMenuViewController: UITableViewDataSource, UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            //Modes de l'aplicacio
            return 1
        case 1:
            //Configuracio
            return 1
        default:
            
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "basicCell")!
        
        switch indexPath.section {
        case 0:
            
            cell.textLabel?.text = "Mode Conducció"
        case 1:
            
            cell.textLabel?.text = "Configuracio"
            cell.imageView?.image = nil
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
            
            return "Modes"
        case 1:
            
            return "Configuració"
        default:
            
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.section {
        case 0:
            
            switch indexPath.row {
            case 0:
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                if GlobalState.connectedLsMakerService != nil {

                    if GlobalState.selectedDrivingState == .fullAccel {
                        let centerViewController = appDelegate.mainStoryboard.instantiateViewController(withIdentifier: "DrivingViewController") as! DrivingViewController
                    
                        appDelegate.centerContainer.setCenterView(UINavigationController(rootViewController: centerViewController), withCloseAnimation: true, completion: nil)
                    }
                    else if GlobalState.selectedDrivingState == .semiAccel {
                        
                        let centerViewController = appDelegate.mainStoryboard.instantiateViewController(withIdentifier: "DrivingViewController") as! DrivingViewController
                        
                        appDelegate.centerContainer.setCenterView(UINavigationController(rootViewController: centerViewController), withCloseAnimation: true, completion: nil)
                    }
                }
                else {
                    
                    let alert = UIAlertController(title: "LsMaker", message: "No estas connectat a cap LsMaker", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Connectar", style: .default, handler: { (action) in
                        
                        let centerViewController = appDelegate.mainStoryboard.instantiateViewController(withIdentifier: "DevicesViewController") as! DevicesViewController
                        
                        appDelegate.centerContainer.setCenterView(UINavigationController(rootViewController: centerViewController), withCloseAnimation: true, completion: nil)
                    }))
                    alert.addAction(UIAlertAction(title: "Cancel·lar", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } 
                
                tableView.deselectRow(at: indexPath, animated: true)
                break
            default: break
            }
        case 1:
            switch indexPath.row {
            case 0:
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let centerViewController = appDelegate.mainStoryboard.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
                
                appDelegate.centerContainer.setCenterView(UINavigationController(rootViewController: centerViewController), withCloseAnimation: true, completion: nil)
                
                tableView.deselectRow(at: indexPath, animated: true)
                break
            default: break
            }
        default: break
            
        }
    }
}
