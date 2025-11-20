import AudioToolbox
extension AudioController {
    func getDeviceName(deviceID: AudioDeviceID) -> String? {
        var deviceName: CFString? = nil
        var size = UInt32(MemoryLayout<CFString?>.size)

        var address = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyDeviceNameCFString,
            mScope: kAudioObjectPropertyScopeGlobal,
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

        if status == noErr, let name = deviceName as String? {
            return name
        }
        return nil
    }

    func getDeviceUID(deviceID: AudioDeviceID) -> String? {
        var deviceUID: CFString? = nil
        var size = UInt32(MemoryLayout<CFString?>.size)

        var address = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyDeviceUID,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        let status = AudioObjectGetPropertyData(
            deviceID,
            &address,
            0,
            nil,
            &size,
            &deviceUID
        )

        if status == noErr, let uid = deviceUID as String? {
            return uid
        }
        return nil
    }

    func getDeviceManufacturer(deviceID: AudioDeviceID) -> String? {
        var manufacturer: CFString? = nil
        var size = UInt32(MemoryLayout<CFString?>.size)

        var address = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyDeviceManufacturerCFString,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        let status = AudioObjectGetPropertyData(
            deviceID,
            &address,
            0,
            nil,
            &size,
            &manufacturer
        )

        if status == noErr, let mfg = manufacturer as String? {
            return mfg
        }
        return nil
    }
}
