//
//  RetrievalCommands.swift
//  
//
//  Created by Moritz Sternemann on 02.07.22.
//

import Foundation
import NIO

extension MemcacheCommand {
    public static func get(_ keys: [MemcacheKey]) -> MemcacheCommand<[MemcacheResponseValue]> {
        .init(keyword: "get", arguments: keys.map(\.rawValue))
    }

    public static func gets(_ key: MemcacheKey) -> MemcacheCommand {
        fatalError("not implemented")
//        .init(keyword: "gets", arguments: [])
    }

    public static func delete(_ key: MemcacheKey) -> MemcacheCommand {
        fatalError("not implemented")
//        .init(keyword: "delete", arguments: [])
    }

    public static func incr(_ key: MemcacheKey) -> MemcacheCommand {
        fatalError("not implemented")
//        .init(keyword: "incr", arguments: [])
    }

    public static func decr(_ key: MemcacheKey) -> MemcacheCommand {
        fatalError("not implemented")
//        .init(keyword: "decr", arguments: [])
    }
}

// MARK: - Client Convenience

extension MemcacheClient {
    public func get(
        _ keys: [MemcacheKey],
        eventLoop: EventLoop? = nil
    ) -> EventLoopFuture<[MemcacheResponseValue]> {
        send(.get(keys), eventLoop: eventLoop)
    }

    public func get<Value: MemcacheResponseValueConvertible>(
        _ keys: [MemcacheKey],
        as type: Value.Type = Value.self,
        eventLoop: EventLoop? = nil
    ) -> EventLoopFuture<[Value?]> {
        get(keys, eventLoop: eventLoop)
            .flatMapThrowing { $0.map(Value.init(fromResponseValue:)) }
    }

    public func get<D: Decodable>(
        _ keys: [MemcacheKey],
        asJSON type: D.Type = D.self,
        decoder: JSONDecoder = .init(),
        eventLoop: EventLoop? = nil
    ) -> EventLoopFuture<[D?]> {
        get(keys, as: Data.self, eventLoop: eventLoop)
            .flatMapThrowing { values in
                try values.map { value in
                    try value.map { try decoder.decode(D.self, from: $0) }
                }
            }
    }

    public func get(
        _ key: MemcacheKey,
        eventLoop: EventLoop? = nil
    ) -> EventLoopFuture<MemcacheResponseValue?> {
        send(.get([key]), eventLoop: eventLoop)
            .map(\.first)
    }
    
    public func get<Value: MemcacheResponseValueConvertible>(
        _ key: MemcacheKey,
        as type: Value.Type = Value.self,
        eventLoop: EventLoop? = nil
    ) -> EventLoopFuture<Value?> {
        get([key], as: type, eventLoop: eventLoop)
            .map { values in
                values.first?.flatMap { $0 }
            }
    }
    
    public func get<D: Decodable>(
        _ key: MemcacheKey,
        asJSON type: D.Type = D.self,
        decoder: JSONDecoder = .init(),
        eventLoop: EventLoop? = nil
    ) -> EventLoopFuture<D?> {
        get(key, as: Data.self, eventLoop: eventLoop)
            .flatMapThrowing { data in
                try data.map { try decoder.decode(D.self, from: $0) }
            }
    }
}
