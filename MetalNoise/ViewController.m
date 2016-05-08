//
//  ViewController.m
//  MetalNoise
//
//  Created by Justin Madewell on 8/11/15.
//  Copyright © 2015 Justin Madewell. All rights reserved.
//

#import "ViewController.h"
#import "BaseGeometry.h"




#import "MBEContext.h"
#import "MBEImageFilter.h"
#import "UIImage+MBETextureUtilities.h"
#import "MBEMainBundleTextureProvider.h"
#import "JDMNoiseAdjustmentFilter.h"


@interface ViewController ()

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) MBEContext *context;
@property (nonatomic, strong) id<MBETextureProvider> imageProvider;
@property (nonatomic, strong) JDMNoiseAdjustmentFilter *noiseFilder;

// UI
@property (nonatomic, strong) UISlider *_turbPowerSlider;
@property (nonatomic, strong) UISlider *_turbSizeSlider;
@property (nonatomic, strong) UISlider *_xPeriodSlider;
@property (nonatomic, strong) UISlider *_yPeriodSlider;
@property (nonatomic, strong) UISlider *_xyPeriodSlider;
@property (nonatomic, strong) UISlider *_zoomSlider;

@property (nonatomic, strong) UISwitch *_noiseTypeSwitch;
@property (nonatomic, strong) UISwitch *_specialTypeSwitch;
@property (nonatomic, strong) UISwitch *_smoothSwitch;
@property (nonatomic, strong) UISwitch *_turbSwitch;


@property (nonatomic, strong) UISlider *_colorSlider1;
@property (nonatomic, strong) UISlider *_colorSlider2;
@property (nonatomic, strong) UISlider *_colorSlider3;

@property (nonatomic, strong) UIView *_colorControllerView;
@property CGPoint hiddenX;
@property CGPoint shownX;



@property int selectedNoiseType;
@property bool isSmooth;
@property bool isSpecial;
@property bool hasTurb;


@property (nonatomic, strong) dispatch_queue_t renderingQueue;
@property (atomic, assign) uint64_t jobIndex;


@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self buildUI];
    
    self.renderingQueue = dispatch_queue_create("Rendering", DISPATCH_QUEUE_SERIAL);
    
    [self buildFilterGraph];
    [self updateImage];
    
    
}

-(void)buildUI
{
    // ImageView
    CGFloat imageViewY = 20;
    CGRect imageViewRect = CGRectMake(0, imageViewY, ScreenWidth(), ScreenWidth());
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:imageViewRect];
    [self.view addSubview:imageView];
    
    self.imageView = imageView;
    
    [self setupControls];
}



- (void)buildFilterGraph
{
    self.context = [MBEContext newContext];
    
    self.imageProvider = [MBEMainBundleTextureProvider textureProviderWithImageNamed:@"mandrill"
                                                                             context:self.context];
    
    self.noiseFilder = [JDMNoiseAdjustmentFilter filterWithTurbulencePower:1.0 context:self.context];
    self.noiseFilder.provider = self.imageProvider;
}

