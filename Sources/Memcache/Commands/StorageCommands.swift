//
//  StorageCommands.swift
//  
//
//  Created by Moritz Sternemann on 02.07.22.
//

import NIO

extension MemcacheCommand {
    public static func `set`(
        _ key: MemcacheKey,
        value: ByteBuffer,
        flags: UInt16? = nil,
        expiration: MemcacheExpiration,
        noReply: Bool = false
    ) -> MemcacheCommand<Void> {
        var arguments: [String] = [key.rawValue]
        arguments.append(flags.map(String.init) ?? "0")
        arguments.append(String(expiration.rawValue))
        arguments.append(String(value.readableBytes))
        if noReply {
            arguments.append("noreply")
        }

        return .init(keyword: "set", arguments: arguments, data: value)
    }

    public static func add(_ key: MemcacheKey) -> MemcacheCommand {
        fatalError("not implemented")
//        .init(keyword: "add", arguments: [])
    }

    public static func replace(_ key: MemcacheKey) -> MemcacheCommand {
        fatalError("not implemented")
//        .init(keyword: "replace", arguments: [])
    }

    public static func append(_ key: MemcacheKey) -> MemcacheCommand {
        fatalError("not implemented")
//        .init(keyword: "append", arguments: [])
    }

    public static func prepend(_ key: MemcacheKey) -> MemcacheCommand {
        fatalError("not implemented")
//        .init(keyword: "prepend", arguments: [])
    }

    public static func cas(_ key: MemcacheKey) -> MemcacheCommand {
        fatalError("not implemented")
//        .init(keyword: "cas", arguments: [])
    }
}

// MARK: - Client Convenience

extension MemcacheClient {
    public func `set`(
        _ key: MemcacheKey,
        to value: ByteBuffer,
        expiration: MemcacheExpiration,
        eventLoop: EventLoop? = nil
    ) -> EventLoopFuture<Void> {
        send(.set(key, value: value, expiration: expiration), eventLoop: eventLoop)
    }
}
