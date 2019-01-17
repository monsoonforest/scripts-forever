var polygon = ee.Geometry.Polygon( [[
 [94.96959686279297,28.839937123160688],
[94.80020927429199, 28.839937123160688],
 [94.80020927429199,28.70052583593362],
 [94.96959686279297,28.70052583593362]]]);

var bandsl5 = ['B2', 'B4','B7'];
var bandsl8 = ['B3', 'B5', 'B7'];

var ic = ee.ImageCollection('LANDSAT/LC08/C01/T1_TOA')
          .filterBounds(polygon).filterDate('2009-01-01', '2017-12-31')
          .filter(ee.Filter.calendarRange(02,06,'month'));

var withCloudiness = ic.map(function(image) {
      var cloud = ee.Algorithms.Landsat.simpleCloudScore(image).select('cloud');
      var cloudiness = cloud.reduceRegion({
        reducer: 'mean', 
        geometry: polygon, 
        scale: 30,
    });
      return image.set(cloudiness);
});

var filteredCollection = withCloudiness.filter(ee.Filter.lt('cloud', 40));
//print(filteredCollection);

// function to map LANDSAT 5 SCENE
var mapitL5 = function(imagename, date){
      var a = ee.Image(imagename).select(bandsl5).clip(polygon);
      var timestamp = ee.Date(a.get('system:time_start'));
      print('Timestamp: ', timestamp); // ee.Date
      Map.addLayer(a, {bands: ['B7', 'B4','B2'], min:0, max:3000}, date);
};

// FUNCTION TO MAP LANDSAT8 SCENE
var mapitL8 = function(imagename, date){
      var a = ee.Image(imagename).select(bandsl8).clip(polygon);
      var timestamp = ee.Date(a.get('system:time_start'));
      print('Timestamp: ', timestamp); // ee.Date
      Map.addLayer(a, {bands: ['B7', 'B5','B3'], min:1, max:5000}, date);
};

var ic5SR = ee.ImageCollection('LANDSAT/LC08/C01/T1_SR');
var spatialFilteredSR = ic5SR.filterBounds(polygon);
//print('spatialFiltered', spatialFiltered);
var temporalFilteredSR = spatialFilteredSR.filterDate('2011-01-01', '2017-12-31')
.filter(ee.Filter.calendarRange(02,07,'month'));
//print('temporalFiltered', temporalFilteredSR);
// This will sort from least to most cloudy.
var sortedSR = temporalFilteredSR.sort('CLOUD_COVER');
//print('cloud-sorted-LANDSAT 8 SR', sortedSR);


var nbrmap = function(cloudyscene, name, exportname){
  
      // select Burned area BANDS
      var bandsl5 = ['B4','B7', 'pixel_qa'];

      // clip the firescene to the given ROI
      var clippedcloudyscene = ee.Image(cloudyscene).clip(polygon).select(bandsl5);

      // Select pixel_qa band for cloud and water masking.
      var msk = clippedcloudyscene.select('pixel_qa');

      // Details for pixel_qa from LEDAPS Product Guide - 22 - Version 8.1
      // Water 68, 132
      // Cloud shadow 72, 136
      // Snow/ice 80, 112, 144, 176
      // Cloud 96, 112, 160, 176, 224
      msk = msk.neq(68).and(msk.neq(132))
            .and(msk.neq(72)).and(msk.neq(136))
            .and(msk.neq(80)).and(msk.neq(112)).and(msk.neq(144)).and(msk.neq(176))
            .and(msk.neq(96)).and(msk.neq(160)).and(msk.neq(176)).and(msk.neq(224));

      // apply mask and call it the firescene
      var firescene = clippedcloudyscene.mask(msk);

      // compute prefire NBR
      var nbr = firescene.expression(
        '(NIR - SWIRII) / (NIR + SWIRII)',{
          'NIR': firescene.select('B4'),
          'SWIRII': firescene.select('B7')
        });
      //colour palette
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
        //folder: "polygon-burnarea",
        //scale: 30,
        //crs:"EPSG:32646",
        //region: polygon  
        //});
};

var nbrmapL8 = function(cloudyscene, name, exportname){

        //Select LANDSAT 8 BANDS FOR BURN AREA
        var bandsl8 = ['B5','B7', 'pixel_qa'];

        // clip the firescene to the given ROI
        var clippedcloudyscene = ee.Image(cloudyscene).clip(polygon).select(bandsl8);

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
          '(NIR - SWIRII) / (NIR + SWIRII)',{
            'NIR': firescene.select('B5'),
            'SWIRII': firescene.select('B7')
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
          //folder: "polygon-burnarea",
          //scale: 30,
          //crs:"EPSG:32646",
          //region: polygon  
          //});
};