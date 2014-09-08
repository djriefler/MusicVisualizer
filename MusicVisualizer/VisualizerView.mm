//
//  VisualizerView.m
//  MusicVisualizer
//
//  Created by Duncan Riefler on 7/31/14.
//  Copyright (c) 2014 Bb. All rights reserved.
//

#import "VisualizerView.h"
#import "MeterTable.h"
#import <Quartz/Quartz.h>

@implementation VisualizerView {
    CAEmitterLayer * emitterLayer;
    CAEmitterLayer * sphereLayer;
    CAEmitterLayer * sphereLayer2;
    CAEmitterLayer * lineLayer;

    CAEmitterCell * cell;
    CAEmitterCell * sphereCell;
    
    CVDisplayLinkRef displayLink;
    MeterTable meterTable;
    
    CGPoint emitterCenter;
    float radius;
    float sphere1Angle;
    float sphere1Speed;
    float sphere2Angle;
    float sphere2Speed;
}

+ (Class)layerClass {
    return [CAEmitterLayer class];
}

- (id) initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self) {
        
        CAEmitterLayer * layer = [CAEmitterLayer layer];
        [layer setBackgroundColor:CGColorCreateGenericRGB(0.0, 0.0 , 0.0, 1.0)];
        [self setWantsLayer:YES];
        [self setLayer:layer];
        
        emitterLayer = (CAEmitterLayer *) self.layer;
        
        CGFloat width = self.frame.size.width;
        CGFloat height = self.frame.size.height;
        emitterCenter = CGPointMake(width/2, height/2 + 200);
        emitterLayer.emitterPosition = CGPointMake(width/2, height/2 + 100);
        emitterLayer.emitterSize = CGSizeMake(width - 80, 60);
        emitterLayer.emitterShape = kCAEmitterLayerRectangle;
        emitterLayer.renderMode = kCAEmitterLayerAdditive;
        
        cell = [CAEmitterCell emitterCell];
        cell.name = @"cell";

        CAEmitterCell * childCell = [CAEmitterCell emitterCell];
        childCell.name = @"childCell";
        childCell.lifetime = 1.0f /60.0f;
        childCell.birthRate = 60.0f;
        childCell.velocity = 0.0f;
        
        // Setup particle image
        NSImage * image = [NSImage imageNamed:@"particleTexture.png"];
        CGImageRef imageRef = [self CGImageCreateWithNSImage:image];
        childCell.contents = (__bridge id) imageRef;
        
        cell.emitterCells = @[childCell];
        
        // Set color ranges
        cell.color = CGColorCreateGenericRGB(1.0f, 0.53f, 0.0f, 0.8f);
        cell.redRange = 0.46f;
        cell.greenRange = 0.49f;
        cell.blueRange = 0.2f;
        cell.alphaRange = 0.55f;
        
        // Set color speeds
        cell.redSpeed = 0.11f;
        cell.greenSpeed = 0.07f;
        cell.blueSpeed = -0.25f;
        cell.alphaSpeed = 0.15f;
        
        // Set scale ranges
        cell.scale = 0.5f;
        cell.scaleRange = 0.5f;
        
        // Set cell lifetime
        cell.lifetime = 1.0f;
        cell.lifetimeRange  = .25f;
        cell.birthRate = 80;
        
        cell.velocity = 100.0f;
        cell.velocityRange = 300.0f;
        cell.emissionRange = M_PI * 2;
        
        emitterLayer.emitterCells = @[cell];
        
        
        // Sphere Layer
        sphereLayer  = [[CAEmitterLayer alloc] init];
        [emitterLayer addSublayer:sphereLayer];
        
        // Setup layer frame and emitter position/size
        float sphereXOffset = 100;
        float sphereYOffset = 100;
        float sphereX = sphereXOffset;;
        float sphereY = sphereYOffset;;
        float sphereWidth = 100;
        float sphereHeight = 100;
        sphereLayer.frame = CGRectMake(sphereX, sphereY, sphereWidth, sphereHeight);
        sphereLayer.emitterPosition = CGPointMake(sphereX, sphereY);
        sphereLayer.emitterSize = CGSizeMake(sphereWidth, sphereHeight);
        sphereLayer.emitterShape = kCAEmitterLayerSphere;
        sphereLayer.renderMode = kCAEmitterLayerSurface;
        
        // Create sphere cell 1
        sphereCell = [CAEmitterCell emitterCell];
        sphereCell.name = @"sphereCell";
        
        // Create child cell
        CAEmitterCell * sphereChildCell = [CAEmitterCell emitterCell];
        sphereChildCell.name = @"sphereChildCell";
        sphereChildCell.lifetime = 1.0f /60.0f;
        sphereChildCell.birthRate = 60.0f;
        sphereChildCell.velocity = 0.0f;
        
        // Set particle image
        sphereChildCell.contents = (__bridge id) imageRef;
        
        
        sphereCell.emitterCells = @[sphereChildCell];
        
        // Set color ranges
        sphereCell.color = CGColorCreateGenericRGB(0.9f, 0.7f, 0.0f, 0.8f);
        sphereCell.redRange = 0.1f;
        sphereCell.greenRange = 0.3f;
        sphereCell.blueRange = 0.0f;
        sphereCell.alphaRange = 0.55f;
        
        // Set color speeds
        sphereCell.redSpeed = 0.11f;
        sphereCell.greenSpeed = 0.07f;
        sphereCell.blueSpeed = 0.25f;
        sphereCell.alphaSpeed = 0.15f;
        
        // Set scale ranges
        sphereCell.scale = 0.5f;
        sphereCell.scaleRange = 0.5f;
        
        // Set cell lifetime
        sphereCell.lifetime = 1.0f;
        sphereCell.lifetimeRange  = .25f;
        sphereCell.birthRate = 100;
        
        sphereCell.velocity = 100.0f;
        sphereCell.velocityRange = 300.0f;
        sphereCell.emissionRange = M_PI * 2;
        
        sphereLayer.emitterCells = @[sphereCell];
        
        // Create 2nd sphere layer
        sphereLayer2 = [[CAEmitterLayer alloc] initWithLayer:sphereLayer];
        float sphere2X = emitterLayer.frame.size.width - sphereXOffset;
        float sphere2Y = emitterLayer.frame.size.height - sphereYOffset;;
        sphereLayer2.frame = CGRectMake(sphere2X, sphere2Y, sphereWidth, sphereHeight);
        
        sphereLayer2.emitterCells = @[sphereCell];
        [emitterLayer addSublayer:sphereLayer2];
        
        radius = sqrtf((powf((emitterCenter.x - sphereLayer.position.x), 2.0f) + powf((emitterCenter.y - sphereLayer.position.y), 2.0f)));
        radius = 320;
        
        
        sphere1Angle = atan((sphereLayer.position.y - emitterCenter.y) / (sphereLayer.position.x - emitterCenter.x))*180.0f / M_PI;
        if (sphereLayer.position.x < 160) {
            sphere1Angle += 180;
        }
        
        sphere2Angle = atan((sphereLayer2.position.y - emitterCenter.y) / (sphereLayer2.position.x - emitterCenter.x))* M_PI;
        if (sphereLayer2.position.x < 160) {
            sphere2Angle += 180;
        }
        
        
        // Line layer
        
        lineLayer = [[CAEmitterLayer alloc] init];
        [emitterLayer addSublayer:lineLayer];
        
        // Setup layer frame and emitter position/size
        float lineX = sphereLayer.position.x;
        float lineY = sphereLayer.position.y;
        float lineWidth = fabs(sphereLayer.position.x - sphereLayer2.position.x);
        float lineHeight = fabs(sphereLayer.position.y - sphereLayer2.position.y);
        lineLayer.frame = CGRectMake(lineX, lineY, lineWidth, lineHeight);
        lineLayer.emitterPosition = CGPointMake(lineX, lineY);
        lineLayer.emitterSize = CGSizeMake(lineWidth, lineHeight);
        lineLayer.emitterShape = kCAEmitterLayerSphere;
        lineLayer.renderMode = kCAEmitterLayerAdditive;
        
        lineLayer.emitterCells = @[sphereCell];
        
        // Other Line layer
        
        CAEmitterLayer * anotherLineLayer = [[CAEmitterLayer alloc] init];
        [emitterLayer addSublayer:anotherLineLayer];
        
        // Setup layer frame and emitter position/size
         lineX = 0;
         lineY = 0;
         lineWidth = self.frame.size.width;
         lineHeight = 100;
        anotherLineLayer.frame = CGRectMake(lineX, lineY, lineWidth, lineHeight);
        anotherLineLayer.emitterPosition = CGPointMake(lineX, lineY);
        anotherLineLayer.emitterSize = CGSizeMake(lineWidth, lineHeight);
        anotherLineLayer.emitterShape = kCAEmitterLayerSphere;
        anotherLineLayer.renderMode = kCAEmitterLayerAdditive;
        
        anotherLineLayer.emitterCells = @[sphereCell];

        CAEmitterLayer * anotherLineLayer2 = [[CAEmitterLayer alloc] init];
        [emitterLayer addSublayer:anotherLineLayer2];
        
        lineX = 0;
        lineY = 400;
        lineWidth = self.frame.size.width + 600;
        lineHeight = 100;
        anotherLineLayer2.frame = CGRectMake(lineX, lineY, lineWidth, lineHeight);
        anotherLineLayer2.emitterPosition = CGPointMake(lineX, lineY);
        anotherLineLayer2.emitterSize = CGSizeMake(lineWidth, lineHeight);
        anotherLineLayer2.emitterShape = kCAEmitterLayerSphere;
        anotherLineLayer2.renderMode = kCAEmitterLayerAdditive;
        
        anotherLineLayer2.emitterCells = @[sphereCell];
        
        // Setup callback loop
        CVDisplayLinkCreateWithActiveCGDisplays(&displayLink);
        CVDisplayLinkSetOutputCallback(displayLink, &MyDisplayLinkCallback, (__bridge void *)self);
        CVDisplayLinkStart(displayLink);
        
    }
    return self;
}

