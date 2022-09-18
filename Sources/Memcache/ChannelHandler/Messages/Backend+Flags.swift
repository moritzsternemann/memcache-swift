import NIOCore

extension MemcacheBackendMessage {
    struct Flags: MemcacheMessagePayloadDecodable, Equatable, ExpressibleByArrayLiteral {
        let flags: [String] // TODO: Do we want something like (Character, token: String?) instead? Or a struct?

        init(_ flags: [String]) {
            self.flags = flags
        }

        init(arrayLiteral elements: String...) {
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
            guard let flagsString = flagsSlice.readString(length: flagsSlice.readableBytes) else {
                preconditionFailure("We have readable bytes so we should be able to read a string")
            }

            return Flags(flagsString.components(separatedBy: " "))
        }
    }
}

extension MemcacheBackendMessage.Flags: CustomDebugStringConvertible {
    var debugDescription: String {
        "[\(flags.map({ "\"\($0)\"" }).joined(separator: ", "))]"
    }
}
