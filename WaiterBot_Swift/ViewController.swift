//
//  ViewController.swift
//  WaiterBot
//
//  Created by Nahum Tariku on 4/17/19.
//  Copyright © 2019 Nahum Tariku. All rights reserved.
//

import UIKit

import CoreBluetooth

import Foundation

extension Data {
    static func dataWithValue(value: Int8) -> Data {
        var variableValue = value
        return Data(buffer: UnsafeBufferPointer(start: &variableValue, count: 1))
    }
    
    func int8Value() -> Int8 {
        return Int8(bitPattern: self[0])
    }
}

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate, UIGestureRecognizerDelegate{
    
    @IBOutlet weak var motorUpDefault: UILongPressGestureRecognizer!
    
    @IBOutlet weak var motorDownDefault: UILongPressGestureRecognizer!
    
    @IBOutlet weak var motorRightDefault: UILongPressGestureRecognizer!
    
    @IBOutlet weak var motorLeftDefault: UILongPressGestureRecognizer!
    
    @IBOutlet weak var armUpDefault: UILongPressGestureRecognizer!
    
    @IBOutlet weak var armDownDefault: UILongPressGestureRecognizer!
    
    var manager: CBCentralManager!
    var dsdPeripheral: CBPeripheral!
    weak var writeCharacteristic: CBCharacteristic?
    let BEAN_NAME = "waiterBot"
    let BEAN_SCRATCH_UUID =
        CBUUID(string: "0xFFE1")
    let BEAN_SERVICE_UUID =
        CBUUID(string: "0xFFE0")
     private var writeType: CBCharacteristicWriteType = .withoutResponse
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        manager = CBCentralManager(delegate: self, queue: nil)
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        // check whether the characteristic we're looking for (0xFFE1) is present - just to be sure
        for characteristic in service.characteristics! {
            if characteristic.uuid == BEAN_SCRATCH_UUID {
                // subscribe to this value (so we'll get notified when there is serial data for us..)
                peripheral.setNotifyValue(true, for: characteristic)
                
                // keep a reference to this characteristic so we can write to it
                writeCharacteristic = characteristic
                
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        
        guard let services = peripheral.services else { return }
        
        for service in services {
            print(service)
            peripheral.discoverCharacteristics([BEAN_SCRATCH_UUID], for: service)
            

        }
        

    }
    
    func write(_ value: Int8) {
        guard let peripheral = dsdPeripheral, let characteristic = writeCharacteristic else {
            return
        }
        let data = Data.dataWithValue(value: value)
        peripheral.writeValue(data, for: characteristic, type: .withoutResponse)
    }
    

    
    func centralManagerDidUpdateState(_ central: CBCentralManager)
    {
       var consoleMsg = ""
        
        switch (central.state)
        {
        case.poweredOff:
            consoleMsg = "off"
        case.poweredOn:
            consoleMsg = "on"
            central.scanForPeripherals(withServices: [BEAN_SERVICE_UUID])
        case.unknown:
            consoleMsg = "unknown"
        case.unsupported:
            consoleMsg = "unsuported"
        case .resetting:
            consoleMsg = "resetting"
        case .unauthorized:
            consoleMsg = "unauthorized"
        }
        print("\(consoleMsg)")
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any], rssi RSSI: NSNumber) {
        print(peripheral)
        dsdPeripheral = peripheral
        dsdPeripheral.delegate = self
        manager.stopScan()
        manager.connect(dsdPeripheral)
    }
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        dsdPeripheral.discoverServices([BEAN_SERVICE_UUID])

    }
    
    @IBAction func motorLeft(_ sender: UILongPressGestureRecognizer) {
        if motorLeftDefault.state.rawValue != 2{
            write(0)
        }
        else
        {
            write(Int8(3))
        }
    }
    @IBAction func motorDown(_ sender: UILongPressGestureRecognizer) {
        if motorDownDefault.state.rawValue != 2{
            write(0)
        }
        else
        {
            write(Int8(2))
        }
        
    }
    
    @IBAction func motorUp(_ sender: UILongPressGestureRecognizer) {
        if motorUpDefault.state.rawValue != 2{
            write(0)
        }
        else
        {
          write(Int8(1))
        }
    }
    @IBAction func motorRight(_ sender: UILongPressGestureRecognizer) {
        if motorRightDefault.state.rawValue != 2{
            write(0)
        }
        else
        {
            write(Int8(4))
        }
        
    }
    
    @IBAction func armUp(_ sender: UILongPressGestureRecognizer) {
        if armUpDefault.state.rawValue != 2{
            write(0)
        }
        else
        {
            write(Int8(5))
        }
    }
    @IBAction func armDown(_ sender: UILongPressGestureRecognizer) {
        if armDownDefault.state.rawValue != 2{
            write(0)
        }
        else
        {
            write(Int8(6))
        }
    }
}