static CVReturn MyDisplayLinkCallback(CVDisplayLinkRef displayLink, const CVTimeStamp* now, const CVTimeStamp* outputTime, CVOptionFlags flagsIn, CVOptionFlags* flagsOut, void* displayLinkContext)
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [((__bridge VisualizerView*)displayLinkContext) update];
    });
    
    return kCVReturnSuccess;
}

- (void) update
{
    if (!_audioPlayer) {
        return;
    }
    float level;
    float scale = 0.5;
    float velocity = 200.0f;
    CGColorRef color = CGColorCreateGenericRGB(0.9f, 0.7f, 0.0f, 0.8f);
    CGColorRef sphereColor =  CGColorCreateGenericRGB(0.9f, 0.7f, 0.0f, 0.8f);
    
    if (_audioPlayer.playing )
    {
        [_audioPlayer updateMeters];
        
        float power = 0.0f;
        for (int i = 0; i < [_audioPlayer numberOfChannels]; i++) {
            power += [_audioPlayer averagePowerForChannel:i];
        }
        power /= [_audioPlayer numberOfChannels];
        
        level = meterTable.ValueAt(power);
        scale = level * 7;
        velocity = level * 3;
        NSLog(@"power: %f", level);
        if (level > 0.9) {
            color = CGColorCreateGenericRGB(0.5f, 0.0f, 1.0f, 0.8f);
        }
        if (level > 0.8) {
            sphereColor =  CGColorCreateGenericRGB(0.5f, 0.0f, 0.8f, 0.8f);
        }
    }
    
    [emitterLayer setValue:@(scale) forKeyPath:@"emitterCells.cell.emitterCells.childCell.scale"];
    [emitterLayer setValue:@(velocity) forKeyPath:@"emitterCells.cell.emitterCells.childCell.velocity"];
    
    cell.color = color;
    emitterLayer.emitterCells = @[cell];

    [self updateSpherePositionWithSpeed:level/5];
    
    sphereCell.color = sphereColor;
    sphereLayer.emitterCells = @[sphereCell];
    sphereLayer2.emitterCells = @[sphereCell];
    
}

