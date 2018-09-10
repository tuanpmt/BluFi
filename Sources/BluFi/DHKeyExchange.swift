//
//  DHKeyExchange.swift
//  BluFiExample
//
//  Created by Tuan PM on 9/10/18.
//  Copyright © 2018 Tuan PM. All rights reserved.
//


import Foundation
import BigInt

class DHKeyExchange: NSObject {
    static public var RADIX = 16
    private static func genDHKey(base: String, power: String, modulus : String) -> BigInt {
        let g = BigInt(base, radix: RADIX)
        let privateKey = BigInt(power, radix: RADIX)
        let p = BigInt(modulus, radix: RADIX)
        
        // pow mod formula to get key
        let key = g!.power(privateKey!, modulus: p!)
        return key
    }
    
    private static func genPrivatedDHRandomKey() -> String {
        var privateDHKey = ""
        for _ in 1...30 {
            privateDHKey += String(Int(arc4random_uniform(UInt32(42949672)) + UInt32(10)), radix: RADIX)
            
        }
        return privateDHKey
    }
    
    static func genDHExchangeKeys(generator: String, primeNumber : String) -> DHKey {
        let privateDHKey = genPrivatedDHRandomKey()
        let publicKey = String(genDHKey(base: generator, power: privateDHKey, modulus: primeNumber), radix: RADIX)
        let dhKeys = DHKey(privateKey: privateDHKey, publicKey: publicKey)
        return dhKeys
    }
    
    static func genDHCryptoKey(privateDHKey: String, serverPublicDHKey: String, primeNumber : String) -> String {
        let cryptoKey = String(genDHKey(base: serverPublicDHKey, power: privateDHKey, modulus: primeNumber), radix: RADIX)
        return cryptoKey
    }
    
    
}

struct DHKey {
    
    var privateKey: String?
    var publicKey: String?

    func asArray(_ data: String?) -> [UInt8] {
        var ret = [UInt8](data!.utf8)
        while ret.count < 256 {
            ret.append(0x00)
        }
        return ret
    }
    func publicKeyAsArray() -> [UInt8] {
        return DHKey.hexStringToBytes(publicKey!)
    }
    
    func privateKeyAsArray() -> [UInt8] {
        return asArray(privateKey)
    }
    
    init(privateKey: String, publicKey: String) {
        
        self.privateKey = privateKey
        self.publicKey = publicKey
        
    }
    static func hexStringToBytes(_ s: String) -> [UInt8] {
        var length = s.count
        var string = s
        if length == 0 {
            return []
        }
        if length & 1 != 0 {
            length += 1
            string = "0" + string
        }
        var bytes = [UInt8]()
        bytes.reserveCapacity(length/2)
        var index = string.startIndex
        for _ in 0..<length/2 {
            let nextIndex = string.index(index, offsetBy: 2)
            if let b = UInt8(string[index..<nextIndex], radix: 16) {
                bytes.append(b)
            } else {
                return []
            }
            index = nextIndex
        }
        return bytes
    }
}
