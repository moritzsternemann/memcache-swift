//
//  MemcacheChannelHandler.swift
//  
//
//  Created by Moritz Sternemann on 27.06.22.
//

import NIOCore

final class MemcacheChannelHandler {
    typealias OutboundCommandPayload = (command: MemcacheMetaCommandPayload, responsePromise: EventLoopPromise<MemcacheMetaResponse<String>>)

    private enum State {
        case `default`
        case error(Error)
    }

    private var commandResponseQueue: CircularBuffer<EventLoopPromise<MemcacheMetaResponse<String>>>
    private var state: State = .default

    private let decoder: NIOSingleStepByteToMessageProcessor<MemcacheMessageDecoder>
    private var encoder: BufferedMessageEncoder!
    
    init(initialQueueCapacity: Int = 3) {
        self.commandResponseQueue = CircularBuffer(initialCapacity: initialQueueCapacity)
        self.decoder = NIOSingleStepByteToMessageProcessor(MemcacheMessageDecoder())
    }
    
    deinit {
        if !commandResponseQueue.isEmpty {
            assertionFailure("Queue not empty (\(commandResponseQueue.count))")
        }
    }
}

extension MemcacheChannelHandler: ChannelHandler {
    func handlerAdded(context: ChannelHandlerContext) {
        encoder = BufferedMessageEncoder(
            buffer: context.channel.allocator.buffer(capacity: 256), // TODO: What size makes sense here?
            encoder: MemcacheMessageEncoder()
        )
    }
}

// MARK: - ChannelInboundHandler

extension MemcacheChannelHandler: ChannelInboundHandler {
    typealias InboundIn = ByteBuffer

    func channelInactive(context: ChannelHandlerContext) {
        failRemainingPromises(reason: MemcacheClientError.connectionClosed)
    }

    func errorCaught(context: ChannelHandlerContext, error: Error) {
        failRemainingPromises(reason: error)
        context.close(promise: nil)
    }

    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let buffer = self.unwrapInboundIn(data)

        guard let promise = commandResponseQueue.popFirst() else { return }

        do {
            try decoder.process(buffer: buffer) { response in
                promise.succeed(response)
            }
        } catch {
            failRemainingPromises(reason: error)
        }
    }
    
    private func failRemainingPromises(reason error: Error) {
        state = .error(error)
        let queue = commandResponseQueue
        commandResponseQueue.removeAll()
        queue.forEach { $0.fail(error) }
    }
}

// MARK: - ChannelOutboundHandler

extension MemcacheChannelHandler: ChannelOutboundHandler {
    typealias OutboundIn = OutboundCommandPayload
    typealias OutboundOut = ByteBuffer

    func write(context: ChannelHandlerContext, data: NIOAny, promise: EventLoopPromise<Void>?) {
        let commandPayload = self.unwrapOutboundIn(data)

        switch state {
        case .`default`:
            commandResponseQueue.append(commandPayload.responsePromise)
            encoder.encode(commandPayload.command)
            context.writeAndFlush(wrapOutboundOut(encoder.flush()), promise: promise)
        case let .error(error):
            commandPayload.responsePromise.fail(error)
        }
    }
}
