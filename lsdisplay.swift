import CoreGraphics

var displayIDs = [CGDirectDisplayID](repeating: 0, count: 16)
var displayCount: UInt32 = 0
CGGetOnlineDisplayList(16, &displayIDs, &displayCount)

guard displayCount > 1 else {
    print("single display")
    exit(0)
}

let mainDisplay = CGMainDisplayID()
guard let externalDisplay = displayIDs.first(where: { $0 != mainDisplay }) else {
    print("single display")
    exit(0)
}

// Check if external display is currently mirroring another display
let mirroredDisplay = CGDisplayMirrorsDisplay(externalDisplay)
if mirroredDisplay != kCGNullDirectDisplay {
    print("mirror")
    exit(0)
}

let mainBounds = CGDisplayBounds(mainDisplay)
let extBounds = CGDisplayBounds(externalDisplay)

let mainWidth = Int32(mainBounds.width)
let mainHeight = Int32(mainBounds.height)
let extWidth = Int32(extBounds.width)
let extHeight = Int32(extBounds.height)

let extX = Int32(extBounds.origin.x)
let extY = Int32(extBounds.origin.y)

// Determine direction and offset relative to main display origin (0,0)
if extX <= -extWidth {
    // Left side
    let offset = extY
    print(offset == 0 ? "left" : "left \(offset)")
} else if extX >= mainWidth {
    // Right side
    let offset = extY
    print(offset == 0 ? "right" : "right \(offset)")
} else if extY <= -extHeight {
    // Top side
    let offset = extX
    print(offset == 0 ? "top" : "top \(offset)")
} else if extY >= mainHeight {
    // Bottom side
    let offset = extX
    print(offset == 0 ? "bottom" : "bottom \(offset)")
} else {
    // Overlapping or unaligned layout
    print("custom (\(extX),\(extY))")
}
