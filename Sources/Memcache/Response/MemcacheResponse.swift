//
//  MemcacheResponse.swift
//  
//
//  Created by Moritz Sternemann on 29.06.22.
//

import NIOCore

public enum MemcacheResponse {
    // Storage
    case stored
    case notStored
    case exists
    
    // Retrieval
    case values([MemcacheResponseValue])
    
    // Deletion
    case deleted
    
    // Increment/Decrement
    case newValue(UInt64)
    
    // Touch
    case touched
    
    // Common
    case notFound
}

extension MemcacheResponse {
    public func map<Value: MemcacheResponseConvertible>(to type: Value.Type = Value.self) throws -> Value {
        guard let value = Value(fromResponse: self) else { fatalError() }
        return value
    }
}
