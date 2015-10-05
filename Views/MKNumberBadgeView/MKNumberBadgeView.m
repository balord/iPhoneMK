//
//  MKNumberBadgeView.m
//  MKNumberBadgeView
//
// Copyright 2009-2012 Michael F. Kamprath
// michael@claireware.com
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#ifndef __has_feature
#define __has_feature(x) 0
#endif
#ifndef __has_extension
#define __has_extension __has_feature // Compatibility with pre-3.0 compilers.
#endif

#if !(__has_feature(objc_arc) && __clang_major__ >= 3)
#error "MKNumberBadgeView is designed to be used with ARC. Please add '-fobjc-arc' to the compiler flags of MKNumberBadgeView.m."
#endif // __has_feature(objc_arc)


#import "MKNumberBadgeView.h"


@interface MKNumberBadgeView () {
	UIFont *_font;
	CGSize _numberSize;
	NSString *_textValue;
}

//
// private methods
//

- (void)initState;
- (CGPathRef)newBadgePathForTextSize:(CGSize)inSize;

@end


@implementation MKNumberBadgeView
@dynamic badgeSize;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if ( self )
    {
        // Initialization code
        [self initState];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if ( self )
    {
        // Initialization code
        [self initState];
    }
    return self;
}


#pragma mark -- private methods --

- (void)initState
{	
	self.opaque = NO;
	self.pad = 2;
	self.font = [UIFont boldSystemFontOfSize:16];
	self.shadow = YES;
	self.shadowOffset = CGSizeMake(0, 3);
	self.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
	self.shine = YES;
	self.alignment = NSTextAlignmentCenter;
	self.fillColor = [UIColor redColor];
	self.strokeColor = [UIColor whiteColor];
	self.strokeWidth = 2.0;
	self.textColor = [UIColor whiteColor];
    self.hideWhenZero = NO;
	self.adjustOffset = CGPointZero;
    self.textFormat = @"%d";
    self.value = 0;
    self.textValue = @"";
    
	self.backgroundColor = [UIColor clearColor];
}


- (void)drawRect:(CGRect)rect 
{
	[super drawRect:rect];
	
	CGRect viewBounds = self.bounds;
	
	CGContextRef curContext = UIGraphicsGetCurrentContext();
    
	CGPathRef badgePath = [self newBadgePathForTextSize:_numberSize];
	
	CGRect badgeRect = CGPathGetBoundingBox(badgePath);
	
	badgeRect.origin.x = 0;
	badgeRect.origin.y = 0;
	badgeRect.size.width = ceil( badgeRect.size.width );
	badgeRect.size.height = ceil( badgeRect.size.height );
	
    
	CGContextSaveGState( curContext );
	CGContextSetLineWidth( curContext, self.strokeWidth );
	CGContextSetStrokeColorWithColor(  curContext, self.strokeColor.CGColor  );
	CGContextSetFillColorWithColor( curContext, self.fillColor.CGColor );
	
	// Line stroke straddles the path, so we need to account for the outer portion
	badgeRect.size.width += ceilf( self.strokeWidth / 2 );
	badgeRect.size.height += ceilf( self.strokeWidth / 2 );
	
	CGPoint ctm;
	
	switch (self.alignment)
	{
		case NSTextAlignmentJustified:
		case NSTextAlignmentNatural:
		case NSTextAlignmentCenter:
			ctm = CGPointMake( round((viewBounds.size.width - badgeRect.size.width)/2), round((viewBounds.size.height - badgeRect.size.height)/2) );
			break;
		case NSTextAlignmentLeft:
			ctm = CGPointMake( 0, round((viewBounds.size.height - badgeRect.size.height)/2) );
			break;
		case NSTextAlignmentRight:
			ctm = CGPointMake( (viewBounds.size.width - badgeRect.size.width), round((viewBounds.size.height - badgeRect.size.height)/2) );
			break;
	}
	
	CGContextTranslateCTM( curContext, ctm.x, ctm.y);

	if (self.shadow)
	{
		CGContextSaveGState( curContext );

		CGSize blurSize = self.shadowOffset;
		
		CGContextSetShadowWithColor( curContext, blurSize, 4, self.shadowColor.CGColor );
		
		CGContextBeginPath( curContext );
		CGContextAddPath( curContext, badgePath );
		CGContextClosePath( curContext );
		
		CGContextDrawPath( curContext, kCGPathFillStroke );
		CGContextRestoreGState(curContext); 
	}
	
	CGContextBeginPath( curContext );
	CGContextAddPath( curContext, badgePath );
	CGContextClosePath( curContext );
	CGContextDrawPath( curContext, kCGPathFillStroke );

	//
	// add shine to badge
	//
	
	if (self.shine)
	{
		CGContextBeginPath( curContext );
		CGContextAddPath( curContext, badgePath );
		CGContextClosePath( curContext );
		CGContextClip(curContext);
		
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB(); 
		CGFloat shinyColorGradient[8] = {1, 1, 1, 0.8, 1, 1, 1, 0}; 
		CGFloat shinyLocationGradient[2] = {0, 1}; 
		CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, 
																	shinyColorGradient, 
																	shinyLocationGradient, 2);
		
		CGContextSaveGState(curContext); 
		CGContextBeginPath(curContext); 
		CGContextMoveToPoint(curContext, 0, 0); 
		
		CGFloat shineStartY = badgeRect.size.height*0.25;
		CGFloat shineStopY = shineStartY + badgeRect.size.height*0.4;
		
		CGContextAddLineToPoint(curContext, 0, shineStartY); 
		CGContextAddCurveToPoint(curContext, 0, shineStopY, 
										badgeRect.size.width, shineStopY, 
										badgeRect.size.width, shineStartY); 
		CGContextAddLineToPoint(curContext, badgeRect.size.width, 0); 
		CGContextClosePath(curContext); 
		CGContextClip(curContext); 
		CGContextDrawLinearGradient(curContext, gradient, 
									CGPointMake(badgeRect.size.width / 2.0, 0), 
									CGPointMake(badgeRect.size.width / 2.0, shineStopY), 
									kCGGradientDrawsBeforeStartLocation); 
		CGContextRestoreGState(curContext); 
		
		CGColorSpaceRelease(colorSpace); 
		CGGradientRelease(gradient); 
		
	}
	CGContextRestoreGState( curContext );
	CGPathRelease(badgePath);
	
	CGPoint textPt = CGPointMake( ctm.x + (badgeRect.size.width - _numberSize.width)/2 + self.adjustOffset.x, ctm.y + (badgeRect.size.height - _numberSize.height)/2 + self.adjustOffset.y);
	
    [self.textValue drawAtPoint:textPt withAttributes:@{ NSFontAttributeName : self.font, NSForegroundColorAttributeName : self.textColor }];
}


