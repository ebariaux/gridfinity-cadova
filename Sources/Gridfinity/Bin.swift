import Cadova

/// A hollow Gridfinity storage container for organizing items.
///
/// A bin is created by hollowing out a block, leaving walls of configurable
/// thickness. Bins can optionally include a stacking lip that allows them
/// to be stacked on top of each other without a baseplate.
public struct Bin: Geometry3D {
    /// The underlying block that defines the bin's outer dimensions.
    public let block: Block
    /// The thickness of the bin walls in millimeters.
    public let wallThickness: Double
    /// The thickness of the bin bottom in millimeters.
    public let bottomThickness: Double
    /// The fillet radius for the inner bottom corners.
    public let innerBottomCornerRadius: Double
    /// Configuration options for this bin.
    public let options: Set<Option>

    /// Creates a new bin with the specified dimensions.
    /// - Parameters:
    ///   - size: The size in grid units (X, Y, and Z dimensions).
    ///   - wallThickness: The wall thickness in millimeters (default: 1.0mm).
    ///   - bottomThickness: The bottom thickness in millimeters (default: 0.6mm).
    ///   - innerBottomCornerRadius: The inner bottom corner fillet radius (default: 1.0mm).
    ///   - options: Configuration options for magnets and stacking lip.
    public init(
        size: Units3D,
        wallThickness: Double = 1.0,
        bottomThickness: Double = 0.6,
        innerBottomCornerRadius: Double = 1.0,
        options: Set<Option> = []
    ) {
        self.block = Block(
            size: Units2D(x: size.x, y: size.y),
            height: Double(size.z) * Units3D.size.z,
            magnetSlots: Set(options.compactMap(\.magnetPosition))
        )
        self.options = options
        self.wallThickness = wallThickness
        self.bottomThickness = bottomThickness
        self.innerBottomCornerRadius = innerBottomCornerRadius
    }

    public var body: any Geometry3D {
        block
            .projected { shell, outline in
                shell.subtracting {
                    outline
                        .offset(amount: -wallThickness, style: .round)
                        .extruded(height: shell.height, bottomEdge: .fillet(radius: innerBottomCornerRadius))
                        .translated(z: block.base.height + bottomThickness)
                }
                .adding {
                    if options.contains(.stackingLip) {
                        StackingLip(shape: outline)
                            .translated(z: shell.height)
                    }
                }
            }
    }

    /// Configuration options for bin features.
    public enum Option: Hashable, Sendable {
        /// Adds a stacking lip on top for nesting bins.
        ///
        /// The stacking lip allows bins to be stacked on top of each other.
        case stackingLip

        /// Adds slots for magnets in each grid cell of the bin's base.
        ///
        /// Magnet slots are 6.5mm in diameter and 2.2mm deep. The position parameter
        /// determines where slots are placed within each cell:
        /// - ``MagnetPosition/corners``: Four slots near the corners of each cell
        /// - ``MagnetPosition/centered``: A single slot in the center of each cell
        ///
        /// Multiple magnet options can be combined to have both corner and centered slots.
        case magnets (MagnetPosition)
    }
}

internal extension Bin.Option {
    var magnetPosition: MagnetPosition? {
        switch self {
        case .magnets (let position): return position
        default: return nil
        }
    }
}

extension Bin {
    // A lip profile that allows bins to stack on top of each other.
    struct StackingLip: Geometry3D {
        let shape: any Geometry2D

        var body: any Geometry3D {
            shape.readingOutlines { geometry, paths in
                if let path = paths.first {
                    let smallChamferDepth = 0.7
                    let largeChamferDepth = 1.9
                    let verticalPartLength = 1.8

                    let profile = BezierPath2D(mode: .relative) {
                        line(x: largeChamferDepth + smallChamferDepth, y: largeChamferDepth + smallChamferDepth)
                        line(x: -smallChamferDepth, y: smallChamferDepth)
                        line(y: verticalPartLength)
                        line(x: -largeChamferDepth, y: largeChamferDepth)
                        line(y: 0).absolute
                    }

                    Polygon(profile)
                        .swept(along: path, pointing: .negativeY, toward: .direction(.negativeZ))
                        .translated(z: -largeChamferDepth - smallChamferDepth)
                }
            }
        }
    }
}