- (void)updateImage
{
    ++self.jobIndex;
    uint64_t currentJobIndex = self.jobIndex;
    
    // Grab these values while we're still on the main thread, since we could
    // conceivably get incomplete values by reading them in the background.
    
    
    float turbPower = __turbPowerSlider.value;
    float turbSize = __turbSizeSlider.value;
    float xPeriod = __xPeriodSlider.value;
    float yPeriod = __yPeriodSlider.value;
    float xyPeriod = __xyPeriodSlider.value;
    int noiseType = self.selectedNoiseType;
    float zoomAmount = __zoomSlider.value;
    bool isSmooth = self.isSmooth;
    bool isSpecial = self.isSpecial;
    bool hasTurb = self.hasTurb;
    
    // colors
    
    float color1 = __colorSlider1.value;
    float color2 = __colorSlider2.value;
    float color3 = __colorSlider3.value;
    
    
    dispatch_async(self.renderingQueue, ^{
        if (currentJobIndex != self.jobIndex)
            return;
        
        self.noiseFilder.turbulencePower = turbPower;
        self.noiseFilder.turbulenceSize = turbSize;
        self.noiseFilder.xPeriod = xPeriod;
        self.noiseFilder.yPeriod = yPeriod;
        self.noiseFilder.xyPeriod = xyPeriod;
        self.noiseFilder.noiseType = noiseType;
        self.noiseFilder.zoomAmount = zoomAmount;
        self.noiseFilder.isSmooth = isSmooth;
        self.noiseFilder.isSpecial = isSpecial;
        
        self.noiseFilder.color1 = color1;
         self.noiseFilder.color2 = color2;
         self.noiseFilder.color3 = color3;
        
        self.noiseFilder.hasTurb = hasTurb;
        
        
        
        id<MTLTexture> texture = self.noiseFilder.texture;
        UIImage *image = [UIImage imageWithMTLTexture:texture];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.imageView.image = image;
        });
    });
}
















#pragma mark - Interface

