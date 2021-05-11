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

version 1.0.9
Made: 2020-07-09 15:20
Last Update: 2021-04-04 08:33
*/

# list of files being dragged.
local sFiles

# The window the mouse pointer is over.
local sMouseStack, sOldMouseStack

# The location of the mouse pointer.
local sMouseLoc

# Graph that is dynamically created in the background for the DragDrop event to be sent.
local sLongIdBackGraphic

# The object that is the object and its type.
local sDragDestination, sTypeDragDestination

# The last control that was imported. It is to select it at the end of everything.
local sLastControl

# Whether to import into the dragDestination or create a new object.
local sOptionShift

constant kBynaryStack = "livecode,rev,mc"
constant kScriptOnlyStack = "livecodescript"
constant kAudio = "mp3,mp4,mpg,mov,avi,m4a,midi,midi,snd,aac,wma,ogg,mpeg,m2v,mpeg2,qt,ram,rm"
constant kImage = "svg,png,jpeg,jpg,gif,bmp,pbm,pgm,ppm,xbm,xpm,xwd,pict,webp,jfif,tif,tiff,dib,vga,pict,pict2,pic"
constant kTextPlan = "json,html,htm,txt,lng,locale,log,mnu,nfo,inf,ini,inc,bar,cfg,sav,conf,manifest,lst,ion,rc,properties,mf,list,wbt,lic,css,hs,iss,js,nsi,nsh,java,php,php3,php4,php5,tct,xml,xsml,xsl,kml,adr,sfx,,sh,bsh,lua,pl,pm,py,as,las,mx,vb,f,for,f90,f95,f2k,tex,mak,tpl,asm,plx,lsp,lisp,scm,smd,ss,kix,au3,ml,mli,sml,thy,ada,ads,adb,v,lhs,cmake,twig,yml"
constant kLiveCodeExtension = "lce"

on extensionInitialize
   if the target is not me then
      pass extensionInitialize
   end if

   if the environment is "development" then
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
   if the tool is "pointer tool" and the dragData["files"] is not empty then _acceptDrop
   pass dragEnter
end dragEnter


on dragMove
   if the tool is "pointer tool" and the dragData["files"] is not empty  then _acceptDrop
   pass dragMove
end dragMove


on dragLeave
   if there is not a stack sMouseStack or within(stack sMouseStack, globalLoc(the mouseLoc)) is false then _deleteBackgroundGraphic
   pass dragLeave
end dragLeave


local sCtrlShift

on dragDrop

   _deleteBackgroundGraphic
   if the tool is no "pointer tool" or sFiles is empty then pass dragDrop

   _setDefaultStack
   if _ItIsIDEStack(sMouseStack) is true then
      put the short name of the topStack into sMouseStack
      set the defaultstack to sMouseStack
   end if

   put the mouseLoc into sMouseLoc

   put the optionKey is down and the shiftKey is down and the number of lines of sFiles is 1  into sOptionShift
   put the controlKey is down and the shiftKey is down into sCtrlShift

   if sFiles is not empty then
      lock screen; lock messages;lock cursor

      set the cursor to watch

      repeat for each line tFile in sFiles
         _importFile tFile
      end repeat

      set the dragData to empty
      set the clipboardData to empty
      unlock messages

      choose pointer tool

      if there is a sLastControl then
         focus on nothing
         select empty
         select sLastControl
      end if

      unlock screen; unlock messages; unlock cursor
      exit dragDrop
   end if

   pass dragDrop
end dragDrop

# remove data being dragged.
on dragEnd
   _deleteBackgroundGraphic
   pass dragEnd
end dragEnd

# remove data being dragged.
on suspendStack
   if sFiles is not empty then
      _deleteBackgroundGraphic
      delete variable sMouseStack
   end if
   pass suspendStack
end suspendStack


