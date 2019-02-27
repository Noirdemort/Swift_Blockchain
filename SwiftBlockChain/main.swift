//
//  main.swift
//  SwiftBlockChain
//
//  Created by Noirdemort on 14/02/19.
//  Copyright © 2019 Noirdemort. All rights reserved.
//

import Foundation
import CommonCrypto


extension String {
    
    func sha512() -> String {
        let data = self.data(using: .utf8)!
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA512_DIGEST_LENGTH))
        data.withUnsafeBytes({
            _ = CC_SHA512($0, CC_LONG(data.count), &digest)
        })
        return digest.map({ String(format: "%02hhx", $0) }).joined(separator: "")
    }
}

struct Block{
    
    let previousHash: String
    let data : String
    let timeStamp: String
    let nonce: Double
    let hash: String
    
    init(previousHash: String, data: String, nonce: Double) {
        self.previousHash = previousHash
        self.data = data
        let now = Date()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let timestamp = formatter.string(from: now)
        self.timeStamp = timestamp
        self.nonce = nonce
        self.hash = "\(previousHash)\(data)\(timeStamp)\(nonce)".sha512()
    }
    
}


class BlockChain{
    
    private var blocks: [Block] = []
    private let validPrefix = "111"
    
    
    init(data: String, seed: Double){
        let block = mine(block: Block(previousHash: "0", data: data, nonce: seed))
        blocks.append(block)
    }
    
//    func add(block: Block)->Block{
//        let minedBlock : Block
//        if isMined(block: block) {
//            minedBlock = block
//        } else {
//            minedBlock = mine(block: block)
//        }
//        blocks.append(minedBlock)
//        return minedBlock
//    }
    
    func createNewBlock(data: String, seed: Double)->Block{
        let block = mine(block: Block(previousHash: blocks.last!.hash, data: data, nonce: seed))
        blocks.append(block)
        return block
    }
    
    private func mine(block: Block)->Block{
        
        print("Mining: \(block)")
        
        var minedBlock = block
        while (!isMined(block: minedBlock)) {
            minedBlock = Block(previousHash: minedBlock.previousHash, data: minedBlock.data, nonce: minedBlock.nonce + 1)
        }
        
        print("Mined : \(minedBlock)")
        
        return minedBlock
    }
    
    private func isMined(block: Block)->Bool{
        return block.hash.starts(with: validPrefix)
    }
    
    
    func isValid()->Bool{
        switch blocks.count {
        case 0:
            return true
        case 1:
            return (blocks[0].hash == calculateHash(block: blocks[0]))
        default:
            for i in 1 ... blocks.count-1 {
                let previousBlock = blocks[i-1]
                let currentBlock = blocks[i]
                
                // data tempering
                if currentBlock.hash != calculateHash(block: currentBlock){
                    print(0)
                    return false
                }
                
                // blockchain tempering
                if currentBlock.previousHash != calculateHash(block: previousBlock) {
                    print(1)
                    return false
                }
                
                // unauthorized insertion --- chain poisoning
                if !(isMined(block: previousBlock) && isMined(block: currentBlock)) {
                    print(2)
                    return false
                }
            }
            return true
        }
    }
    
    private func calculateHash(block: Block)->String{
        return "\(block.previousHash)\(block.data)\(block.timeStamp)\(block.nonce)".sha512()
    }
    
}



let chain = BlockChain(data: "genesis block", seed: 0)
let secondBlock = chain.createNewBlock(data: "second block", seed: 23)
let thirdBlock = chain.createNewBlock(data: "third block", seed: 212)

print(secondBlock)
print(thirdBlock)
print(chain.isValid())

