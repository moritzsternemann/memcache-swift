//
//  NIO.swift
//  
//
//  Created by Moritz Sternemann on 27.06.22.
//

import NIO

extension ChannelPipeline {
    func addBaseMemcacheHandlers() -> EventLoopFuture<Void> {
        let handlers: [(ChannelHandler, name: String)] = [
            (MessageToByteHandler(MemcacheMessageEncoder()), "memcache-swift.OutgoingHandler"),
            (ByteToMessageHandler(MemcacheByteDecoder()), "memcache-swift.IncomingHandler"),
            (MemcacheCommandHandler(), "memcache-swift.CommandHandler")
        ]
        return .andAllSucceed(
            handlers.map { self.addHandler($0, name: $1) },
            on: self.eventLoop
        )
    }
}
