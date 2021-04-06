/// An implementation of the ISAAC number generator.
public struct ISAAC: CSPRNG {
    /// The initial state of the generator.
    private var state: [UInt64] = [UInt64](repeating: 0x9e3779b97f4a7c13, count: 8)

    /// Internal generator states.
    private var mm = [UInt64]()
    private var aa, bb, cc: UInt64

    /// The output of the last generation.
    private var result = [UInt64](repeating: 0, count: 256)
    /// The number of values already consumed from the result values.
    private var count = 256

    /// Initialize the generator with a seed.
    /// - Note: The seed is expected to have 256 elements.
    /// When more than 256 elements are found, the excess elements will be dropped.
    /// When less than 256 elements are found, the seed is extended with zero's.
    /// - Parameter seed: The seed.
    public init(seed: [UInt64]) {
        let seed = Self.normalize(seed: seed)

        aa = 0; bb = 0; cc = 0

        for _ in 0 ..< 4 {
            mix()
        }

        for i in stride(from: 0, to: 256, by: 8) {
            for j in 0 ..< 8 {
                state[j] &+= seed[i + j]
            }
            mix()
            self.mm.append(contentsOf: state)
        }

        for i in stride(from: 0, to: 256, by: 8) {
            for j in 0 ..< 8 {
                state[j] &+= mm[i + j]
            }
            mix()
            for j in 0 ..< 8 {
                mm[i + j] = state[j]
            }
        }
    }

    public init<G: RandomNumberGenerator>(using generator: inout G) {
        self.init(seed: (0 ..< 256).map { _ in UInt64.random(in: 0 ..< UInt64.max, using: &generator) })
    }

    /// Initialize the generator using the system random number generator.
    public init() {
        var systemRandom = SystemRandomNumberGenerator()
        self.init(using: &systemRandom)
    }

    /// Normalize the provided seed by removing superfluous elements or by appending required elements.
    /// - Parameter seed: The provided seed.
    /// - Returns: The normalized seed.
    private static func normalize(seed: [UInt64]) -> [UInt64] {
        switch seed.count {
        case let count where count < 256:
            return seed + [UInt64](repeating: 0, count: 256 - count)
        case let count where count > 256:
            return seed.dropLast(count - 256)
        default:
            return seed
        }
    }

    /// Mix the internal state.
    private mutating func mix() {
        state[0] ^= state[1]<<11; state[3] &+= state[0]; state[1] &+= state[2]
        state[1] ^= state[2]>>2 ; state[4] &+= state[1]; state[2] &+= state[3]
        state[2] ^= state[3]<<8 ; state[5] &+= state[2]; state[3] &+= state[4]
        state[3] ^= state[4]>>16; state[6] &+= state[3]; state[4] &+= state[5]
        state[4] ^= state[5]<<10; state[7] &+= state[4]; state[5] &+= state[6]
        state[5] ^= state[6]>>4 ; state[0] &+= state[5]; state[6] &+= state[7]
        state[6] ^= state[7]<<8 ; state[1] &+= state[6]; state[7] &+= state[0]
        state[7] ^= state[0]>>9 ; state[2] &+= state[7]; state[0] &+= state[1]
    }

    /// Generate random values.
    private mutating func generate() {
        cc &+= 1
        bb &+= cc

        for i in 0 ..< 256 {
            let x = mm[i]
            switch i & 3 {
            case 0:
                aa ^= aa << 13
            case 1:
                aa ^= aa >> 6
            case 2:
                aa ^= aa << 2
            case 3:
                aa ^= aa >> 16
            default: fatalError()
            }
            aa = mm[i ^ 128] &+ aa
            mm[i] = mm[Int(x >> 2) & 0xff] &+ aa &+ bb
            let y = mm[i]
            bb = mm[Int(y >> 10) & 0xff] &+ x
            result[i] = bb
        }
        count = 0
    }

    public mutating func next() -> UInt64 {
        defer {
            count += 1
        }
        if count == 256 {
            generate()
        }
        return result[count]
    }
}
