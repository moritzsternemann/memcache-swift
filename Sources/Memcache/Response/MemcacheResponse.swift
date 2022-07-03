//
//  MemcacheResponse.swift
//  
//
//  Created by Moritz Sternemann on 29.06.22.
//

import NIO

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
