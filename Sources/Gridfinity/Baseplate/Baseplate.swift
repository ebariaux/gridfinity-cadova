import Cadova
import Helical

/// A Gridfinity baseplate that provides sockets for blocks and trays.
///
/// Baseplates form the foundation of a Gridfinity storage system. They feature
/// a grid of sockets that blocks snap into, and can optionally include an
/// interlocking foundation layer for connecting multiple baseplates together.
public struct Baseplate: Shape3D {
    let size: Units2D
    let options: Set<Option>

    public init(size: Units2D, options: Set<Option> = []) {
        self.size = size
        self.options = options
    }

    private var needsFoundation: Bool {
        options.contains(where: \.requiresFoundation)
    }

    public var body: any Geometry3D {
        let socket = Socket()
        let socketLayer = Rectangle(x: Double(size.x) * Units2D.size.x, y: Double(size.y) * Units2D.size.y)
            .extruded(height: socket.height - 0.4)
            .subtracting {
                socket
                    .repeated(along: .x, spacing: 0, count: size.x)
                    .repeated(along: .y, spacing: 0, count: size.y)
            }

        Stack(.z) {
            if needsFoundation {
                Foundation(
                    size: size,
                    shape: socketLayer.projected(),
                    magnetSlots: Set(options.compactMap(\.magnetPosition)),
                    addTabs: options.contains(.tabs),
                    addScrewHoles: options.contains(.screws)
                )
            }
            socketLayer
        }
    }

    /// Configuration options for baseplate features.
    ///
    /// Options can be combined freely. Note that ``tabs``, ``screws``, and ``magnets``
    /// all implicitly enable the foundation layer since they require it.
    public enum Option: Hashable, Sendable {
        /// Adds a foundation layer beneath the socket layer.
        ///
        /// The foundation is a solid 7mm tall base. Use this when you want the extra
        /// height but don't need tabs, screws, or magnets.
        case foundation

        /// Adds interlocking tabs for connecting adjacent baseplates.
        ///
        /// Tabs are placed on the top and left edges (positive), with matching
        /// negative slots on the bottom and right edges. This allows baseplates
        /// to snap together. Implicitly enables the foundation layer.
        case tabs

        /// Adds M3 screw holes and nut traps for secure fastening.
        ///
        /// Countersunk clearance holes are placed on the bottom and left edges,
        /// with square nut traps on the top and right edges. Use M3x6 countersunk
        /// bolts with thin square nuts. Implicitly enables the foundation layer.
        case screws

        /// Adds slots for magnets in each grid cell.
        ///
        /// Magnet slots are 6.5mm in diameter and 2.2mm deep. The position parameter
        /// determines where slots are placed within each cell:
        /// - ``MagnetPosition/corners``: Four slots near the corners of each cell
        /// - ``MagnetPosition/centered``: A single slot in the center of each cell
        ///
        /// Multiple magnet options can be combined to have both corner and centered slots.
        /// Implicitly enables the foundation layer.
        case magnets (MagnetPosition)
    }
}

internal extension Baseplate.Option {
    var magnetPosition: MagnetPosition? {
        switch self {
        case .magnets (let position): return position
        default: return nil
        }
    }

    var requiresFoundation: Bool {
        switch self {
        case .foundation, .tabs, .screws, .magnets: return true
        }
    }
}
