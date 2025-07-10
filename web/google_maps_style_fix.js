// Fix for Google Maps Flutter Web empty style JSON parsing error
// This is a workaround for a bug in google_maps_flutter_web where
// an empty string is passed as style and causes JSON.parse to fail
(function() {
  console.log('✅ Google Maps Style Fix Loaded');
  
  // Store original JSON.parse
  const originalParse = JSON.parse;
  
  // Override JSON.parse to catch what's being parsed
  JSON.parse = function(text, reviver) {
    try {
      // FIX: Handle empty string case for map styles
      if (text === '' && new Error().stack.includes('_mapStyles')) {
        return []; // Return empty array instead of trying to parse empty string
      }
      
      
      return originalParse.call(this, text, reviver);
    } catch (e) {
      // Additional fix: If parsing fails and it's from _mapStyles, return empty array
      if (new Error().stack.includes('_mapStyles')) {
        return [];
      }
      
      // Re-throw other errors
      throw e;
    }
  };

  
})();