var bomdo = ee.Geometry.Polygon( [[
 [94.96959686279297,28.839937123160688],
[94.80020927429199, 28.839937123160688],
 [94.80020927429199,28.70052583593362],
 [94.96959686279297,28.70052583593362]]]);

var bandsl5 = ['B2', 'B4','B7'];
var bandsl8 = ['B1','B2','B3','B4','B5','B6','B7', 'pixel_qa'];

// function to map LANDSAT 5 SCENE
var mapitL5 = function(imagename, date){
      var a = ee.Image(imagename).select(bandsl5).clip(bomdo);
      var timestamp = ee.Date(a.get('system:time_start'));
      print('Timestamp: ', timestamp); // ee.Date
      Map.addLayer(a, {bands: ['B7', 'B4','B2'], min:0, max:3000}, date);
};

// FUNCTION TO MAP LANDSAT8 SCENE
var mapitL8 = function(imagename, date){
      var a = ee.Image(imagename).select(bandsl8).clip(bomdo);
      var timestamp = ee.Date(a.get('system:time_start'));
      print('Timestamp: ', timestamp); // ee.Date
      Map.addLayer(a, {bands: ['B7', 'B5','B3'], min:1, max:5000}, date);
};

var nbrmapL8 = function(cloudyscene, name, exportname){

        //Select LANDSAT 8 BANDS FOR BURN AREA
        var bandsl8 = ['B5','B7', 'pixel_qa'];

        // clip the firescene to the given ROI
        var clippedcloudyscene = ee.Image(cloudyscene).clip(bomdo).select(bandsl8);

        // Select pixel_qa band for cloud and water masking.
        var msk = clippedcloudyscene.select('pixel_qa');

        // Details for pixel_qa from LEDAPS Product Guide - 22 - Version 8.1
        //Water 324, 388, 836, 900, 1348
        //Cloud shadow 328, 392, 840, 904, 1350
        //Snow/ice 336, 368, 400, 432, 848, 880, 912, 944, 1352
        //Cloud 352, 368, 416, 432, 480, 864, 880, 928, 944, 992

        msk = msk.neq(324).and(msk.neq(388)).and(msk.neq(836)).and(msk.neq(900)).and(msk.neq(1348))
              .and(msk.neq(328)).and(msk.neq(392)).and(msk.neq(840)).and(msk.neq(904)).and(msk.neq(1350))
              .and(msk.neq(336)).and(msk.neq(368)).and(msk.neq(400)).and(msk.neq(432)).and(msk.neq(848))
              .and(msk.neq(880)).and(msk.neq(912)).and(msk.neq(944)).and(msk.neq(1352))
              .and(msk.neq(352)).and(msk.neq(416)).and(msk.neq(480)).and(msk.neq(864)).and(msk.neq(928))
              .and(msk.neq(992));

        // apply mask and call it the firescene
        var firescene = clippedcloudyscene.mask(msk);

        // compute prefire NBR
        var nbr = firescene.expression(
          '(SWIRI - NIR) / (SWIRI + NIR)',{
            'NIR': firescene.select('B5'),
            'SWIRI': firescene.select('B6')
          });


        var NBRcolourpalette =
          '<RasterSymbolizer>' +
            '<ColorMap  type="intervals" extended="false" >' +
              '<ColorMapEntry color="#d73027" quantity="-0.3" label=">-0.3"/>' +
              '<ColorMapEntry color="#fc8d59" quantity="-0.1" label="-0.3 to -0.1"/>' +
              '<ColorMapEntry color="#fee090" quantity="0.1" label="-0.1 to 0.1"/>' +
              '<ColorMapEntry color="#e0f3f8" quantity="0.27" label="0.1 to 0.27" />' +
              '<ColorMapEntry color="#91bfdb" quantity="0.44" label="0.27 to 0.44" />' +
              '<ColorMapEntry color="#4575b4" quantity="0.66" label="0.44 to 0.66" />' +
                 '</ColorMap>' +
          '</RasterSymbolizer>';
        Map.addLayer(nbr.sldStyle(NBRcolourpalette), {}, name);

        //Export.image.toDrive({
          //image:nbr,
          //description : exportname,
          //folder: "bomdo-burnarea",
          //scale: 30,
          //crs:"EPSG:32646",
          //region: bomdo  
          //});
};


