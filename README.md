# MetalNoise
a Perlin Noise Visualizer for iOS powered by Metal 

![alt text](https://github.com/jmade/jmade.github.io/blob/master/metalnoise.png?raw=true "Metal Noise")

## Overview

A Perlin Noise Visulizer powered by 🤘 `Metal`. 

This is to demonstrate the flexiblility of using noise with simple colors and some basic math to create a number of different visualizations. 

I first started out trying to use a `CALayer` to render the results, but it was incredibly slow. I quickly realized why and rewrote my implementation using the `Metal` framework to do the rendering as a compute shader. 

Most of the routines were followed and adapted to the `MetalShadingLanguage` from [this site](http://freespace.virgin.net/hugo.elias/models/m_perlin.htm).

For the Implementation I used sample code and learned from articles at [Metal By Example](http://metalbyexample.com).

## Clouds

![Alt Text](https://github.com/jmade/jmade.github.io/blob/master/clouds.gif?raw=true)

This is your typical white Noise example. flicking on the green and blue switches will switch the colors to blue and you can adjust the zoom slider control to see it in more or less detail

## Marble

![Alt Text](https://github.com/jmade/jmade.github.io/blob/master/marble.gif?raw=true)

The X and Y sliders will adjust the amount of lines in the vertical and horizontal directions. 


## Wood

![Alt Text](https://github.com/jmade/jmade.github.io/blob/master/wood.gif?raw=true)

The rings slider adjusts how many rings are formed 

## Terrain

![Alt Text](https://github.com/jmade/jmade.github.io/blob/master/terrain_first.gif?raw=true)

The pattern here is a lattice or diamond. Tapping on the blue circle with a plus sign on the bottom left corner will produce a menu with sliders allowing you to change the end result manipulating the colors. 

## Metal 
This was my first taste of the `Metal` framework and I was both intrigued and impressed by the approach and power. 



