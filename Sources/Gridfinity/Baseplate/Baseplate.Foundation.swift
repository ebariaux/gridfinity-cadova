import Cadova
import Helical

extension Baseplate {
    // The foundation layer with interlocking tabs and fastener holes.
    struct Foundation: Shape3D {
        let size: Units2D
        let shape: any Geometry2D
        let addMagnetSlots: Bool
        let addTabs: Bool
        let addScrewHoles: Bool
        let addCenterMagnetSlot: Bool


        static let bolt = Bolt.hexSocketCountersunk(.m3, length: 6)
        static let nut = Nut.square(.m3, series: .thin)

        var body: any Geometry3D {
            let height = Units3D.size.z
            let wallThickness = Socket().wallThickness
            let tab = Tab(height: height)

            let outline = shape.filled()
            let magnetInset = 8.0
            let magnetDiameter = 6.5
            let magnetDepth = 2.2
            let magnetMargin = 3.0

            shape
                .adding {
                    if addMagnetSlots {
                        Rectangle(magnetInset + magnetDiameter / 2 + magnetMargin)
                            .cuttingEdgeProfile(.fillet(radius: magnetDiameter / 2 + magnetMargin), on: .maxXmaxY)
                            .translated(x: -Units2D.size.x / 2, y: -Units2D.size.x / 2)
                            .symmetry(over: .xy)
                            .translated(x: Units2D.size.x / 2, y: Units2D.size.x / 2)
                            .repeated(along: .x, step: Units2D.size.x, count: size.x)
                            .repeated(along: .y, step: Units2D.size.y, count: size.y)
                            .intersecting { outline }
                    }
                    if addCenterMagnetSlot {
						Rectangle(Units2D.size.x)
							.subtracting {
								Rectangle( Units2D.size.x / 2 + 7 ) //width of the structs
									.cuttingEdgeProfile(.fillet(radius:  magnetDiameter / 2 + magnetMargin + 2.0), on: .maxXmaxY)
									.translated(x: -Units2D.size.x / 2 - 8, y: -Units2D.size.y / 2 - 8)
									.symmetry(over: .xy)
									.translated(x:  Units2D.size.x / 2 + 8, y:  Units2D.size.y / 2 + 8)
									.rotated(45°)
									.translated(x: 21,y: -20)
									
							}
						// Following snippet creates a support for the centermagnet in the form of a plus sign instead of a cross like above, 
						// doesn't work well when used together with screws  
//						Rectangle(Units2D.size.x)
//							.subtracting {
//								Rectangle( Units2D.size.x / 2 - 1.5) //width of the structs
//									.cuttingEdgeProfile(.fillet(radius:  magnetDiameter / 2 + magnetMargin + 2.0), on: .maxXmaxY)
//									.cuttingEdgeProfile(.fillet(radius:  magnetDiameter / 2 + magnetMargin + 2.0 ), on: .maxXminY)
//									.cuttingEdgeProfile(.fillet(radius:  magnetDiameter / 2 + magnetMargin + 2.0), on: .minXmaxY)
//									.translated(x: -Units2D.size.x / 2, y: -Units2D.size.y / 2)
//									.symmetry(over: .xy)
//									.translated(x:  Units2D.size.x / 2, y:  Units2D.size.y / 2)
//							}
							.repeated(along: .x, step: Units2D.size.x, count: size.x)
							.repeated(along: .y, step: Units2D.size.y, count: size.y)
							.intersecting { outline } // Doesn't seem to do anything here now, saw it reduce clipping when I had a misalignment so keeping it
					}
                }
                .rounded(insideRadius: addMagnetSlots ? 3 : nil)
                .extruded(height: height)
                .adding {
                    if addTabs {
                        tab.positivePair
                            .repeated(along: .x, step: Units2D.size.x, count: size.x)
                            .translated(y: Units2D.size.y * Double(size.y))

                        tab.positivePair
                            .rotated(z: 90°)
                            .repeated(along: .y, step: Units2D.size.y, count: size.y)
                    }
                }
                .subtracting {
                    if addMagnetSlots {
                        Cylinder(diameter: magnetDiameter, height: magnetDepth)
                            .translated(x: magnetInset, y: magnetInset, z: height - magnetDepth)
                            .translated(x: -Units2D.size.x / 2, y: -Units2D.size.x / 2)
                            .symmetry(over: .xy)
                            .translated(x: Units2D.size.x / 2, y: Units2D.size.x / 2)
                            .repeated(along: .x, step: Units2D.size.x, count: size.x)
                            .repeated(along: .y, step: Units2D.size.y, count: size.y)
                    }
                    if addCenterMagnetSlot {
						Cylinder(diameter: magnetDiameter, height: magnetDepth)
							.translated(x: -Units2D.size.x / 2, y: -Units2D.size.y / 2, z: height - magnetDepth  + 0.0000001) //getting weird bridge-strings on top of surface without +0.00001 (0.00000000000001 works too..)
							.symmetry(over: .xy)
							.repeated(along: .x, step: Units2D.size.x, count: size.x)
							.repeated(along: .y, step: Units2D.size.y, count: size.y);
					}

                    if addTabs {
                        tab.negativePair
                            .repeated(along: .x, step: Units2D.size.x, count: size.x)

                        tab.negativePair
                            .rotated(z: 90°)
                            .repeated(along: .y, step: Units2D.size.y, count: size.y)
                            .translated(x: Units2D.size.x * Double(size.x))
                    }

                    if addScrewHoles {
                        let clearanceHole = Self.bolt.clearanceHole(recessedHead: true)
                            .within(z: (-1)...)
                            .rotated(y: 90°)
                            .translated(x: 0.2 - wallThickness, z: height / 2)
                        
                        clearanceHole
                            .rotated(z: 180°)
                            .repeated(along: .y, step: Units2D.size.x, count: size.y)
                            .translated(y: Units2D.size.y / 2)
                        
                        clearanceHole
                            .rotated(z: 90°)
                            .repeated(along: .x, step: Units2D.size.x, count: size.x)
                            .translated(x: Units2D.size.x / 2, y: Units2D.size.y * Double(size.y))
                        
                        // Nut
                        let nutTrap = Self.nut.nutTrap(depthClearance: 1)
                            .translated(z: -1)
                            .adding {
                                ClearanceHole(diameter: Self.bolt.thread.majorDiameter, depth: wallThickness + 1, edgeProfile: nil)
                            }
                            .rotated(y: 90°)
                            .translated(z: height / 2)
                        
                        nutTrap
                            .repeated(along: .y, step: Units2D.size.y, count: size.y)
                            .translated(x: Units2D.size.x * Double(size.x) - wallThickness, y: Units2D.size.y / 2)
                        
                        nutTrap
                            .rotated(z: -90°)
                            .repeated(along: .x, step: Units2D.size.x, count: size.x)
                            .translated(x: Units2D.size.x / 2, y: wallThickness)
                    }
                }
                .withCircularOverhangMethod(.bridge)
        }
    }
}

extension Baseplate.Foundation {
    // An interlocking tab used to connect adjacent baseplate foundations.
    struct Tab: Shape2D {
        let height: Double

        private var shape: BezierPath2D {
            BezierPath(from: [-2.5, -0.5]) {
                curve(controlX: -0.5, controlY: 0, controlX: -0.5, controlY: 0.55, endX: -2, endY: 0.9)
                continuousCurve(distance: 1, controlX: -2.5, controlY: 2.0, endX: 0, endY: 2.0)
                line(y: -0.5)
            }
        }

        var body: any Geometry2D {
            Polygon(shape)
                .symmetry(over: .x)
        }

        @GeometryBuilder3D
        var positivePair: any Geometry3D {
            body
                .distributed(at: [Units2D.size.x * 0.25, Units2D.size.x * 0.75], along: .x)
                .extruded(height: height - 0.4)
        }

        @GeometryBuilder3D
        var negativePair: any Geometry3D {
            @Environment(\.tolerance) var tolerance
            body
                .distributed(at: [Units2D.size.x * 0.25, Units2D.size.x * 0.75], along: .x)
                .offset(amount: tolerance, style: .round)
                .translated(y: -0.1)
                .extruded(height: height)
        }
    }
}
