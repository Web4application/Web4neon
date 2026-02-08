  PRO emboss_band1_extensions_init
  COMPILE_OPT IDL2
   
  ; Get ENVI session
  e = ENVI(/CURRENT)
   
  ; Add the extension to a subfolder
  e.AddExtension, 'Emboss Band 1', 'emboss_band1'
   
  END
   
  PRO emboss_band1
  COMPILE_OPT IDL2
   
  ; General error handler
  CATCH, err
  IF err NE 0 THEN BEGIN
    CATCH, /CANCEL
    IF OBJ_VALID(e) THEN $
      e.ReportError,'ERROR: ' + !error_state.msg
    MESSAGE,/RESET
    RETURN
  ENDIF
   
  ; Get ENVI session
  e = ENVI(/CURRENT)
   
  ; Prompt for the input file
  inFile = DIALOG_PICKFILE(DIALOG_PARENT = e.WIDGET_ID, $
    TITLE='Please select input file', $
    /MUST_EXIST)
  ; Prompt for the output file
  outFile = DIALOG_PICKFILE(DIALOG_PARENT = e.WIDGET_ID, $
    TITLE = 'Please select output file')
   
  ; Open the input file and display it
  raster = e.OpenRaster(inFile)
  view = e.GetView()
  layer1 = view.CreateLayer(raster, BANDS = [0])
   
  ; Create the output
  rasterNew = ENVIRaster(URI=outFile, INHERITS_FROM=raster)
   
  ; Iterate through the tiles of the original data set
  ; for the first band
  tiles = raster.CreateTileIterator(BANDS = [0])
  FOREACH tile, Tiles DO BEGIN
    data = EMBOSS(tile, /EDGE_WRAP)
    rasterNew.SetTile, Data, Tiles
  ENDFOREACH
   
  ; Save the data and display
  rasterNew.Save
  layer2 = view.CreateLayer(rasterNew)
   
  ; Create a portal and flicker
  portal = view.CreatePortal()
  portal.Animate
   
  END
