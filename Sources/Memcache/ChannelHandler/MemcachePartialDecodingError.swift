import NIOCore

struct MemcachePartialDecodingError: Error {
    let description: String
    let file: StaticString
    let line: UInt

    static func fieldNotDecodable(
        as type: Any.Type,
        from string: String,
        file: StaticString = #file,
        line: UInt = #line
    ) -> Self {
        MemcachePartialDecodingError(
            description: "Could not read '\(type)' from '\(string)' from the ByteBuffer.",
            file: file,
            line: line
        )
    }
}
