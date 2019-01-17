var bandsl5 = ['B2', 'B4','B7'];
var bandsl1 = ['20', '30', '40'];
var bandslm1 = ['B4', 'B5','B6', 'B7'];
var bandsl8 = ['B3', 'B5','B7'];
var bandsS2 = ['B12', 'B8','B4'];

var ic5 = ee.ImageCollection('LANDSAT/LT05/C01/T1_SR');
var spatialFiltered = ic5.filterBounds(namchaarea)
.filter(ee.Filter.eq('WRS_PATH', 135))
  .filter(ee.Filter.eq('WRS_ROW', 39));
//print('spatialFiltered', spatialFiltered);
var temporalFiltered = spatialFiltered.filterDate('1985-01-01', '2017-12-31')
.filter(ee.Filter.calendarRange(04,10,'month'));
//print('temporalFiltered', temporalFiltered);
// This will sort from least to most cloudy.
var sorted = temporalFiltered.sort('CLOUD_COVER');
print('cloud-sorted', sorted);

var ic8 = ee.ImageCollection('LANDSAT/LC08/C01/T1_SR');
var spatialFiltered8 = ic8.filterBounds(namchaarea)
.filter(ee.Filter.eq('WRS_PATH', 135))
  .filter(ee.Filter.eq('WRS_ROW', 39));
//print('spatialFiltered', spatialFiltered);
var temporalFiltered8 = spatialFiltered8.filterDate('2011-01-01', '2017-12-31')
.filter(ee.Filter.calendarRange(04,10,'month'));
//print('temporalFiltered', temporalFiltered);
// This will sort from least to most cloudy.
var sorted8 = temporalFiltered8.sort('CLOUD_COVER');
print('cloud-sortedL8', sorted8);

var ics2 = ee.ImageCollection('COPERNICUS/S2');
var spatialFiltereds2 = ics2.filterBounds(namchaarea);
//print('spatialFiltered', spatialFiltered);
var temporalFiltereds2 = spatialFiltereds2.filterDate('2015-01-01', '2018-12-31')
.filter(ee.Filter.calendarRange(04,01,'month'));
//print('temporalFiltered', temporalFiltered);
// This will sort from least to most cloudy.
var sorteds2 = temporalFiltereds2.sort('CLOUD_COVER');
print('cloud-sorteds2', sorteds2);

var mapitL5 = function(imagename, date){
var a = ee.Image(imagename).select(bandsl5);
Map.addLayer(a, {bands: ['B7', 'B4','B2'], min:-300, max:8000}, date);
};

var mapitL1 = function(imagename, date){
var a = ee.Image(imagename).select(bandsl1);
Map.addLayer(a, {bands: ['40', '30','20'], min:1, max:130}, date);
};

var mapitL8 = function(imagename, date){
var a = ee.Image(imagename).select(bandsl8);
Map.addLayer(a, {bands: ['B7', 'B5','B3'], min:1, max:8500}, date);
};

var mapitS2 = function(imagename, date){
var a = ee.Image(imagename).select(bandsS2);
Map.addLayer(a, {bands: ['B12', 'B8','B4'], min:1, max:8500}, date);
};

//mosaic function for mapping Sentinel-2 of an ROI
var S2mosaicfunction = function(from, to, name) {
 var sentinel2 = ee.ImageCollection('COPERNICUS/S2')
  .filterBounds(namchaarea)
  .filterDate(from, to);
// Spatially mosaic the images in the collection and display.
var mosaic = sentinel2.mosaic();
Map.setCenter(94.9054, 30.012);
Map.addLayer(mosaic, {bands: ['B12', 'B8','B4'], min:1, max:10000}, name);
};



