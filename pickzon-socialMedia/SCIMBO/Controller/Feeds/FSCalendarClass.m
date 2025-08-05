//
//  FSCalendarClass.m
//  SCIMBO
//
//  Created by Radheshyam Yadav on 4/18/24.
//  Copyright © 2024 Pickzon Inc. All rights reserved.
//

#import <FSCalendar.h>
#import "FSCalendarClass.h"


@implementation FSCalendarClass


#pragma mark - Private methods

+ (void)configureVisibleCells:(FSCalendar*)calendar  date11:(NSDate *)date11  date22:(NSDate *)date22 gregorian1:(NSCalendar*)gregorian1
{
    [calendar.visibleCells enumerateObjectsUsingBlock:^(__kindof FSCalendarCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDate *date = [calendar dateForCell:obj];
        FSCalendarMonthPosition position = [calendar monthPositionForCell:obj];
        [self configureCell:obj forDate:date atMonthPosition:position  date1:date11 date2:date22 gregorian:gregorian1];
    }];
}

+ (void)configureCell:(__kindof FSCalendarCell *)cell forDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)position date1:(NSDate *)date1  date2:(NSDate *)date2 gregorian:(NSCalendar*)gregorian
{
    RangePickerCell *rangeCell = cell;
    if (position != FSCalendarMonthPositionCurrent) {
        rangeCell.middleLayer.hidden = YES;
        rangeCell.selectionLayer.hidden = YES;
        return;
    }
    if (date1 && date2) {
        // The date is in the middle of the range
        BOOL isMiddle = [date compare:date1] != [date compare:date2];
        rangeCell.middleLayer.hidden = !isMiddle;
    } else {
        rangeCell.middleLayer.hidden = YES;
    }
    BOOL isSelected = NO;
    isSelected |= date1 && [gregorian isDate:date inSameDayAsDate:date1];
    isSelected |= date2 && [gregorian isDate:date inSameDayAsDate:date2];
    rangeCell.selectionLayer.hidden = !isSelected;
}

@end
