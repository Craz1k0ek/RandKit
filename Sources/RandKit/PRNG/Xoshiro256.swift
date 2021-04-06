/// An implementation of the xoshiro256** generator.
public struct Xoshiro256: PRNG {
    /// The internal state of the generator.
    private var state: (UInt64, UInt64, UInt64, UInt64)

    /// Initialize the generator with a seed.
    /// - Parameter state: The seed.
    init(seed: (UInt64, UInt64, UInt64, UInt64)) {
        state = seed
    }

    public init<G: RandomNumberGenerator>(using generator: inout G) {
        self.init(seed: (generator.next(), generator.next(), generator.next(), generator.next()))
    }

    public mutating func next() -> UInt64 {
        let result = Self.rol(state.1 &* 5, 7) &* 9
        let t = state.1 << 17

        state.2 ^= state.0
        state.3 ^= state.1
        state.1 ^= state.2
        state.0 ^= state.3

        state.2 ^= t
        state.3 = Self.rol(state.3, 45)

        return result
    }

    @inlinable static func rol(_ x: UInt64, _ k: UInt64) -> UInt64 {
        (x << k) | (x >> (64 - k))
    }
}