private command _acceptDrop
    
    
    if the tool is not "pointer tool" then
        _deleteBackgroundGraphic
        unlock messages
        exit _acceptDrop
    end if
    
    put the dragData["files"] into sFiles
        
    _setDefaultStack
    
    if _inMouseStack() and _filesTypeDragDrop(sFiles) is true and the cantModify of stack sMouseStack is not true then
        set the dragAction to "copy"
        
    else
        set the dragAction to "none"
        _deleteBackgroundGraphic
        unlock messages
        exit _acceptDrop
    end if
    
    
    if there is not graphic "frlDragDropBack" of this cd of stack sMouseStack then
        lock messages
        
        # I create this graph because the drag & drop message is not generated on the card
        create invisible graphic "frlDragDropBack" in this cd
        put it into sLongIdBackGraphic
        
        set the rect of sLongIdBackGraphic to the rect of this cd of stack sMouseStack
        
        try
            set the opaque     of sLongIdBackGraphic to true
            set the blendlevel of sLongIdBackGraphic to 100
            set the layer      of sLongIdBackGraphic to bottom
            set the lineSize   of sLongIdBackGraphic to 0
            set the backColor  of sLongIdBackGraphic to revIDEColor("edition_color")
            set the visible    of sLongIdBackGraphic to true
        end try
        
        put empty into sDragDestination
        put empty into sTypeDragDestination
        put empty into sOptionShift
        
        if _ItIsIDEStack(sMouseStack) is true then set the blendlevel of sLongIdBackGraphic to 100
        else set the blendlevel of sLongIdBackGraphic to 0
        unlock messages
    end if
    
end _acceptDrop


private command _importFile pFilePath
   local tExtension

   set the itemdel to "."


   lock messages
   put _dragDestination() into sDragDestination

   _deleteBackgroundGraphic

   put word 1 of sDragDestination into sTypeDragDestination
   put item - 1 of pFilePath into tExtension

   set the itemdel to comma

   if there is a file pFilePath then
      switch
            # SVG
         case tExtension is "svg"
            _importPathSVG pFilePath
            break

            # LiveCode, Revolution and MetaCard binary stack files
         case tExtension is among the items of kBynaryStack
            unlock messages
            go to card 1 of stack pFilePath
            break

            # Script-only stack
         case tExtension is kScriptOnlyStack
            edit the script of stack pFilePath
            break

            # Images file
         case tExtension is among the items of kImage
            _importImage pFilePath, "file"
            break

            # Audio and Videos file
         case tExtension is among the items of kAudio
            _importPlayer pFilePath
            break

            # Text Plan
         case tExtension is among the items of kTextPlan
            _importTextPlan pFilePath
            break

            # LiveCode Extension
         case tExtension is kLiveCodeExtension
            _installExtension pFilePath
            break

      end switch

   end if
   unlock messages
end _importFile


