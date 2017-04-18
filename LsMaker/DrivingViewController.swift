//
//  DrivingViewController.swift
//  LsMaker
//
//  Created by Ramon Pans on 25/03/17.
//  Copyright © 2017 LaSalle. All rights reserved.
//

import UIKit
import CoreMotion

class DrivingViewController: UIViewController {
    
    var motionManager = CMMotionManager()
    
    var currentTurn: Int = 0
    var currentSpeed: Int = 0
    
    var initialXGrav: Double?
    
    var speedSlider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if GlobalState.selectedDrivingState == .fullAccel {
            
            setupFullAccelerometerView()
        }
        else  if GlobalState.selectedDrivingState == .semiAccel {
            
            setupSemiAccelerometerView()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        stopDriving()
    }
    
    //MARK: UI for ".fullAccel" mode
    
    func setupFullAccelerometerView() {
        
        let drivingButton = UIButton(type: .system)
        drivingButton.translatesAutoresizingMaskIntoConstraints = false
        drivingButton.setImage(#imageLiteral(resourceName: "steering_wheel"), for: .normal)
        drivingButton.setTitleColor(UIColor.white, for: .normal)
        drivingButton.contentMode = .scaleAspectFit
        drivingButton.tintColor = UIColor.white
        drivingButton.addTarget(self, action: #selector(startDriving), for: .touchDown)
        drivingButton.addTarget(self, action: #selector(stopDriving), for: .touchUpInside)
        
        view.addSubview(drivingButton)
        
        drivingButton.heightAnchor.constraint(equalToConstant: 90).isActive = true
        drivingButton.widthAnchor.constraint(equalToConstant: 90).isActive = true
        drivingButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -60).isActive = true
        
        if GlobalState.invertedControls {
            drivingButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 60).isActive = true
        }
        else {
            drivingButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -60).isActive = true
        }
    }
    
    func setupSemiAccelerometerView() {
        
        speedSlider = UISlider()
        speedSlider.translatesAutoresizingMaskIntoConstraints = false
        speedSlider.maximumValue = 100
        speedSlider.minimumValue = 0
        speedSlider.value = 50
        speedSlider.addTarget(self, action: #selector(sliderValueChanged(sender:)), for: .valueChanged)

        
        let forwardButton = UIButton(type: .system)
        forwardButton.translatesAutoresizingMaskIntoConstraints = false
        forwardButton.setImage(#imageLiteral(resourceName: "upDoubleArrow"), for: .normal)
        forwardButton.setTitleColor(UIColor.white, for: .normal)
        forwardButton.contentMode = .scaleAspectFit
        forwardButton.tintColor = UIColor.white
        forwardButton.addTarget(self, action: #selector(startDrivingWithSpeed), for: .touchDown)
        forwardButton.addTarget(self, action: #selector(stopDriving), for: .touchUpInside)
        
        let backwardsButton = UIButton(type: .system)
        backwardsButton.translatesAutoresizingMaskIntoConstraints = false
        backwardsButton.setImage(#imageLiteral(resourceName: "downDoubleArrow"), for: .normal)
        backwardsButton.setTitleColor(UIColor.white, for: .normal)
        backwardsButton.contentMode = .scaleAspectFit
        backwardsButton.tintColor = UIColor.white
        backwardsButton.addTarget(self, action: #selector(startDrivingWithSpeedBack), for: .touchDown)
        backwardsButton.addTarget(self, action: #selector(stopDriving), for: .touchUpInside)
        
        let minLabel = UILabel()
        minLabel.translatesAutoresizingMaskIntoConstraints = false
        minLabel.text = "0"
        minLabel.textColor = UIColor.white
        
        let maxLabel = UILabel()
        maxLabel.translatesAutoresizingMaskIntoConstraints = false
        maxLabel.text = "100"
        maxLabel.textColor = UIColor.white
        
        
        view.addSubview(speedSlider)
        view.addSubview(forwardButton)
        view.addSubview(backwardsButton)
        view.addSubview(minLabel)
        view.addSubview(maxLabel)
        
        speedSlider.heightAnchor.constraint(equalToConstant: 20).isActive = true
        speedSlider.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30).isActive = true
        
        maxLabel.bottomAnchor.constraint(equalTo: speedSlider.topAnchor).isActive = true
        maxLabel.trailingAnchor.constraint(equalTo: speedSlider.trailingAnchor).isActive = true
        maxLabel.widthAnchor.constraint(equalToConstant: 30).isActive = true
        maxLabel.heightAnchor.constraint(equalToConstant: 21).isActive = true

        minLabel.bottomAnchor.constraint(equalTo: speedSlider.topAnchor).isActive = true
        minLabel.leadingAnchor.constraint(equalTo: speedSlider.leadingAnchor).isActive = true
        minLabel.widthAnchor.constraint(equalToConstant: 30).isActive = true
        minLabel.heightAnchor.constraint(equalToConstant: 21).isActive = true

        
        
        forwardButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        forwardButton.widthAnchor.constraint(equalToConstant: 50).isActive = true

        backwardsButton.topAnchor.constraint(equalTo: forwardButton.bottomAnchor, constant: 60).isActive = true
        backwardsButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -45).isActive = true
        backwardsButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        backwardsButton.leadingAnchor.constraint(equalTo: forwardButton.leadingAnchor).isActive = true
        backwardsButton.trailingAnchor.constraint(equalTo: forwardButton.trailingAnchor).isActive = true
        
        if GlobalState.invertedControls {
            
            speedSlider.leadingAnchor.constraint(equalTo: forwardButton.trailingAnchor, constant: 70).isActive = true
            speedSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -60).isActive = true
            forwardButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 60).isActive = true
        }
        else {
            
            speedSlider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 60).isActive = true
            speedSlider.trailingAnchor.constraint(equalTo: forwardButton.leadingAnchor, constant: -70).isActive = true
            forwardButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -60).isActive = true
        }
        
    }
    
    func sliderValueChanged(sender: UISlider) {
        
        //print("SliderValue: \(sender.value)")
    }
    
    func startDriving() {
        
        // Motion Logic
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.01
            motionManager.startDeviceMotionUpdates(to: .main) {
                [weak self] (data: CMDeviceMotion?, error: Error?) in
                if let gravity = data?.gravity {
                    if let initialX = self?.initialXGrav {
                        
                        // Speed calculations
                        var speed = Int((gravity.x - initialX) * 100)
                        
                        if speed > 100 {
                            speed = 100
                        }
                        if speed < -100 {
                            speed = -100
                        }
                        
                        // Rotation calculations
                        let rotationDegrees = (atan2(gravity.y, gravity.x) + M_PI) * 180.0 / M_PI
                        var finalDegree = 0.0
                        if rotationDegrees > 180.0 {
                            finalDegree = rotationDegrees - 360
                            if finalDegree < -45 {
                                finalDegree = -45
                            }
                        }
                        else {
                            finalDegree = rotationDegrees
                            if finalDegree > 45 {
                                finalDegree = 45
                            }
                            
                        }
                        let rotation = Int((finalDegree * 100) / 45)
                        
                        let message = BluetoothMessageFormatter.generateMovementFrame(speed: speed, acceleration: 0, rotation: -rotation)
                        GlobalState.connectedLsMakerService?.writeMessage(message: message)
                    }
                    else {
                        self?.initialXGrav = gravity.x
                    }
                }
            }
        }
    }
    
