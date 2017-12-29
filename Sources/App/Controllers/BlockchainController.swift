//
//  BlockchainController.swift
//  Run
//
//  Created by Mohammad Azam on 12/27/17.
//

import Foundation
import Vapor

class BlockchainController {
    
    private (set) var drop :Droplet
    private (set) var blockchainService :BlockchainService!
    
    init(drop :Droplet) {
        
        self.drop = drop
        self.blockchainService = BlockchainService() 
        
        // setup the routes for the controller
        setupRoutes()
    }
    
    private func setupRoutes() {
        
        self.drop.get("nodes") { request in
            
            return try JSONEncoder().encode(self.blockchainService.getNodes())
        }
    
        
        self.drop.get("nodes/resolve") { request in
            
            return try Response.async { portal in
                
                self.blockchainService.resolve { blockchain in
                    let blockchain = try! JSONEncoder().encode(blockchain)
                    portal.close(with: blockchain.makeResponse())
                }
                
            }
           
        }
        
        self.drop.post("nodes/register") { request in
            
            guard let blockchainNode = BlockchainNode(request :request) else {
                return try JSONEncoder().encode(["message":"Error registering node"])
            }
            
            self.blockchainService.registerNode(blockchainNode)
            return try JSONEncoder().encode(blockchainNode)
        }
        
        self.drop.get("mine") { request in
            
            let block = Block()
            self.blockchainService.addBlock(block)
            return try JSONEncoder().encode(block)
            
        }
        
        // adding a new transaction
        self.drop.post("transaction") { request in
            
            if let transaction = Transaction(request: request) {
                // add the transaction to the block
                
                // get the last mined block
                let block = self.blockchainService.getLastBlock()
                block.addTransaction(transaction: transaction)
                
                //let block = Block(transaction: transaction)
                //self.blockchainService.addBlock(block)
                return try JSONEncoder().encode(block)
            }
            
            return try JSONEncoder().encode(["message":"Something bad happend!"])
        }
        
        // get the chain
        self.drop.get("blockchain") { request in
            
            if let blockchain = self.blockchainService.getBlockchain() {
                return try JSONEncoder().encode(blockchain)
            }
            
            return try! JSONEncoder().encode(["message":"Blockchain is not initialized. Please mine a block"])
        }
        
    }
    
}
