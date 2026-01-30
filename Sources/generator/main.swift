import Foundation
import Cadova
import Gridfinity

await Project(packageRelative: "Models") {
    Metadata(
        title: "Gridfinity Cadova",
        description: "Parametric Gridfinity models and baseplates",
        author: "Tomas Wincent Franzén",
        license: "MIT"
    )
    Environment {
        $0.tolerance = 0.2
    }

    // MARK: - Bins
    await Model("Bin 1x1x2") {
        Bin(size: Units3D(x: 1, y: 1, z: 2), options: [.stackingLip])
    }

    await Model("Bin 2x2x3") {
        Bin(size: Units3D(x: 2, y: 2, z: 3), options: [.stackingLip])
    }

    await Model("Bin 3x3x4") {
        Bin(size: Units3D(x: 3, y: 3, z: 4), options: [.stackingLip])
    }

    await Model("Bin 4x5x3") {
        Bin(size: Units3D(x: 4, y: 5, z: 3), options: [.stackingLip])
    }

    // MARK: - Baseplates

    await Model("Baseplate 3x3") {
        Baseplate(size: Units2D(x: 3, y: 3), options: [.foundation, .tabs, .screws])
    }

    await Model("Baseplate 6x4") {
        Baseplate(size: Units2D(x: 6, y: 4), options: [.foundation, .tabs, .screws])
    }

    // MARK: - Baseplate Sets

    await Model("Baseplate set for drawer") {
        // Drawer interior: 508 mm x 332 mm
        BaseplateSet(footprint: [508, 332], printbedSize: [256, 256])
    }
}
