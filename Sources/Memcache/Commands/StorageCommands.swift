//
//  StorageCommands.swift
//  
//
//  Created by Moritz Sternemann on 02.07.22.
//

import NIOCore

extension MemcacheMetaCommand {
    public static func metaSet(
        _ key: MemcacheKey,
        value: ByteBuffer,
        flags: MemcacheMetaSetFlags = []
    ) -> MemcacheMetaCommand<MemcacheMetaSetFlag> {
        .init(commandCode: "ms", key: key, flags: flags, data: value)
    }
}

// MARK: - Connection Convenience

extension MemcacheConnection {
    public func set(
        _ key: MemcacheKey,
        to value: ByteBuffer,
        expiration: MemcacheExpiration,
        eventLoop: EventLoop? = nil
    ) -> EventLoopFuture<MemcacheMetaResponse<MemcacheMetaSetFlag>> {
        send(.metaSet(key, value: value, flags: [.ttl("\(expiration.rawValue)")]), eventLoop: eventLoop)
    }
}
