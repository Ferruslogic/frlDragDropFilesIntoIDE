script "com.ferruslogic.library.dragDropFilesIntoIDE"
/*
Copyright (c) 2020 FerrusLogic

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files the frlDragDropFilesIntoIDE, to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

Summary
This small library is to aid in the application creation process by
allowing you to drag files into the development IDE. So it only runs
in development mode for the time being.

version 1.0.1
Made: 2020-07-09 15:20
Last Update: 2020-08-06 09:39
*/

# list of files being dragged.
local sFiles

# The stack that is on top.
local sTopStack

# Graph that is dynamically created in the background for the DragDrop event to be sent.
local sLongIdBackGraphic

# The object that is the object and its type.
local sDragDestination, sTypeDragDestination

# The last control that was imported. It is to select it at the end of everything.
local sLastControl

# Whether to import into the dragDestination or create a new object.
local sReplace

constant kBynaryStack = "livecode,rev,mc"
constant kScriptOnlyStack = "livecodescript"
constant kAudio = "mp3,mp4,mpg,mov,avi,m4a,midi,midi,snd,aac,wma,ogg,mpeg,m2v,mpeg2,qt,ram,rm"
constant kImage = "svg,png,jpeg,jpg,gif,bmp,pbm,pgm,ppm,xbm,xpm,xwd,pict,webp,jfif,tif,tiff,dib,vga,pict,pict2,pic"
constant kTextPlan = "json,html,htm,txt,lng,locale,log,mnu,nfo,inf,ini,inc,bar,cfg,sav,conf,manifest,lst,ion,rc,properties,mf,list,wbt,lic,css,hs,iss,js,nsi,nsh,java,php,php3,php4,php5,tct,xml,xsml,xsl,kml,adr,sfx,,sh,bsh,lua,pl,pm,py,as,las,mx,vb,f,for,f90,f95,f2k,tex,mak,tpl,asm,plx,lsp,lisp,scm,smd,ss,kix,au3,ml,mli,sml,thy,ada,ads,adb,v,lhs,cmake,twig,yml"


on extensionInitialize
   if the target is not me then
      pass extensionInitialize
   end if

   if the environment contains "development" then
      insert the script of me into front
      set the _ideoverride of me to true
   end if
end extensionInitialize

on extensionFinalize
   if the target is not me then
      pass extensionFinalize
   end if

   remove the script of me from front
end extensionFinalize


on dragEnter
   set the acceptDrop to _filesTypeDragDrog(sFiles)

   _acceptDrop

   pass dragEnter
end dragEnter


on dragMove
   _acceptDrop

   pass dragMove
end dragMove


private command _acceptDrop

   _setDefaultStack

   put the dragData["files"] into sFiles

   if sFiles is empty then exit _acceptDrop

   if the mouse is down and sFiles is not empty and there is not graphic "frlDragDropBack" of this cd of stack sTopStack then

      # I create this graph because the drag & drop message is not generated on the card
      create invisible graphic "frlDragDropBack" in this cd
      put it into sLongIdBackGraphic

      set the rect of sLongIdBackGraphic to the rect of this cd of stack sTopStack

      try
         set the opaque of sLongIdBackGraphic to true
         set the blendlevel of sLongIdBackGraphic to 100
         set the visible of sLongIdBackGraphic to true
         set the layer  of sLongIdBackGraphic to 1
      end try

      put empty into sDragDestination
      put empty into sTypeDragDestination
      put empty into sReplace

   end if

   set the acceptDrop to _filesTypeDragDrog(sFiles)

end _acceptDrop


on dragDrop
   if sFiles is empty then pass dragDrop

   _deleteBackgroundGraphic

   put the optionKey is down and the shiftKey is down and the number of lines of sFiles is 1  into sReplace

   if sFiles is not empty then
      lock screen; lock messages;lock cursor

      set the cursor to watch

      repeat for each line tFile in sFiles
         _importFile tFile
      end repeat

      unlock messages

      choose pointer tool

      if there is a sLastControl then
         focus on nothing
         select empty
         select sLastControl
      end if

      unlock screen; unlock cursor
      exit dragDrop
   end if

   pass dragDrop
end dragDrop


# remove data being dragged.
on dragEnd
   if sFiles is empty then pass dragEnd

   delete the dragSource
   _deleteBackgroundGraphic
   pass dragEnd
