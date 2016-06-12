#import "AppDelegate.h"
#import "SSKeychain.h"
#import "USBDevices.h"

@interface AppDelegate () {
	BOOL oldState;
}

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	oldState = NO;
	[NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(check) userInfo:nil repeats:YES];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
	// Insert code here to tear down your application
}

- (void)check {
	if ([[NSUserDefaults standardUserDefaults] stringForKey:@"device"] == nil) {
		return;
	}
	
	BOOL currentState = [self isPlugged];
	if (oldState == currentState) {
		return;
	}
	
	if (currentState) {
		if ([self isLocked]) {
			[self wakeScreen];
			sleep(1);
			[self unlockScreen];
		}
	} else {
		[self lockScreen];
	}
	
	oldState = currentState;
}

- (BOOL)isPlugged {
	BOOL deviceFound = NO;
	NSString *search = [[NSUserDefaults standardUserDefaults] stringForKey:@"device"];
	NSArray *devices = [USBDevices deviceAttributes];
	for (NSString *device in devices) {
		if ([search isEqualToString:device]) {
			deviceFound = YES;
			break;
		}
	}
	return deviceFound;
}

- (BOOL)isLocked {
	NSDictionary *dict = (NSDictionary *)CFBridgingRelease(CGSessionCopyCurrentDictionary());
	NSNumber *l =  [dict objectForKey:@"CGSSessionScreenIsLocked"];
	return [l boolValue];
}

- (void)lockScreen {
	// http://apple.stackexchange.com/a/123738
	NSBundle *bundle = [NSBundle bundleWithPath:@"/Applications/Utilities/Keychain Access.app/Contents/Resources/Keychain.menu"];
	Class principalClass = [bundle principalClass];
	id instance = [[principalClass alloc] init];
	[instance performSelector:@selector(_lockScreenMenuHit:) withObject:nil];
}

- (void)wakeScreen {
	// 	caffeinate -u -t 1
	NSTask *task = [[NSTask alloc] init];
	task.launchPath = @"/usr/bin/caffeinate";
	task.arguments = @[@"-u", @"-t 2"];
	
	[task launch];
}

- (void)unlockScreen {
	NSDictionary* errorDict;
	NSString *password = [SSKeychain passwordForService:@"loginPassword" account:@"USB-Lock"];
	NSString *script = [NSString stringWithFormat:@"\
						tell application \"System Events\"\n\
						tell application process \"loginwindow\"\n\
						keystroke \"%@\"\n\
						delay 1.5\n\
						keystroke return\n\
						end tell\n\
						end tell", password];
	
	NSAppleScript* scriptObject = [[NSAppleScript alloc] initWithSource:script];
	
	[scriptObject executeAndReturnError: &errorDict];
	NSLog(@"%@", errorDict);
}



@end
