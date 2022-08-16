//
//  MemcacheMetaResponse.swift
//  
//
//  Created by Moritz Sternemann on 29.06.22.
//

import NIOCore

public enum MemcacheMetaResponse<Flag: Hashable> {
    case header(Set<Flag>)
    case notFound(Set<Flag>)
    case notStored(Set<Flag>)
    case exists(Set<Flag>)
    case value(Set<Flag>, ByteBuffer)
    case end
}

extension MemcacheMetaResponse {
    public func map<Value: MemcacheMetaResponseConvertible>(to type: Value.Type = Value.self) throws -> Value {
        guard let value = Value(fromResponse: self) else { fatalError() }
        return value
    }
}

extension MemcacheMetaResponse where Flag == String {
    public func mapFlags<NewFlag: MemcacheMetaFlag>() throws -> MemcacheMetaResponse<NewFlag> {
        switch self {
        case .header(let flags):
            return .header(try NewFlag.map(flags))
        case .notFound(let flags):
            return .notFound(try NewFlag.map(flags))
        case .notStored(let flags):
            return .notStored(try NewFlag.map(flags))
        case .exists(let flags):
            return .exists(try NewFlag.map(flags))
        case .value(let flags, let value):
            return .value(try NewFlag.map(flags), value)
        case .end:
            return .end
        }
    }
}
