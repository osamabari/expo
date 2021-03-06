/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "ABI18_0_0RCTAlertManager.h"

#import "ABI18_0_0RCTAssert.h"
#import "ABI18_0_0RCTConvert.h"
#import "ABI18_0_0RCTLog.h"
#import "ABI18_0_0RCTUtils.h"

@implementation ABI18_0_0RCTConvert (UIAlertViewStyle)

ABI18_0_0RCT_ENUM_CONVERTER(ABI18_0_0RCTAlertViewStyle, (@{
  @"default": @(ABI18_0_0RCTAlertViewStyleDefault),
  @"secure-text": @(ABI18_0_0RCTAlertViewStyleSecureTextInput),
  @"plain-text": @(ABI18_0_0RCTAlertViewStylePlainTextInput),
  @"login-password": @(ABI18_0_0RCTAlertViewStyleLoginAndPasswordInput),
}), ABI18_0_0RCTAlertViewStyleDefault, integerValue)

@end

@interface ABI18_0_0RCTAlertManager()

@end

@implementation ABI18_0_0RCTAlertManager
{
  NSHashTable *_alertControllers;
}

ABI18_0_0RCT_EXPORT_MODULE()

- (dispatch_queue_t)methodQueue
{
  return dispatch_get_main_queue();
}

- (void)invalidate
{
  for (UIAlertController *alertController in _alertControllers) {
    [alertController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
  }
}

/**
 * @param {NSDictionary} args Dictionary of the form
 *
 *   @{
 *     @"message": @"<Alert message>",
 *     @"buttons": @[
 *       @{@"<key1>": @"<title1>"},
 *       @{@"<key2>": @"<title2>"},
 *     ],
 *     @"cancelButtonKey": @"<key2>",
 *   }
 * The key from the `buttons` dictionary is passed back in the callback on click.
 * Buttons are displayed in the order they are specified.
 */
ABI18_0_0RCT_EXPORT_METHOD(alertWithArgs:(NSDictionary *)args
                  callback:(ABI18_0_0RCTResponseSenderBlock)callback)
{
  NSString *title = [ABI18_0_0RCTConvert NSString:args[@"title"]];
  NSString *message = [ABI18_0_0RCTConvert NSString:args[@"message"]];
  ABI18_0_0RCTAlertViewStyle type = [ABI18_0_0RCTConvert ABI18_0_0RCTAlertViewStyle:args[@"type"]];
  NSArray<NSDictionary *> *buttons = [ABI18_0_0RCTConvert NSDictionaryArray:args[@"buttons"]];
  NSString *defaultValue = [ABI18_0_0RCTConvert NSString:args[@"defaultValue"]];
  NSString *cancelButtonKey = [ABI18_0_0RCTConvert NSString:args[@"cancelButtonKey"]];
  NSString *destructiveButtonKey = [ABI18_0_0RCTConvert NSString:args[@"destructiveButtonKey"]];
  UIKeyboardType keyboardType = [ABI18_0_0RCTConvert UIKeyboardType:args[@"keyboardType"]];

  if (!title && !message) {
    ABI18_0_0RCTLogError(@"Must specify either an alert title, or message, or both");
    return;
  }

  if (buttons.count == 0) {
    if (type == ABI18_0_0RCTAlertViewStyleDefault) {
      buttons = @[@{@"0": ABI18_0_0RCTUIKitLocalizedString(@"OK")}];
      cancelButtonKey = @"0";
    } else {
      buttons = @[
        @{@"0": ABI18_0_0RCTUIKitLocalizedString(@"OK")},
        @{@"1": ABI18_0_0RCTUIKitLocalizedString(@"Cancel")},
      ];
      cancelButtonKey = @"1";
    }
  }

  UIViewController *presentingController = ABI18_0_0RCTPresentedViewController();
  if (presentingController == nil) {
    ABI18_0_0RCTLogError(@"Tried to display alert view but there is no application window. args: %@", args);
    return;
  }

  UIAlertController *alertController = [UIAlertController
                                        alertControllerWithTitle:title
                                        message:nil
                                        preferredStyle:UIAlertControllerStyleAlert];
  switch (type) {
    case ABI18_0_0RCTAlertViewStylePlainTextInput: {
      [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.secureTextEntry = NO;
        textField.text = defaultValue;
        textField.keyboardType = keyboardType;
      }];
      break;
    }
    case ABI18_0_0RCTAlertViewStyleSecureTextInput: {
      [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = ABI18_0_0RCTUIKitLocalizedString(@"Password");
        textField.secureTextEntry = YES;
        textField.text = defaultValue;
        textField.keyboardType = keyboardType;
      }];
      break;
    }
    case ABI18_0_0RCTAlertViewStyleLoginAndPasswordInput: {
      [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = ABI18_0_0RCTUIKitLocalizedString(@"Login");
        textField.text = defaultValue;
        textField.keyboardType = keyboardType;
      }];
      [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = ABI18_0_0RCTUIKitLocalizedString(@"Password");
        textField.secureTextEntry = YES;
      }];
      break;
    }
    case ABI18_0_0RCTAlertViewStyleDefault:
      break;
  }

  alertController.message = message;

  for (NSDictionary<NSString *, id> *button in buttons) {
    if (button.count != 1) {
      ABI18_0_0RCTLogError(@"Button definitions should have exactly one key.");
    }
    NSString *buttonKey = button.allKeys.firstObject;
    NSString *buttonTitle = [ABI18_0_0RCTConvert NSString:button[buttonKey]];
    UIAlertActionStyle buttonStyle = UIAlertActionStyleDefault;
    if ([buttonKey isEqualToString:cancelButtonKey]) {
      buttonStyle = UIAlertActionStyleCancel;
    } else if ([buttonKey isEqualToString:destructiveButtonKey]) {
      buttonStyle = UIAlertActionStyleDestructive;
    }
    __weak UIAlertController *weakAlertController = alertController;
    [alertController addAction:[UIAlertAction actionWithTitle:buttonTitle
                                                        style:buttonStyle
                                                      handler:^(__unused UIAlertAction *action) {
      switch (type) {
        case ABI18_0_0RCTAlertViewStylePlainTextInput:
        case ABI18_0_0RCTAlertViewStyleSecureTextInput:
          callback(@[buttonKey, [weakAlertController.textFields.firstObject text]]);
          break;
        case ABI18_0_0RCTAlertViewStyleLoginAndPasswordInput: {
          NSDictionary<NSString *, NSString *> *loginCredentials = @{
            @"login": [weakAlertController.textFields.firstObject text],
            @"password": [weakAlertController.textFields.lastObject text]
          };
          callback(@[buttonKey, loginCredentials]);
          break;
        }
        case ABI18_0_0RCTAlertViewStyleDefault:
          callback(@[buttonKey]);
          break;
      }
    }]];
  }

  if (!_alertControllers) {
    _alertControllers = [NSHashTable weakObjectsHashTable];
  }
  [_alertControllers addObject:alertController];

  [presentingController presentViewController:alertController animated:YES completion:nil];
}

@end
