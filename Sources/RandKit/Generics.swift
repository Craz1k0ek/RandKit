/// A pseudorandom number generator.
public protocol PRNG: RandomNumberGenerator {
    /// Initialize the generator using another generator.
    /// - Parameter generator: The other number generator.
    init<G: RandomNumberGenerator>(using generator: inout G)
}

public extension PRNG {
    /// Initialize the twister using the system random number generator.
    init() {
        var systemRandom = SystemRandomNumberGenerator()
        self.init(using: &systemRandom)
    }
}

/// A cryptographically secure pseudorandom number generator.
public protocol CSPRNG: PRNG {}
