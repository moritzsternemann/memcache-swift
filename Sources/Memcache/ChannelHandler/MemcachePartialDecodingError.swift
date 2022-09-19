import NIOCore

struct MemcachePartialDecodingError: Error {
    let description: String
    let file: String
    let line: UInt

    static func expectedExactlyNRemainingBytes(
        _ expected: Int,
        actual: Int,
        file: String = #fileID,
        line: UInt = #line
    ) -> Self {
        MemcachePartialDecodingError(
            description: "Expected exactly '\(expected)' but found '\(actual)' remaining bytes",
            file: file,
            line: line
        )
    }

    static func fieldNotDecodable(
        as type: Any.Type,
        from string: String,
        file: String = #fileID,
        line: UInt = #line
    ) -> Self {
        MemcachePartialDecodingError(
            description: "Could not read '\(type)' from '\(string)' from the ByteBuffer.",
            file: file,
            line: line
        )
    }
}
