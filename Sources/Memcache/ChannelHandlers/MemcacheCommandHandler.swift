//
//  MemcacheCommandHandler.swift
//  
//
//  Created by Moritz Sternemann on 27.06.22.
//

import NIOCore

final class MemcacheCommandHandler {
    typealias OutboundCommandPayload = (command: MemcacheCommandPayload, responsePromise: EventLoopPromise<MemcacheResponse>)

    private enum State {
        case `default`
        case error(Error)
    }

    private var commandResponseQueue: CircularBuffer<EventLoopPromise<MemcacheResponse>>
    private var state: State = .default
    
    init(initialQueueCapacity: Int = 3) {
        self.commandResponseQueue = CircularBuffer(initialCapacity: initialQueueCapacity)
    }
    
    deinit {
        if !commandResponseQueue.isEmpty {
            assertionFailure("Queue not empty (\(commandResponseQueue.count))")
        }
    }
}

// MARK: - ChannelInboundHandler

extension MemcacheCommandHandler: ChannelInboundHandler {
    typealias InboundIn = MemcacheResponse

    func errorCaught(context: ChannelHandlerContext, error: Error) {
        failRemainingPromises(reason: error)
        context.close(promise: nil)
    }

    func channelInactive(context: ChannelHandlerContext) {
        failRemainingPromises(reason: MemcacheClientError.connectionClosed)
    }

    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let value = self.unwrapInboundIn(data)

        guard let promise = commandResponseQueue.popFirst() else { return }

        promise.succeed(value)
    }
    
    private func failRemainingPromises(reason error: Error) {
        state = .error(error)
        let queue = commandResponseQueue
        commandResponseQueue.removeAll()
        queue.forEach { $0.fail(error) }
    }
}

// MARK: - ChannelOutboundHandler

extension MemcacheCommandHandler: ChannelOutboundHandler {
    typealias OutboundIn = OutboundCommandPayload
    typealias OutboundOut = MemcacheCommandPayload

    func write(context: ChannelHandlerContext, data: NIOAny, promise: EventLoopPromise<Void>?) {
        let commandPayload = self.unwrapOutboundIn(data)

        switch state {
        case .`default`:
            self.commandResponseQueue.append(commandPayload.responsePromise)
            context.write(
                self.wrapOutboundOut(commandPayload.command),
                promise: promise
            )
        case let .error(error):
            commandPayload.responsePromise.fail(error)
        }
    }
}
