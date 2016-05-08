/*
 
 Erica Sadun, http://ericasadun.com
 
 */

#import "BaseGeometry.h"

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#pragma mark - UTILITY


CGFloat ScreenLarger()
{
    CGFloat larger;
    
    if ([UIScreen mainScreen].bounds.size.height > [UIScreen mainScreen].bounds.size.width) {
        larger = [UIScreen mainScreen].bounds.size.height;
    }
    else
    {
        larger = [UIScreen mainScreen].bounds.size.width;
    }
    
    return larger;
}


CGFloat ScreenSmaller()
{
    CGFloat smaller;
    
    if ([UIScreen mainScreen].bounds.size.height < [UIScreen mainScreen].bounds.size.width) {
        smaller = [UIScreen mainScreen].bounds.size.height;
    }
    else
    {
        smaller = [UIScreen mainScreen].bounds.size.width;
    }
    
    return smaller;
}




CGFloat ScreenHeight()
{
    return [UIScreen mainScreen].bounds.size.height;
}
CGFloat ScreenWidth()
{
    return [UIScreen mainScreen].bounds.size.width;
}

CGSize ScreenSize()
{
    return [UIScreen mainScreen].bounds.size;
}


CGRect ScreenRect()
{
    return [UIScreen mainScreen].bounds;
}

CGRect DoubleScreenRect()
{
    CGFloat w = ScreenWidth() * 2;
    CGFloat h = ScreenHeight() * 2;
    
    return CGRectMake(-w/2, -h/2, w, h);
}


CGRect HalfScreenRect()
{
    CGRect screenRect = [UIScreen mainScreen].bounds;
    
    return CGRectMake(screenRect.size.width/4, screenRect.size.height/4, screenRect.size.width/2, screenRect.size.height/2);
    
}

#pragma mark - Conversion
// Degrees from radians
CGFloat DegreesFromRadians(CGFloat radians)
{
    return radians * 180.0f / M_PI;
}

// Radians from degrees
CGFloat RadiansFromDegrees(CGFloat degrees)
{
    return degrees * M_PI / 180.0f;
}

#pragma mark - Clamp
CGFloat Clamp(CGFloat a, CGFloat min, CGFloat max)
{
    return fmin(fmax(min, a), max);
}

CGPoint ClampToRect(CGPoint pt, CGRect rect)
{
    CGFloat x = Clamp(pt.x, CGRectGetMinX(rect), CGRectGetMaxX(rect));
    CGFloat y = Clamp(pt.y, CGRectGetMinY(rect), CGRectGetMaxY(rect));
    return CGPointMake(x, y);
}


#pragma mark - General Geometry
CGPoint RectGetCenter(CGRect rect)
{
    return CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
}

CGFloat PointDistanceFromPoint(CGPoint p1, CGPoint p2)
{
    CGFloat dx = p2.x - p1.x;
    CGFloat dy = p2.y - p1.y;
    
    return sqrt(dx*dx + dy*dy);
}

CGPoint RectGetPointAtPercents(CGRect rect, CGFloat xPercent, CGFloat yPercent)
{
    CGFloat dx = xPercent * rect.size.width;
    CGFloat dy = yPercent * rect.size.height;
    return CGPointMake(rect.origin.x + dx, rect.origin.y + dy);
}

#pragma mark - Rectangle Construction
CGRect RectMakeRect(CGPoint origin, CGSize size)
{
    return (CGRect){.origin = origin, .size = size};
}

CGRect SizeMakeRect(CGSize size)
{
    return (CGRect){.size = size};
}

CGRect PointsMakeRect(CGPoint p1, CGPoint p2)
{
    CGRect rect = CGRectMake(p1.x, p1.y, p2.x - p1.x, p2.y - p1.y);
    return CGRectStandardize(rect);
}

CGRect OriginMakeRect(CGPoint origin)
{
    return (CGRect){.origin = origin};
}

CGRect RectAroundCenter(CGPoint center, CGSize size)
{
    CGFloat halfWidth = size.width / 2.0f;
    CGFloat halfHeight = size.height / 2.0f;
    
    return CGRectMake(center.x - halfWidth, center.y - halfHeight, size.width, size.height);
}

CGRect RectCenteredInRect(CGRect rect, CGRect mainRect)
{
    CGFloat dx = CGRectGetMidX(mainRect)-CGRectGetMidX(rect);
    CGFloat dy = CGRectGetMidY(mainRect)-CGRectGetMidY(rect);
    return CGRectOffset(rect, dx, dy);
}

#pragma mark - Point Location
CGPoint PointAddPoint(CGPoint p1, CGPoint p2)
{
    return CGPointMake(p1.x + p2.x, p1.y + p2.y);
}

CGPoint PointSubtractPoint(CGPoint p1, CGPoint p2)
{
    return CGPointMake(p1.x - p2.x, p1.y - p2.y);
}

