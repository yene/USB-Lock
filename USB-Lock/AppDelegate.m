#import "AppDelegate.h"
#import "SSKeychain.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	return;
	[self lockScreen];
	sleep(5);
	if ([self isLocked]) {
		[self wakeScreen];
		sleep(1);
		[self unlockScreen];
	}
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
	// Insert code here to tear down your application
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
						delay 3.0\n\
						keystroke return\n\
						end tell\n\
						end tell", password];
	
	NSAppleScript* scriptObject = [[NSAppleScript alloc] initWithSource:script];
	
	[scriptObject executeAndReturnError: &errorDict];
	NSLog(@"%@", errorDict);
}



@end
