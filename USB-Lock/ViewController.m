#import "ViewController.h"
#import "SSKeychain.h"
#import "USBDevices.h"


@implementation ViewController

- (IBAction)done:(id)sender {
	[SSKeychain setPassword:self.password.stringValue forService:@"loginPassword" account:@"USB-Lock"];
	[[NSUserDefaults standardUserDefaults] setObject:self.usb.selectedItem.title forKey:@"device"];
	
	NSWindow *window = [[NSApplication sharedApplication] keyWindow];
	[window performClose:sender];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	[self listUSBDevices];
	self.password.stringValue = [SSKeychain passwordForService:@"loginPassword" account:@"USB-Lock"];
}

- (void)setRepresentedObject:(id)representedObject {
	[super setRepresentedObject:representedObject];
}

- (void)listUSBDevices {
	NSArray *devices = [USBDevices deviceAttributes];
	[self.usb addItemsWithTitles:devices];
}

@end
