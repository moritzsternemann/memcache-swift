import NIOCore

struct MemcachePartialDecodingError: Error {
    let description: String
    let file: String
    let line: UInt

    static func expectedExactlyNRemainingCharacters(
        _ expected: Int,
        actual: Int,
        file: String = #fileID,
        line: UInt = #line
    ) -> Self {
        MemcachePartialDecodingError(
            description: "Expected exactly '\(expected)' but found '\(actual)' remaining characters",
            file: file,
            line: line
        )
    }

    static func expectedAtLeastNRemainingCharacters(
        _ expected: Int,
        actual: Int,
        file: String = #fileID,
        line: UInt = #line
    ) -> Self {
        MemcachePartialDecodingError(
            description: "Expected at  least '\(expected)' but found '\(actual)' remaining characters",
            file: file,
            line: line
        )
    }

    static func expectedAtMostNRemainingCharacters(
        _ expected: Int,
        actual: Int,
        file: String = #fileID,
        line: UInt = #line
    ) -> Self {
        MemcachePartialDecodingError(
            description: "Expected at  most '\(expected)' but found '\(actual)' remaining characters",
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
            description: "Could not decode '\(type)' from '\(string)'",
            file: file,
            line: line
        )
    }
}
