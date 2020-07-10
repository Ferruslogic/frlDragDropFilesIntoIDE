script "com.ferruslogic.library.dragDropFilesIntoID"
## This small library is to aid in the application creation process by 
## allowing you to drag files to our development ID. So it only runs
## in development mode for the time being.
##
## By FerrusLogic
## version 1.0.0b
## Date: 2020-07-09 15:20

local sFiles
local sTopStack
local sLongIdBackGraphic
local sTarget, sTypeTarget

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


--on dragStart

--   set the allowableDragActions to "copy"
--   set the dragAction to "copy"

--   pass dragStart
--end dragStart

on dragMove
   
   _setDefaultStack
   
   put the dragData["files"] into sFiles
   
   if the mouse is down and sFiles is not empty and there is not graphic "frlDragDropBack" of this cd of stack sTopStack then
      
      # I create this graph because the drag & drop message is not generated on the card
      create invisible graphic "frlDragDropBack" in this cd
      put it into sLongIdBackGraphic
      
      set the rect of sLongIdBackGraphic to the rect of this cd of stack sTopStack 
      set the opaque of sLongIdBackGraphic to true
      set the blendlevel of sLongIdBackGraphic to 100
      set the backcolor of sLongIdBackGraphic to 0,0,0
      set the visible of sLongIdBackGraphic to true
      set the layer  of sLongIdBackGraphic to 1
      
      put "" into sTarget
      put "" into sTypeTarget
      set the acceptDrop to true
      
   end if
   
   set the acceptDrop to sFiles is not empty
   
   pass dragMove
end dragMove

on dragDrop
   
   _deleteBackgroundGraphic
   
   if sFiles is not empty then
      lock screen
      lock messages
      set the cursor to watch
      lock cursor
      
      repeat for each line tFile in sFiles
         _importFile tFile
      end repeat
      
      choose pointer tool
      
      unlock screen; unlock cursor; unlock messages
      exit dragDrop
   end if
   
   pass dragDrop
end dragDrop

private command _importFile pFilePath
   local tExtencion
   set the itemdel to "."
   
   put _target() into sTarget
   
   put word 1 of sTarget into sTypeTarget
   put item - 1 of pFilePath into tExtencion
   
   if there is a file pFilePath then
      set the itemdel to comma
      -- try
         switch 
            
            # LiveCode, Revolution and MetaCard binary stack files
            case tExtencion is among the items of "livecode,rev,mc"
               open stack pFilePath
               break
               
               # Script-only stack
            case tExtencion is "livecodescript"
               open stack pFilePath
               edit the script of stack pFilePath
               break
               
               # Images file
            case tExtencion is among the items of "png,jpeg,jpg,gif,bmp,pbm,pgm,ppm,xbm,xpm,xwd,pict,webp,jfif,tif,tiff,dib,vga,pict,pict2,pic"
               _importImage pFilePath, "file"
               break
               
               # Audio and Videos file
            case tExtencion is among the items of "mp3,mp4,mpg,mov,avi,m4a,midi,midi,snd,aac,wma,ogg,mpeg,m2v,mpeg2,qt,ram,rm"
               _importPlayer pFilePath
               break
               
               # SVG
            case tExtencion is "svg"
               _importPathSVG pFilePath
               break
         end switch
      -- end try
   end if
end _importFile

private  command _importImage pPathOrData, pType
   local tNameFile
   set the itemdel to "/"
   
   _setDefaultStack
   
   if there is stack sTopStack then 
      
      if pType is "file" then
         
         if there is a sTarget and sTypeTarget is "image" then
            
            if the filename of sTarget is empty then
               set the text of sTarget to URL ("binfile:" & pPathOrData)
            else
               set the filename of sTarget to _convertPathToRelativePath(pPathOrData)
            end if
            
         else
            local tNewImage, tMouseLoc
            
            put the mouseLoc into tMouseLoc
            set the text of templateImage to URL ("binfile:" & pPathOrData)
            
            put item - 1 of pPathOrData into tNameFile
            create image tNameFile in this cd
            put it into tNewImage
            
            if the text of tNewImage is empty then
               set the filename of tNewImage to _convertPathToRelativePath(pPathOrData)
            end if
            
            if within(stack sTopStack, tMouseLoc) then
               set the loc of tNewImage to tMouseLoc
            else
               set the loc of tNewImage to (the loc of cd 1 of stack sTopStack)
            end if
            
         end if
         
      else
         set the text of templateImage to pPathOrData
         create image in this cd
         
      end if
      
      reset templateImage
   end if
   
end _importImage

private command _importPlayer pPathOrData
   local tNameFile, tNumPlayer
   set the itemdel to "/"
   
   _setDefaultStack
   
   if there is stack sTopStack then
      
      if there is a sTarget and sTypeTarget is "player" then
         
         set the filename of sTarget to _convertPathToRelativePath(pPathOrData)
         
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
         
      end if
      
      reset templatePlayer
   end if
   
end _importPlayer

private command _importPathSVG pFilePath
   local tNewWidget, tPathSVG
   set the itemdel to "/"
   
   _setDefaultStack
   
   put _getPathSVG(pFilePath) into tPathSVG
   
   if there is stack sTopStack and tPathSVG is not empty then
      local tKind
      try
         put the kind of sTarget into tKind
      end try
      
      if there is a sTarget and sTypeTarget is "widget" and tKind is "com.livecode.widget.svgpath" then
         
         set the iconPath of sTarget to tPathSVG
         
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
         
      end if
      
   end if
end _importPathSVG

private command _setDefaultStack
   
   put the short name of the topstack into sTopStack
   set the defaultStack to sTopStack
end _setDefaultStack

private function _target
   local tStack, tTarget
   
   _setDefaultStack
   
   put the target into tTarget
   
   if there is stack sTopStack then
      
      if there is  tTarget then
         put the long id of tTarget into tTarget
         
         put _meOwnerStack(tTarget) into tStack
         
         if there is a tTarget and  tStack is the long name stack sTopStack then
            return tTarget
         end if
         
      end if
      
      return the long id of this cd
   end if
end _target

private function _meOwnerStack pLongIdControl
   local tOffset, tLongStack, tTarget
   
   put the long id of pLongIdControl into tTarget
   
   put wordOffset("stack",tTarget) into tOffset
   put word tOffset to -1 of tTarget into tLongStack
   
   return tLongStack
end _meOwnerStack

private command _deleteBackgroundGraphic
   
   if there is sLongIdBackGraphic then
      
      delete sLongIdBackGraphic
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
   
   if there is stack sTopStack then
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

