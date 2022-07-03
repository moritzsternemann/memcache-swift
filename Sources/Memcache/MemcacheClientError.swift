//
//  MemcacheClientError.swift
//  
//
//  Created by Moritz Sternemann on 29.06.22.
//

import Foundation

enum MemcacheClientError: LocalizedError {
    case connectionClosed
    
    var errorDescription: String? {
        switch self {
        case .connectionClosed:
            return "connection closed"
        }
    }
}
