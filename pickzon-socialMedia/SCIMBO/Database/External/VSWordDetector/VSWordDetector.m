//
//  VSWordDetector.m
//  VSWordDetector
//
//  Created by TheTiger on 05/02/14.
//  Copyright (c) 2014 TheTiger. All rights reserved.
//

#import "VSWordDetector.h"
#import <UIKit/UIKit.h>
@interface VSWordDetector ()

@property (strong, nonatomic) id <VSWordDetectorDelegate> delegate;
@property (strong, nonatomic) NSMutableArray *words;
@property (strong, nonatomic) NSMutableArray *wordAreas;

@end

@implementation VSWordDetector
@synthesize delegate = _delegate;
@synthesize words = _words;
@synthesize wordAreas = _wordAreas;

#pragma mark - Initializaiton
-(id)initWithDelegate:(id<VSWordDetectorDelegate>)delegate
{
    self = [super init];
    if (self)
    {
        self.delegate = delegate;
    }
    
    return self;
}

#pragma mark - Adding Detector on view
-(void)addOnView:(id)view
{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    if ([view isKindOfClass:[UITextView class]])
    {
        [view addGestureRecognizer:tapGesture];
        
        UITextView *textView = (UITextView *)view;
        textView.userInteractionEnabled = YES;
        textView.editable = NO;
        textView.scrollEnabled = NO;
    }
    else if ([view isKindOfClass:[UILabel class]])
    {
        [view addGestureRecognizer:tapGesture];
        
        UILabel *label = (UILabel *)view;
        label.userInteractionEnabled = YES;
    }
}

#pragma mark - Tapped
-(void)tapped:(UIGestureRecognizer *)recognizer
{
    
    @try {
    
    if ([recognizer.view isKindOfClass:[UITextView class]])
    {
        UITextView *textView = (UITextView *)recognizer.view;
        
        NSLayoutManager *layoutManager = textView.layoutManager;
        CGPoint location = [recognizer locationInView:textView];
        location.x -= textView.textContainerInset.left;
        location.y -= textView.textContainerInset.top;
        
        // FIND THE CHARACTER WHICH HAVE BEEN TAPPED
        NSInteger characterIndex = [layoutManager characterIndexForPoint:location inTextContainer:textView.textContainer fractionOfDistanceBetweenInsertionPoints:NULL];
        
        if (characterIndex < textView.textStorage.length)
        {
            NSString *word = [self tappedWordInTextView:textView fromIndex:characterIndex];
            if ([self.delegate respondsToSelector:@selector(wordDetector:detectWord:)])
            {
                [self.delegate wordDetector:self detectWord:word];
            }
        }
    } else if ([recognizer.view isKindOfClass:[UILabel class]]) {
        
        UILabel *label = (UILabel *)recognizer.view;
        CGPoint location = [recognizer locationInView:label];
        
        
        NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:label.attributedText];
        NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
        [textStorage addLayoutManager:layoutManager];
        
        CGSize size = label.bounds.size;
        NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:CGSizeMake(label.frame.size.width, label.frame.size.height)];
        textContainer.lineFragmentPadding = 0;
        textContainer.maximumNumberOfLines = label.numberOfLines;
        textContainer.lineBreakMode = label.lineBreakMode;
        textContainer.size = label.frame.size;
        [layoutManager addTextContainer:textContainer];
        
        
        NSUInteger characterIndex = [layoutManager characterIndexForPoint:location
                                                          inTextContainer:textContainer
                                 fractionOfDistanceBetweenInsertionPoints:NULL];
        
        
        
        NSUInteger glyphIndex = [layoutManager glyphIndexForPoint:location inTextContainer:textContainer fractionOfDistanceThroughGlyph:NULL];
        
        NSUInteger characterIndexx = [layoutManager glyphIndexForCharacterAtIndex:glyphIndex];
        
        if (characterIndex < textStorage.length) {
//            NSRange range = NSMakeRange(characterIndex, 1);
//            NSString *value = [label.attributedText.string substringWithRange:range];
//            NSLog(@"%@, %zd, %zd", value, range.location, range.length);
            NSString *word = [self tappedWordInLabel:label fromIndex:characterIndex];
            if ([self.delegate respondsToSelector:@selector(wordDetector:detectWord:)])
            {
                [self.delegate wordDetector:self detectWord:word];
            }
            
            NSLog(@"word==",word);
        }
    }  else if ([recognizer.view isKindOfClass:[UILabel class]])
    {
        UILabel *label = (UILabel *)recognizer.view;
        CGPoint location = [recognizer locationInView:label];
    
        // GETTING ALL WORDS OF LABEL
        self.words = nil;
      //  NSString *str = [[label text] stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
      // self.words = [[[[label attributedText] string] componentsSeparatedByString:@" "] mutableCopy];
       self.words = [[[[label attributedText] string] componentsSeparatedByString:@" "] mutableCopy];

      //  self.words = [[[[label attributedText] string] componentsSeparatedByCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet] mutableCopy];

        
        
        self.wordAreas = nil;
        self.wordAreas = [[NSMutableArray alloc] init];
        
        __block CGPoint drawPoint = CGPointMake(0, 0);
        CGRect rect = [label frame];
        CGSize space = [@" " sizeWithFont:label.font constrainedToSize:rect.size lineBreakMode:label.lineBreakMode];
        
        
        

        
        // GETTING AREA OF EACH WORD OF LABEL
        [self.words enumerateObjectsUsingBlock:^(NSString *word, NSUInteger idx, BOOL *stop) {
            
            UIFont *font = [label font];
            CGSize size = [word sizeWithAttributes:font];
            
            if(drawPoint.x + size.width > rect.size.width) {
                drawPoint = CGPointMake(0, drawPoint.y + size.height);
            }
            
            [self.wordAreas addObject:[NSValue valueWithCGRect:CGRectMake(drawPoint.x, drawPoint.y, size.width, size.height)]];
            
            drawPoint = CGPointMake(drawPoint.x + size.width + space.width, drawPoint.y);
        }];

        // NOW FINDING THE WORD OF TAPPED AREA
        [self.wordAreas enumerateObjectsUsingBlock:^(NSValue *obj, NSUInteger idx, BOOL *stop) {
            CGRect area = [obj CGRectValue];
            if (CGRectContainsPoint(area, location)) {
                if([self.delegate respondsToSelector:@selector(wordDetector:detectWord:)]){
                    NSString *word = [self.words objectAtIndex:idx];
                    [self.delegate wordDetector:self detectWord:word];
                }
                *stop = YES;
            }
        }];

        
    }
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
    } @finally {
        NSLog(@"ERROR");
    }
    
}

