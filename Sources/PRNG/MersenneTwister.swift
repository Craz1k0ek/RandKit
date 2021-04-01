import Foundation

/// An implementation of the MT19937-64 Mersenne Twister.
public struct MersenneTwister: RandomNumberGenerator {
    private var mt: [UInt64]
    private var index: UInt64

    /// Initialize the twister with a seed.
    /// - Parameter seed: The seed.
    public init(seed: UInt64) {
        mt = [UInt64](repeating: 0, count: Int(Self.n))
        index = Self.n
        mt[0] = seed

        for i in 1 ..< Self.n {
            mt[Int(i)] = (Self.f &* (mt[Int(i - 1)] ^ (mt[Int(i - 1)] >> (Self.w - 2))) + i)
        }
    }

    /// Initialize the twister using the system random number generator.
    public init() {
        var systemRandom = SystemRandomNumberGenerator()
        self.init(seed: systemRandom.next())
    }

    /// Twist the twister, generating new data.
    private mutating func twist() {
        for i in 0 ..< Self.n {
            let x = (mt[Int(i)] & Self.upperMask) + (mt[Int((i + 1) % Self.n)] & Self.lowerMask)
            var xA = x >> 1
            if x & UInt64(0x01) != 0 {
                xA ^= Self.a
            }
            mt[Int(i)] = mt[Int((i + Self.m) % Self.n)] ^ xA
        }
        index = 0
    }

    mutating public func next() -> UInt64 {
        var i = index
        if index >= Self.n {
            twist()
            i = index
        }

        var y = mt[Int(i)]
        index = i + 1

        y ^= (y >> Self.u) & Self.d;
        y ^= (y << Self.s) & Self.b;
        y ^= (y << Self.t) & Self.c;
        y ^= (y >> Self.l);

        return y
    }
}

// MARK: - Mersenne Twister variables

private extension MersenneTwister {
    /// The word size in number of bits.
    private static let w: UInt64 = 64
    /// The degree of recurrence.
    private static let n: UInt64 = 312
    /// The middle word, an offset used in the recurrence relation defining the series `x, 1 ≤ m < n`.
    private static let m: UInt64 = 156
    /// Separation point of one word, or the number of bits of the lower bitmask, `0 ≤ r ≤ w -1`.
    private static let r: UInt64 = 31

    /// Coefficients of the rational normal twist matrix.
    private static let a: UInt64 = 0xB5026F5AA96619E9

    /// Additional Mersenne Twister tempering bit shifts/masks.
    private static let u: UInt64 = 11
    /// Additional Mersenne Twister tempering bit shifts/masks.
    private static let d: UInt64 = 0x5555555555555555

    /// A `TGFSR(R)` tempering bit shift.
    private static let s: UInt64 = 17
    /// A `TGFSR(R)` tempering bit mask.
    private static let b: UInt64 = 0x71D67FFFEDA60000

    /// A `TGFSR(R)` tempering bit shift.
    private static let t: UInt64 = 37
    /// A `TGFSR(R)` tempering bit mask.
    private static let c: UInt64 = 0xFFF7EEE000000000

    /// Additional Mersenne Twister tempering bit shifts/masks.
    private static let l: UInt64 = 43

    /// Another generator parameter, though not part of the algorithm.
    private static let f: UInt64 = 0x5851F42D4C957F2D

    /// Additional Mersenne Twister masks.
    private static let lowerMask: UInt64 = (1 << r) - 1
    private static let upperMask: UInt64 = ~lowerMask
}
