var bandsL5 = ['B1','B3','B4', 'pixelqa'];
var bandsL8 = ['B2','B4','B5', 'pixelqa'];


var L5collection = ee.ImageCollection('LANDSAT/LT05/C01/T1_SR')
					.select(bandsL5)
					.filterBounds(papumrf).filterDate('1990-01-01','2011-01-01')
					.filter(ee.Filter.calendarRange(11,05,'month'));


var eviL5 = EVIscene.expression(
  ('((NIR-RED)/(NIR+(C1*RED)-(C2*BLUE)-L))*2.5'), {
    
    'NIR' : L5collection.select('B4'),
    'RED' : L5collection.select('B3'),
    'BLUE': L5collection.select('B1'),
    'C1'  : 6,
    'C2'  : 7.5,
    'L'   : 1,
   
  });


var series = L5collection.map(eviL5(image));


var bandsS2 = ['B2', 'B3', 'B4', 'B5', 'B6', 'B7', 'B8', 'B12'];
var collection = ee.ImageCollection('COPERNICUS/S2').filterBounds(namchaarea);

var mapitS2 = function(imagename, date){
var a = ee.Image(imagename).select(bandsS2);
Map.addLayer(a, {bands: ['B4', 'B3','B2'], min:1, max:8500}, date);
};