- (void) updateSpherePositionWithSpeed:(int) speed
{
    sphere1Angle += 0.5;
    sphere2Angle += 0.5;
    
    float newX = emitterCenter.x + cos(sphere1Angle * (M_PI / 180.0f))*radius;
    float newY = emitterCenter.y + sin(sphere1Angle * (M_PI / 180.0f))*radius;
    sphereLayer.position = CGPointMake(newX, newY);
    
     newX = emitterCenter.x + cos(sphere2Angle * (M_PI / 180.0f))*radius;
     newY = emitterCenter.y + sin(sphere2Angle * (M_PI / 180.0f))*radius;
    
    sphereLayer2.position = CGPointMake(newX, newY);
    
    // Setup layer frame and emitter position/size
    float lineX;
    if(sphereLayer.position.x >sphereLayer2.position.x) {
        lineX = sphereLayer2.position.x;
    }
    else {
        lineX = sphereLayer.position.x;
    }
    float lineY;
    if(sphereLayer.position.y >sphereLayer2.position.y) {
        lineY = sphereLayer2.position.y;
    }
    else {
        lineY = sphereLayer.position.y;
    }
    float lineWidth = fabs(sphereLayer2.position.x - sphereLayer.position.x);
    float lineHeight = fabs(sphereLayer2.position.y - sphereLayer.position.y);
    lineLayer.frame = CGRectMake(lineX, lineY, lineWidth, lineHeight);
    lineLayer.emitterPosition = CGPointMake(lineX, lineY);
    lineLayer.emitterSize = CGSizeMake(lineWidth, lineHeight);
}

- (CGImageRef) CGImageCreateWithNSImage: (NSImage *)image  {
    NSSize imageSize = [image size];
    
    CGContextRef bitmapContext = CGBitmapContextCreate(NULL, imageSize.width, imageSize.height, 8, 0, [[NSColorSpace genericRGBColorSpace] CGColorSpace], kCGBitmapByteOrder32Host|kCGImageAlphaPremultipliedFirst);
    
    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithGraphicsPort:bitmapContext flipped:NO]];
    [image drawInRect:NSMakeRect(0, 0, imageSize.width, imageSize.height) fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0];
    [NSGraphicsContext restoreGraphicsState];
    
    CGImageRef cgImage = CGBitmapContextCreateImage(bitmapContext);
    CGContextRelease(bitmapContext);
    return cgImage;
}

@end
