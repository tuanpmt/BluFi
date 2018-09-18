//
//  BlufiParameter.swift
//  BluFi
//
//  Created by Tuan PM on 9/1/18.
//  Copyright © 2018 Tuan PM. All rights reserved.
//

import Foundation

public struct WiFiEntry {
    public var ssid: String
    public var rssi: Int8
    
    public init(_ ssid: String, _ rssi: Int8) {
        self.ssid = ssid
        self.rssi = rssi
    }
}

class OP_MODE {
    public static let NULL = 0x00
    public static let STA = 0x01
    public static let SOFTAP = 0x02
    public static let STASOFTAP = 0x03
}

class SOFTAP_SECURITY {
    public static let OPEN = 0x00
    public static let WEP = 0x01
    public static let WPA = 0x02
    public static let WPA2 = 0x03
    public static let WPA_WPA2 = 0x04
}

class NEG_SET_SEC {
    public static let TOTAL_LEN = 0x00
    public static let ALL_DATA = 0x01
}
class FRAME_CTRL {
    public static let POSITION_ENCRYPTED = 0
    public static let POSITION_CHECKSUM = 1
    public static let POSITION_DATA_DIRECTION = 2
    public static let POSITION_REQUIRE_ACK = 3
    public static let POSITION_FRAG = 4
}

class Type {
    public enum Ctrl {
        public static let PACKAGE_VALUE = 0x00
        
        public static let SUBTYPE_ACK = 0x00
        public static let SUBTYPE_SET_SEC_MODE = 0x01
        public static let SUBTYPE_SET_OP_MODE = 0x02
        public static let SUBTYPE_CONNECT_WIFI = 0x03
        public static let SUBTYPE_DISCONNECT_WIFI = 0x04
        public static let SUBTYPE_GET_WIFI_STATUS = 0x05
        public static let SUBTYPE_DEAUTHENTICATE = 0x06
        public static let SUBTYPE_GET_VERSION = 0x07
        public static let SUBTYPE_CLOSE_CONNECTION = 0x08
        public static let SUBTYPE_GET_WIFI_LIST = 0x09
    }
    
    public enum Data {
        public static let PACKAGE_VALUE = 0x01
        
        public static let SUBTYPE_NEG = 0x00
        public static let SUBTYPE_STA_WIFI_BSSID = 0x01
        public static let SUBTYPE_STA_WIFI_SSID = 0x02
        public static let SUBTYPE_STA_WIFI_PASSWORD = 0x03
        public static let SUBTYPE_SOFTAP_WIFI_SSID = 0x04
        public static let SUBTYPE_SOFTAP_WIFI_PASSWORD = 0x05
        public static let SUBTYPE_SOFTAP_MAX_CONNECTION_COUNT = 0x06
        public static let SUBTYPE_SOFTAP_AUTH_MODE = 0x07
        public static let SUBTYPE_SOFTAP_CHANNEL = 0x08
        public static let SUBTYPE_USERNAME = 0x09
        public static let SUBTYPE_CA_CERTIFICATION = 0x0a
        public static let SUBTYPE_CLIENT_CERTIFICATION = 0x0b
        public static let SUBTYPE_SERVER_CERTIFICATION = 0x0c
        public static let SUBTYPE_CLIENT_PRIVATE_KEY = 0x0d
        public static let SUBTYPE_SERVER_PRIVATE_KEY = 0x0e
        public static let SUBTYPE_WIFI_CONNECTION_STATE = 0x0f
        public static let SUBTYPE_VERSION = 0x10
        public static let SUBTYPE_WIFI_LIST = 0x11
        public static let SUBTYPE_ERROR = 0x12
        public static let SUBTYPE_CUSTOM_DATA = 0x13
    }
}
class BluFiParameter {
    public static let POSITION_ENCRYPTED: Int = 1
}

class FrameCtrlData {
    private var mValue: Int = 0
    
    public init(frameCtrlValue: Int) {
        mValue = frameCtrlValue
    }
    
    private func check(position: Int) -> Bool {
        return ((mValue >> position) & 1) == 1
    }
    
    public func isEncrypted() -> Bool {
        return check(position: FRAME_CTRL.POSITION_ENCRYPTED)
    }
    
    public func isChecksum() -> Bool {
        return check(position: FRAME_CTRL.POSITION_CHECKSUM)
    }
    
    public func requireAck() -> Bool {
        return check(position: FRAME_CTRL.POSITION_REQUIRE_ACK)
    }
    
    public func hasFrag() -> Bool {
        return check(position: FRAME_CTRL.POSITION_FRAG)
    }
    
}

class BlufiNotiData {
    private var mTypeValue: Int = 0
    private var mPkgType: Int = 0
    private var mSubType: Int = 0
    
    private var mFrameCtrlValue: Int = 0
    
    private var mSequence: Int = 0
    
    private var mDataList = [UInt8]()
    
    
    public func getType() -> Int {
        return mTypeValue
    }
    
    public func setType(typeValue: Int) -> Void {
        mTypeValue = typeValue
    }
    
    public func getPkgType() -> Int {
        return mPkgType
    }
    
    public func setPkgType(pkgType: Int) -> Void {
        mPkgType = pkgType
    }
    
    public func getSubType() -> Int {
        return mSubType
    }
    
    public func setSubType(subType: Int) -> Void {
        mSubType = subType
    }
    
    public func getFrameCtrl() -> Int {
        return mFrameCtrlValue
    }
    
    public func setFrameCtrl(frameCtrl: Int) -> Void{
        mFrameCtrlValue = frameCtrl
    }
    
    public func addData(b: UInt8) -> Void{
        mDataList.append(b)
    }
    
    public func addData(bytes: [UInt8]) -> Void {
        mDataList.append(contentsOf: bytes)
    }
    
    public func getDataArray() -> [UInt8]{
        return mDataList
    }
    
    public func getDataList() -> [UInt8] {
        return mDataList
    }
    
    public func clear() {
        mTypeValue = 0
        mPkgType = 0
        mSubType = 0
        mDataList.removeAll()
    }
}

class CRC {
    public static func crc16(_ data: [UInt8]) -> UInt16 {
        let crc = Update(crc: 0xFFFF, data: data, table: makeTable())
        return crc ^ 0xFFFF
    }
    
    static func Update(crc: UInt16, data: [UInt8], table: [UInt16]) -> UInt16 {
        var crcRet = crc
        for d in data {
            let idx = Int(UInt8(crcRet>>8)^UInt8(d))
            crcRet = crcRet<<8 ^ table[idx]
        }
        return crcRet
    }
    static func makeTable() -> [UInt16] {
        var table = [UInt16]()
        let poly: UInt16 = 0x1021
        for n in 0..<256 {
            var crc = UInt16(n) << 8
            for _ in 0..<8 {
                let bit = (crc & 0x8000) != 0
                crc <<= 1
                if bit {
                    crc ^= poly
                }
            }
            table.append(crc)
        }
        return table
    }
    
    public static func getCRC16(data_p: [UInt8]) -> [UInt8] {
        let crc = crc16(data_p)
        let b0 = UInt8(crc >> 8)
        let b1 = UInt8(crc & 0x00FF)
        return [b1, b0]
    }
    
}

