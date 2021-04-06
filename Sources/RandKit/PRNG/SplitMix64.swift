/// An implementation of the SplitMix64 generator.
public struct SplitMix64: PRNG {
    /// The internal state of the generator.
    private var state: UInt64

    /// Initialize the generator with a seed.
    /// - Parameter seed: The seed.
    public init(seed: UInt64) {
        state = seed
    }

    public init<G: RandomNumberGenerator>(using generator: inout G) {
        self.init(seed: generator.next())
    }

    public mutating func next() -> UInt64 {
        state &+= 0x9e3779b97f4a7c15
        var result = state
        result = (result ^ (result >> 30)) &* 0xbf58476d1ce4e5b9
        result = (result ^ (result >> 27)) &* 0x94d049bb133111eb
        return result ^ (result >> 31)
    }
}
