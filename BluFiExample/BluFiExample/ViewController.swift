//
//  ViewController.swift
//  BluFiExample
//
//  Created by Tuan PM on 9/10/18.
//  Copyright © 2018 Tuan PM. All rights reserved.
//

import UIKit
import BluFi
import CoreBluetooth
import RxBluetoothKit
import RxSwift


class ViewController: UIViewController {
    var bluFi: BluFiMangager?
    let manager = CentralManager(queue: .main)
    private let bluFiServiceUUID = CBUUID(string: "0000ffff-0000-1000-8000-00805f9b34fb")
    private let bluFiDataOutCharsUUID = CBUUID(string: "0000ff01-0000-1000-8000-00805f9b34fb")
    private let bluFiDataInCharsUUID = CBUUID(string: "0000ff02-0000-1000-8000-00805f9b34fb")
    
    fileprivate      var activePeripheral: Peripheral!
    fileprivate      var activeService: Service!
    fileprivate      var dataOutCharacteristics: Characteristic?
    fileprivate      var dataInCharacteristics: Characteristic?
    
    @IBOutlet weak var setupWifi: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bluFi = BluFiMangager(writeToBluetooth: { (data) in
            //write data to Bluetooth
            self.dataOutCharacteristics?
                .writeValue(data, type: .withResponse)
                .subscribe(onSuccess: { characteristic in
                    print("write done")
                }, onError: { error in
                    print("write error")
                })
        })
        
        let state: BluetoothState = manager.state
        
        manager.observeState()
            .startWith(state)
            .filter { $0 == .poweredOn }
            .flatMap { _ in self.manager.scanForPeripherals(withServices: [self.bluFiServiceUUID]) }
            .take(1)
            .flatMap { $0.peripheral.establishConnection() }
            .flatMap { $0.discoverServices([self.bluFiServiceUUID]) }.asObservable()
            .flatMap { Observable.from($0) }
            .flatMap { $0.discoverCharacteristics([self.bluFiDataInCharsUUID, self.bluFiDataOutCharsUUID])}.asObservable()
            .flatMap { Observable.from($0) }
            .subscribe(onNext: { characteristic in
                if characteristic.uuid == self.bluFiDataInCharsUUID {
                    self.dataInCharacteristics = characteristic
                    characteristic
                        .observeValueUpdateAndSetNotification()
                        .subscribe(onNext: {
                            let data = $0.value
                            self.bluFi?.readFromBluetooth(data!)
                        })
                    self.bluFi?.negotiate()
                }
                if characteristic.uuid == self.bluFiDataOutCharsUUID {
                    self.dataOutCharacteristics = characteristic
                }
                print("Discovered characteristic: \(characteristic)")
            })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func setupWiFiTouchUp(_ sender: Any) {
        self.bluFi?.setWiFiSta("WiFiSSID", "wifiPassword")
    }
    @IBAction func writeCustomData(_ sender: Any) {
        self.bluFi?.writeCustomData([1, 2, 3], false)
    }
    
}


