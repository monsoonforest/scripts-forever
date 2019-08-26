Map.centerObject(papumrf)
Map.addLayer(papumrf)
var bandsL5 = ['B1','B3','B4', 'pixelqa'];
var bandsL8 = ['B2','B4','B5', 'pixelqa'];


var L5collection = ee.ImageCollection('LANDSAT/LT05/C01/T1_SR')
					.select(bandsL5)
					.filterBounds(papumrf).filterDate('1990-01-01','2011-01-01')
					.filter(ee.Filter.calendarRange(,05,'month'));
					
var L8collection = ee.ImageCollection('LANDSAT/LC08/C01/T1_SR')
					.select(bandsL8)
					.filterBounds(papumrf).filterDate('1990-01-01','2011-01-01')
					.filter(ee.Filter.calendarRange(11,05,'month'));
					

// select pixel_qa band as mask
var msk5 = L5collection.select('pixel_qa');
var msk8 = L8collection.select('pixel_qa')

//conditions which to mask out - no shadows, snow or clouds
msk5 = msk.neq(68).and(msk.neq(132))
      .and(msk.neq(72)).and(msk.neq(136))
       .and(msk.neq(80)).and(msk.neq(112)).and(msk.neq(144)).and(msk.neq(176))
        .and(msk.neq(96)).and(msk.neq(160)).and(msk.neq(176)).and(msk.neq(224));

// FOR LANDSAT 8 pixel_qa
msk8 = msk.neq(0).and(msk.neq(2))
		.and(msk.neq(3)).and(msk.neq(4)).and(msk.neq(5))
			.and(msk.neq(6)).and(msk.neq(7)).and(msk.neq(8)).and(msk.neq(9)).and(msk.neq(10))


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