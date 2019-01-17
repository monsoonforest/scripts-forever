This is in the Arabian desert. Just a few kilometres west of Thabloten, Saudi Arabia.

There is water amidst the desert dunes and this is likely due to very recent rainfall in the area. Perhaps this area received about 10 - 100 mm of rainfall between 20th and 25th May.

The Landsat 8 image was taken on May 29th, 2018, around 0646 hrs UTC. The bands used are B6, B5 and B4.
From google earth imagery the interdunal areas are of different colour, perhaps indicating a different soil texture or something similar.
Apparently it happens every few years. One gorgeous desert huh.

var bandsl8 = ['B1','B2','B3','B4','B5','B6','B7'];

var mapitL8 = function(imagename, date){
      var a = ee.Image(imagename).select(bandsl8);
      var timestamp = ee.Date(a.get('system:time_start'));
      print('Timestamp: ', timestamp); // ee.Date
      Map.addLayer(a, {bands: ['B6', 'B5','B4'], min:0.03, max:0.7}, date);
};

var ic = ee.ImageCollection('LANDSAT/LC08/C01/T1_TOA')
          .filterBounds(dunes).filterDate('2018-05-25', '2018-06-11')
//          .filter(ee.Filter.calendarRange(02,06,'month'));
print(ic);

/*var withCloudiness = ic.map(function(image) {
      var cloud = ee.Algorithms.Landsat.simpleCloudScore(image).select('cloud');
      var cloudiness = cloud.reduceRegion({
        reducer: 'mean', 
        geometry: dunes, 
        scale: 30,
    });
      return image.set(cloudiness);
});*/


mapitL8('LANDSAT/LC08/C01/T1_TOA/LC08_160046_20180529', '46');
mapitL8('LANDSAT/LC08/C01/T1_TOA/LC08_160044_20180529', '44');
mapitL8('LANDSAT/LC08/C01/T1_TOA/LC08_160045_20180529', '45');