mapitL1('LANDSAT/GLS1975/p145r039_1x19731221', '1973-12-21');
mapitL1('LANDSAT/GLS1975/p145r040_2x19770101', '1977-01-01');
mapitL5('LANDSAT/LT05/C01/T1_SR/LT05_135039_19861114', '1986-11-14');
mapitL5('LANDSAT/LT05/C01/T1_SR/LT05_135039_19870117', '1987-01-17');
mapitL5('LANDSAT/LT05/C01/T1_SR/LT05_135039_19870407', '1987-04-07');
mapitL5('LANDSAT/LT05/C01/T1_SR/LT05_135039_19871219', '1987-12-19');
mapitL5('LANDSAT/LT05/C01/T1_SR/LT05_135039_19880205', '1988-02-05');
mapitL5('LANDSAT/LT05/C01/T1_SR/LT05_135039_19890122', '1989-01-22');
mapitL5('LANDSAT/LT05/C01/T1_SR/LT05_135039_19891208', '1989-12-08');
mapitL5('LANDSAT/LT05/C01/T1_SR/LT05_135039_19900517', '1990-05-17');
mapitL5('LANDSAT/LT05/C01/T1_SR/LT05_135039_19910128', '1991-01-28');
mapitL5('LANDSAT/LT05/C01/T1_SR/LT05_135039_19910317', '1991-03-17');
mapitL5('LANDSAT/LT05/C01/T1_SR/LT05_135039_19920404', '1992-04-04');
mapitL5('LANDSAT/LT05/C01/T1_SR/LT05_135039_19921216', '1992-12-16');
mapitL5('LANDSAT/LT05/C01/T1_SR/LT05_135039_19930117', '1993-01-17');
mapitL5('LANDSAT/LT05/C01/T1_SR/LT05_135039_19930525', '1993-05-25');
mapitL5('LANDSAT/LT05/C01/T1_SR/LT05_135039_19931203', '1993-12-03');
mapitL5('LANDSAT/LT05/C01/T1_SR/LT05_135039_19941104', '1994-11-04');
mapitL5('LANDSAT/LT05/C01/T1_SR/LT05_135039_19941206', '1994-12-06');
mapitL5('LANDSAT/LT05/C01/T1_SR/LT05_135039_19950429', '1995-04-29');
mapitL5('LANDSAT/LT05/C01/T1_SR/LT05_135039_19951107', '1995-11-07');
mapitL5('LANDSAT/LT05/C01/T1_SR/LT05_135039_19960415', '1996-04-15');
mapitL5('LANDSAT/LT05/C01/T1_SR/LT05_135039_19961227', '1996-12-27');
mapitL5('LANDSAT/LT05/C01/T1_SR/LT05_135039_19971027', '1997-10-27');
mapitL5('LANDSAT/LT05/C01/T1_SR/LT05_135039_19980304', '1998-03-04');
mapitL5('LANDSAT/LT05/C01/T1_SR/LT05_135039_19981115', '1998-11-15');
mapitL5('LANDSAT/LT05/C01/T1_SR/LT05_135039_19990118', '1999-01-18');
mapitL5('LANDSAT/LT05/C01/T1_SR/LT05_135039_19981217', '1998-12-17');
mapitL5('LANDSAT/LT05/C01/T1_SR/LT05_135039_20000512', '2000-05-12');
mapitL5('LANDSAT/LT05/C01/T1_SR/LT05_135039_20001222', '2000-12-22');
mapitL5('LANDSAT/LT05/C01/T1_SR/LT05_135039_20010224', '2001-02-24');
mapitL5('LANDSAT/LT05/C01/T1_SR/LT05_135039_20010702', '2001-07-02');
mapitL5('LANDSAT/LT05/C01/T1_SR/LT05_135039_20020110', '2002-01-10');
mapitL5('LANDSAT/LT05/C01/T1_SR/LT05_135039_20021110', '2002-11-10');
mapitL5('LANDSAT/LT05/C01/T1_SR/LT05_135039_20030419', '2003-04-19');
mapitL5('LANDSAT/LT05/C01/T1_SR/LT05_135039_20030724', '2003-07-24');
mapitL5('LANDSAT/LT05/C01/T1_SR/LT05_135039_20031215', '2003-12-15');
mapitL5('LANDSAT/LT05/C01/T1_SR/LT05_135039_20040217', '2004-02-16');
mapitL5('LANDSAT/LT05/C01/T1_SR/LT05_135039_20040507', '2004-05-07');
mapitL5('LANDSAT/LT05/C01/T1_SR/LT05_135039_20060206', '2006-02-06');
mapitL5('LANDSAT/LT05/C01/T1_SR/LT05_135039_20061121', '2006-11-21');
mapitL5('LANDSAT/LT05/C01/T1_SR/LT05_135039_20070124', '2007-01-24');
mapitL5('LANDSAT/LT05/C01/T1_SR/LT05_135039_20070414', '2007-04-14');
mapitL5('LANDSAT/LT05/C01/T1_SR/LT05_135039_20080705', '2008-07-05');
mapitL5('LANDSAT/LT05/C01/T1_SR/LT05_135039_20081126', '2008-11-26');
mapitL5('LANDSAT/LT05/C01/T1_SR/LT05_135039_20090302', '2009-03-02');
mapitL5('LANDSAT/LT05/C01/T1_SR/LT05_135039_20091129', '2009-11-29');
mapitL5('LANDSAT/LT05/C01/T1_SR/LT05_135039_20100321', '2010-03-21');
mapitL5('LANDSAT/LT05/C01/T1_SR/LT05_135039_20101218', '2010-12-18');
mapitL5('LANDSAT/LT05/C01/T1_SR/LT05_135039_20110204', '2011-02-04');
mapitL5('LANDSAT/LT05/C01/T1_SR/LT05_135039_20110831', '2011-08-31');
mapitL5('LANDSAT/LE07/C01/T1_SR/LE07_135039_20111111', '2011-11-11');
mapitL8('LANDSAT/LC08/C01/T1_SR/LC08_135039_20130804', '2013-08-04');
mapitL8('LANDSAT/LC08/C01/T1_SR/LC08_135039_20131124', '2013-11-24');
mapitL8('LANDSAT/LC08/C01/T1_SR/LC08_135039_20140316', '2014-03-16');
mapitL8('LANDSAT/LC08/C01/T1_SR/LC08_135039_20141229', '2014-12-29');
mapitL8('LANDSAT/LC08/C01/T1_SR/LC08_135039_20150420', '2015-04-20');
mapitL8('LANDSAT/LC08/C01/T1_SR/LC08_135039_20151130', '2015-11-30');
mapitL8('LANDSAT/LC08/C01/T1_SR/LC08_135039_20160305', '2016-03-05');
mapitL8('LANDSAT/LC08/C01/T1_SR/LC08_135039_20160524', '2016-05-24');

