import AudioToolbox
extension AudioController {
    func getDefaultOutputDevice() -> AudioDeviceID? {
        var deviceID: AudioDeviceID = 0
        var size = UInt32(MemoryLayout<AudioDeviceID>.size)
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultOutputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        let status = AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &address,
            0,
            nil,
            &size,
            &deviceID
        )

        return status == noErr ? deviceID : nil
    }

    func getCurrentDeviceName() -> String? {
        guard let deviceID = getDefaultOutputDevice() else { return nil }

        var deviceName: CFString? = nil
        var size = UInt32(MemoryLayout<CFString>.size)

        var address = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyDeviceNameCFString,
            mScope: kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain
        )

        let status = AudioObjectGetPropertyData(
            deviceID,
            &address,
            0,
            nil,
            &size,
            &deviceName
        )

        return status == noErr ? deviceName as String? : nil
    }

    func getAllAudioDevices() -> [AudioDeviceID] {
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDevices,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        var size: UInt32 = 0
        let status = AudioObjectGetPropertyDataSize(
            AudioObjectID(kAudioObjectSystemObject),
            &address,
            0,
            nil,
            &size
        )

        guard status == noErr else { return [] }

        let deviceCount = Int(size) / MemoryLayout<AudioDeviceID>.size
        var deviceIDs = [AudioDeviceID](repeating: 0, count: deviceCount)

        AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &address,
            0,
            nil,
            &size,
            &deviceIDs
        )

        return deviceIDs
    }

    func getAllOutputDevices() -> [AudioDeviceID] {
        let allDevices = getAllAudioDevices()
        return allDevices.filter { isOutputDevice(deviceID: $0) }
    }

    // Check if a device is an output device
    private func isOutputDevice(deviceID: AudioDeviceID) -> Bool {
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyStreams,
            mScope: kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain
        )

        var size: UInt32 = 0
        let status = AudioObjectGetPropertyDataSize(deviceID, &address, 0, nil, &size)
        return status == noErr && size > 0
    }

    func getCurrentOutputDevice() -> (id: AudioDeviceID, name: String?)? {
        guard let deviceID = getDefaultOutputDevice() else { return nil }
        let name = getDeviceName(deviceID: deviceID)
        return (deviceID, name)
    }

    // List all output devices with details
    func listOutputDevices() {
        let outputDevices = getAllOutputDevices()
        let currentDevice = getDefaultOutputDevice()

        print("Output Devices (\(outputDevices.count) found):")
        print("==========================================")

        for deviceID in outputDevices {
            if let name = getDeviceName(deviceID: deviceID),
               let uid = getDeviceUID(deviceID: deviceID) {

                let isCurrent = deviceID == currentDevice
                let currentMarker = isCurrent ? " [CURRENT]" : ""

                print("\(deviceID): \(name)\(currentMarker)")
                print("  UID: \(uid)")

                if let manufacturer = getDeviceManufacturer(deviceID: deviceID) {
                    print("  Manufacturer: \(manufacturer)")
                }

                // Get volume info if available
                if let volume = getVolumeForDevice(deviceID: deviceID) {
                    print("  Volume: \(String(format: "%.0f%%", volume * 100))")
                }

                if let muted = getMuteForDevice(deviceID: deviceID) {
                    print("  Muted: \(muted ? "Yes" : "No")")
                }
                print()
            }
        }
    }
}
