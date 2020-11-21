//
//  getenvhook.c
//  HOOKingC
//
//  Created by 李玉 on 2020/11/20.
//  Copyright © 2020 LYfinacial.com. All rights reserved.
//

#include "getenvhook.h"
#import <dlfcn.h>
#import <assert.h>
#import <stdio.h>
#import <dispatch/dispatch.h>
#import <string.h>

//#define RTLD_LAZY    0x1
//#define RTLD_NOW    0x2
//#define RTLD_LOCAL    0x4
//#define RTLD_GLOBAL    0x8


char * getenv(const char *name) {
  static void *handle;      // 1
  static char * (*real_getenv)(const char *); // 2

  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{  // 3
    handle = dlopen("/usr/lib/system/libsystem_c.dylib",
                    RTLD_NOW);
    assert(handle);
    real_getenv = dlsym(handle, "getenv");
  });

  if (strcmp(name, "HOME") == 0) { // 4
    return "/WOOT";
  }

  return real_getenv(name); // 5
}
