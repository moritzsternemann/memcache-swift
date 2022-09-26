import NIOCore

extension MemcacheBackendMessage {
    struct Flags: MemcacheMessagePayloadDecodable, ExpressibleByArrayLiteral {
        let flags: [MemcacheFlag]

        init(_ flags: [MemcacheFlag]) {
            self.flags = flags
        }

        init(arrayLiteral elements: MemcacheFlag...) {
            flags = elements
        }

        /// Decode flags from any backend message.
        ///
        /// The following formats can be decoded from the `buffer`:
        /// - `<flags>\r\n`. Flags are space-separated strings.
        /// - `\r\n`. No flags.
        static func decode(from buffer: inout ByteBuffer) throws -> Self {
            // Flags are always the last part of a message, which is terminated by \r\n.
            // Because we get passed a potentially longer buffer here, we parse until \r\n.
            guard var flagsSlice = buffer.readCarriageReturnNewlineTerminatedSlice() else {
                // No \r\n? Something went terribly wrong...
                preconditionFailure("Expected to only see messages that contain \r\n here.")
            }

            // Flags can always be empty
            guard flagsSlice.readableBytes > 0 else { return [] }

            // The slice now only contains the flags separated by <space>
            let flagsString = flagsSlice.readString(length: flagsSlice.readableBytes)!

            return try Flags(
                flagsString
                    .split(separator: " ")
                    .map { flag in
                        guard let codeCharacter = flag.first,
                              let code = MemcacheFlag.Code(rawValue: codeCharacter)
                        else {
                            throw MemcachePartialDecodingError.fieldNotDecodable(as: MemcacheFlag.Code.self, from: String(flag))
                        }
                        return try .decode(from: flag.dropFirst(), for: code)
                    }
            )
        }
    }
}

extension MemcacheBackendMessage.Flags: CustomDebugStringConvertible {
    var debugDescription: String {
        "flags: [" +
        flags
            .map(String.init(describing:))
            .joined(separator: ", ")
        + "]"
    }
}

// MARK: - Flag decoding

extension MemcacheFlag {
    static func decode(from substring: Substring, for code: Code) throws -> MemcacheFlag {
        switch code {
        case .b:
            return .b
        case .c:
            return .c
        case .k:
            return .k
        case .O:
            return try .O(.decode(from: substring))
        case .q:
            return .q
        case .v:
            return .v
        case .t:
            return .t
        case .T:
            return try .T(.decode(from: substring))
        case .C:
            return try .C(.decode(from: substring))
        case .I:
            return .I
        case .N:
            return try .N(.decode(from: substring))
        case .M:
            return try .M(.decode(from: substring))
        case .f:
            return .f
        case .h:
            return .h
        case .l:
            return .l
        case .s:
            return .s
        case .u:
            return .u
        case .R:
            return try .R(.decode(from: substring))
        case .W:
            return .W
        case .X:
            return .X
        case .Z:
            return .Z
        case .F:
            return try .F(.decode(from: substring))
        case .J:
            return try .J(.decode(from: substring))
        case .D:
            return try .D(.decode(from: substring))
        case .P:
            return try .P(.decode(from: substring))
        case .L:
            return try .L(.decode(from: substring))
        }
    }
}

// MARK: - Token types

protocol MemcacheMessageFlagTokenDecodable {
    static func decode(from substring: Substring) throws -> Self
}

extension MemcacheFlag.StringToken: MemcacheMessageFlagTokenDecodable {
    static func decode(from substring: Substring) throws -> Self {
        return Self(stringLiteral: String(substring))
    }
}

extension MemcacheFlag.NumericToken: MemcacheMessageFlagTokenDecodable where Value: LosslessStringConvertible {
    static func decode(from substring: Substring) throws -> Self {
        guard let numericValue = Value(String(substring)) else {
            throw MemcachePartialDecodingError.fieldNotDecodable(as: Value.self, from: String(substring))
        }
        return Self(value: numericValue)
    }
}

extension MemcacheFlag.OpaqueToken: MemcacheMessageFlagTokenDecodable {
    static func decode(from substring: Substring) throws -> Self {
        guard substring.count <= 32 else {
            throw MemcachePartialDecodingError.expectedAtMostNRemainingCharacters(32, actual: substring.count)
        }
        return Self(stringLiteral: String(substring))
    }
}

extension MemcacheFlag.TTLToken: MemcacheMessageFlagTokenDecodable {
    static func decode(from substring: Substring) throws -> Self {
        let numeric = try MemcacheFlag.NumericToken<UInt32>.decode(from: substring)
        return Self(integerLiteral: numeric.value)
    }
}

extension MemcacheFlag.ModeToken: MemcacheMessageFlagTokenDecodable {
    static func decode(from substring: Substring) throws -> Self {
        guard substring.count == 1 else {
            throw MemcachePartialDecodingError.expectedExactlyNRemainingCharacters(1, actual: substring.count)
        }
        guard let token = Self(rawValue: substring.first!) else {
            throw MemcachePartialDecodingError.fieldNotDecodable(as: Self.self, from: String(substring))
        }
        return token
    }
}
