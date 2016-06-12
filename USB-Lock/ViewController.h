//
//  ViewController.h
//  USB-Lock
//
//  Created by Yannick Weiss on 11/06/16.
//  Copyright © 2016 Yannick Weiss. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController
@property (weak) IBOutlet NSSecureTextField *password;
@property (weak) IBOutlet NSPopUpButton *usb;


@end