- (CGPathRef)newBadgePathForTextSize:(CGSize)inSize
{
	CGFloat arcRadius = ceil((inSize.height+self.pad)/2.0);
	
	CGFloat badgeWidthAdjustment = inSize.width - inSize.height/2.0;
	CGFloat badgeWidth = 2.0*arcRadius;
	
	if ( badgeWidthAdjustment > 0.0 )
	{
		badgeWidth += badgeWidthAdjustment;
	}
	
	
	CGMutablePathRef badgePath = CGPathCreateMutable();
	
	CGPathMoveToPoint( badgePath, NULL, arcRadius, 0 );
	CGPathAddArc( badgePath, NULL, arcRadius, arcRadius, arcRadius, 3.0*M_PI_2, M_PI_2, YES);
	CGPathAddLineToPoint( badgePath, NULL, badgeWidth-arcRadius, 2.0*arcRadius);
	CGPathAddArc( badgePath, NULL, badgeWidth-arcRadius, arcRadius, arcRadius, M_PI_2, 3.0*M_PI_2, YES);
	CGPathAddLineToPoint( badgePath, NULL, arcRadius, 0 );
	
	return badgePath;
	
}

#pragma mark -- property methods --

- (UIFont *)font
{
    // attributes dictionary requires return value
    if ( !_font ) {
        return [UIFont boldSystemFontOfSize:16]; //default
    }
    return _font;
}

- (void) setFont:(UIFont *)font
{
	if ( _font != font ) {
		
		_font = font;
		_numberSize = [self.textValue sizeWithAttributes:@{ NSFontAttributeName : _font }];
		
	}
}

- (UIColor *)textColor
{
    // attributes dictionary requires return value
    if ( !_textColor ) {
        return [UIColor whiteColor]; //default;
    }
    return _textColor;
}

- (void)setValue:(NSUInteger)inValue
{
    if ( _value != inValue ) {
        
        _value = inValue;
        
        _textValue = [NSString stringWithFormat:self.textFormat, _value];
        _numberSize = [_textValue sizeWithAttributes:@{ NSFontAttributeName : self.font }];
        
        [self setNeedsDisplay];
        
    }
	
	self.hidden = self.hideWhenZero && _value == 0;
}

- (void) setTextValue:(NSString *)textValue
{
    if ( _textValue != textValue ) {
        
		if ( !textValue )
			textValue = @"";
        _textValue = [textValue copy];
		
		_numberSize = [_textValue sizeWithAttributes:@{ NSFontAttributeName : self.font }];
        _value = 0;
        
        [self setNeedsDisplay];
        
    }
		
	self.hidden = self.hideWhenZero && [_textValue length] == 0;
}

- (CGSize)badgeSize
{
	CGPathRef badgePath = [self newBadgePathForTextSize:_numberSize];
	
	CGRect badgeRect = CGPathGetBoundingBox(badgePath);
	
	badgeRect.origin.x = 0;
	badgeRect.origin.y = 0;
	badgeRect.size.width = ceil( badgeRect.size.width );
	badgeRect.size.height = ceil( badgeRect.size.height );
	
	CGPathRelease(badgePath);
	
	return badgeRect.size;
}



@end
