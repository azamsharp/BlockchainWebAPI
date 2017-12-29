import Foundation
import Vapor

let DIFFICULTY = "000"

class Transaction :Codable {
    
    var from :String
    var to :String
    var amount :Double
    
    init(from :String, to :String, amount :Double) {
        self.from = from
        self.to = to
        self.amount = amount
    }
    
    init?(request :Request) {
        
        guard let from = request.data["from"]?.string,
              let to = request.data["to"]?.string,
              let amount = request.data["amount"]?.double
            else {
                return nil
        }
        
        self.from = from
        self.to = to
        self.amount = amount
    }
}

class Block : Codable {
    
    var index :Int = 0
    var dateCreated :String
    var previousHash :String!
    var hash :String!
    var nonce :Int
    var message :String = ""
    private (set) var transactions :[Transaction] = [Transaction]()
    
    var key :String {
        get {
            
            let transactionsData = try! JSONEncoder().encode(self.transactions)
            let transactionsJSONString = String(data: transactionsData, encoding: .utf8)
            
            return String(self.index) + self.dateCreated + self.previousHash + transactionsJSONString! + String(self.nonce)
        }
    }
    
    func addTransaction(transaction :Transaction) {
        self.transactions.append(transaction)
    }
    
    init() {
        self.dateCreated = Date().toString()
        self.nonce = 0
        self.message = "Mined a New Block"
    }
    
    init(transaction :Transaction) {
        
        self.dateCreated = Date().toString()
        self.nonce = 0
        self.addTransaction(transaction: transaction)
        
    }
    
}

class BlockchainNode :Codable {
    
    var address :String
    
    init(address :String) {
        self.address = address
    }
    
    init?(request :Request) {
        
        guard let address = request.data["address"]?.string else {
            return nil
        }
        
        self.address = address
    }
    
}

class Blockchain : Codable {
    
    var blocks :[Block] = [Block]()
    var nodes :[BlockchainNode] = [BlockchainNode]()
    
    private enum CodingKeys :String, CodingKey {
        case blocks
    }
    
    init() {
        
    }
    
    init(_ genesisBlock :Block) {
        
        self.addBlock(genesisBlock)
    }
    
    func addNode(_ blockchainNode :BlockchainNode) {
        self.nodes.append(blockchainNode)
    }
    
    func addBlock(_ block :Block) {
        
        if self.blocks.isEmpty {
            // add the genesis block
            // no previous has was found for the first block
            block.previousHash = "0"
            
        } else {
            let previousBlock = getPreviousBlock()
            block.previousHash = previousBlock.hash
            block.index = self.blocks.count
        }
        
        block.hash = generateHash(for: block)
        self.blocks.append(block)
        block.message = "Block added to the Blockchain"
    }
    
    private func getPreviousBlock() -> Block {
        return self.blocks[self.blocks.count - 1]
    }
    
    private func displayBlock(_ block :Block) {
        print("------ Block \(block.index) ---------")
        print("Date Created : \(block.dateCreated) ")
        //print("Data : \(block.data) ")
        print("Nonce : \(block.nonce) ")
        print("Previous Hash : \(block.previousHash!) ")
        print("Hash : \(block.hash!) ")
    }
    
    private func generateHash(for block: Block) -> String {
        
        var hash = block.key.sha256()!
        
        // setting the proof of work.
        // In "00" is good to start since "0000" will take forever and Playground will eventually crash :)
        while(!hash.hasPrefix(DIFFICULTY)) {
            block.nonce += 1
            hash = block.key.sha256()!
            print(hash)
        }
        
        return hash
    }
}


