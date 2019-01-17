var prfSII = ee.ImageCollection('COPERNICUS/S2')
                .filterDate('2018-01-01', '2018-05-31')
                .filterBounds(foothills);
var sorteds2 = prfSII.sort('CLOUD_COVER');
print('cloud-sorteds2', sorteds2);                
var bandsS2 = ['B12', 'B8','B4'];
var mapitS2 = function(imagename, date){
var a = ee.Image(imagename).select(bandsS2);
Map.addLayer(a, {bands: ['B12', 'B8','B4'], min:1, max:8500}, date);
};

                
mapitS2('COPERNICUS/S2/20180517T042711_20180517T042706_T46REQ', '2018-01-02')                