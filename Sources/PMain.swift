import ArgumentParser
import AudioToolbox

@main
struct AudioCtl: ParsableCommand {
    static let configuration = CommandConfiguration(
            commandName: "audioctl",
            abstract: "Control system audio settings",
            subcommands: [Volume.self, Mute.self, Device.self],
            defaultSubcommand: Volume.self
    )
}
