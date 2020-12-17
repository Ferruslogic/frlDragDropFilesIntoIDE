# frlDragDropFilesIntoIDE

This plugin allows you to drag image, video, SVG and plain text files and import them into any of the LiveCode IDE's open windows.


### LEEME en español [(aquí)](LEEME.md)

### See the [conduct code](CODE_OF_CONDUCT.md)

## Author:

Developed by [FerrusLogic](https://ferruslogic.com)



## License:

frlDragDropFilesIntoIDE is distributed under the [MIT license](LICENSE).



## Current version: 1.0.6



## Installation

To install the plugin use the **dragdropFilesIntoIDEInstaller.livecode** stack. It will copy the extension to your LiveCode extensions folder.

## Supported files

The multimedia files that are imported will be those with the following extensions.

### Image:

`` png, jpeg, jpg, gif, bmp, pbm, pgm, ppm, xbm, xpm, xwd, pict, webp, jfif, tif, tiff, dib, vga, pict, pict2, pic ``

### Audio and video:

`` mp3, mp4, mpg, mov, avi, m4a, midi, midi, snd, aac, wma, ogg, mpeg, m2v, mpeg2, qt, ram, rm``

### SVG:

``svg``

### Plain text:

`` txt, lng, locale, log, mnu, nfo, inf, ini, inc, bar, cfg, sav, conf, manifest, lst, ion, rc, properties, mf, list, wbt, lic, css, hs, iss, js, nsi, nsh, java, php, php3, php4, php5, tct, xml, xsml, xsl, kml, adr, sfx ,, sh, bsh, lua, pl, pm, py, as, las, mx , vb, f, for, f90, f95, f2k, tex, mak, tpl, asm, plx, lsp, lisp, scm, smd, ss, kix, au3, ml, mli, sml, thy, ada, ads, adb , v, lhs, cmake, twig, yml``

### Stacks

In addition to the multimedia files, we also have the possibility of dragging any binary or code-only stack to our IDE to open it.

 `` livecode, livecodescript, rev, mc ``

### Replace one multimedia with another.

To update the content of a multimedia object in the IDE. We press the Alt + Shift keys on Windows and Option + shift on Mac OS. Then we drag and drop the file onto the object. So if we have an image in our stack we press the keys according to our operating system and we drop the file of the new image without releasing the keys and the content of the image will be replaced.