private  command _importImage pPathOrData, pType
    local tNameFile, tImageData, tNewImage
    
    set the itemdel to slash
    
    _setDefaultStack
    
    if _ItIsIDEStack(sMouseStack) is true then
        put the short name of the topStack into sMouseStack
        set the defaultstack to sMouseStack
    end if
    
    if there is a stack sMouseStack and not _ItIsIDEStack(sMouseStack) then
        
        if pType is "file" then
            
            if there is a sDragDestination and sTypeDragDestination is "image" and sOptionShift is true  then
                local tLockLoc
                
                put the lockLoc of sDragDestination into tLockLoc
                set the lockLoc of sDragDestination to true
                
                if the filename of sDragDestination is empty then
                    set the text of sDragDestination to URL ("binfile:" & pPathOrData)
                else
                    set the filename of sDragDestination to _convertPathToRelativePath(pPathOrData)
                end if
                
                set the lockLoc of sDragDestination to tLockLoc
                
                put sDragDestination into sLastControl
                
                exit _importImage
            end if
            
            if sCtrlShift is false then set the text of templateImage to URL ("binfile:" & pPathOrData)
            
            put item - 1 of pPathOrData into tNameFile
            
            create image tNameFile in this cd
            put it into tNewImage
            
            if the text of tNewImage is empty then
                set the filename of tNewImage to _convertPathToRelativePath(pPathOrData)
            end if
            
            if there is tNewImage then
                
                _scaleImage tNewImage
                
                if sMouseLoc is within the rect of card 1 of stack sMouseStack then
                    set the loc of tNewImage to sMouseLoc
                else
                    set the loc of tNewImage to (the loc of cd 1 of stack sMouseStack)
                end if
                
                
                put tNewImage into sLastControl
            end if
            
            reset templateImage
            
        else
            local tOldText, tNewText
            put drawingSvgCompileFile(pPathOrData) into tNewText
            
            if tNewText is not empty then
                
                if there is a sDragDestination and sTypeDragDestination is "image" then
                    put the text of sDragDestination  into tOldText
                    
                    set the text of sDragDestination to tNewText
                    _scaleImage tNewImage
                    
                    if the text of sDragDestination is empty then
                        set the text of sDragDestination to tOldText
                    end if
                    
                else
                    put the mouseLoc into sMouseLoc
                    set the text of templateImage to tNewText
                    
                    put item - 1 of pPathOrData into tNameFile
                    create image tNameFile in this cd
                    put it into tNewImage
                    
                    
                    if there is tNewImage then
                        _scaleImage tNewImage
                        
                        if sMouseLoc is within the rect of card 1 of stack sMouseStack then
                            set the loc of tNewImage to sMouseLoc
                            
                        else
                            set the loc of tNewImage to (the loc of cd 1 of stack sMouseStack)
                            
                        end if
                        
                        put tNewImage into sLastControl
                    end if
                    
                    reset templateImage
                end if
            else
                beep
            end if
        end if
    end if
    
end _importImage


private command _importPlayer pPathOrData
   local tNameFile, tNumPlayer
   set the itemdel to slash

   _setDefaultStack

   if _ItIsIDEStack(sMouseStack) is true then
      put the short name of the topStack into sMouseStack
      set the defaultstack to sMouseStack
   end if


   if there is a stack sMouseStack and not _ItIsIDEStack(sMouseStack) then

      if there is a sDragDestination and sTypeDragDestination is "player" and sOptionShift is true then

         set the filename of sDragDestination to _convertPathToRelativePath(pPathOrData)
         put sDragDestination into sLastControl
      else
         local tNewPlayer

         set the filename of templatePlayer to _convertPathToRelativePath(pPathOrData)
         set the showController of templatePlayer to true

         put item - 1 of pPathOrData into tNameFile
         create player tNameFile in this cd
         put it into tNewPlayer

         if sMouseLoc is within the rect of card 1 of stack sMouseStack then
            set the loc of tNewPlayer to sMouseLoc
         else
            set the loc of tNewPlayer to (the loc of cd 1 of stack sMouseStack)
         end if

         put tNewPlayer into sLastControl
      end if

      reset templatePlayer
   end if

end _importPlayer


private command _importPathSVG pFilePath
    local tNewWidget, tPathSVG, tName

    set the itemdel to slash

    put last item of pFilePath into tName

    _setDefaultStack

    if _ItIsIDEStack(sMouseStack) is true then
        put the short name of the topStack into sMouseStack
        set the defaultstack to sMouseStack
    end if

    put _getPathSVG(pFilePath) into tPathSVG

    if there is a stack sMouseStack and not _ItIsIDEStack(sMouseStack) then
        if tPathSVG is not empty then

            local tKind
            try
                put the kind of sDragDestination into tKind
            end try

            if there is a sDragDestination and sTypeDragDestination is "widget" and tKind is "com.livecode.widget.svgpath" and sOptionShift is true then

                set the iconPath of sDragDestination to tPathSVG

                put sDragDestination into sLastControl
            else


                create widget tName as "com.livecode.widget.svgpath" in this cd
                put it into tNewWidget

                set the iconPath of tNewWidget to tPathSVG
                set the width of tNewWidget to 180
                set the height of tNewWidget to 180

                if sMouseLoc is within the rect of card 1 of stack sMouseStack then
                    set the loc of tNewWidget to sMouseLoc
                else
                    set the loc of tNewWidget to (the loc of cd 1 of stack sMouseStack)
                end if

                put tNewWidget into sLastControl
            end if
        else
            _importImage pFilePath, "SVG_Data"
        end if
    end if
