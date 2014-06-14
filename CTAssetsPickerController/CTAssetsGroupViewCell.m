/*
 CTAssetsGroupViewCell.m
 
 The MIT License (MIT)
 
 Copyright (c) 2013 Clement CN Tsang
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 
 */

#import "CTAssetsPickerConstants.h"
#import "CTAssetsGroupViewCell.h"


static const NSUInteger kPosterViews = 3;
static const CGSize kPosterSize = {68.5, 68.5};
static const CGFloat kLeftPadding = 9.0f;
static const CGFloat kLabelLeftPadding = 6.0f;

static const CGFloat kPosterPeek = 1.5f;
static const CGFloat kWhiteBorder = 0.5f;
static const CGFloat kXShrinkIncrement = 2.0f;


@implementation CTAssetsGroupViewCell {
    NSString *_accessibilityLabel;
    NSArray *_posterViews;
}

+ (CGFloat)neededHeight {
    return 86.0f;
}

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        
        CGFloat topTop = 4.0f;
        CGFloat totalIncrement = kPosterPeek + kWhiteBorder;
        
        NSMutableArray *posterViews = [NSMutableArray arrayWithCapacity:kPosterViews];
        for (int i = 0; i < kPosterViews; i++) {
            CGFloat leftIdent = (kPosterViews - i - 1) * kXShrinkIncrement;
            CGFloat topIdent = i * totalIncrement;
            CGFloat width = kPosterSize.width - (leftIdent * 2);
            CGRect pivFrame = CGRectMake(kLeftPadding + leftIdent, topTop + topIdent, width, kPosterSize.height);
            
            UIImageView *piv = [[UIImageView alloc] initWithFrame:pivFrame];
            piv.backgroundColor = [UIColor blackColor];
            piv.layer.borderColor = [UIColor whiteColor].CGColor;
            piv.layer.borderWidth = kWhiteBorder;
            
            [posterViews insertObject:piv atIndex:0];
            [self.contentView addSubview:piv];
        }
        
        _posterViews = posterViews;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat posterRightEdge = CGRectGetMaxX([[_posterViews firstObject] frame]);
    CGFloat labelLeft = posterRightEdge + kLeftPadding + kLabelLeftPadding;
    CGFloat textLabelRightEdge = self.frame.size.width - 32.0f;
    
    self.textLabel.frame = CGRectMake(labelLeft, self.textLabel.frame.origin.y, textLabelRightEdge - labelLeft, self.textLabel.frame.size.height);
    self.detailTextLabel.frame = CGRectMake(labelLeft, self.detailTextLabel.frame.origin.y, textLabelRightEdge - labelLeft, self.detailTextLabel.frame.size.height);
}

- (void)bind:(ALAssetsGroup *)assetsGroup
{
    float scale = [[UIScreen mainScreen] scale];
    
    /**
     * Fill in the first view with group's poster image.
     */
    UIImageView *firstPIV = _posterViews[0];
    if (assetsGroup.posterImage) {
        firstPIV.image = [UIImage imageWithCGImage:assetsGroup.posterImage scale:scale orientation:UIImageOrientationUp];
    }
    else {
        firstPIV.image = nil;
    }
    
    /**
     * Fill in all poster views after the first, since we only have
     * one posterImage.
     */
    NSUInteger posterOffset = assetsGroup.posterImage ? 1 : 0;
    NSRange fillRange = NSMakeRange(posterOffset, MIN([_posterViews count], assetsGroup.numberOfAssets) - posterOffset);
    [assetsGroup enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:fillRange]
                                  options:0
                               usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                                   if (index == NSNotFound)
                                       return;
                                   UIImageView *piv = _posterViews[index];
                                   piv.image = [UIImage imageWithCGImage:result.thumbnail
                                                                   scale:scale
                                                             orientation:UIImageOrientationUp];
                               }];
    
    // Clear the missed image views
    for (NSUInteger i = fillRange.location + fillRange.length; i < [_posterViews count]; i++) {
        UIImageView *piv = _posterViews[i];
        piv.image = nil;
    }
    
    // Fill the other views
    self.textLabel.text         = [assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    self.detailTextLabel.text   = [NSString stringWithFormat:@"%ld", (long)assetsGroup.numberOfAssets];
    self.accessoryType          = UITableViewCellAccessoryDisclosureIndicator;
    
    // Accessibility
    NSString *label             = [assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    _accessibilityLabel         = [label stringByAppendingFormat:NSLocalizedString(@"%ld Photos", nil), (long)assetsGroup.numberOfAssets];
}

- (NSString *)accessibilityLabel {
    return _accessibilityLabel;
}

@end