    func startDrivingWithSpeed() {
        
        let speed = Int(speedSlider.value)
        // Motion Logic
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.01
            motionManager.startDeviceMotionUpdates(to: .main) { (data: CMDeviceMotion?, error: Error?) in
                
                if let gravity = data?.gravity {
                        
                    // Rotation calculations
                    let rotationDegrees = (atan2(gravity.y, gravity.x) + M_PI) * 180.0 / M_PI
                    var finalDegree = 0.0
                    if rotationDegrees > 180.0 {
                        finalDegree = rotationDegrees - 360
                        if finalDegree < -45 {
                            finalDegree = -45
                        }
                    }
                    else {
                        finalDegree = rotationDegrees
                        if finalDegree > 45 {
                            finalDegree = 45
                        }
                        
                    }
                    let rotation = Int((finalDegree * 100) / 45)
                    
                    let message = BluetoothMessageFormatter.generateMovementFrame(speed: speed, acceleration: 0, rotation: -rotation)
                    GlobalState.connectedLsMakerService?.writeMessage(message: message)
                }
            }
        }
    }
    
    func startDrivingWithSpeedBack() {
        
        let speed = -Int(speedSlider.value)
        // Motion Logic
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.01
            motionManager.startDeviceMotionUpdates(to: .main) { (data: CMDeviceMotion?, error: Error?) in
                
                if let gravity = data?.gravity {
                    
                    // Rotation calculations
                    let rotationDegrees = (atan2(gravity.y, gravity.x) + M_PI) * 180.0 / M_PI
                    print("Degrees: \(rotationDegrees)")
                    var finalDegree = 0.0
                    if rotationDegrees > 180.0 {
                        finalDegree = rotationDegrees - 360
                        if finalDegree < -45 {
                            finalDegree = -45
                        }
                    }
                    else {
                        finalDegree = rotationDegrees
                        if finalDegree > 45 {
                            finalDegree = 45
                        }
                        
                    }
                    let rotation = Int((finalDegree * 100) / 45)
                    
                    // Rotation and speed ready to be sent!
                    print("Rotation: \(rotation)\t Speed: \(speed)")
                    
                    print("How about this? \(-rotation)")
                    
                    let message = BluetoothMessageFormatter.generateMovementFrame(speed: speed, acceleration: 0, rotation: -rotation)
                    GlobalState.connectedLsMakerService?.writeMessage(message: message)
                }
            }
        }
    }
    
    func stopDriving() {
        
        initialXGrav = nil
        motionManager.stopDeviceMotionUpdates()
    }
    
    @IBAction func drawerButtonPressed(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.centerContainer.toggle(.left, animated: true, completion: nil)
    }
    
}
