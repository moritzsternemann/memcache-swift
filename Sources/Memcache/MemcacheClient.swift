//
//  MemcacheClient.swift
//  
//
//  Created by Moritz Sternemann on 04.06.22.
//

import NIOCore

public protocol MemcacheClient {
    var eventLoop: EventLoop { get }

    func send<Result>(
        _ command: MemcacheCommand<Result>,
        eventLoop: EventLoop?
    ) -> EventLoopFuture<Result>
}
