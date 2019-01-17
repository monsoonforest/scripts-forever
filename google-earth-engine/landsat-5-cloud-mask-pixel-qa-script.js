//cloudy image
var cloudy_scene = ee.Image('LANDSAT/LT05/C01/T1_SR/LT05_135040_19900517');
Map.centerObject(cloudy_scene);

// add true color composite to map
Map.addLayer(cloudy_scene,{min:0,max:3000,bands:['B3','B2','B1']},'cloudy');

// Details for pixel_qa from LEDAPS Product Guide - 22 - Version 8.1
// 68, 132 = Water 
// 72, 136 =  Cloud shadow
// 80, 112, 144, 176 = Snow/ice
// 96, 112, 160, 176, 224 = Cloud


// select pixel_qa band as mask
var msk = cloudy_scene.select('pixel_qa');

//conditions which to mask out - no shadows, snow or clouds
msk = msk.neq(68).and(msk.neq(132))
      .and(msk.neq(72)).and(msk.neq(136))
       .and(msk.neq(80)).and(msk.neq(112)).and(msk.neq(144)).and(msk.neq(176))
        .and(msk.neq(96)).and(msk.neq(160)).and(msk.neq(176)).and(msk.neq(224));

// FOR LANDSAT 8 pixel_qa
msk = msk.neq(0).and(msk.neq(2))
		.and(msk.neq(3)).and(msk.neq(4)).and(msk.neq(5))
			.and(msk.neq(6)).and(msk.neq(7)).and(msk.neq(8)).and(msk.neq(9)).and(msk.neq(10))



// apply mask
var masked = cloudy_scene.mask(msk);

// add masked image to Layer
Map.addLayer(masked,{min:0,max:3000,bands:['B3','B2','B1']},'masked');
If one needs to apply an image mask over a collection use the map() function:

var rectangle = ee.Geometry.Rectangle(96.01669, 18.52621, 96.04819, 18.49634);
Map.centerObject(rectangle);

var bands = ['NDVI', 'SummaryQA'];

var modis = ee.ImageCollection("MODIS/006/MOD13Q1").filterDate('2000-01-01', '2018-01-01').select(bands).filterBounds(rectangle);

// PIXEL QUALITY MASKING
var maskQA = function(image) {
   var summaryqaband = image.select('SummaryQA')
     var mask = summaryqaband.neq(2).and(summaryqaband.neq(3))
        return image.updateMask(mask);
};

var goodqualdataset = modis.map(maskQA)

print(goodqualdataset);

// MAKE A LIST OF THE IMAGES IN THE COLLECTION
var goodquallistOfImages = goodqualdataset.toList(goodqualdataset.size());


// VISUALIZATION PARAMETERS
var ndviParams = {bands:['NDVI'], min: -1, max: 1, palette: ['blue', 'white', 'green']};

var img1 = goodquallistOfImages.get(0);

// ADD THE LAYER AND SEE HOW THE MASK WORKED
Map.addLayer(ee.Image(img1).divide(10000).clip(rectangle), ndviParams, 'masked-modis