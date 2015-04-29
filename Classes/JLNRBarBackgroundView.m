//
//  JLNRBarBackgroundView.m
//  Pods
//
//  Created by Julian Raschke on 27.04.15.
//
//

#import "JLNRBarBackgroundView.h"

@implementation JLNRBarBackgroundView

- (void)setBorderColor:(UIColor *)borderColor
{
    _borderColor = borderColor;
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    UIColor *borderColor = (self.borderColor ?: [UIColor colorWithRed:178.f/255 green:178.f/255 blue:178.f/255 alpha:1]);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGSize size = self.bounds.size;
    CGFloat borderWidth = 1.0f / self.window.screen.scale;
    
    CGContextSetFillColorWithColor(context, borderColor.CGColor);
    
    if (size.width > size.height) {
        CGContextFillRect(context, CGRectMake(0, 0, size.width, borderWidth));
    }
    else {
        CGContextFillRect(context, CGRectMake(size.width - borderWidth, 0, borderWidth, size.height));
    }
}

@end
