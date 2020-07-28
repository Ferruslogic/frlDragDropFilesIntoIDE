# frlDragDropFilesIntoIDE
 Is a helper for LiveCode developers
 
### Author: 
[Ferrus Logic.](http://ferruslogic.com/)

### License: 
This code was developed by FerrusLogic and is distributed under the MIT license.

### Version:
1.0.0b
 
### Summary.
This code allows you to drag image, video, SVG and stack files to any of the open windows in our LiveCode IDE. This is only to help us when developing so it only runs under the development environment.
 
### Drag and drop images, audio, videos, SVG and stacks
To import an image, audio and video to LiveCode, just drag the or the files to LiveCode and they will be imported into your project.
Dragging a binary or script-only stack will open it in the LiveCode.
If you want to change the filename of an image or a player object, just drag and drop the file on top of it.
You can also import SVG files to LiveCode by dragging and dropping it. It will only be imported if it is supported by LiveCode.
 
### How do I start using this extension.
When started, LiveCode searches a particular folder for your custom extensions. Their locations vary by operating system:

Windows: My Documents / My LiveCode / Extensions

OS X: ~ / Documents / My LiveCode / Extensions

Linux: ~ / my_livecode / Extensions /

For this extension to be integrated with the LiveCode you can do it in two ways. The easy and the easiest.
 
### The easy way
You must copy the folder (com.ferruslogic.library.dragDropFilesIntoIDE.1.0.0) as it is in this repository to the root of your LiveCode custom extensions directory.
 
### The easiest
Open the stack startup.livecode and it will copy the extension folder to your custom extensions directory. As long as the folder (com.ferruslogic.library.dragDropFilesIntoIDE.1.0.0) is at the same level as this stack.

# Developed by
![Ferrus Logic Logo](https://ferruslogic.com/wp-content/uploads/2020/06/logo-Ferrus-Logic.svg)
