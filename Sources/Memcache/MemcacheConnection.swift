//
//  MemcacheConnection.swift
//  
//
//  Created by Moritz Sternemann on 04.06.22.
//

import NIOCore
import NIOPosix

public final class MemcacheConnection {
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
            .channelInitializer {
                $0.pipeline.addHandler(MemcacheChannelHandler())
            }

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
    public func send<Flag: MemcacheMetaFlag>(
        _ command: MemcacheMetaCommand<Flag>,
        eventLoop: EventLoop? = nil
    ) -> EventLoopFuture<MemcacheMetaResponse<Flag>> {
        print("send", command)
        let finalEventLoop = eventLoop ?? channel.eventLoop

        // TODO: guard isConnected

        let promise = self.eventLoop.makePromise(of: MemcacheMetaResponse<String>.self)

        let outboundData: MemcacheChannelHandler.OutboundCommandPayload = (command.payload, promise)
        let writeFuture = channel.writeAndFlush(outboundData)

        return writeFuture
            .flatMap { promise.futureResult }
            .flatMapThrowing { try $0.mapFlags() }
            .hop(to: finalEventLoop)
    }

    public func send<Flag: MemcacheMetaFlag, Result: MemcacheMetaResponseConvertible>(
        _ command: MemcacheMetaCommand<Flag>,
        eventLoop: EventLoop? = nil
    ) -> EventLoopFuture<Result> {
        send(command, eventLoop: eventLoop)
            .flatMapThrowing { try $0.map(to: Result.self) }
    }
}