var nbrtmapL8 = function(cloudyscene, name, exportname){

        //Select LANDSAT 8 BANDS FOR BURN AREA
        var bandsl8 = ['B1','B2','B3','B4','B5','B6','B7','B11', 'pixel_qa'];

        // clip the firescene to the given ROI
        var clippedcloudyscene = ee.Image(cloudyscene).clip(bomdo).select(bandsl8);

        // Select pixel_qa band for cloud and water masking.
        var msk = clippedcloudyscene.select('pixel_qa');

        // Details for pixel_qa from LEDAPS Product Guide - 22 - Version 8.1
        //Water 324, 388, 836, 900, 1348
        //Cloud shadow 328, 392, 840, 904, 1350
        //Snow/ice 336, 368, 400, 432, 848, 880, 912, 944, 1352
        //Cloud 352, 368, 416, 432, 480, 864, 880, 928, 944, 992

        msk = msk.neq(324).and(msk.neq(388)).and(msk.neq(836)).and(msk.neq(900)).and(msk.neq(1348))
              .and(msk.neq(328)).and(msk.neq(392)).and(msk.neq(840)).and(msk.neq(904)).and(msk.neq(1350))
              .and(msk.neq(336)).and(msk.neq(368)).and(msk.neq(400)).and(msk.neq(432)).and(msk.neq(848))
              .and(msk.neq(880)).and(msk.neq(912)).and(msk.neq(944)).and(msk.neq(1352))
              .and(msk.neq(352)).and(msk.neq(416)).and(msk.neq(480)).and(msk.neq(864)).and(msk.neq(928))
              .and(msk.neq(992));

        // apply mask and call it the firescene
        var firescene = clippedcloudyscene.mask(msk);

        // compute POST-FIRE NORMALIZED BURN RATIO THERMAL
       var nbrt = firescene.expression(
  '(NIR - 0.0001 * SWIR * Temp) / (NIR + 0.0001 * SWIR * Temp)', {
    'NIR': firescene.select('B5'),
    'SWIR': firescene.select('B7'),
    'Temp': firescene.select('B11')
});
       var burnPalette = ['green', 'blue', 'yellow', 'red'];
       Map.addLayer(nbrt, {min: 0, max: 0.9, palette: burnPalette}, 'NBRT');


  /*      var NBRcolourpalette =
          '<RasterSymbolizer>' +
            '<ColorMap  type="intervals" extended="false" >' +
              '<ColorMapEntry color="#d73027" quantity="-0.3" label=">-0.3"/>' +
              '<ColorMapEntry color="#fc8d59" quantity="-0.1" label="-0.3 to -0.1"/>' +
              '<ColorMapEntry color="#fee090" quantity="0.1" label="-0.1 to 0.1"/>' +
              '<ColorMapEntry color="#e0f3f8" quantity="0.27" label="0.1 to 0.27" />' +
              '<ColorMapEntry color="#91bfdb" quantity="0.44" label="0.27 to 0.44" />' +
              '<ColorMapEntry color="#4575b4" quantity="0.66" label="0.44 to 0.66" />' +
                 '</ColorMap>' +
          '</RasterSymbolizer>';
        Map.addLayer(nbr.sldStyle(NBRcolourpalette), {}, name);*/

        //Export.image.toDrive({
          //image:nbr,
          //description : exportname,
          //folder: "bomdo-burnarea",
          //scale: 30,
          //crs:"EPSG:32646",
          //region: bomdo  
          //});
};

mapitL8('LANDSAT/LC08/C01/T1_SR/LC08_135040_20130430', '2013-image');
nbrmapL8('LANDSAT/LC08/C01/T1_SR/LC08_135040_20130430', 'NBR-2013-April', '2013-02-NBR');
nbrtmapL8('LANDSAT/LC08/C01/T1_SR/LC08_135040_20130430', 'NBRT-2013-April', '2013-02-NBRT');
