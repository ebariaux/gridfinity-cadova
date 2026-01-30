import Cadova

/// A hollow Gridfinity storage container for organizing items.
///
/// A bin is created by hollowing out a block, leaving walls of configurable
/// thickness. Bins can optionally include a stacking lip that allows them
/// to be stacked on top of each other without a baseplate.
public struct Bin: Shape3D {
    /// The underlying block that defines the bin's outer dimensions.
    public let block: Block
    /// The thickness of the bin walls in millimeters.
    public let wallThickness: Double
    /// The thickness of the bin bottom in millimeters.
    public let bottomThickness: Double
    /// The fillet radius for the inner bottom corners.
    public let innerBottomCornerRadius: Double
    /// Whether to include a stacking lip on top for nesting bins.
    public let useStackingLip: Bool

    /// Creates a new bin with the specified dimensions.
    /// - Parameters:
    ///   - size: The size in grid units (X, Y, and Z dimensions).
    ///   - wallThickness: The wall thickness in millimeters (default: 1.0mm).
    ///   - bottomThickness: The bottom thickness in millimeters (default: 0.6mm).
    ///   - innerBottomCornerRadius: The inner bottom corner fillet radius (default: 1.0mm).
    ///   - withStackingLip: Whether to add a stacking lip for nesting.
    ///   - withMagnet: Add magnet slots to the bottom of the corners of the bin
    ///   - withCenteredMagnet: Add magnet slot in the center of the bottom of the bin
    public init(
        size: Units3D,
        wallThickness: Double = 1.0,
        bottomThickness: Double = 0.6,
        innerBottomCornerRadius: Double = 1.0,
        withStackingLip: Bool = false,
        withMagnet: Bool = false
  		withCenteredMagnet: Bool = false

    ) {
        self.block = Block(size: Units2D(x: size.x, y: size.y), height: Double(size.z) * Units3D.size.z, withMagnet: withMagnet,withCenteredMagnet: withCenteredMagnet)
        self.useStackingLip = withStackingLip
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
                    if useStackingLip {
                        StackingLip(shape: outline)
                            .translated(z: shell.height)
                    }
                }
            }
    }
}

extension Bin {
    // A lip profile that allows bins to stack on top of each other.
    struct StackingLip: Shape3D {
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
                        .swept(along: path)
                        .translated(z: -largeChamferDepth - smallChamferDepth)
                }
            }
        }
    }
}
