/// Flags for Meta Get, Set, Delete, and Arithmetic commands. Meta Debug and Meta No-Op don't support flags.
enum MemcacheFlag {
    // MARK: Common flags

    /// Interpret key as base64 encoded binary value.
    ///
    /// Available for the following commands:
    /// - **Meta Get**
    /// - **Meta Set**
    /// - **Meta Delete**
    /// - **Meta Arithmetic**
    case b

    /// Return item CAS token.
    ///
    /// Available for the following commands:
    /// - **Meta Get**
    /// - **Meta Set**: Return item's CAS token if successfully stored.
    /// - **Meta Arithmetic**: Return item's CAS token if successfully stored.
    case c

    /// Return key as a token.
    ///
    /// Available for the following commands:
    /// - **Meta Get**
    /// - **Meta Set**
    /// - **Meta Delete**
    case k

    /// Opaque value, consumes a token and copies back with response.
    ///
    /// Available for the following commands:
    /// - **Meta Get**
    /// - **Meta Set**
    /// - **Meta Delete**
    case O(OpaqueToken)

    /// Use noreply semantics for return codes.
    ///
    /// Available for the following commands:
    /// - **Meta Get**
    /// - **Meta Set**
    /// - **Meta Delete**
    /// - **Meta Arithmetic**
    case q

    /// Return item value in \<data block\>.
    ///
    /// Available for the following commands:
    /// - **Meta Get**
    /// - **Meta Arithmetic**: Return new value.
    case v

    /// Return item TTL remaining in seconds (-1 for unlimited).
    ///
    /// Available for the following commands:
    /// - **Meta Get**
    /// - **Meta Arithmetic**
    case t

    /// Update remaining TTL.
    ///
    /// Available for the following commands:
    /// - **Meta Get**
    /// - **Meta Set**
    /// - **Meta Delete**: Updates TTL, only when paired with the `.I` flag.
    /// - **Meta Arithmetic**: Update TTL on success.
    case T(TTLToken)

    /// Compare CAS value.
    ///
    /// Available for the following commands:
    /// - **Meta Set**: Compare CAS value when storing item.
    /// - **Meta Delete**
    /// - **Meta Arithmetic**
    case C(NumericToken<UInt64>)

    /// Invalidate: set to invalid if supplied CAS is older than item's CAS.
    ///
    /// Available for the following commands:
    /// - **Meta Set**
    /// - **Meta Delete**
    case I

    /// Vivify on miss, takes TTL as a argument.
    ///
    /// Available for the following commands:
    /// - **Meta Get**
    /// - **Meta Arithmetic**: Auto-create item on miss with supplied TTL.
    case N(TTLToken)

    /// Mode switch.
    ///
    /// Available for the following commands:
    /// - **Meta Set**: Mode switch to change behavior to add, replace, append, prepend.
    /// - **Meta Arithmetic**: Mode switch to change between incr and decr modes.
    case M(ModeToken)

    // MARK: 'Get'-only flags

    /// Return client flags token.
    ///
    /// Available for the following commands:
    /// - **Meta Get**
    case f

    /// Return whether item has been hit before as a 0 or 1.
    ///
    /// Available for the following commands:
    /// - **Meta Get**
    case h

    /// Return time since item was last accessed in seconds.
    ///
    /// Available for the following commands:
    /// - **Meta Get**
    case l

    /// Return item size token.
    ///
    /// Available for the following commands:
    /// - **Meta Get**
    case s

    /// Don't bump the item in the LRU.
    ///
    /// Available for the following commands:
    /// - **Meta Get**
    case u

    /// If token is less than remaining TTL win for recache.
    ///
    /// Available for the following commands:
    /// - **Meta Get**
    case R(TTLToken)

    /// Client has "won" the recache flag.
    ///
    /// Available for the following commands:
    /// - **Meta Get**
    case W

    /// Item is stale.
    ///
    /// Available for the following commands:
    /// - **Meta Get**
    case X

    /// Item has already sent a winning flag.
    ///
    /// Available for the following commands:
    /// - **Meta Get**
    case Z

    // MARK: 'Set'-only flags

    /// Set client flags to token.
    ///
    /// Available for the following commands:
    /// - **Meta Set**
    case F(NumericToken<UInt32>) // TODO: Docs say '32 bit unsigned numeric'

    // MARK: 'Delete'-only flags

    // No 'Delete'-only flags

    // MARK: 'Arithmetic'-only flags

    /// Initial value to use if auto created after miss (default 0).
    ///
    /// Available for the following commands:
    /// - **Meta Arithmetic**
    case J(NumericToken<UInt64>)

    /// Delta to apply (default 1).
    ///
    /// Available for the following commands:
    /// - **Meta Arithmetic**
    case D(NumericToken<UInt64>) // TODO: Docs say 'unsigned decimal number'

    // MARK: Ignored tokens

    /// This flag is completely ignored by the memcached daemon. It can be used as a hint or path specification to a proxy or
    /// router inbetween a client and the memcached daemon.
    case P(StringToken)

    /// This flag is completely ignored by the memcached daemon. It can be used as a hint or path specification to a proxy or
    /// router inbetween a client and the memcached daemon.
    case L(StringToken)
}

extension MemcacheFlag: CustomDebugStringConvertible {
    var debugDescription: String {
        switch self {
        case .b:
            return ".b"
        case .c:
            return ".c"
        case .k:
            return ".k"
        case let .O(token):
            return ".O(\(token))"
        case .q:
            return ".q"
        case .v:
            return ".v"
        case .t:
            return ".t"
        case let .T(token):
            return ".T(\(token))"
        case let .C(token):
            return ".C(\(token))"
        case .I:
            return ".I"
        case let .N(token):
            return ".N(\(token))"
        case let .M(token):
            return ".M(\(token))"
        case .f:
            return ".f"
        case .h:
            return ".h"
        case .l:
            return ".l"
        case .s:
            return ".s"
        case .u:
            return ".u"
        case let .R(token):
            return ".R(\(token))"
        case .W:
            return ".W"
        case .X:
            return ".X"
        case .Z:
            return ".Z"
        case let .F(token):
            return ".F(\(token))"
        case let .J(token):
            return ".J(\(token))"
        case let .D(token):
            return ".D(\(token))"
        case let .P(token):
            return ".P(\(token))"
        case let .L(token):
            return ".L(\(token))"
        }
    }
}

// MARK: -

extension MemcacheFlag {
    enum Code: Character {
        // MARK: Common flags

        case b = "b"
        case c = "c"
        case k = "k"
        case O = "O"
        case q = "q"
        case v = "v"
        case t = "t"
        case T = "T"
        case C = "C"
        case I = "I"
        case N = "N"
        case M = "M"

        // MARK: 'Get'-only flags

        case f = "f"
        case h = "h"
        case l = "l"
        case s = "s"
        case u = "u"
        case R = "R"
        case W = "W"
        case X = "X"
        case Z = "Z"

        // MARK: 'Set'-only flags

        case F = "F"

        // MARK: 'Delete'-only flags

        // No 'Delete'-only flags

        // MARK: 'Arithmetic'-only flags

        case J = "J"
        case D = "D"

        // MARK: Ignored flags

        case P = "P"
        case L = "L"
    }
}
