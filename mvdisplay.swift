import CoreGraphics

// Usage: mvdisplay <left|right|top|bottom|mirror> [offset]
let args = CommandLine.arguments
guard args.count > 1 else {
    print("Usage: mvdisplay <left|right|top|bottom|mirror> [offset]")
    exit(1)
}

let direction = args[1].lowercased()
let offset: Int32 = args.count > 2 ? Int32(args[2]) ?? 0 : 0

var displayIDs = [CGDirectDisplayID](repeating: 0, count: 16)
var displayCount: UInt32 = 0
CGGetOnlineDisplayList(16, &displayIDs, &displayCount)

guard displayCount > 1 else {
    print("Error: Only one screen detected.")
    exit(1)
}

let mainDisplay = CGMainDisplayID()
guard let externalDisplay = displayIDs.first(where: { $0 != mainDisplay }) else {
    print("Error: External display not found.")
    exit(1)
}

var config: CGDisplayConfigRef?
CGBeginDisplayConfiguration(&config)

if direction == "mirror" {
    // Mirror external display to main display
    CGConfigureDisplayMirrorOfDisplay(config, externalDisplay, mainDisplay)
    print("Secondary display set to mirror primary display.")
} else {
    // Un-mirror secondary display if currently mirrored
    CGConfigureDisplayMirrorOfDisplay(config, externalDisplay, kCGNullDirectDisplay)

    let mainWidth = Int32(CGDisplayPixelsWide(mainDisplay))
    let mainHeight = Int32(CGDisplayPixelsHigh(mainDisplay))
    let extWidth = Int32(CGDisplayPixelsWide(externalDisplay))
    let extHeight = Int32(CGDisplayPixelsHigh(externalDisplay))

    var targetX: Int32 = 0
    var targetY: Int32 = 0

    switch direction {
    case "left":
        targetX = -extWidth
        targetY = offset // Negative moves UP, Positive moves DOWN
    case "right":
        targetX = mainWidth
        targetY = offset // Negative moves UP, Positive moves DOWN
    case "top":
        targetX = offset // Negative moves LEFT, Positive moves RIGHT
        targetY = -extHeight
    case "bottom":
        targetX = offset // Negative moves LEFT, Positive moves RIGHT
        targetY = mainHeight
    default:
        print("Invalid direction. Use: left, right, top, bottom, or mirror.")
        exit(1)
    }

    CGConfigureDisplayOrigin(config, externalDisplay, targetX, targetY)
    print("Secondary display set to \(direction) with offset \(offset).")
}

CGCompleteDisplayConfiguration(config, .permanently)