#pragma mark - Cardinal Points
CGPoint RectGetTopLeft(CGRect rect)
{
    return CGPointMake(
                       CGRectGetMinX(rect),
                       CGRectGetMinY(rect)
                       );
}

CGPoint RectGetTopRight(CGRect rect)
{
    return CGPointMake(
                       CGRectGetMaxX(rect),
                       CGRectGetMinY(rect)
                       );
}

CGPoint RectGetBottomLeft(CGRect rect)
{
    return CGPointMake(
                       CGRectGetMinX(rect),
                       CGRectGetMaxY(rect)
                       );
}

CGPoint RectGetBottomRight(CGRect rect)
{
    return CGPointMake(
                       CGRectGetMaxX(rect),
                       CGRectGetMaxY(rect)
                       );
}

CGPoint RectGetMidTop(CGRect rect)
{
    return CGPointMake(
                       CGRectGetMidX(rect),
                       CGRectGetMinY(rect)
                       );
}

CGPoint RectGetMidBottom(CGRect rect)
{
    return CGPointMake(
                       CGRectGetMidX(rect),
                       CGRectGetMaxY(rect)
                       );
}

CGPoint RectGetMidLeft(CGRect rect)
{
    return CGPointMake(
                       CGRectGetMinX(rect),
                       CGRectGetMidY(rect)
                       );
}

CGPoint RectGetMidRight(CGRect rect)
{
    return CGPointMake(
                       CGRectGetMaxX(rect),
                       CGRectGetMidY(rect)
                       );
}

#pragma mark - Aspect and Fitting
CGSize SizeScaleByFactor(CGSize aSize, CGFloat factor)
{
    return CGSizeMake(aSize.width * factor, aSize.height * factor);
}

CGSize RectGetScale(CGRect sourceRect, CGRect destRect)
{
    CGSize sourceSize = sourceRect.size;
    CGSize destSize = destRect.size;
    
    CGFloat scaleW = destSize.width / sourceSize.width;
    CGFloat scaleH = destSize.height / sourceSize.height;
    
    return CGSizeMake(scaleW, scaleH);
}

CGFloat AspectScaleFill(CGSize sourceSize, CGRect destRect)
{
    CGSize destSize = destRect.size;
    CGFloat scaleW = destSize.width / sourceSize.width;
    CGFloat scaleH = destSize.height / sourceSize.height;
    return fmax(scaleW, scaleH);
}

CGFloat AspectScaleFit(CGSize sourceSize, CGRect destRect)
{
    CGSize destSize = destRect.size;
    CGFloat scaleW = destSize.width / sourceSize.width;
    CGFloat scaleH = destSize.height / sourceSize.height;
    return fmin(scaleW, scaleH);
}

CGRect RectByFittingRect(CGRect sourceRect, CGRect destinationRect)
{
    CGFloat aspect = AspectScaleFit(sourceRect.size, destinationRect);
    CGSize targetSize = SizeScaleByFactor(sourceRect.size, aspect);
    return RectAroundCenter(RectGetCenter(destinationRect), targetSize);
}

CGRect RectByFillingRect(CGRect sourceRect, CGRect destinationRect)
{
    CGFloat aspect = AspectScaleFill(sourceRect.size, destinationRect);
    CGSize targetSize = SizeScaleByFactor(sourceRect.size, aspect);
    return RectAroundCenter(RectGetCenter(destinationRect), targetSize);
}

CGRect RectInsetByPercent(CGRect rect, CGFloat percent)
{
    CGFloat wInset = rect.size.width * (percent / 2.0f);
    CGFloat hInset = rect.size.height * (percent / 2.0f);
    return CGRectInset(rect, wInset, hInset);
}

#pragma mark - Transforms

// Extract the x scale from transform
CGFloat TransformGetXScale(CGAffineTransform t)
{
    return sqrt(t.a * t.a + t.c * t.c);
}

// Extract the y scale from transform
CGFloat TransformGetYScale(CGAffineTransform t)
{
    return sqrt(t.b * t.b + t.d * t.d);
}

// Extract the rotation in radians
CGFloat TransformGetRotation(CGAffineTransform t)
{
    return atan2f(t.b, t.a);
}



#pragma mark - Random Float Helpers
//
float randomFloat(float Min, float Max){
    return ((arc4random()%RAND_MAX)/(RAND_MAX*1.0))*(Max-Min)+Min;
}

/* Return a random integer number between low and high inclusive */
int randomInt(int low, int high)
{
    return (arc4random() % (high-low+1)) + low;
}

/* Return a random BOOL value */
BOOL randomBool()
{
    return (BOOL)randomInt(0, 1);
}

/* Return a random float between 0.0 and 1.0 */
float randomClamp()
{
    return (float)(arc4random() % ((unsigned)RAND_MAX + 1)) / (float)((unsigned)RAND_MAX + 1);
}