// ONLY FOR TEXT VIEW
-(NSString *)tappedWordInTextView:(UITextView *)textView fromIndex:(NSUInteger)index
{
    
    @try {
   
    NSMutableString *fString = [[NSMutableString alloc] init];
    NSMutableString *sString = [[NSMutableString alloc] init];
    
    // GET STRING BEFORE TAPPED CHARACTER UNTIL SPACE
    
    for (NSInteger i=index; i>=0; i--)
    {
        unichar character = [textView.text characterAtIndex:i];
        NSInteger asciiValue = [[NSString stringWithFormat:@"%d", character] integerValue];
        if (asciiValue == 32)
        {
            // THIS IS SPACE
            break;
        }
        
        [fString appendFormat:@"%c", character];
    }
    
    // REVERSE fString
    
    NSMutableString *reversedString = [NSMutableString stringWithCapacity:[fString length]];
    
    [fString enumerateSubstringsInRange:NSMakeRange(0,[fString length])
                                options:(NSStringEnumerationReverse | NSStringEnumerationByComposedCharacterSequences)
                             usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                 [reversedString appendString:substring];
                             }];
    fString = reversedString;
    
    // GET STRING AFTER TAPPED CHARACTER UNTIL SPACE
    
    for (NSInteger i=index+1; i<textView.text.length; i++)
    {
        unichar character = [textView.text characterAtIndex:i];
        NSInteger asciiValue = [[NSString stringWithFormat:@"%d", character] integerValue];
        if (asciiValue == 32)
        {
            // THIS IS SPACE
            break;
        }
        
        [sString appendFormat:@"%c", character];
    }
    
    return [NSString stringWithFormat:@"%@%@", fString, sString];
    
    } @catch (NSException *exception) {
        
    } @finally {
        return @"";
    }
}



// ONLY FOR TEXT VIEW
-(NSString *)tappedWordInLabel:(UILabel *)label fromIndex:(NSUInteger)index
{
    NSMutableString *fString = [[NSMutableString alloc] init];
    NSMutableString *sString = [[NSMutableString alloc] init];
    @try {
    
    // GET STRING BEFORE TAPPED CHARACTER UNTIL SPACE
    
    for (NSInteger i=index; i>=0; i--)
    {
        if ([[label attributedText] length]  > i){
        char character = [label.attributedText.string characterAtIndex:i];
        NSInteger asciiValue = [[NSString stringWithFormat:@"%d", character] integerValue];
        if ((asciiValue == 32) || (asciiValue == 10))
        {
            // THIS IS SPACE
            break;
        }else{
            [fString appendFormat:@"%c", character];
        }
        }
    }
    
    // REVERSE fString
    
    NSMutableString *reversedString = [NSMutableString stringWithCapacity:[fString length]];
    
    [fString enumerateSubstringsInRange:NSMakeRange(0,[fString length])
                                options:(NSStringEnumerationReverse | NSStringEnumerationByComposedCharacterSequences)
                             usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                 [reversedString appendString:substring];
                             }];
    fString = reversedString;
    
        NSLog(@"reversedString ==%@",reversedString);
    // GET STRING AFTER TAPPED CHARACTER UNTIL SPACE
    
    for (NSInteger i=index+1; i<label.attributedText.length; i++)
    {
        if ([[label attributedText] length]  > i){
            
            char character = [label.attributedText.string characterAtIndex:i];
            NSInteger asciiValue = [[NSString stringWithFormat:@"%d", character] integerValue];
            if ((asciiValue == 32) || (asciiValue == 10))
            {
                // THIS IS SPACE
                break;
            }else{
                [sString appendFormat:@"%c", character];
            }
        }
        
        
        
        
    }
    
        NSLog(@"fString ==%@",fString);

    return [NSString stringWithFormat:@"%@%@", fString, sString];
    } @catch (NSException *exception) {
        
    } @finally {
        return [NSString stringWithFormat:@"%@%@", fString, sString];

        return  @"";
    }
}




@end