-(void)setupControls
{
    CGFloat height =  ScreenHeight() - ScreenWidth()-28;
    CGFloat Y = self.imageView.frame.size.height + self.imageView.frame.origin.y + 4;
    CGRect nextFrame = CGRectMake(0, Y, ScreenWidth(), height);
    
    UIView *controlsView = [[UIView alloc]initWithFrame:nextFrame];
    controlsView.backgroundColor = [UIColor lightGrayColor];
    
    CGFloat startY = 16;
    CGFloat labelH = 42;
    
    __turbPowerSlider = [self makeSliderOfType:@"Turbulence Power" atY:startY OfWidth:ScreenWidth()*0.80];
    __zoomSlider = [self makeSliderOfType:@"Zoom" atY:startY OfWidth:ScreenWidth()*0.80];
    __turbSizeSlider = [self makeSliderOfType:@"Turbulence Size" atY:startY+labelH OfWidth:ScreenWidth()*0.80];
    
    __xPeriodSlider = [self makeSliderOfType:@"X Period" atY:(startY+(labelH * 2)) OfWidth:ScreenWidth()*0.80];
    __yPeriodSlider = [self makeSliderOfType:@"Y Period" atY:(startY+(labelH * 3)) OfWidth:ScreenWidth()*0.80];
    __xyPeriodSlider = [self makeSliderOfType:@"XY Period (Rings)" atY:(startY+(labelH * 2)) OfWidth:ScreenWidth()*0.80];
    
    
    // noise switcher button
    CGFloat noiseSwitchH = 40;
    CGFloat noiseSwitchY = controlsView.frame.size.height - noiseSwitchH;
    
    CGRect noiseswitchLabelRect = CGRectMake(0, noiseSwitchY, 100, noiseSwitchH);
    
    UILabel *noiseSwitchLabel = [[UILabel alloc]initWithFrame:noiseswitchLabelRect];
    noiseSwitchLabel.text = @"Noise";
    noiseSwitchLabel.textAlignment = NSTextAlignmentCenter;
    noiseSwitchLabel.textColor = [UIColor whiteColor];
    noiseSwitchLabel.backgroundColor = [UIColor blackColor];
    noiseSwitchLabel.layer.cornerRadius = noiseSwitchH/2;
    noiseSwitchLabel.layer.masksToBounds = YES;
    noiseSwitchLabel.center = CGPointMake(controlsView.center.x, noiseSwitchY);
    [noiseSwitchLabel setUserInteractionEnabled:YES];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
    tap.numberOfTapsRequired = 1;
    [noiseSwitchLabel addGestureRecognizer:tap];
    
    
    // Switch
    CGFloat switchY = height - 28;
    CGFloat switchWidth = 32;
    CGFloat switchX = controlsView.frame.size.width - controlsView.frame.size.width/12;
    CGRect switchRect = CGRectMake(switchX, switchY, switchWidth, 28);
    __noiseTypeSwitch = [[UISwitch alloc]initWithFrame:switchRect];
    __noiseTypeSwitch.on = NO;
    __noiseTypeSwitch.onTintColor = [UIColor blackColor];
    __noiseTypeSwitch.center = __xPeriodSlider.center;
    [__noiseTypeSwitch addTarget:self action:@selector(handleNoiseTypeChanged:) forControlEvents:UIControlEventValueChanged];

    
    __specialTypeSwitch = [[UISwitch alloc]initWithFrame:switchRect];
    __specialTypeSwitch.on = NO;
    __specialTypeSwitch.onTintColor = [UIColor darkGrayColor];
    __specialTypeSwitch.thumbTintColor = [UIColor blueColor];
    __specialTypeSwitch.center = CGPointMake(__yPeriodSlider.center.x, __yPeriodSlider.center.x - 8);
    [__specialTypeSwitch addTarget:self action:@selector(handleNoiseTypeChanged:) forControlEvents:UIControlEventValueChanged];
    
    __turbSwitch = [[UISwitch alloc]initWithFrame:switchRect];
    __turbSwitch.on = NO;
    __turbSwitch.onTintColor = [UIColor orangeColor];
    __turbSwitch.thumbTintColor = [UIColor greenColor];
    __turbSwitch.center = CGPointMake(__specialTypeSwitch.center.x, __specialTypeSwitch.center.y - 40);
    [__turbSwitch addTarget:self action:@selector(handleNoiseTypeChanged:) forControlEvents:UIControlEventValueChanged];

    
    
    
    CGFloat buttonSizeNum = 32;
    CGSize buttonSize = CGSizeMake(buttonSizeNum, buttonSizeNum);
    CGFloat buttonY = controlsView.frame.size.height - buttonSize.height;
    CGRect buttonRect = CGRectMake(8, buttonY, buttonSize.width, buttonSize.height);
    UIButton *button = [UIButton buttonWithType:UIButtonTypeContactAdd];
    button.frame = buttonRect;
    button.showsTouchWhenHighlighted = YES;
    [button addTarget:self action:@selector(refreshButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [controlsView addSubview:__turbPowerSlider];
    [controlsView addSubview:__turbSizeSlider];
    [controlsView addSubview:__xPeriodSlider];
    [controlsView addSubview:__yPeriodSlider];
    [controlsView addSubview:__xyPeriodSlider];
    [controlsView addSubview:__zoomSlider];

    
    [controlsView addSubview:__noiseTypeSwitch];
    [controlsView addSubview:button];
    [controlsView addSubview:noiseSwitchLabel];
    [controlsView addSubview:__specialTypeSwitch];
    [controlsView addSubview:__turbSwitch];
    
    __colorControllerView = [self constructColorControlsViewForView:controlsView];
    
    
    
    [self.view addSubview:controlsView];
    
    
    
    

    
    
    
    [self setDefaultsForNoiseType:@"Noise"];
    self.selectedNoiseType = 0;
    self.isSmooth = false;
    self.hasTurb = NO;
    [__turbSizeSlider setEnabled:NO];
    
    
    
    
    [self recheckLabels];
    
     [self hideColorControls];

}


-(UIView*)constructColorControlsViewForView:(UIView*)containedView
{
    // make view
    // add sliders
    // __colorControllerView;
    CGSize ccSize = CGSizeMake(containedView.frame.size.width * 0.80, (containedView.frame.size.height/3)*2);
    
    CGRect ccRect = CGRectMake(containedView.frame.size.width * 0.20, 0, ccSize.width, ccSize.height);
    UIView *view = [[UIView alloc]initWithFrame:ccRect];
    
    view.layer.cornerRadius = ccSize.height/8;
    view.layer.masksToBounds = YES;
    
    view.backgroundColor = [UIColor colorWithRed:67/255.0f green:114/255.0f blue:170/255.0f alpha:1.0];
    
    CGFloat labelH = 50;
    
    CGFloat frameHeight = ccSize.height;
    
    CGFloat totalLabelH = labelH * 3;
    
    CGFloat startingY = frameHeight/2 - totalLabelH/2;
    
    CGFloat bumper = 12;
    
    startingY = startingY + bumper;
    
    CGFloat l1Y = startingY;
    CGFloat l2Y = startingY + labelH;
    CGFloat l3Y = startingY + (labelH * 2);
    
    CGFloat wid = ccSize.width * 0.80;
    
    __colorSlider1 = [self makeSliderOfType:@"Color 1" atY:l1Y OfWidth:wid];
    __colorSlider2 = [self makeSliderOfType:@"Color 2" atY:l2Y OfWidth:wid];
    __colorSlider3 = [self makeSliderOfType:@"Color 3" atY:l3Y OfWidth:wid];
    
    CGFloat max = 360;
    CGFloat min = 0.01;
    
    __colorSlider1.maximumValue = max;
    __colorSlider2.maximumValue = max;
    __colorSlider3.maximumValue = max;
    
    __colorSlider1.minimumValue = min;
    __colorSlider2.minimumValue = min;
    __colorSlider3.minimumValue = min;
    
    
    __colorSlider1.value = 94;
    __colorSlider2.value = 168;
    __colorSlider3.value = 147;
    
    CGFloat centerX = view.center.x - containedView.frame.size.width * 0.20;
    
    
    __colorSlider1.center = CGPointMake(centerX, __colorSlider1.center.y);
    __colorSlider2.center = CGPointMake(centerX, __colorSlider2.center.y);
    __colorSlider3.center = CGPointMake(centerX, __colorSlider3.center.y);
    
    [view addSubview:__colorSlider1];
    [view addSubview:__colorSlider2];
    [view addSubview:__colorSlider3];
    
    [containedView addSubview:view];
    
    
    _shownX = view.center;
    _hiddenX = CGPointMake(view.center.x + ccSize.width, view.center.y);
    
    

    
    
    return view;
}


-(void)showColorControls
{
    
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.65 initialSpringVelocity:0.82 options:UIViewAnimationOptionCurveEaseInOut animations:^{
       
        [__colorControllerView setHidden:NO];
        __colorControllerView.center = _shownX;
        

        
    } completion:^(BOOL finished) {
    }];
}


-(void)hideColorControls
{
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.65 initialSpringVelocity:0.82 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        //
        __colorControllerView.center = _hiddenX;
        
    } completion:^(BOOL finished) {
        //
         [__colorControllerView setHidden:YES];
    }];

}