end dragEnd

on dragLeave
   if sFiles is empty then pass dragLeave

   _deleteBackgroundGraphic
   pass dragLeave
end dragLeave

private command _importFile pFilePath
   local tExtencion
   set the itemdel to "."

   put _DragDestination() into sDragDestination

   put word 1 of sDragDestination into sTypeDragDestination
   put item - 1 of pFilePath into tExtencion

   if there is a file pFilePath then
      set the itemdel to comma

      switch


         case tExtencion is "svg"
            _importPathSVG pFilePath
            break

            # LiveCode, Revolution and MetaCard binary stack files
         case tExtencion is among the items of kBynaryStack
            unlock messages
            open stack pFilePath
            lock messages
            break

            # Script-only stack
         case tExtencion is kScriptOnlyStack
            --open stack pFilePath
            edit the script of stack pFilePath
            break

            # Images file
         case tExtencion is among the items of kImage
            _importImage pFilePath, "file"
            break

            # Audio and Videos file
         case tExtencion is among the items of kAudio
            _importPlayer pFilePath
            break

            # Text Plan
         case tExtencion is among the items of kTextPlan
            _importTextPlan pFilePath
            break

      end switch

   end if
end _importFile


private  command _importImage pPathOrData, pType
   local tNameFile, tImageData, tNewImage, tMouseLoc

   set the itemdel to slash

   _setDefaultStack



   if there is a stack sTopStack then

      if pType is "file" then
         if there is a sDragDestination and sTypeDragDestination is "image" and sReplace is true  then

            if the filename of sDragDestination is empty then
               set the text of sDragDestination to URL ("binfile:" & pPathOrData)
            else
               set the filename of sDragDestination to _convertPathToRelativePath(pPathOrData)
            end if

            put sDragDestination into sLastControl
            exit _importImage
         end if

         put the mouseLoc into tMouseLoc
         set the text of templateImage to URL ("binfile:" & pPathOrData)

         put item - 1 of pPathOrData into tNameFile
         create image tNameFile in this cd
         put it into tNewImage

         if the text of tNewImage is empty then
            set the filename of tNewImage to _convertPathToRelativePath(pPathOrData)
         end if

         if there is tNewImage then
            if within(stack sTopStack, tMouseLoc) then
               set the loc of tNewImage to tMouseLoc
            else
               set the loc of tNewImage to (the loc of cd 1 of stack sTopStack)
            end if

            put tNewImage into sLastControl
         end if

         reset templateImage

      else
         local tOldText, tNewText
         put drawingSvgCompileFile(pPathOrData) into tNewText

         if there is a sDragDestination and sTypeDragDestination is "image" then
            put the text of sDragDestination  into tOldText

            set the text of sDragDestination to tNewText

            if the text of sDragDestination is empty then
               set the text of sDragDestination to tOldText
            end if

         else
            put the mouseLoc into tMouseLoc
            set the text of templateImage to tNewText

            put item - 1 of pPathOrData into tNameFile
            create image tNameFile in this cd
            put it into tNewImage


            if there is tNewImage then
               if within(stack sTopStack, tMouseLoc) then
                  set the loc of tNewImage to tMouseLoc
               else
                  set the loc of tNewImage to (the loc of cd 1 of stack sTopStack)
               end if

               put tNewImage into sLastControl
            end if
            reset templateImage
         end if
      end if
   end if

end _importImage

private command _importPlayer pPathOrData
   local tNameFile, tNumPlayer
   set the itemdel to slash

   _setDefaultStack

   if there is a stack sTopStack then

      if there is a sDragDestination and sTypeDragDestination is "player" and sReplace is true then

         set the filename of sDragDestination to _convertPathToRelativePath(pPathOrData)
         put sDragDestination into sLastControl
      else
         local tNewPlayer, tMouseLoc

         put the mouseLoc into tMouseLoc
         set the filename of templatePlayer to _convertPathToRelativePath(pPathOrData)
         set the showController of templatePlayer to true

         put item - 1 of pPathOrData into tNameFile
         create player tNameFile in this cd
         put it into tNewPlayer

         if within(stack sTopStack, tMouseLoc) then
            set the loc of tNewPlayer to tMouseLoc
         else
            set the loc of tNewPlayer to (the loc of cd 1 of stack sTopStack)
         end if
         put tNewPlayer into sLastControl
      end if

      reset templatePlayer
   end if

