# USB-Lock
🔒 Lock/Unlock your Mac based on USB device.

## Security
Don't use this app to secure your computer. 🔥🔥🔥

## TODO
- [ ] Use USB serial to identify devices
- [ ] Observe USB mount/unmount with low level API
- [ ] open preference window only when not configured, else over menu

## Notes and Material
* Command to list all USB devices: `ioreg -Src IOUSBDevice`
* http://stackoverflow.com/a/7569013/279890
* https://github.com/armadsen/ORSSerialPort/blob/master/Source/ORSSerialPortManager.m#L220
* http://oroboro.com/usb-serial-number-osx/
* https://developer.apple.com/library/mac/documentation/DeviceDrivers/Conceptual/AccessingHardware/AH_IOKitLib_API/AH_IOKitLib_API.html
* http://stackoverflow.com/questions/17305260/objective-c-c-detect-usb-drive-via-iokit-only-on-mac
* http://stackoverflow.com/questions/7567872/how-to-create-a-program-to-list-all-the-usb-devices-in-a-mac