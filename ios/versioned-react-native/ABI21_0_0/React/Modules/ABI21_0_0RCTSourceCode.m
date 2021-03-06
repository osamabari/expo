/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "ABI21_0_0RCTSourceCode.h"

#import "ABI21_0_0RCTBridge.h"

@implementation ABI21_0_0RCTSourceCode

ABI21_0_0RCT_EXPORT_MODULE()

@synthesize bridge = _bridge;

- (NSDictionary<NSString *, id> *)constantsToExport
{
  return @{
    @"scriptURL": self.bridge.bundleURL.absoluteString ?: @""
  };
}

@end