mapitL8('LANDSAT/LC08/C01/T1_SR/LC08_135039_20161031', '2016-10-31');
mapitL8('LANDSAT/LC08/C01/T1_RT/LC08_135039_20170204', '2017-02-04');
mapitL8('LANDSAT/LC08/C01/T1_RT/LC08_135039_20171221', '2017-12-21');
mapitL8('LANDSAT/LC08/C01/T1_RT/LC08_135039_20180122', '2018-12-22');

S2mosaicfunction('2016-12-10', '2016-12-11', '2016-12-11');
S2mosaicfunction('2017-12-20', '2017-12-21', '2017-12-20');
S2mosaicfunction('2018-01-19', '2018-01-20', '2018-01-19');

var exportfunc = function(imagenumber, name, B1, B2, B3, min, max, scale){ 
var i = ee.Image(imagenumber);
var iviz = i.visualize({bands: [B1, B2, B3], min:min, max: max});

Export.image.toDrive({
  image:iviz,
  description: name,
  folder: "gyala-peri-glacier",
	scale: scale,
	crs:"EPSG:32646",
	region: geometry  
	});};
	
exportfunc('LANDSAT/LC08/C01/T1_SR/LC08_135039_20161031', '2016-10-31', 'B7', 'B5', 'B3', 1, 8500, 30);