#pragma mark - Handle Interaction

-(void)refreshButtonTapped:(UIButton*)button
{
    if (__colorControllerView.isHidden) {
        [self showColorControls];
    }
    else
    {
        [self hideColorControls];
    }
    
}



-(void)handleNoiseTypeChanged:(UISwitch*)noiseTypeSwitch
{
    if (noiseTypeSwitch == __turbSwitch) {
        if (__turbSwitch.isOn) {
            self.hasTurb = YES;
            [__turbSizeSlider setEnabled:YES];
        }
        else
        {
            [__turbSizeSlider setEnabled:NO];
            __turbSizeSlider.value = 0;
            self.hasTurb = NO;
        }
    }
    
    
    if (noiseTypeSwitch == __specialTypeSwitch) {
        
        if (__specialTypeSwitch.isOn) {
            self.isSpecial = true;
        }
        else
        {
            self.isSpecial = false;
        }
    }
    
    
    if (noiseTypeSwitch.isOn) {
        self.isSmooth = true;
    }
    else
    {
        self.isSmooth = false;
    }
    
    
    
    [self updateImage];
}




#pragma mark - Change Noise Type
-(void)handleTap:(UITapGestureRecognizer*)tap
{
    NSString *noiseTypeString;
    
    static int counter;
    
    if (counter > 3) {
        counter = 0;
    }
    
    switch (counter) {
        case 0:
            noiseTypeString = @"Noise";
            break;
        case 1:
            noiseTypeString = @"Marble";
            break;
        case 2:
            noiseTypeString = @"Wood";
            break;
        case 3:
            noiseTypeString = @"Terrain";
            
        default:
            break;
            
    }
    
    [self setDefaultsForNoiseType:noiseTypeString];
    
    UILabel* tappedLabel = (UILabel*)tap.view;
    tappedLabel.text = noiseTypeString;
    
    [self updateImage];
    
    counter++;
}


