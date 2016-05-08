//
//  Shaders.metal
//  ImageProcessing
//
//  Created by Warren Moore on 10/4/14.
//  Copyright (c) 2014 Metal By Example. All rights reserved.
//

#include <metal_stdlib>

using namespace metal;

struct NoiseUniforms
{
    float turbulencePower;
    float turbulenceSize;
    float xPeriod;
    float yPeriod;
    float xyPeriod;
    int noiseType;
    float zoomAmount;
    bool isSmooth;
    bool isSpecial;
    float color1;
    float color2;
    float color3;
    bool hasTurb;
    
};

constant uint NOISE_DIM = 512;
constant float PI = 3.14159;

// Noise Declarations
float rand(int x, int y);
float smoothNoise(float x, float y);
float turbulence(float x, float y, float size);
float turbulenceSmoothless(float x, float y, float size);
float turbulence(float x, float y, float size, bool shouldSmooth);


float3 HSL2RGB(float h, float sl, float l);
float3 RGBTOHSL(float r,float g, float b);
float threeway_max(float a, float b, float c);
float threeway_min(float a, float b, float c);




float4 noiseColor(int x, int y, float zoomAmount, bool isSmooth,float turbSize,bool hasTurb);
float4 marbleColor(int x, int y, float turbPower, float turbSize, float yPeriod,float xPeriod);
float4 woodColor(int x, int y, float turbPower, float turbSize, float xyPeriod);
float4 cloudNoiseColor(int x, int y,float zoomAmount, bool isSmooth,float turbSize);
float4 latticeNoiseColor(int x, int y, float turbPower, float turbSize,float c1, float c2,float c3, uint h,uint w,float xyPeriod);







// The Kernel
kernel void adjust_noise(texture2d<float, access::read> inTexture [[texture(0)]],
                         texture2d<float, access::write> outTexture [[texture(1)]],
                         constant NoiseUniforms &uniforms [[buffer(0)]],
                         uint2 gid [[thread_position_in_grid]])
{
    
    
    uint w = inTexture.get_width(0);
    uint h = inTexture.get_height(0);

    float4 outColor;
    
    if (uniforms.noiseType == 0)
    {
        // Noise
        if (uniforms.isSpecial == true)
        {
            outColor = cloudNoiseColor(gid.x,gid.y,uniforms.zoomAmount,uniforms.isSmooth,uniforms.turbulenceSize);
        }
        else
        {
            outColor = noiseColor(gid.x,gid.y,uniforms.zoomAmount,uniforms.isSmooth,uniforms.turbulenceSize,uniforms.hasTurb);
        }
        
    }
    else if (uniforms.noiseType == 1)
    {
        // Marble
        outColor = marbleColor(gid.x,gid.y, uniforms.turbulencePower,uniforms.turbulenceSize,uniforms.xPeriod,uniforms.yPeriod);
    }
    else if (uniforms.noiseType == 2)
    {
        // Wood
        outColor =  woodColor(gid.x,gid.y, uniforms.turbulencePower,uniforms.turbulenceSize,uniforms.xyPeriod);
    }
    else if (uniforms.noiseType == 3)
    {
        outColor = latticeNoiseColor(gid.x,gid.y, uniforms.turbulencePower,uniforms.turbulenceSize,uniforms.color1,uniforms.color2,uniforms.color3 ,h,w,uniforms.xyPeriod);
    }
    
    
    
    outTexture.write(outColor, gid);
}





// Noise Colors
//
// Marble
float4 marbleColor(int x, int y, float turbPower, float turbSize, float yPeriod,float xPeriod)
{
    float xyValue = x * xPeriod / NOISE_DIM + y * yPeriod / NOISE_DIM + turbPower * turbulence(x, y, turbSize) / 256.0;
    float sineValue = 256 * fabs(sin(xyValue * PI));
    
    return float4(sineValue/255.0,sineValue/255.0,sineValue/255.0,1.0);
}