end _importPathSVG


private command _importTextPlan pFilePath
    local tText

    _setDefaultStack

    if _ItIsIDEStack(sMouseStack) is true then
        put the short name of the topStack into sMouseStack
        set the defaultstack to sMouseStack
    end if

    if there is a stack sMouseStack and not _ItIsIDEStack(sMouseStack) then
        put URL("file:" & pFilePath) into tText

        if there is a sDragDestination and sTypeDragDestination is "field" and sOptionShift is true then
            set the text of sDragDestination to tText

        else
            create field ( the last item of pFilePath)
            put it into sLastControl
            set the text of sLastControl to tText
            set the locktext of sLastControl to true

            if sMouseLoc is within the rect of card 1 of stack sMouseStack then
                set the loc of sLastControl to sMouseLoc
            else
                set the loc of sLastControl to (the loc of cd 1 of stack sMouseStack)
            end if
        end if
    end if

end _importTextPlan


private command _installExtension pExtensionURL
    // get from local .lce file
   send"installExtension pExtensionURL, , widget" to stack"revIDEExtensionManager" in 0.1 sec
end _installExtension


private command _setDefaultStack
   if there is a the mouseStack then put the short name of the mouseStack into sMouseStack

   if sOldMouseStack is not sMouseStack then
      _deleteBackgroundGraphic
   end if

   put sMouseStack into sOldMouseStack
   set the defaultStack to sMouseStack
end _setDefaultStack


private function _dragDestination
   local tStack, tDragDestination

   _setDefaultStack

   put the dragDestination into tDragDestination

   if there is an stack sMouseStack then

      if there is  tDragDestination then
         put the long id of tDragDestination into tDragDestination

         put ideStackOfObject(tDragDestination) into tStack

         if there is a tDragDestination and tStack is the long name stack sMouseStack then
            return tDragDestination
         end if

      end if

      return the long id of this cd
   end if
end _dragDestination


private command _deleteBackgroundGraphic

   if sLongIdBackGraphic is not empty and there is sLongIdBackGraphic then
      delete sLongIdBackGraphic
      delete variable sLongIdBackGraphic
   end if

end _deleteBackgroundGraphic


private function _convertPathToRelativePath pPath
   local tStackPath

   set the itemdel to slash

   if there is not a stack sMouseStack then return pPath

   put item 1 to - 2 of the effective filename of stack sMouseStack into tStackPath
   if there is not a folder tStackPath then return pPath

   replace backslash with slash in pPath
   replace tStackPath & slash with empty in pPath

   return pPath
end _convertPathToRelativePath


