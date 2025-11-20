import AudioToolbox
extension AudioController {
    func setVolume(_ volume: Float) -> Bool {
        guard let deviceId = getDefaultOutputDevice() else { return false }
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwareServiceDeviceProperty_VirtualMainVolume,
            mScope: kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain
        )

        var canSetVolume: DarwinBoolean = false
        var size = UInt32(MemoryLayout<Bool>.size)
        var status = AudioObjectIsPropertySettable(deviceId, &address, &canSetVolume)
        guard status == noErr && canSetVolume.boolValue else { return false }

        var vol = max(0.0, min(1.0, volume))  // Clamp to 0.0-1.0
        size = UInt32(MemoryLayout<Float>.size)
        status = AudioObjectSetPropertyData(
            deviceId,
            &address,
            0,
            nil,
            size,
            &vol
        )

        return status == noErr
    }

    func getVolume() -> Float? {
        guard let deviceID = getDefaultOutputDevice() else { return nil }

        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwareServiceDeviceProperty_VirtualMainVolume,
             mScope: kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain
        )

        var volume: Float = 0.0
        var size = UInt32(MemoryLayout<Float>.size)
        let status = AudioObjectGetPropertyData(
            deviceID,
            &address,
            0,
            nil,
            &size,
            &volume
        )

        return status == noErr ? volume : nil
    }

    func getVolumeForDevice(deviceID: AudioDeviceID) -> Float? {
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwareServiceDeviceProperty_VirtualMainVolume,
            mScope: kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain
        )

        var canGetVolume: DarwinBoolean = false
        var size = UInt32(MemoryLayout<Bool>.size)
        var status = AudioObjectIsPropertySettable(deviceID, &address, &canGetVolume)

        guard status == noErr && canGetVolume.boolValue else { return nil }

        var volume: Float = 0.0
        size = UInt32(MemoryLayout<Float>.size)
        status = AudioObjectGetPropertyData(
            deviceID,
            &address,
            0,
            nil,
            &size,
            &volume
        )

        return status == noErr ? volume : nil
    }
}
