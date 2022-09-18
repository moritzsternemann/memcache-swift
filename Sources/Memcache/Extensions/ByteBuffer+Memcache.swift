import NIOCore

extension ByteBuffer {
    @inlinable
    func _getCarriageReturnNewlineTerminatedSliceLength(at index: Int) -> Int? {
        guard readerIndex <= index && index < writerIndex - 1 else {
            return nil
        }

        var subview = readableBytesView[index...]
        repeat {
            guard let carriageReturnIndex = subview.firstIndex(of: UInt8(ascii: "\r")) else {
                return nil
            }
            let expectedNewlineIndex = carriageReturnIndex + 1

            if subview.endIndex > expectedNewlineIndex,
               subview[expectedNewlineIndex] == UInt8(ascii: "\n") {
                return (expectedNewlineIndex - 1) &- index
            } else {
                subview = readableBytesView[expectedNewlineIndex...]
            }
        } while subview.count >= 2

        return nil
    }

    /// Read a slice off this `ByteBuffer` that is terminated with `\r\n`. Move the reader index forward by the slices length and
    /// it's two terminator characters.
    ///
    /// - Returns: A `ByteBuffer` slice of this `ByteBuffer` or `nil` if there isn't a complete `\r\n`-terminated slice, including
    ///            terminators, in the readable bytes of the buffer. The returned slice does not include the terminators.
    @inlinable
    mutating func readCarriageReturnNewlineTerminatedSlice() -> ByteBuffer? {
        guard let sliceLength = _getCarriageReturnNewlineTerminatedSliceLength(at: readerIndex) else {
            return nil
        }
        let result = readSlice(length: sliceLength)
        moveReaderIndex(forwardBy: 2) // move forward by \r\n
        return result
    }

    /// Get a slice at `index` from this `ByteBuffer` that is terminated with `\r\n`. Does not move the reader index.
    /// The selected bytes must be readable or else `nil` will be returned.
    ///
    /// - Parameters:
    ///     - index: The starting index into `ByteBuffer` containing the `\r\n`-terminated slice of interest.
    /// - Returns: A `ByteBuffer` slice of this `ByteBuffer` or `nil` if there isn't a complete `\r\n`-terminated slice, including
    ///            terminators, in the readable bytes after `index` in the buffer. The returned slice does not include the terminators.
    @inlinable
    func getCarriageReturnNewlineTerminatedSlice(at index: Int) -> ByteBuffer? {
        guard let sliceLength = _getCarriageReturnNewlineTerminatedSliceLength(at: index) else {
            return nil
        }
        return getSlice(at: index, length: sliceLength)
    }
}
