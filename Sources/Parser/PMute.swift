import ArgumentParser

// Mute subcommands
struct Mute: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "mute",
        abstract: "Get or set mute state",
        subcommands: [Get.self, Set.self],
        defaultSubcommand: Get.self
    )
}

extension Mute {
    struct Get: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "get",
            abstract: "Get current mute state"
        )

        mutating func run() throws {
            let audioController = AudioController()
            if let muted = audioController.getMute() {
                print(muted ? "on" : "off")
            } else {
                print("Error: Could not get mute state")
                throw ExitCode.failure
            }
        }
    }
}

extension Mute {
    struct Set: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "set",
            abstract: "Set mute state (on/off)"
        )

        @Argument(help: "Mute state: on or off")
        var state: MuteState

        mutating func run() throws {
            let audioController = AudioController()
            if audioController.setMute(state == .on) {
                print("Mute set to \(state.rawValue)")
            } else {
                print("Error: Could not set mute state")
                throw ExitCode.failure
            }
        }

        enum MuteState: String, CaseIterable, ExpressibleByArgument {
            case on, off
        }
    }
}
