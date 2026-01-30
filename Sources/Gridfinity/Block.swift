import Cadova

/// A solid Gridfinity block that fits into baseplate sockets.
///
/// A block consists of a grid of interconnected base units that form
/// the characteristic Gridfinity profile, allowing it to securely attach
/// to baseplates.
public struct Block: Shape3D {
    /// The size of the block in grid units.
    public let size: Units2D
    /// The total height of the block in millimeters.
    public let height: Double
    public let useMagnet: Bool
	public let useCenteredMagnet: Bool
	
    let base = Base()
    
	let magnetInset = 8.0
	let magnetDiameter = 6.5
	let magnetDepth = 2.2
	let magnetMargin = 3.0
    
    public init(size: Units2D, height: Double, withMagnet: Bool = false, withCenteredMagnet: Bool = false) {
        self.size = size
        self.height = height
        self.useMagnet = withMagnet
		self.useCenteredMagnet = withCenteredMagnet
    }

    public init(size: Units3D) {
        self.init(size: size.base, height: Double(size.z) * Units3D.size.z)
    }

    public var body: any Geometry3D {
        base
            .subtracting {
                if useMagnet {
                    Cylinder(diameter: magnetDiameter, height: magnetDepth)
                        .translated(x: magnetInset, y: magnetInset, z: 0)
                        .translated(x: -Units2D.size.x / 2, y: -Units2D.size.x / 2)
                        .symmetry(over: .xy)
                }
				if useCenteredMagnet {
					Cylinder(diameter: magnetDiameter, height: magnetDepth)
						.translated(x: -Units2D.size.x / 2 , y: Units2D.size.y / 2)
						.translated(x: Units2D.size.x / 2, y: -Units2D.size.x / 2)
						
				}
            }
            .repeated(along: .x, step: Units2D.size.x, count: size.x)
            .repeated(along: .y, step: Units2D.size.y, count: size.y)
            .measuringBounds { bases, bounds in
                Stack(.z) {
                    bases
                    bases
                        .projected()
                        .convexHull()
                        .extruded(height: height - bounds.maximum.z)
                }
            }
            .aligned(at: .minXY)
    }

    /// The 2D outline of the block's outer perimeter.
    public var outerShape: any Geometry2D {
        Polygon(base.outerShape)
            .repeated(along: .x, step: Units2D.size.x, count: size.x)
            .repeated(along: .y, step: Units2D.size.y, count: size.y)
            .convexHull()
            .aligned(at: .min)
    }

    // A single Gridfinity base unit with the characteristic interlocking profile.
    struct Base: Shape3D {
        private let cornerRadius = 3.75
        private let smallChamferDepth = 0.8
        private let largeChamferDepth = 2.15
        private let verticalPartLength = 1.8

        private var profile: BezierPath2D {
            BezierPath(mode: .relative) {
                line(x: cornerRadius - smallChamferDepth - largeChamferDepth - 0.1)
                line(x: smallChamferDepth, y: smallChamferDepth)
                line(y: verticalPartLength)
                line(x: largeChamferDepth, y: largeChamferDepth)
                line(x: 0).absolute
            }
        }

        var height: Double { smallChamferDepth + largeChamferDepth + verticalPartLength }

        var effectiveWidth: Double {
            let outerTolerance = 0.5
            return Units2D.size.x - outerTolerance
        }

        var outerShape: BezierPath2D {
            .roundedRectangle(size: Vector2D(effectiveWidth), cornerRadius: cornerRadius)
        }

        var body: any Geometry3D {
            Polygon(profile)
                .flipped(along: .x)
                .aligned(at: .minX)
                .swept(along: outerShape)

            Rectangle(effectiveWidth - 2 * cornerRadius + 0.3)
                .aligned(at: .center)
                .extruded(height: height)
        }
    }
}
