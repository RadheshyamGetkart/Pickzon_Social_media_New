//
//  FSCalendarClass.h
//  SCIMBO
//
//  Created by Radheshyam Yadav on 4/18/24.
//  Copyright © 2024 Pickzon Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSCalendar.h"
#import "RangePickerCell.h"
#import "FSCalendarExtensions.h"

NS_ASSUME_NONNULL_BEGIN

@interface FSCalendarClass : NSObject

+ (void)configureCell:(__kindof FSCalendarCell *)cell forDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)position date1:(NSDate *)date1  date2:(NSDate *)date2 gregorian:(NSCalendar*)gregorian;

+ (void)configureVisibleCells:(FSCalendar*)calendar  date11:(NSDate *)date11  date22:(NSDate *)date22 gregorian1:(NSCalendar*)gregorian1;

@end

NS_ASSUME_NONNULL_END
