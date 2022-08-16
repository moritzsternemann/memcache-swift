//
//  RetrievalCommands.swift
//  
//
//  Created by Moritz Sternemann on 02.07.22.
//

import NIOCore

extension MemcacheMetaCommand {
    public static func metaGet(_ key: MemcacheKey, flags: MemcacheMetaGetFlags = []) -> MemcacheMetaCommand<MemcacheMetaGetFlag> {
        .init(commandCode: "mg", key: key, flags: flags)
    }
}

// MARK: - Connection Convenience

extension MemcacheConnection {
    public func get<Value: MemcacheMetaResponseConvertible>(
        _ key: MemcacheKey,
        eventLoop: EventLoop? = nil
    ) -> EventLoopFuture<Value> {
        send(.metaGet(key, flags: [.value]), eventLoop: eventLoop)
    }
}
