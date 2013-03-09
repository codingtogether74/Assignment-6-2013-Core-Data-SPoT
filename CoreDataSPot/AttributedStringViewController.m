//
//  AttributedStringViewController.m
//  SPoT
//
//  Created by Tatiana Kornilova on 2/23/13.
//  Copyright (c) 2013 Tatiana Kornilova. All rights reserved.
//

#import "AttributedStringViewController.h"

@interface AttributedStringViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation AttributedStringViewController

-(void) setText:(NSAttributedString *)text
{
    _text = text;
    self.textView.attributedText =text;
}

-(void) viewDidLoad
{
    [super viewDidLoad];
    self.textView.attributedText = self.text;
}
@end