-(void)setDefaultsForNoiseType:(NSString*)noiseTypeString
{
    //TODO: redo into a switch statement
    
    if ([noiseTypeString isEqualToString:@"Wood"])
    {
//        [__noiseLayer setTurbPower:0.1];
//        [__noiseLayer setTurbSize:8];
//        [__noiseLayer setXyPeriod:12.0];

        self.selectedNoiseType = 2;
        
        [__turbSwitch setHidden:YES];
        [__xPeriodSlider setHidden:YES];
        [__yPeriodSlider setHidden:YES];
        [__xyPeriodSlider setHidden:NO];
        [__turbPowerSlider setHidden:NO];
        [__zoomSlider setHidden:YES];
        [__noiseTypeSwitch setHidden:YES];
        
        __turbPowerSlider.minimumValue = 0.01;
        __turbPowerSlider.value = 0.05;
        __turbPowerSlider.maximumValue = 1.0;
        
        __turbSizeSlider.minimumValue = 1.0;
        __turbSizeSlider.value = 4.0;
        __turbSizeSlider.maximumValue = 16;
        
        __xPeriodSlider.minimumValue = 1.0;
        __xyPeriodSlider.value = 5.0;
        __xPeriodSlider.maximumValue = 32;
        
        __yPeriodSlider.minimumValue = 1.0;
        __yPeriodSlider.value = 10.0;
        __yPeriodSlider.maximumValue = 32;
        
        __xyPeriodSlider.minimumValue = 1.0;
        __xyPeriodSlider.maximumValue = 32.0;
        __xyPeriodSlider.value = 4;
        return;
    }
    else if ([noiseTypeString isEqualToString:@"Marble"])
    {
//        [__noiseLayer setTurbPower:0.5];
//        [__noiseLayer setTurbSize:8];
//        [__noiseLayer setXPeriod:5.0];
//        [__noiseLayer setYPeriod:10.0];
        
        self.selectedNoiseType = 1;
        
        if (!__turbSizeSlider.isEnabled) {
            [__turbSizeSlider setEnabled:YES];
        }
        
        
        [__turbSwitch setHidden:YES];
        
        
        [__xPeriodSlider setHidden:NO];
        [__yPeriodSlider setHidden:NO];
        [__xyPeriodSlider setHidden:YES];
        [__turbPowerSlider setHidden:NO];
        [__zoomSlider setHidden:YES];
        [__noiseTypeSwitch setHidden:YES];
        
        
        __turbPowerSlider.minimumValue = 0.01;
        __turbPowerSlider.value = 0.5;
        __turbPowerSlider.maximumValue = 5.0;
        
        __turbSizeSlider.minimumValue = 1.0;
        __turbSizeSlider.value = 8.0;
        __turbSizeSlider.maximumValue = 16;
        
        __xPeriodSlider.minimumValue = 0;
        __xPeriodSlider.value = 5.0;
        __xPeriodSlider.maximumValue = 12;
        
        __yPeriodSlider.minimumValue = 0;
        __yPeriodSlider.value = 10.0;
        __yPeriodSlider.maximumValue = 12;
        
        __xyPeriodSlider.minimumValue = 1.0;
        __xyPeriodSlider.maximumValue = 32.0;
        __xyPeriodSlider.value = 12.0;
          return;
        
    }
    else if ([noiseTypeString isEqualToString:@"Noise"])
    {
//        [__noiseLayer setTurbSize:8];
//        [__noiseLayer setZoomAmount:2.0];
        
//         [self prepareYSliderForTerrain:NO];
//        [self prepareXSliderForTerrain:NO];
        
        [__turbSwitch setHidden:NO];
        
      
        
        self.selectedNoiseType = 0;
        
        [__xPeriodSlider setHidden:YES];
        [__yPeriodSlider setHidden:YES];
        [__xyPeriodSlider setHidden:YES];
        [__turbPowerSlider setHidden:YES];
        [__zoomSlider setHidden:NO];
        [__noiseTypeSwitch setHidden:NO];
        
        [__specialTypeSwitch setHidden:NO];
        
        __turbSizeSlider.minimumValue = 1;
        __turbSizeSlider.value = 1;
        __turbSizeSlider.maximumValue = 128;
        
        if (__turbSwitch.isOn) {
            __turbSizeSlider.value = 0;
            [__turbSizeSlider setEnabled:NO];
        }

        
        
        __zoomSlider.minimumValue = 0.001;
        __zoomSlider.value = 0.01;
        __zoomSlider.maximumValue = 1.0;
          return;
        
    }
    else if ([noiseTypeString isEqualToString:@"Terrain"])
    {
        self.selectedNoiseType = 3;
        
        [__turbSwitch setHidden:YES];
        
        [__xPeriodSlider setHidden:YES];
        [__yPeriodSlider setHidden:YES];
        [__xyPeriodSlider setHidden:NO];
        [__specialTypeSwitch setHidden:YES];
        
        __turbPowerSlider.minimumValue = 0;
        __turbPowerSlider.value = 0;
        __turbPowerSlider.maximumValue = 1.0;
        
        __turbSizeSlider.minimumValue = 1.0;
        __turbSizeSlider.value = 8.0;
        __turbSizeSlider.maximumValue = 128;
        
//        __yPeriodSlider.minimumValue = 1.0;
//        __yPeriodSlider.value = 145;
//        __yPeriodSlider.maximumValue = 360;
//        
//        __xPeriodSlider.minimumValue = 1.0;
//        __xPeriodSlider.maximumValue = 360;
//        __xPeriodSlider.value = 95.0;
        
//        [self prepareYSliderForTerrain:YES];
//        [self prepareXSliderForTerrain:YES];
        
        __xyPeriodSlider.minimumValue = 1.0;
        __xyPeriodSlider.maximumValue = 32.0;
        __xyPeriodSlider.value = 12.0;
          return;
        
    }
    
    
    
    [self recheckLabels];
}