private function _getPathSVG pFilePath
    local tSVG, tPathOpen , tOpen = 0, tClose, tSVGPath, tNumChars, tNewPath, tName, tSvgColorToJPG = false
    
    set the itemdel to slash
    put the last item of pFilePath into tName
    
    set the itemdel to quote
    
    if there is a file pFilePath then
        
        put URL( "file:" & pFilePath ) into tSVG
        
        put length(tSVG) into tNumChars
        
        put "#" is in tSVG and not (the controlKey is down and the shiftKey is down)  into tSvgColorToJPG
        
        if tSvgColorToJPG is false  and "path" is in tSVG then
            repeat for tNumChars
                put offset("path", tSVG, tPathOpen) into tOpen
                
                if tOpen is 0 then exit repeat
                if tNumChars <= tOpen then exit repeat
                put tOpen + tPathOpen into tPathOpen
                
                if the char(tPathOpen - 1) of tSVG is not "<" and char (tPathOpen - 1)  of tSVG is not space then
                    put tPathOpen  + 3 into tPathOpen
                    next repeat
                end if
                
                put offset("d=" & quote, tSVG, tPathOpen)  into tOpen
                if tOpen is 0 then exit repeat
                put tOpen + tPathOpen  + 3 into tOpen
                
                put offset(quote, tSVG, tOpen)  into tClose
                if tClose is 0 then exit repeat
                put tOpen + tClose into tClose
                
                put char tOpen to (tClose - 1) of tSVG into tNewPath
                add 1 to tClose
                put tClose into tPathOpen
                
                get (the item 1 to 2 of ( the char tClose to - 1 of tSVG))
                
                if the trueWord 1 of it is "fill" and the trueWord -1 of it is "none" then
                    next repeat
                end if
                
                put tNewPath && cr after tSVGPath
                
            end repeat
        end if
    else
        
        put tSVG into tSVGPath
    end if
    
    local tWidget, tOutPathSVG
    
    create widget tName as "com.livecode.widget.svgpath"
    put it into tWidget
    
    try
        set the iconPath of tWidget to tSVGPath
        put tSVGPath into tOutPathSVG
    end try
    
    delete tWidget
    
    return tOutPathSVG
end _getPathSVG


private function _filesTypeDragDrop pFiles
   local tResult = true, tExtension

   if pFiles is empty then return false

   repeat for each line tFile in pFiles

      set the itemdel to "."
      put item - 1 of tFile into tExtension

      set the itemdel to comma

      if tExtension is not among the items of (kBynaryStack,kScriptOnlyStack,kAudio,kImage,kTextPlan,kLiveCodeExtension) then
         put false into tResult
         exit repeat
      end if
   end repeat

   return tResult
end _filesTypeDragDrop


private command _scaleImage pLongId
   local tFormattedWidth, tFormattedHeight, tWidthCard, tHeightCard, tAspectRatio

   _setDefaultStack

   if _ItIsIDEStack(sMouseStack) is true then
      put the short name of the topStack into sMouseStack
      set the defaultstack to sMouseStack
   end if

   put the formattedWidth of pLongId into tFormattedWidth
   put the formattedHeight of pLongId into tFormattedHeight

   put the width of this card into tWidthCard
   put the height of this card into tHeightCard

   if tFormattedWidth is 0 or tFormattedHeight is 0 or (tFormattedWidth < tWidthCard and tFormattedHeight < tHeightCard) then
      exit _scaleImage
   end if

   put min(tWidthCard/tFormattedWidth, tHeightCard/tFormattedHeight) into tAspectRatio

   set the width of pLongId to tFormattedWidth * tAspectRatio
   set the height of pLongId to tFormattedHeight * tAspectRatio
end _scaleImage


private function _ItIsIDEStack pNameStack
   if there is not a stack pNameStack then return false
   return the mainstack of stack pNameStack is not among the lines of ideUserMainStacks()
end _ItIsIDEStack


private command _cancelPendingMessages pMessageName
   local tPendingMessages

   set the itemDelimiter to comma
   put the pendingMessages into tPendingMessages

   repeat for each line tMessage in tPendingMessages
      if item 3 of tMessage is pMessageName then
         cancel item 1 of tMessage
      end if
   end repeat
end _cancelPendingMessages


private function _inMouseStack
   local tTarget, tStackOfControlLeave

   put the target into tTarget
   if tTarget is empty then return false

   if word 1 of tTarget is in "card stack" then
      put ideStackOfObject(  the long id of  tTarget) into tStackOfControlLeave

      if there is a stack tStackOfControlLeave and globalLoc(the mouseLoc) is not within the rect of stack tStackOfControlLeave then
         _deleteBackgroundGraphic
         return false
      end if

   end if
   return true
end _inMouseStack
