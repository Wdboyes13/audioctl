import AudioToolbox
extension AudioController {
    func setDefaultOutputDevice(deviceID: AudioDeviceID) -> Bool {
        var newDeviceID = deviceID
        let size = UInt32(MemoryLayout<AudioDeviceID>.size)

        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultOutputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        let status = AudioObjectSetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &address,
            0,
            nil,
            size,
            &newDeviceID
        )

        return status == noErr
    }

    func setDefaultOutputDeviceByName(_ name: String) -> Bool {
        let outputDevices = getAllOutputDevices()

        for deviceID in outputDevices {
            if let deviceName = getDeviceName(deviceID: deviceID),
               deviceName == name {
                return setDefaultOutputDevice(deviceID: deviceID)
            }
        }

        return false
    }

    // Set default output device by UID
    func setDefaultOutputDeviceByUID(_ uid: String) -> Bool {
        let outputDevices = getAllOutputDevices()

        for deviceID in outputDevices {
            if let deviceUID = getDeviceUID(deviceID: deviceID),
               deviceUID == uid {
                return setDefaultOutputDevice(deviceID: deviceID)
            }
        }

        return false
    }
}