-(void)prepareYSliderForTerrain:(BOOL)prepare
{
    if (prepare) {
        UILabel *label = (UILabel*)[__yPeriodSlider.subviews objectAtIndex:0];
        label.text = @"Color";
    }
    else
    {
        UILabel *label = (UILabel*)[__yPeriodSlider.subviews objectAtIndex:0];
        label.text = @"Y Period";

    }
}

-(void)prepareXSliderForTerrain:(BOOL)prepare
{
    if (prepare) {
        UILabel *label = (UILabel*)[__xPeriodSlider.subviews objectAtIndex:0];
        label.text = @"Color";
        
     CGPoint newCenter =  __specialTypeSwitch.center;
        
        [__specialTypeSwitch setHidden:YES];
        
        [__xPeriodSlider setCenter:newCenter];
        
        
        
        
    }
    else
    {
        UILabel *label = (UILabel*)[__xPeriodSlider.subviews objectAtIndex:0];
        label.text = @"X Period";
        
        CGPoint newCenter = __xyPeriodSlider.center;
        
        [__specialTypeSwitch setHidden:NO];
        
        [__xPeriodSlider setCenter:newCenter];

        
    }

}


-(void)recheckLabels
{
    
    
    
    NSArray *sliders = @[__turbSizeSlider,
                         __turbPowerSlider,
                         __xPeriodSlider,
                         __yPeriodSlider,
                         __xyPeriodSlider,
                         __zoomSlider,
                         ];
    
    for (UISlider *slider in sliders) {
        
        UILabel *label = (UILabel*)[slider.subviews objectAtIndex:1];
        label.text = [@"" stringByAppendingFormat:@"%.02f",slider.value];
        
        if (slider == __turbSizeSlider) {
            
            int sliderInt = slider.value;
            label.text = [@"" stringByAppendingFormat:@"%i",sliderInt];
            
        }
        
        if (slider == __xPeriodSlider) {
            int sliderInt = slider.value;
            label.text = [@"" stringByAppendingFormat:@"%i",sliderInt];
        }
        
        if (slider == __yPeriodSlider) {
            int sliderInt = slider.value;
            label.text = [@"" stringByAppendingFormat:@"%i",sliderInt];
        }
        
        if (slider == __xyPeriodSlider) {
            int sliderInt = slider.value;
            label.text = [@"" stringByAppendingFormat:@"%i",sliderInt];
        }
        
        if (slider == __zoomSlider) {
            int sliderInt = slider.value;
            label.text = [@"" stringByAppendingFormat:@"%i",sliderInt];
        }
    }
    
}




