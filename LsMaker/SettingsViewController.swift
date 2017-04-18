//
//  ViewController.swift
//  LsMaker
//
//  Created by Ramon Pans on 06/02/17.
//  Copyright © 2017 LaSalle. All rights reserved.
//

import UIKit
import MMDrawerController

class SettingsViewController: UIViewController {
    

    @IBOutlet weak var drawerButton: MMDrawerBarButtonItem!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var makerName: UILabel!
    @IBOutlet weak var makerAddress: UILabel!
    
    @IBOutlet weak var bluetoothButton: UIButton!
    
    @IBOutlet weak var invertedControlSwitch: UISwitch!
    @IBOutlet weak var drivingModeTextField: UITextField!
    
    var picker: UIPickerView!
    let pickerOptions = ["SEMI_ACCELEROMETER", "FULL_ACCELEROMETER"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(red:0.42, green:0.68, blue:0.89, alpha:1.0)]
        drawerButton.tintColor = UIColor(red:0.42, green:0.68, blue:0.89, alpha:1.0)
        
        if let maker = GlobalState.connectedLsMakerService {
            
            makerName.text = maker.peripheral!.name ?? "No name"
            makerAddress.text = maker.peripheral!.identifier.uuidString
        }
        else {
            makerName.text = ""
            makerAddress.text = ""
        }
        
        if GlobalState.invertedControls {
            
            invertedControlSwitch.setOn(true, animated: true)
        }
        
        setUpDrivingTextField()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func drawerButtonPressed(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.centerContainer.toggle(.left, animated: true, completion: nil)
    }

    @IBAction func bluetoothButtonPressed() {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let centerViewController = appDelegate.mainStoryboard.instantiateViewController(withIdentifier: "DevicesViewController") as! DevicesViewController
        
        appDelegate.centerContainer.setCenterView(UINavigationController(rootViewController: centerViewController), withCloseAnimation: true, completion: nil)
    }
    
    @IBAction func invertedControlSwitchValueChanged(_ sender: Any) {
        
        if invertedControlSwitch.isOn {
            
            GlobalState.invertedControls = true
        } else {
            GlobalState.invertedControls = false
        }
    }
}


//Tota la gestio per el UIPickerView esta aqui
extension SettingsViewController: UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    
    func setUpDrivingTextField() {
        
        picker = UIPickerView(frame: CGRect(x: 0, y: 200, width: view.frame.width, height: 200))
        picker.backgroundColor = .white
        
        picker.showsSelectionIndicator = true
        picker.delegate = self
        picker.dataSource = self
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        drivingModeTextField.inputView = picker
        drivingModeTextField.inputAccessoryView = toolBar
        
        drivingModeTextField.text = pickerOptions[GlobalState.selectedDrivingState.rawValue]
    }
    
    func donePicker() {
        
        drivingModeTextField.text = pickerOptions[picker.selectedRow(inComponent: 0)]
        GlobalState.selectedDrivingState = GlobalState.drivingStates(rawValue: picker.selectedRow(inComponent: 0))!
        drivingModeTextField.resignFirstResponder()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return pickerOptions[row]
    }
}

