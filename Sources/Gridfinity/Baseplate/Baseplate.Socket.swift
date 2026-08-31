import Cadova
import Helical

extension Baseplate {
    // A socket cavity that accepts Gridfinity block base units.
    struct Socket: Geometry3D {
        let cornerRadius = 4.0
        var height: Double { wallThickness + verticalPartLength }
        var wallThickness: Double { smallChamferDepth + largeChamferDepth }

        private let smallChamferDepth = 0.7
        private let largeChamferDepth = 2.15
        private let verticalPartLength = 1.8

        private var profile: BezierPath2D {
            BezierPath(mode: .relative) {
                line(x: smallChamferDepth, y: smallChamferDepth)
                line(y: verticalPartLength)
                line(x: largeChamferDepth, y: largeChamferDepth)
                line(y: 0.001)
                line(x: -cornerRadius + 0.1)
                line(y: 0).absolute
            }
        }

        var body: any Geometry3D {
            Polygon(profile)
                .aligned(at: .maxX)
                .flipped(along: .x)
                .swept(along: BezierPath.roundedRectangle(size: Units2D.size, cornerRadius: cornerRadius), pointing: .negativeY, toward: .direction(.negativeZ))
                .simplified()
                .adding {
                    Rectangle(Units2D.size.x - cornerRadius * 2 + 0.3)
                        .aligned(at: .center)
                        .extruded(height: height)
                }
                .aligned(at: .minXY)
        }
    }
}
