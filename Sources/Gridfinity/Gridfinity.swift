import Foundation
import Cadova

/// A 2D grid unit count for the Gridfinity modular storage system.
///
/// Gridfinity uses a standardized 42mm × 42mm grid. This type represents
/// a count of grid units in the X and Y dimensions.
public struct Units2D: Hashable, Sendable {
    /// The number of grid units in the X dimension.
    public let x: Int
    /// The number of grid units in the Y dimension.
    public let y: Int

    /// The physical size of one Gridfinity grid unit (42mm × 42mm).
    public static let size = Vector2D(42, 42)

    public init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
}

/// A 3D grid unit count for the Gridfinity modular storage system.
///
/// Extends the 2D grid with a Z dimension using a 7mm vertical unit height.
public struct Units3D: Hashable, Sendable {
    /// The number of grid units in the X dimension.
    public let x: Int
    /// The number of grid units in the Y dimension.
    public let y: Int
    /// The number of grid units in the Z dimension.
    public let z: Int

    public init(x: Int, y: Int, z: Int) {
        self.x = x
        self.y = y
        self.z = z
    }

    public init(base: Units2D, z: Int) {
        self.x = base.x
        self.y = base.y
        self.z = z
    }

    public var base: Units2D {
        Units2D(x: x, y: y)
    }

    /// The physical size of one Gridfinity 3D grid unit (42mm × 42mm × 7mm).
    public static let size = Vector3D(Units2D.size, z: 7)
}

/// The position of magnet slots within a Gridfinity grid cell.
///
/// Used with ``Baseplate/Option/magnets(_:)`` to specify where magnet slots
/// should be placed in baseplates.
public enum MagnetPosition: Sendable, Hashable {
    /// Four magnet slots positioned near the corners of each grid cell.
    ///
    /// This is the standard Gridfinity magnet placement, compatible with bins
    /// that have corner magnets.
    case corners

    /// A single magnet slot positioned in the center of each grid cell.
    ///
    /// Useful for bins with a single centered magnet.
    case centered
}
