// Deprecated APIs for backwards compatibility with 1.0.0

public extension Block {
    @available(*, deprecated, message: "Use init(size:height:magnetSlots:) instead")
    init(size: Units2D, height: Double, withMagnet: Bool) {
        self.init(size: size, height: height, magnetSlots: withMagnet ? [.corners] : [])
    }
}

public extension Bin {
    @available(*, deprecated, message: "Use init(size:wallThickness:bottomThickness:innerBottomCornerRadius:options:) instead")
    init(
        size: Units3D,
        wallThickness: Double = 1.0,
        bottomThickness: Double = 0.6,
        innerBottomCornerRadius: Double = 1.0,
        withStackingLip: Bool = false,
        withMagnet: Bool = false
    ) {
        var opts = Set<Option>()
        if withStackingLip { opts.insert(.stackingLip) }
        if withMagnet { opts.insert(.magnets(.corners)) }
        self.init(
            size: size,
            wallThickness: wallThickness,
            bottomThickness: bottomThickness,
            innerBottomCornerRadius: innerBottomCornerRadius,
            options: opts
        )
    }
}

public extension Baseplate.Option {
    @available(*, deprecated, renamed: "magnets(_:)", message: "Use .magnets(.corners) instead")
    static var magnets: Baseplate.Option { .magnets(.corners) }
}
