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
import SystemConfiguration.CaptiveNetwork

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
    var isBluFiFinish = false
    
    @IBOutlet weak var setupWifi: UIButton!
    @IBOutlet weak var ssidTxt: UITextField!
    @IBOutlet weak var passTxt: UITextField!
    @IBOutlet weak var writeDataBtn: UIButton!
    @IBOutlet weak var lblIp: UILabel!
    @IBOutlet weak var lblModel: UILabel!
    @IBOutlet weak var lblHwID: UILabel!
    @IBOutlet weak var accessIdTxt: UITextField!
    @IBOutlet weak var accessKeyTxt: UITextField!
    @IBOutlet weak var writeNullBtn: UIButton!
    
    func scanAndConnect() {
        let state: BluetoothState = manager.state
        
        _ = manager.observeState()
            .startWith(state)
            .filter { $0 == .poweredOn }
            .flatMap { _ in self.manager.scanForPeripherals(withServices: [self.bluFiServiceUUID]) }
            .take(1)
            .flatMap { d in
                d.peripheral.establishConnection()
            }
            .flatMap { $0.discoverServices([self.bluFiServiceUUID]) }.asObservable()
            .flatMap { Observable.from($0) }
            .flatMap { $0.discoverCharacteristics([self.bluFiDataInCharsUUID, self.bluFiDataOutCharsUUID])}.asObservable()
            .flatMap { Observable.from($0) }
            .subscribe(onNext: { characteristic in
                if characteristic.uuid == self.bluFiDataInCharsUUID {
                    self.dataInCharacteristics = characteristic
                    _ = characteristic
                        .observeValueUpdateAndSetNotification()
                        .subscribe(onNext: {
                            let data = $0.value
                            self.bluFi?.readFromBluetooth(data!)
                        })
                    self.isBluFiFinish = ((self.bluFi?.negotiate()) != nil)
                    self.writeDataBtn.isEnabled = self.isBluFiFinish
                    self.writeNullBtn.isEnabled = self.isBluFiFinish
                }
                if characteristic.uuid == self.bluFiDataOutCharsUUID {
                    self.dataOutCharacteristics = characteristic
                }
            })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bluFi = BluFiMangager(writeToBluetooth: { (data) in
            //write data to Bluetooth
            _ = self.dataOutCharacteristics?
                .writeValue(data, type: .withResponse)
                .subscribe(onSuccess: { characteristic in
                    print("write done")
                }, onError: { error in
                    print("write error \(error)")
                })
        })
        writeDataBtn.isEnabled = false
        writeNullBtn.isEnabled = false
        scanAndConnect()
        ssidTxt.text = self.getWiFiSsid()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getWiFiSsid() -> String? {
        guard let interfaces = CNCopySupportedInterfaces() as? [String] else { return nil }
        let key = kCNNetworkInfoKeySSID as String
        for interface in interfaces {
            guard let interfaceInfo = CNCopyCurrentNetworkInfo(interface as CFString) as NSDictionary? else { continue }
            return interfaceInfo[key] as? String
        }
        return nil
    }
    
    func convertToDictionary(_ text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    @IBAction func writeCustomData(_ sender: Any) {
        let password = passTxt.text ?? ""
        let ssid = ssidTxt.text ?? ""
        let accessId = accessIdTxt.text ?? ""
        let accessKey = accessKeyTxt.text ?? ""
        lblIp.text = ""
        let wifiData = "{\"ssid\":\"" + ssid + "\", \"password\": \"" + password + "\", \"access_id\":\"" + accessId + "\", \"access_key\":\"" + accessKey + "\"}"
        _ = self.bluFi?.writeCustomData([UInt8](wifiData.utf8), true).done({ (data) in
            
            let jsonString = String(bytes: data, encoding: .utf8)
            let json = self.convertToDictionary(jsonString ?? "")
            
            self.lblIp.text = json?["ip"] as? String
            print("receive data \(data), json: \(String(describing: json))")
        })
    }
    
    @IBAction func writeCustomNullData(_ sender: Any) {
        _ = self.bluFi?.writeCustomData([UInt8]([0]), true).done({ (data) in
            
            let jsonString = String(bytes: data, encoding: .utf8)
            let json = self.convertToDictionary(jsonString ?? "")
            
            self.lblIp.text = json?["ip"] as? String
            self.lblModel.text = json?["model"] as? String
            self.lblHwID.text = json?["hw_id"] as? String
            print("receive data \(data), json: \(String(describing: json))")
        })
    }
    
    @IBAction func ScanAndConnect(_ sender: Any) {
        scanAndConnect()
    }
}

