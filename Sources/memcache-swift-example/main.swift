import Memcache
import NIOCore
import NIOPosix

let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
defer {
    try? group.syncShutdownGracefully()
}

let connection = try MemcacheConnection.make(
    address: try .init(ipAddress: "127.0.0.1", port: 11211),
    boundEventLoop: group.next()
).wait()

print("connected")

let buffer = ByteBuffer(staticString: "Hello World")
let result = try connection
    .set("mykey", to: buffer, expiration: .relative(1337))
    .flatMap { response -> EventLoopFuture<String> in
        print("Set result: \(String(describing: response))")

        return connection.get("mykey")
    }
    .wait()

print("Get result: \(String(describing: result))")
