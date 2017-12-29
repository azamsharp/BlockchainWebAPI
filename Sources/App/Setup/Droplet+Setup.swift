@_exported import Vapor

extension Droplet {
    
    public func setupControllers() {
        _ = BlockchainController(drop: self)
    }
    
    public func setup() throws {
        try setupRoutes()
        setupControllers()
    }
}
