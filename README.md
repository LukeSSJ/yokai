# Yokai

A simple pixel art editor made in Godot.

⚠️ WARNING: Yokai is still early in development and may have bugs. Use at your own risk! ⚠️

See the user documentation [here](https://github.com/LukeSSJ/yokai/wiki)

## Features
* Drawing tools: Pencil, Rubber and Eyedropper
* Draw shapes: Line, Rectangle and Circle
* Flood fill tool
* Selection tool to move and copy parts of the image
* Simple transformations, 90deg rotatation and flip, that can be applied to the whole image or a selection
* Tabs to work with mulitple images
* Palettes
* Undos and redos
* Work in PNG. Don't get bogged down by custom file formats
* Unit tests to prevent regressions
* Made in Godot, making it simple to compile for all systems

## What it DOESN'T have
* Layers
* Anti-aliasing for drawing and shapes
* Its own image file format. You will work in PNG!
* Animation (this is most likely to change in future)

If you require these features you are better off with an editor like [Pixelorama](https://github.com/Orama-Interactive/Pixelorama)

## Why does this exist?
Despite the large choice of the image editors out there its quite difficult to find something free, easy to get running and simple. General purpose image editors like GIMP require configuration to work for pixel art and are not easy to use. Decicated pixel art editors are better but often have a lots of tools and features which I don't need to use which add complexity to both the user experience and source code.

Really what it comes down to is: I wanted a software that I could open, draw something, save it as a PNG then close without it nagging me to save it as its own magical image format.