-(UISlider*)makeSliderOfType:(NSString*)sliderType atY:(CGFloat)Y OfWidth:(CGFloat)width
{
    CGFloat sliderSize = width;
    
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake((ScreenWidth()/2 - sliderSize/2) , Y , sliderSize, 26)];
    
    [slider addTarget:self action:@selector(handleSlider:) forControlEvents:UIControlEventAllTouchEvents];
    
    slider.minimumTrackTintColor = [UIColor blackColor];
    
    CGRect labelRect = CGRectMake(0, -8, sliderSize, 8);
    
    UILabel *title = [[UILabel alloc]initWithFrame:labelRect];
    title.textAlignment = NSTextAlignmentCenter;
    title.font = [UIFont fontWithName:@"Helvetica" size:10];
    title.text = sliderType;
    [slider addSubview:title];
    
    UILabel *valueLabel = [[UILabel alloc]initWithFrame:labelRect];
    valueLabel.textAlignment = NSTextAlignmentRight;
    valueLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
    valueLabel.text = [@"" stringByAppendingFormat:@"%.02f",slider.value];
    [slider addSubview:valueLabel];
    
    return slider;
}

-(void)handleSlider:(UISlider*)slider
{
    UILabel *label = (UILabel*)[slider.subviews objectAtIndex:1];
    label.text = [@"" stringByAppendingFormat:@"%.02f",slider.value];
    
    if (slider == __turbSizeSlider) {
        
        int sliderInt = slider.value;
        label.text = [@"" stringByAppendingFormat:@"%i",sliderInt];
    }
    
    if (slider == __xPeriodSlider) {
        int sliderInt = slider.value;
        label.text = [@"" stringByAppendingFormat:@"%i",sliderInt];
    }
    
    if (slider == __yPeriodSlider) {
        int sliderInt = slider.value;
        label.text = [@"" stringByAppendingFormat:@"%i",sliderInt];
    }
    
    if (slider == __xyPeriodSlider) {
        int sliderInt = slider.value;
        label.text = [@"" stringByAppendingFormat:@"%i",sliderInt];
    }
    
    if (slider == __zoomSlider) {
        int sliderInt = slider.value;
        label.text = [@"" stringByAppendingFormat:@"%i",sliderInt];
    }
    
    [self checkSlider:slider];
    [self updateImage];
}





-(void)checkSlider:(UISlider*)slider
{
    
    UILabel *label = (UILabel*)[slider.subviews objectAtIndex:1];
    label.text = [@"" stringByAppendingFormat:@"%.02f",slider.value];
    
}



@end
