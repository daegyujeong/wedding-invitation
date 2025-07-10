// Suppress Google Maps deprecation warnings for web platform
// This is a known issue with google_maps_flutter plugin
// The warning doesn't affect functionality and will be fixed in future plugin updates

// Override console.warn to suppress specific Google Maps warnings
const originalWarn = console.warn;
console.warn = function (...args) {
  // List of warnings to suppress
  const suppressedWarnings = [
    'Google Maps JavaScript API deprecation warning',
    'The Google Maps JavaScript API',
    'ImportError: The google.maps JavaScript API',
    'InvalidKeyMapError',
    'js_interop',
    'dart:js_interop'
  ];

  const message = args.join(' ');

  // Check if the warning should be suppressed
  const shouldSuppress = suppressedWarnings.some(warning =>
    message.includes(warning)
  );

  if (!shouldSuppress) {
    originalWarn.apply(console, args);
  }
};

// Override console.error to suppress JSON parsing errors from Google Maps
const originalError = console.error;
console.error = function (...args) {
  const message = args.join(' ');
  
  // Suppress JSON parsing errors from Google Maps Flutter Web
  if (message.includes('Unexpected') && message.includes('JSON') && 
      (message.includes('_mapStyles') || message.includes('google_maps_flutter_web'))) {
    console.log('Suppressed Google Maps JSON parsing error');
    return;
  }
  
  originalError.apply(console, args);
};

// Handle Google Maps API loading errors
window.addEventListener('error', function (event) {
  if (event.error && event.error.message) {
    const errorMessage = event.error.message;

    // Suppress JSON parsing errors from Google Maps
    if (errorMessage.includes('Unexpected') && errorMessage.includes('JSON') &&
        (errorMessage.includes('_mapStyles') || errorMessage.includes('google_maps_flutter_web'))) {
      console.log('Caught and suppressed Google Maps JSON error');
      event.preventDefault();
      return true;
    }

    // Handle common Google Maps errors
    if (errorMessage.includes('InvalidKeyMapError') ||
      errorMessage.includes('Google Maps API key')) {
      console.error('Google Maps API Key Error:', errorMessage);

      // Show user-friendly error message
      const errorDiv = document.createElement('div');
      errorDiv.innerHTML = `
        <div style="
          position: fixed;
          top: 50%;
          left: 50%;
          transform: translate(-50%, -50%);
          background: #fff;
          padding: 20px;
          border-radius: 8px;
          box-shadow: 0 4px 12px rgba(0,0,0,0.1);
          z-index: 9999;
          max-width: 400px;
          text-align: center;
        ">
          <h3 style="color: #e74c3c; margin: 0 0 10px 0;">지도 로드 오류</h3>
          <p style="margin: 0 0 15px 0;">Google Maps API 키 설정에 문제가 있습니다.</p>
          <button onclick="this.parentElement.parentElement.remove()" style="
            background: #3498db;
            color: white;
            border: none;
            padding: 8px 16px;
            border-radius: 4px;
            cursor: pointer;
          ">확인</button>
        </div>
      `;

      document.body.appendChild(errorDiv);
      return true; // Prevent default error handling
    }
  }

  return false;
}, true);

// Log successful Google Maps API loading
window.addEventListener('load', function () {
  if (typeof google !== 'undefined' && google.maps) {
    console.log('Google Maps API loaded successfully');
  } else {
    console.warn('Google Maps API not loaded');
  }
});