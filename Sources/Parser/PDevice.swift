import ArgumentParser
import AudioToolbox
struct Device: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "device",
        abstract: "Get or set output device(s)",
        subcommands: [GetCurrent.self, Set.self, GetAll.self],
        defaultSubcommand: GetCurrent.self
    )
}

extension Device {
    struct GetCurrent: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "get",
            abstract: "Get the current output device",
        )

        mutating func run() throws {
            let audiocontroller = AudioController()
            if let device = audiocontroller.getCurrentDeviceName() {
                print(device)
            } else {
                print("Error: Could not get current device")
                throw ExitCode.failure
            }
        }
    }
}


extension Device {
    struct GetAll: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "list",
            abstract: "List all output devices"
        )

        mutating func run() throws {
            let audiocontroller = AudioController()
            audiocontroller.listOutputDevices()
        }
    }
}

extension Device {
    struct Set: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "set",
            abstract: "Set output device by name or ID"
        )

        @Argument(help: "Device name or ID")
        var device: String

        mutating func run() throws {
            let audioController = AudioController()
            var success = false
            var matchedDevice: (id: AudioDeviceID, name: String?)?

            // Try to parse as device ID first
            if let deviceID = AudioDeviceID(device) {

                // Verify this is a valid output device
                let outputDevices = audioController.getAllOutputDevices()
                if outputDevices.contains(deviceID) {
                    success = audioController.setDefaultOutputDevice(deviceID: deviceID)
                    matchedDevice = (deviceID, audioController.getDeviceName(deviceID: deviceID))
                } else {
                    print("Error: Device ID \(deviceID) is not a valid output device")
                    throw ExitCode.failure
                }
            } else {

                let outputDevices = audioController.getAllOutputDevices()
                var matches: [(AudioDeviceID, String)] = []

                for deviceID in outputDevices {
                    if let name = audioController.getDeviceName(deviceID: deviceID) {
                        if name == device {
                            matches.append((deviceID, name))
                        }
                    }
                }

                if matches.count == 1 {
                    success = audioController.setDefaultOutputDevice(deviceID: matches[0].0)
                    matchedDevice = (matches[0].0, matches[0].1)
                } else if matches.count > 1 {
                    print("Error: Multiple devices found with name '\(device)':")
                    for match in matches {
                        print("  - ID: \(match.0), Name: \(match.1)")
                    }
                    print("Use the device ID instead to specify which one to use.")
                    throw ExitCode.failure
                } else {
                    // No exact match, try partial matching
                    var partialMatches: [(AudioDeviceID, String)] = []

                    for deviceID in outputDevices {
                        if let name = audioController.getDeviceName(deviceID: deviceID),
                           name.localizedCaseInsensitiveContains(device) {
                            partialMatches.append((deviceID, name))
                        }
                    }

                    if partialMatches.count == 1 {
                        success = audioController.setDefaultOutputDevice(deviceID: partialMatches[0].0)
                        matchedDevice = (partialMatches[0].0, partialMatches[0].1)
                    } else if partialMatches.count > 1 {
                        print("Error: Multiple partial matches found for '\(device)':")
                        for match in partialMatches {
                            print("  - ID: \(match.0), Name: \(match.1)")
                        }
                        print("Use the exact device name or ID instead.")
                        throw ExitCode.failure
                    }
                }
            }

            if success, let matched = matchedDevice {
                print("Output device set to: \(matched.name ?? "Unknown") (ID: \(matched.id))")

                // Show new device info
                if let current = audioController.getCurrentOutputDevice() {
                    print("Current output device confirmed: \(current.name ?? "Unknown")")
                }
            } else {
                print("Error: Could not set output device '\(device)'")
                print("Available output devices:")

                let outputDevices = audioController.getAllOutputDevices()
                let currentDevice = audioController.getDefaultOutputDevice()

                for deviceID in outputDevices {
                    if let name = audioController.getDeviceName(deviceID: deviceID) {
                        let currentMarker = deviceID == currentDevice ? " [CURRENT]" : ""
                        print("  - \(deviceID): \(name)\(currentMarker)")
                    }
                }

                throw ExitCode.failure
            }
        }
    }
}
