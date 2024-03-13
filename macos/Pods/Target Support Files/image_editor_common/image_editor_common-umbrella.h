#ifdef __OBJC__
#import <Cocoa/Cocoa.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "FICommonUtils.h"
#import "FIConvertUtils.h"
#import "FIEPlugin.h"
#import "FIImport.h"
#import "FIMerger.h"
#import "FIUIImageHandler.h"
#import "ImageEditorPlugin.h"

FOUNDATION_EXPORT double image_editor_commonVersionNumber;
FOUNDATION_EXPORT const unsigned char image_editor_commonVersionString[];