// Wood
float4 woodColor(int x, int y, float turbPower, float turbSize, float xyPeriod)
{
    float noiseSize = NOISE_DIM;
    
    float xValue = (x - noiseSize / 2) / noiseSize;
    float yValue = (y - noiseSize / 2) / noiseSize;
    float distValue = sqrt(xValue * xValue + yValue * yValue) + turbPower * turbulence(x, y, turbSize) / 256.0;
    float sineValue = 128 * fabs(sin(2 * xyPeriod * distValue * PI));
    
    float r = sineValue+80.0;
    float g = sineValue+30.0;
    float b = 30.0;
    
    
    return float4(r/255.0,g/255.0,b/255.0,1.0);
}

// Noise
float4 noiseColor(int x, int y,float zoomAmount, bool isSmooth,float turbSize,bool hasTurb)
{
    float colorVal;
    
    float xVal = x;
    float yVal = y;
    
    float xZoomed = xVal/zoomAmount;
    float yZoomed = yVal/zoomAmount;
    
    // straight noise
    colorVal = 256.0 * rand(xZoomed,yZoomed);
    
    // no turbulence
    if (isSmooth == true)
    {
        colorVal = 256.0 * smoothNoise(xZoomed,yZoomed);
        
    }
    
    
    
    if (hasTurb == true)
    {
         colorVal = 256 * turbulence(xZoomed, yZoomed, turbSize, isSmooth);
    }
    
    
    return float4(colorVal/255.0,colorVal/255.0,colorVal/255.0,1.0);
}

float4 cloudNoiseColor(int x, int y,float zoomAmount, bool isSmooth,float turbSize)
{
    
    float xVal = x;
    float yVal = y;
    
    float xZoomed = xVal/zoomAmount;
    float yZoomed = yVal/zoomAmount;
    
    float L = 192 + ( turbulenceSmoothless(xZoomed, yZoomed, turbSize) / 3 );
    
    if (isSmooth == true)
    {
        L = 192 + ( turbulence(xZoomed, yZoomed, turbSize) / 3 );
        
    }
    
    
    
    
    
    
    
    
    float h = 169/255.0;
    float s = 1;
    float l = L/255.0;
    
    float3 newColorVal = HSL2RGB(h,s,l);
    
    float r = newColorVal.x;
    float g = newColorVal.y;
    float b = newColorVal.z;
   
    return float4(r/255.0,g/255.0,b/255.0,1.0);
}

float4 latticeNoiseColor(int x, int y, float turbPower, float turbSize,float c1, float c2,float c3, uint h,uint w,float xyPeriod)
{
    float dim = 512;
    float divisor = 256;
    
    float nDim = 256;
    
    float xValue = (x - nDim / 2) / dim + turbPower * ( turbulence(x, y, turbSize) / divisor );
    float yValue = (y - nDim / 2) / dim + turbPower * (turbulence(w - x, h - y, turbSize)/ divisor );
    
    
    //float colorValue = 113; // 113

    float sineValue = c1 * fabs(sin(xyPeriod * xValue * PI) + sin(xyPeriod * yValue * PI));
    
    
    
  
    // 147
    
    //113
    float3 colorHSL = RGBTOHSL(sineValue,c3,c2);
    
    //colorHSL.x = xPeriod;
    
    
    
    float3 newColorVal = HSL2RGB(colorHSL.x,colorHSL.y,colorHSL.z);
    
    float r = newColorVal.x;
    float b = newColorVal.y;
    float g = newColorVal.z;
    
    return float4(r/255.0,g/255.0,b/255.0,1.0);
}









// Noise Functions
float smoothNoise(float x, float y)
{
    // Get the truncated x, y, and z values
    int intX = x;
    int intY = y;
    
    // Get the fractional reaminder of x, y, and z
    float fractX = x - intX;
    float fractY = y - intY;
    
    // Get first whole number before
    int x1 = (intX + NOISE_DIM) % NOISE_DIM;
    int y1 = (intY + NOISE_DIM) % NOISE_DIM;
    
    // Get the number after
    int x2 = (x1 + NOISE_DIM - 1) % NOISE_DIM;
    int y2 = (y1 + NOISE_DIM - 1) % NOISE_DIM;
    
    // interpolate the noise
    float value = 0.0;
    value += fractX       * fractY       * rand(x1,y1);
    value += fractX       * (1 - fractY) * rand(x1,y2);
    value += (1 - fractX) * fractY       * rand(x2,y1);
    value += (1 - fractX) * (1 - fractY) * rand(x2,y2);
    
    return value;
}


