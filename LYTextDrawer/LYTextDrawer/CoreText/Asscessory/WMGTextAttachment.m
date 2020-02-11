//
//  WMGTextAttachment.m
//  LYTextDrawer
//
//  Created by 李玉臣 on 2020/2/9.
//  Copyright © 2020 LYfinacial.com. All rights reserved.
//

#import "WMGTextAttachment.h"
#import "WMGTextLayoutRun.h"
#import "WMGTextAttachment+Event.h"

NSString * const WMGTextAttachmentAttributeName = @"WMGTextAttachmentAttributeName";
NSString * const WMGTextAttachmentReplacementCharacter = @"\uFFFC";

@interface WMGTextAttachment ()

@property (nonatomic, strong) NSMutableArray *callBacks;

@end


@implementation WMGTextAttachment
@synthesize type = _type, size = _size, edgeInsets = _edgeInsets, contents = _contents, position = _position, length =_length, baselineFontMetrics = _baselineFontMetrics;

-(instancetype)init {
    if (self = [super init]) {
        _retriveFontMetricsAutomatically = YES;
        _baselineFontMetrics = WMGFontMetricsZero;

        _edgeInsets = UIEdgeInsetsMake(0, 1, 0, 1);
        // Event
        _userInfoPriority = 999;
        _eventPriority = 999;

        _callBacks = [NSMutableArray array];

    }
    return self;
}

+(instancetype)textAttachmentWithContents:(id)contents type:(WMGAttachmentType)type size:(CGSize)size {
    WMGTextAttachment *att = [[WMGTextAttachment alloc] init];
    att.contents = contents;
    att.type = type;
    att.size = size;

    return att;
}


-(UIEdgeInsets)edgeInsets {
    if (_retriveFontMetricsAutomatically) {
        CGFloat lineHeight = WMGFontMetricsGetLineHeight(_baselineFontMetrics);
        // 垂直居中显示
        CGFloat inset = (lineHeight - self.size.height) / 2;
        return UIEdgeInsetsMake(inset, _edgeInsets.left, inset, _edgeInsets.right);
    }

    return _edgeInsets;
}

-(CGSize)placeholderSize {
    
    return CGSizeMake(self.size.width + self.edgeInsets.left + self.edgeInsets.right, self.size.height + self.edgeInsets.top + self.edgeInsets.bottom);
}

#pragma mark -Event

// ????????? controlEvents没有保存
-(void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents {
    _target = target;
    _selector = action;

    _responseEvent = (_target && _selector) && [_target respondsToSelector:_selector];
}

-(void)registerClickBlock:(void (^)(void))callBack {
    if (!callBack) {
        return;
    }
    [_callBacks addObject:callBack];
}

-(void)handleEvent:(id)sender {
    if (_target && _selector) {
        if (_target && _selector) {
            if ([_target respondsToSelector:_selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [_target performSelector:_selector withObject:sender];
#pragma clang diagnostic pop
            }
        }
    }
    if (_callBacks.count) {
        for (void(^callBack)(void) in _callBacks) {
            if (callBack) {
                callBack();
            }
        }
    }
}

@end


@implementation NSAttributedString (GTextAttachment)


-(void)wmg_enumerateTextAttachmentsWithBlock:(void (^)(WMGTextAttachment * _Nonnull, NSRange, BOOL * _Nonnull))block {
    [self wmg_enumerateTextAttachmentsWithOptions:0 block:block];
}

- (void)wmg_enumerateTextAttachmentsWithOptions:(NSAttributedStringEnumerationOptions)options block:(void (^)(WMGTextAttachment * _Nonnull, NSRange, BOOL * _Nonnull))block {
    if (!block) {
        return;
    }

    [self enumerateAttribute:WMGTextAttachmentAttributeName inRange:NSMakeRange(0, self.length) options:options usingBlock:^(WMGTextAttachment  * attachment, NSRange range, BOOL * _Nonnull stop) {
        if (attachment && [attachment isKindOfClass:[WMGTextAttachment class]]) {
            block(attachment, range, stop);
        }
    }];
}

+(instancetype)wmg_attributedStringWithTextAttachment:(WMGTextAttachment *)attachment {

    return [self wmg_attributedStringWithTextAttachment:attachment attributes:@{}];
}

/*
将TextAttachment转化为String，将CTRunDelegateRef和TextAttachment对象保存到属性信息中
 */
+(instancetype)wmg_attributedStringWithTextAttachment:(WMGTextAttachment *)attachment attributes:(NSDictionary *)attributes {
    // Core Text 通过runDelegate确定非文字（attachment）区域的大小
    CTRunDelegateRef runDelegate = [WMGTextLayoutRun textLayoutRunWithAttachment:attachment];

    NSMutableDictionary *placeholderAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];


    /**
        @{kCTRunDelegateAttributeName: runDelegate,
        kCTForegroundColorAttributeName:[UIColor clearColor].CGColor,
        WMGTextAttachmentAttributeName: attachment
     }

     */
    [placeholderAttributes addEntriesFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:(__bridge id )runDelegate, (NSString *)kCTRunDelegateAttributeName, [UIColor clearColor].CGColor, (NSString *)kCTForegroundColorAttributeName, attachment, WMGTextAttachmentAttributeName, nil]];


    NSString *str = WMGTextAttachmentReplacementCharacter;
    NSAttributedString *result = [[[self class] alloc] initWithString:str attributes:placeholderAttributes];


    CFRelease(runDelegate);

    return result;
}
@end
