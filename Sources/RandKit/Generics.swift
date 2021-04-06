/// A pseudorandom number generator.
public protocol PRNG: RandomNumberGenerator {
    /// Initialize the generator using another generator.
    /// - Parameter generator: The other number generator.
    init<G: RandomNumberGenerator>(using generator: inout G)
}

/// A cryptographically secure pseudorandom number generator.
public protocol CSPRNG: PRNG {}
