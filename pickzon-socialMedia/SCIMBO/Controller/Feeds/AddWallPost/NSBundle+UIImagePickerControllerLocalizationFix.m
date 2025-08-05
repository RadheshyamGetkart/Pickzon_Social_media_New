//
//  NSBundle+UIImagePickerControllerLocalizationFix.m
//  SCIMBO
//
//  Created by Naresh Kumar on 10/18/21.
//  Copyright © 2021 Radheshyam Yadav. All rights reserved.
//

#import "NSBundle+UIImagePickerControllerLocalizationFix.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@implementation NSBundle (UIImagePickerControllerLocalizationFix)



+ (void) load {
    SEL const selector = @selector (localizedStringForKey:value:table:);
    Method const localizedStringMethod = class_getInstanceMethod (self, selector);
    NSString *(*originalImp) (NSBundle *, SEL, NSString *, NSString *, NSString *) = (typeof (originalImp)) method_getImplementation (localizedStringMethod);
    IMP const updatedImp = (typeof (updatedImp)) imp_implementationWithBlock (^(NSBundle *bundle, NSString *key, NSString *value, NSString *tableName) {
        NSString *const result = originalImp (bundle, selector, key, value, tableName);
        if ([key isEqualToString:@"VIDEO_TOO_LONG_TITLE"] && [result isEqualToString:key]) {
            static NSBundle *properLocalizationBundle = nil;
            static NSString *properLocalizationTable = nil;
            static dispatch_once_t onceToken;
            dispatch_once (&onceToken, ^{
                NSString *const originalBundleName = bundle.infoDictionary [(NSString *) kCFBundleNameKey];
                NSArray <NSBundle *> *const frameworkBundles = [NSBundle allFrameworks];
                for (NSBundle *frameworkBundle in frameworkBundles) {
                    NSString *const possibleTableName = [originalBundleName isEqualToString:tableName] ? frameworkBundle.infoDictionary [(NSString *) kCFBundleNameKey] : tableName;
                    NSString *const localizedKey = originalImp (frameworkBundle, selector, key, value, possibleTableName);
                    if (![localizedKey isEqualToString:key]) {
                        properLocalizationBundle = frameworkBundle;
                        properLocalizationTable = possibleTableName;
                        break;
                    }
                }

                if (!(properLocalizationBundle && properLocalizationTable)) { // Giving up
                    properLocalizationBundle = bundle;
                    properLocalizationTable = tableName;
                }
            });

            return originalImp (properLocalizationBundle, selector, key, value, properLocalizationTable);
        } else {
            return result;
        }
    });
    method_setImplementation (localizedStringMethod, updatedImp);
}

@end
