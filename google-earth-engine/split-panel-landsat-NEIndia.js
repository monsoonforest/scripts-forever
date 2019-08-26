// CHANGE THE STATE NAME IN NE INDIA TO DISPLAY ACCORDINGLY FIRST LETTER ALWAYS CAPITAL

var area = neindia.filterMetadata('NAME_1', 'equals', "Arunachal Pradesh")


var images = {
  '1986' : getYearlyLandsatComposite('1986-01-01'),
  '1987' : getYearlyLandsatComposite('1987-01-01'),
  '1988' : getYearlyLandsatComposite('1988-01-01'),
  '1989' : getYearlyLandsatComposite('1989-01-01'),
  '1990' : getYearlyLandsatComposite('1990-01-01'),
  '1991' : getYearlyLandsatComposite('1991-01-01'),
  '1992' : getYearlyLandsatComposite('1992-01-01'),
  '1993' : getYearlyLandsatComposite('1993-01-01'),
  '1994' : getYearlyLandsatComposite('1994-01-01'),
  '1995' : getYearlyLandsatComposite('1995-01-01'),
  '1996' : getYearlyLandsatComposite('1996-01-01'),
  '1997' : getYearlyLandsatComposite('1997-01-01'),
  '1998' : getYearlyLandsatComposite('1998-01-01'),
  '1999' : getYearlyLandsatComposite('1999-01-01'),
  '2000' : getYearlyLandsatComposite('2000-01-01'),
  '2001' : getYearlyLandsatComposite('2001-01-01'),
  '2002' : getYearlyLandsatComposite('2002-01-01'),
  '2003' : getYearlyLandsatComposite('2003-01-01'),
  '2004' : getYearlyLandsatComposite('2004-01-01'),
  '2005' : getYearlyLandsatComposite('2005-01-01'),
  '2006' : getYearlyLandsatComposite('2006-01-01'),
  '2007' : getYearlyLandsatComposite('2007-01-01'),
  '2008' : getYearlyLandsatComposite('2008-01-01'),
  '2009' : getYearlyLandsatComposite('2009-01-01'),
  '2010' : getYearlyLandsatComposite('2010-01-01'),
  '2011' : getYearlyLandsatComposite('2011-01-01'),
  '2012' : getYearlyLandsat8Composite('2012-01-01'),
  '2013' : getYearlyLandsat8Composite('2013-01-01'),
  '2014' : getYearlyLandsat8Composite('2014-01-01'),
  '2015' : getYearlyLandsat8Composite('2015-01-01'),
  '2016' : getYearlyLandsat8Composite('2016-01-01'),
  '2017' : getYearlyLandsat8Composite('2017-01-01'),
  '2018' : getYearlyLandsat8Composite('2018-01-01')
    };

// for landsat 5
function getYearlyLandsatComposite(dated) {
  var start = ee.Date(dated);

var end = ee.Date(start.advance(364, 'day'))

var collection = ee.ImageCollection('LANDSAT/LT05/C01/T1').filterDate(start, end);

  var mosaic = ee.Algorithms.Landsat.simpleComposite(collection);
var clipit = mosaic.clip(area)
   return clipit.visualize({bands:['B3', 'B2', 'B1'], min: 0,  max : 45});
}

// For Landsat 8
function getYearlyLandsat8Composite(dated) {
  var start = ee.Date(dated);

var end = ee.Date(start.advance(364, 'day'))

var collection = ee.ImageCollection('LANDSAT/LC08/C01/T1').filterDate(start, end);

  var mosaic = ee.Algorithms.Landsat.simpleComposite(collection);
var clipit = mosaic.clip(area)
   return clipit.visualize({bands:['B4', 'B3', 'B2'], min: 0,  max : 45});
}
var leftMap = ui.Map();
leftMap.setControlVisibility(false);
var leftSelector = addLayerSelector(leftMap, 0, 'top-left');

// Create the right map, and have it display layer 1.
var rightMap = ui.Map();
rightMap.setControlVisibility(true);
var rightSelector = addLayerSelector(rightMap, 1, 'top-right');

// Adds a layer selection widget to the given map, to allow users to change
// which image is displayed in the associated map.
function addLayerSelector(mapToChange, defaultValue, position) {
  var label = ui.Label('CHOOSE YEAR');

  // This function changes the given map to show the selected image.
  function updateMap(selection) {
    mapToChange.layers().set(0, ui.Map.Layer(images[selection]));
  }

  // Configure a selection dropdown to allow the user to choose between images,
  // and set the map to update when a user makes a selection.
  var select = ui.Select({items: Object.keys(images), onChange: updateMap});
  select.setValue(Object.keys(images)[defaultValue], true);

  var controlPanel =
      ui.Panel({widgets: [label, select], style: {position: position} });

  mapToChange.add(controlPanel);
}


/*
 * Tie everything together
 */

// Create a SplitPanel to hold the adjacent, linked maps.
var splitPanel = ui.SplitPanel({
  firstPanel: leftMap,
  secondPanel: rightMap,
  wipe: true,
  style: {stretch: 'both'}

});

// Set the SplitPanel as the only thing in the UI root.
ui.root.widgets().reset([splitPanel]);
var linker = ui.Map.Linker([leftMap, rightMap]);
leftMap.setCenter(94.6828, 28.3212, 9);


