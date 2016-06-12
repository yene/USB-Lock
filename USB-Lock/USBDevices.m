#import "USBDevices.h"
#include <IOKit/IOKitLib.h>
#include <IOKit/usb/IOUSBLib.h>

@implementation USBDevices

+ (void)debugDevices {
	
	CFMutableDictionaryRef matchingDict;
	io_iterator_t iter;
	kern_return_t kr;
	io_service_t device;
	
	/* set up a matching dictionary for the class */
	matchingDict = IOServiceMatching(kIOUSBDeviceClassName);
	if (matchingDict == NULL) {
		//return -1; // fail
	}
	
	/* Now we have a dictionary, get an iterator.*/
	kr = IOServiceGetMatchingServices(kIOMasterPortDefault, matchingDict, &iter);
	if (kr != KERN_SUCCESS) {
		//return -1;
	}
	
	while ((device = IOIteratorNext(iter))) {
		io_name_t devName;
		io_string_t pathName;
		
		IORegistryEntryGetName(device, devName);
		printf("Device's name = %s\n", devName);
		IORegistryEntryGetPath(device, kIOServicePlane, pathName);
		printf("Device's path in IOService plane = %s\n", pathName);
		IORegistryEntryGetPath(device, kIOUSBPlane, pathName);
		printf("Device's path in IOUSB plane = %s\n", pathName);
		
		
		io_name_t className;
		IOObjectGetClass(device, className);
		
		io_name_t deviceName;
		IORegistryEntryGetName( device, deviceName );
		
		
		IOObjectRelease(device);
	}
	
	/* Done, release the iterator */
	IOObjectRelease(iter);
}

// The following code will return an array having configured Ids and Name of all the mounted USB devices.
+ (NSArray *)deviceAttributes {
	mach_port_t masterPort;
	CFMutableDictionaryRef matchingDict;
	NSMutableArray *devicesAttributes = [NSMutableArray array];
	kern_return_t kr;
	
	// Create a master port for communication with the I/O Kit
	kr = IOMasterPort(MACH_PORT_NULL, &masterPort);
	if (kr || !masterPort) {
		NSLog(@"Error: Couldn't create a master I/O Kit port(%08x)", kr);
		return devicesAttributes;
	}
	
	// Set up matching dictionary for class IOUSBDevice and its subclasses
	matchingDict = IOServiceMatching(kIOUSBDeviceClassName);
	if (!matchingDict) {
		NSLog(@"Error: Couldn't create a USB matching dictionary");
		mach_port_deallocate(mach_task_self(), masterPort);
		return devicesAttributes;
	}
	io_iterator_t iterator;
	IOServiceGetMatchingServices(kIOMasterPortDefault, matchingDict, &iterator);
	io_service_t usbDevice;
	// Iterate for USB devices
	while ((usbDevice = IOIteratorNext(iterator))) {
		IOCFPlugInInterface **plugInInterface = NULL;
		SInt32 theScore;
		// Create an intermediate plug-in
		kr = IOCreatePlugInInterfaceForService(usbDevice, kIOUSBDeviceUserClientTypeID, kIOCFPlugInInterfaceID, &plugInInterface, &theScore);
		if ((kIOReturnSuccess != kr) || !plugInInterface) {
			printf("Unable to create a plug-in (%08x)\n", kr);
		}
		IOUSBDeviceInterface182 **dev = NULL;
		// Create the device interface
		HRESULT result = (*plugInInterface)->QueryInterface(plugInInterface, CFUUIDGetUUIDBytes(kIOUSBDeviceInterfaceID), (LPVOID)&dev);
		if (result || !dev) {
			printf("Couldn't create a device interface (%08x)\n", (int)result);
		}
		UInt16 vendorId;
		UInt16 productId;
		
		UInt16 releaseId;
		// Get configuration Ids of the device
		(*dev)->GetDeviceVendor(dev, &vendorId);
		(*dev)->GetDeviceProduct(dev, &productId);
		(*dev)->GetDeviceReleaseNumber(dev, &releaseId);
		UInt8 stringIndex;
		(*dev)->USBGetProductStringIndex(dev, &stringIndex);
		IOUSBConfigurationDescriptorPtr descriptor;
		(*dev)->GetConfigurationDescriptorPtr(dev, stringIndex, &descriptor);
		//Get Device name
		io_name_t deviceName;
		kr = IORegistryEntryGetName(usbDevice, deviceName);
		if (kr != KERN_SUCCESS) {
			NSLog(@"fail 0x%8x", kr);
			deviceName[0] = '\0';
		}
		
		NSString *name = [NSString stringWithCString:deviceName encoding:NSASCIIStringEncoding];
		// data will be initialized only for USB storage devices.
		// bsdName can be converted to mounted path of the device and vice-versa using DiskArbitration framework, hence we can identify the device through it's mounted path
		CFTypeRef data = IORegistryEntrySearchCFProperty(usbDevice, kIOServicePlane, CFSTR("BSD Name"), kCFAllocatorDefault, kIORegistryIterateRecursively);
		NSString *bsdName = [(__bridge NSString *)data substringToIndex:5];
		NSString *attributeString = @"";
		if (bsdName) {
			attributeString = [NSString stringWithFormat:@"%@,%@,0x%x,0x%x,0x%x", name, bsdName, vendorId, productId, releaseId];
		} else {
			attributeString = [NSString stringWithFormat:@"%@,0x%x,0x%x,0x%x", name, vendorId, productId, releaseId];
		}
		[devicesAttributes addObject:attributeString];
		IOObjectRelease(usbDevice);
		(*plugInInterface)->Release(plugInInterface);
		(*dev)->Release(dev);
	}
	
	//Finished with master port
	mach_port_deallocate(mach_task_self(), masterPort);
	masterPort = 0;
	return devicesAttributes;
}

@end