float turbulence(float x, float y, float size)
{
    float value = 0.0, initialSize = size;
    
    while(size >= 1)
    {
        value += smoothNoise(x / size, y / size) * size;
        size /= 2.0;
    }
    
    return(128.0 * value / initialSize);
}

float turbulence(float x, float y, float size, bool shouldSmooth)
{
    float value = 0.0, initialSize = size;
    
    while(size >= 1)
    {
        
        
        value += rand(x / size, y / size) * size;
        size /= 2.0;

        
        
        if (shouldSmooth == true)
        {
            value += smoothNoise(x / size, y / size) * size;
            size /= 2.0;
        }
        
    }
    
    return(128.0 * value / initialSize);
}








float turbulenceSmoothless(float x, float y, float size)
{
    float value = 0.0, initialSize = size;
    
    while(size >= 1)
    {
        value += rand(x / size, y / size) * size;
        size /= 2.0;
    }
    
    return(128.0 * value / initialSize);
}



// Generate a random float in the range [0.0f, 1.0f] using x, y, and z (based on the xor128 algorithm)
float rand(int x, int y)
{
    int seed = x + y * 57 * 241;
    seed = (seed<< 13) ^ seed;
    return (( 1.0 - ( (seed * (seed * seed * 15731 + 789221) + 1376312589) & 2147483647) / 1073741824.0f) + 1.0f) / 2.0f;
}

// Given H,S,L in range of 0-1
// Returns a Color (RGB struct) in range of 0-255
float3 HSL2RGB(float h, float sl, float l)
{
    float v;
    float r,g,b;
    
    r = l;   // default to gray
    g = l;
    b = l;
    v = (l <= 0.5) ? (l * (1.0 + sl)) : (l + sl - l * sl);
    if (v > 0)
    {
        float m;
        float sv;
        int sextant;
        float fract, vsf, mid1, mid2;
        
        m = l + l - v;
        sv = (v - m ) / v;
        h *= 6.0;
        sextant = (int)h;
        fract = h - sextant;
        vsf = v * sv * fract;
        mid1 = m + vsf;
        mid2 = v - vsf;
        switch (sextant)
        {
            case 0:
                r = v;
                g = mid1;
                b = m;
                break;
            case 1:
                r = mid2;
                g = v;
                b = m;
                break;
            case 2:
                r = m;
                g = v;
                b = mid1;
                break;
            case 3:
                r = m;
                g = mid2;
                b = v;
                break;
            case 4:
                r = mid1;
                g = m;
                b = v;
                break;
            case 5:
                r = v;
                g = m;
                b = mid2;
                break;
        }
    }
    
    float3 returnColor;
    
    returnColor.x = r * 255.0f;
    returnColor.y = g * 255.0f;
    returnColor.z = b * 255.0f;
    
    return returnColor;
}


float3 RGBTOHSL(float r,float g, float b)
{
    float rd = r/255;
    float gd = g/255;
    float bd = b/255;
    float max = threeway_max(rd, gd, bd);
    float min = threeway_min(rd, gd, bd);
    float h, s, l = (max + min) / 2;
    
    if (max == min) {
        h = s = 0; // achromatic
    } else {
        float d = max - min;
        s = l > 0.5 ? d / (2 - max - min) : d / (max + min);
        if (max == rd) {
            h = (gd - bd) / d + (gd < bd ? 6 : 0);
        } else if (max == gd) {
            h = (bd - rd) / d + 2;
        } else if (max == bd) {
            h = (rd - gd) / d + 4;
        }
        h /= 6;
    }
    
    return float3(h,s,l);
    
}

float threeway_min(float a, float b, float c) {
    return max(a, max(b, c));
}

float threeway_max(float a, float b, float c) {
    return min(a, min(b, c));
}








