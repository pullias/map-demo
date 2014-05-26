//
//  MapDemoCalloutView.m
//  Map Demo
//
//  Created by Jason Pullias on 5/26/14.
//  Copyright (c) 2014 pullias.com. All rights reserved.
//

#import "MapDemoCalloutView.h"

@interface MapDemoCalloutView()
@property (nonatomic, strong) UITextView * textView;
@end

@implementation MapDemoCalloutView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor redColor];
        [self addSubview:self.textView];
    }
    return self;
}

- (UITextView *)textView {
    if (!_textView) {
        _textView = [[UITextView alloc] initWithFrame:self.bounds];
        _textView.scrollEnabled = YES;
        _textView.userInteractionEnabled = YES;
        _textView.editable = NO;
    }
    return _textView;
}

- (void)setTitle:(NSString *)title andSubTitle:(NSString *)subTitle {
    NSAttributedString * attributedTitle = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n",title] attributes:@{NSFontAttributeName:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]}];
    NSAttributedString * attributedSubtitle = [[NSAttributedString alloc] initWithString:subTitle attributes:@{NSFontAttributeName:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]}];
    
    NSMutableAttributedString * finalString = [[NSMutableAttributedString alloc] initWithAttributedString:attributedTitle];
    [finalString appendAttributedString:attributedSubtitle];

    // add line spacing between paragraphs
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.paragraphSpacing = 10;
    NSRange wholeRange = {0,[finalString length]};
    [finalString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:wholeRange];

    self.textView.attributedText = finalString;
}

@end
