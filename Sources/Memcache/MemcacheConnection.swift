//
//  MemcacheConnection.swift
//  
//
//  Created by Moritz Sternemann on 04.06.22.
//

import NIO

public final class MemcacheConnection: MemcacheClient {
    public static func make(
        address: SocketAddress,
        boundEventLoop eventLoop: EventLoop,
        configuredTCPClient client: ClientBootstrap? = nil
    ) -> EventLoopFuture<MemcacheConnection> {
        let client = client ?? ClientBootstrap(group: eventLoop)
            .channelOption(
                ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR),
                value: 1
            )
            .channelInitializer { $0.pipeline.addBaseMemcacheHandlers() }

        let future = client
            .connect(to: address)
            .map { MemcacheConnection(configuredChannel: $0) }

        return future
    }

    private let channel: Channel

    public var eventLoop: EventLoop {
        channel.eventLoop
    }

    private init(configuredChannel: Channel) {
        self.channel = configuredChannel
    }
}

// MARK: Sending

extension MemcacheConnection {
    public func send<Result>(
        _ command: MemcacheCommand<Result>,
        eventLoop: EventLoop? = nil
    ) -> EventLoopFuture<Result> {
        print("send", command)
        let finalEventLoop = eventLoop ?? channel.eventLoop

        // TODO: guard isConnected

        let promise = self.eventLoop.makePromise(of: MemcacheResponse.self)

        let outboundData: MemcacheCommandHandler.OutboundCommandPayload = (command.payload, promise)
        let writeFuture = channel.writeAndFlush(outboundData)

        return writeFuture
            .flatMap { promise.futureResult }
            .flatMapThrowing { try command.transform($0) }
            .hop(to: finalEventLoop)
    }
}