end _importPlayer

private command _importPathSVG pFilePath
   local tNewWidget, tPathSVG

   set the itemdel to slash

   _setDefaultStack

   put _getPathSVG(pFilePath) into tPathSVG

   if there is a stack sTopStack then
      if  tPathSVG is not empty then

         local tKind
         try
            put the kind of sDragDestination into tKind
         end try

         if there is a sDragDestination and sTypeDragDestination is "widget" and tKind is "com.livecode.widget.svgpath" and sReplace is true then

            set the iconPath of sDragDestination to tPathSVG

            put sDragDestination into sLastControl
         else
            local tMouseLoc
            put the mouseLoc into tMouseLoc

            create widget as "com.livecode.widget.svgpath" in this cd
            put it into tNewWidget

            set the iconPath of tNewWidget to tPathSVG
            set the width of tNewWidget to 180
            set the height of tNewWidget to 180

            if within(stack sTopStack, tMouseLoc) then
               set the loc of tNewWidget to tMouseLoc
            else
               set the loc of tNewWidget to (the loc of cd 1 of stack sTopStack)
            end if

            put tNewWidget into sLastControl
         end if
      else
         _importImage pFilePath, "SVG_Data"
      end if
   end if
end _importPathSVG

command _importTextPlan pFilePath
   local tText

   _setDefaultStack

   if there is a stack sTopStack then
      put URL("file:" & pFilePath) into tText

      if there is a sDragDestination and sTypeDragDestination is "field" and sReplace is true then
         set the text of sDragDestination to tText

      else
         set the text of templateField to tText
         create field

         reset templateField
      end if
   end if

end _importTextPlan

private command _setDefaultStack

   put the short name of the topstack into sTopStack
   set the defaultStack to sTopStack
end _setDefaultStack

private function _DragDestination
   local tStack, tDragDestination

   _setDefaultStack

   put the dragDestination into tDragDestination

   if there is a stack sTopStack then

      if there is  tDragDestination then
         put the long id of tDragDestination into tDragDestination

         put _meOwnerStack(tDragDestination) into tStack

         if there is a tDragDestination and  tStack is the long name stack sTopStack then
            return tDragDestination
         end if

      end if

      return the long id of this cd
   end if
end _DragDestination

private function _meOwnerStack pLongIdControl
   local tOffset, tLongStack, tDragDestination

   put the long id of pLongIdControl into tDragDestination

   put wordOffset("stack",tDragDestination) into tOffset
   put word tOffset to -1 of tDragDestination into tLongStack

   return tLongStack
end _meOwnerStack

private command _deleteBackgroundGraphic

   if there is sLongIdBackGraphic then
      delete sLongIdBackGraphic
      delete variable sLongIdBackGraphic
   end if

end _deleteBackgroundGraphic

private function _convertPathToRelativePath pPath
   local tStackPath

   set the itemdel to slash

   if there is not a stack sTopStack then return pPath

   put item 1 to - 2 of the effective filename of stack sTopStack into tStackPath
   if there is not a folder tStackPath then return pPath

   replace backslash with slash in pPath
   replace tStackPath & slash with empty in pPath

   return pPath
end _convertPathToRelativePath


private function _getPathSVG pFilePath
   local tInPathSVG, tOutPathSVG, tWidget

   _setDefaultStack

   put empty into tOutPathSVG

   if there is a stack sTopStack then
      put URL("file:" & pFilePath) into tInPathSVG

      create widget as "com.livecode.widget.svgpath"
      put it into tWidget

      try
         set the iconPath of tWidget to tInPathSVG
         put tInPathSVG into tOutPathSVG
      end try

      delete tWidget
   end if

   return tOutPathSVG
end _getPathSVG


private function _filesTypeDragDrog pFiles
   local tResult, tExtension
   put false into tResult

   repeat for each line tFile in pFiles

      set the itemdel to "."
      put item - 1 of tFile into tExtension

      set the itemdel to comma

      if tExtension is among the items of (kBynaryStack,kScriptOnlyStack,kAudio,kImage,kTextPlan) then
         put true into tResult
         exit repeat
      end if
   end repeat

   return tResult
end _filesTypeDragDrog
