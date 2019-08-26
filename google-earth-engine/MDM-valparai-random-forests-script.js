// STEPS INVOLVED IN SUPERVISED CLASSIFICATION OF LAND COVER

//----- 1. PREPARE RELEVANT IMAGE DATA -----
// Select an image collection from which you'd like to use images to classify land-cover types
// Here, we are using images obtained from the Copernicus Sentinel-2 satellite
var s2 = ee.ImageCollection('COPERNICUS/S2');

// Select a point or region of interest around which you'd like to classify land cover
var poi = ee.Geometry.Point([76.89157, 10.30961]); //Valparai, India

// Use appropriate spatial, temporal and metadata filters to obtain a relevant subset of images
// and create a simple or median composite image, keeping only relevant bands
var s2_composite = s2.filterBounds(poi) //spatial filter
          .filterDate("2018-01-01", "2018-12-31") //temporal filter
          .filter(ee.Filter.lt('CLOUDY_PIXEL_PERCENTAGE', 25)) // metadata filter
          .median() //create median composite
          .select("B.*") //select only non QA bands
          .divide(10000); //rescale reflectance values 

Map.setCenter(76.89157, 10.30961, 14);
Map.addLayer(s2_composite, {bands:['B4', 'B3', 'B2'], min:0.05, max:0.17}, 'S2_Composite_RGB');


//----- 2. PREPARE LABELLED LAND-COVER DATA FOR TRAINING -----
// Creating training data within code editor
// Create feature collections for water and land, labelled 0 and 1, respectively
var trdata = water.merge(vegetation).merge(bare_soil);

// Demo creation of a new feature collection for bare soil, labelled 2, and merging with 
// var trdata = water.merge(vegetation).merge(bare_soil);

// Alternatively, you can import your own training data from a shapefile, or from an EE asset.
// see https://developers.google.com/earth-engine/importing


//----- 3. CREATE SPECTRAL SIGNATURES FOR LAND-COVER TYPES -----
// Sample the input imagery to get a FeatureCollection of training data.
var training = s2_composite.sampleRegions({
  collection: trdata,
  properties: ['label'],
  scale: 20
});


//----- 4. TRAIN A CLASSIFIER -----
// Make a Random Forest classifier with 10 trees and train it.
var classifier = ee.Classifier.randomForest(10).train({
  features: training,
  classProperty: 'label'
});


//----- 5. APPLY CLASSIFIER AND GENERATE CLASSIFIED IMAGE -----
// Classify the input imagery.
var classified = s2_composite.classify(classifier);

// Define a palette for the land-cover types
var palette = [
  '041ed6', // water = blue
  '6fb500', //  vegetation = green
  'f9da00' //  bare = gold
];

// Display the classification result and the input image.
Map.addLayer(classified, {min: 0, max: 2, palette: palette, opacity: 0.7}, 'Land-cover Classification');


//----- 5. ASSESS ACCURACY OF THE CLASSIFIER -----
// Get a confusion matrix representing resubstitution accuracy.
print('Training Error Matrix: ', classifier.confusionMatrix());
print('Training Accuracy: ', classifier.confusionMatrix().accuracy());

// Training Accuracy is a measure of how well the classifier classifies data it has already
// seen, and hence not very useful. Where a large set of labelled land-cover data are available
// one must use one fraction of these data as 'training fraction' to train a classifier, and
// the remainder as an independent 'validation fraction' to test the accuracy of the classifier
// in classifying labelled data that it has not previously seen.