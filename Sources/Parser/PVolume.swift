import ArgumentParser
struct Volume: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "volume",
        abstract: "Get or set volume level",
        subcommands: [Get.self, Set.self],
        defaultSubcommand: Get.self
    )
}

extension Volume {
    struct Get: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "get",
            abstract: "Get current volume level"
        )

        mutating func run() throws {
            let audioController = AudioController()
            if let volume = audioController.getVolume() {
                print(String(format: "%.2f", volume))
            } else {
                print("Error: Could not get volume")
                throw ExitCode.failure
            }
        }
    }
}

extension Volume {
    struct Set: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "set",
            abstract: "Set volume level (0.0 to 1.0)"
        )

        @Argument(help: "Volume level (0.0 to 1.0)")
        var level: Double

        mutating func run() throws {
            guard (0.0...1.0).contains(level) else {
                print("Error: Volume must be between 0.0 and 1.0")
                throw ExitCode.failure
            }

            let audioController = AudioController()
            if audioController.setVolume(Float(level)) {
                print("Volume set to \(String(format: "%.2f", level))")
            } else {
                print("Error: Could not set volume")
                throw ExitCode.failure
            }
        }
    }
}
