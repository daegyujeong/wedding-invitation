// iOS Safari Map Helper - Provides iOS-compatible map initialization
window.iOSMapHelper = {
  
  // Detect if running on iOS Safari
  isIOSSafari: function() {
    const ua = navigator.userAgent.toLowerCase();
    const isIOS = /iphone|ipad|ipod/.test(ua) || 
                  (navigator.platform && /iphone|ipad|ipod/.test(navigator.platform.toLowerCase())) ||
                  (navigator.maxTouchPoints && navigator.maxTouchPoints > 1 && /mac/.test(ua));
    
    console.log('🔍 iOS Detection:', {
      userAgent: ua,
      platform: navigator.platform,
      maxTouchPoints: navigator.maxTouchPoints,
      isIOS: isIOS
    });
    
    // For iOS, return true regardless of browser (Safari, Chrome, WebView, etc.)
    return isIOS;
  },
  
  // Initialize map with iOS-specific handling
  initIOSMap: function(elementId, options) {
    console.log('🍎 Initializing iOS-compatible map for:', elementId);
    
    return new Promise((resolve, reject) => {
      // Wait for Google Maps to be fully loaded
      const checkGoogleMaps = () => {
        if (typeof google !== 'undefined' && google.maps && google.maps.Map) {
          try {
            const mapElement = document.getElementById(elementId);
            if (!mapElement) {
              console.error('Map element not found:', elementId);
              reject(new Error('Map element not found'));
              return;
            }
            
            // Force element to be visible and have dimensions
            mapElement.style.display = 'block';
            mapElement.style.width = '100%';
            mapElement.style.height = '100%';
            mapElement.style.minHeight = '300px';
            
            // Add a small delay for iOS Safari to properly render the container
            setTimeout(() => {
              try {
                // Simple map initialization without complex styles for iOS
                const map = new google.maps.Map(mapElement, {
                  center: { lat: options.latitude || 37.5665, lng: options.longitude || 126.9780 },
                  zoom: options.zoom || 15,
                  // Simplified controls for iOS
                  zoomControl: true,
                  mapTypeControl: false,
                  scaleControl: false,
                  streetViewControl: false,
                  rotateControl: false,
                  fullscreenControl: false,
                  // Disable complex features that might cause issues
                  gestureHandling: 'greedy',
                  // Use simple map type
                  mapTypeId: google.maps.MapTypeId.ROADMAP
                });
                
                // Add marker with simpler configuration
                const marker = new google.maps.Marker({
                  position: { lat: options.latitude, lng: options.longitude },
                  map: map,
                  title: options.venue || 'Wedding Venue'
                });
                
                // Simple info window
                if (options.venue) {
                  const infoWindow = new google.maps.InfoWindow({
                    content: `
                      <div style="padding: 10px; font-family: -apple-system, sans-serif;">
                        <h3 style="margin: 0 0 8px 0; font-size: 16px;">${options.venue}</h3>
                        ${options.address ? `<p style="margin: 0; font-size: 14px; color: #666;">${options.address}</p>` : ''}
                        <a href="https://maps.google.com/?q=${options.latitude},${options.longitude}" 
                           target="_blank" 
                           style="display: inline-block; margin-top: 10px; padding: 6px 12px; background: #4285f4; color: white; text-decoration: none; border-radius: 4px; font-size: 14px;">
                          Get Directions
                        </a>
                      </div>
                    `
                  });
                  
                  marker.addListener('click', () => {
                    infoWindow.open(map, marker);
                  });
                  
                  // Auto-open info window
                  setTimeout(() => {
                    infoWindow.open(map, marker);
                  }, 1000);
                }
                
                console.log('✅ iOS map initialized successfully');
                resolve({ map, marker });
                
              } catch (error) {
                console.error('Error creating iOS map:', error);
                reject(error);
              }
            }, 100); // Small delay for iOS rendering
            
          } catch (error) {
            console.error('Error setting up iOS map:', error);
            reject(error);
          }
        } else {
          // Retry after a short delay
          setTimeout(checkGoogleMaps, 100);
        }
      };
      
      checkGoogleMaps();
    });
  },
  
  // Create a static map fallback for iOS
  createStaticMapFallback: function(elementId, options) {
    const mapElement = document.getElementById(elementId);
    if (!mapElement) {
      console.error('📍 Map element not found for static fallback:', elementId);
      return;
    }
    
    console.log('📱 Creating static map fallback for iOS');
    
    const staticMapUrl = `https://maps.googleapis.com/maps/api/staticmap?` +
      `center=${options.latitude},${options.longitude}` +
      `&zoom=${options.zoom || 15}` +
      `&size=600x400` +
      `&maptype=roadmap` +
      `&markers=color:red%7C${options.latitude},${options.longitude}` +
      `&key=AIzaSyDYtu2Bu-VPXsA3z5sWaENXOqa-B-m8vxM`;
    
    const fallbackHtml = `
      <div style="width: 100%; height: 100%; position: relative; background: #f0f0f0; border-radius: 12px; overflow: hidden;">
        <img src="${staticMapUrl}" alt="${options.venue || 'Map'}" style="width: 100%; height: 100%; object-fit: cover;">
        <div style="position: absolute; bottom: 0; left: 0; right: 0; background: rgba(255,255,255,0.95); padding: 12px; text-align: center;">
          <h4 style="margin: 0 0 8px 0; font-size: 16px; color: #333;">${options.venue || 'Location'}</h4>
          ${options.address ? `<p style="margin: 0 0 8px 0; font-size: 14px; color: #666;">${options.address}</p>` : ''}
          <a href="https://maps.apple.com/?q=${options.latitude},${options.longitude}" 
             target="_blank" 
             style="display: inline-block; padding: 8px 16px; background: #007aff; color: white; text-decoration: none; border-radius: 20px; font-size: 14px;">
            Open in Apple Maps
          </a>
        </div>
      </div>
    `;
    
    mapElement.innerHTML = fallbackHtml;
    console.log('✅ Static map fallback created');
  },
  
  // Force replace all map widgets on iOS
  replaceAllMapsOnIOS: function() {
    if (!this.isIOSSafari()) return;
    
    console.log('🍎 Force replacing all maps for iOS compatibility');
    
    // Wedding venue locations
    const venues = {
      malaysia: { lat: 3.8077, lng: 103.3260, name: 'DeVenue', address: 'Klang, Malaysia' },
      singapore: { lat: 1.2713102232292395, lng: 103.81929169938385, name: 'Arbora', address: 'Mount Faber, Singapore' },
      korea: { lat: 35.62885057440548, lng: 129.21897305040977, name: '일월의정원', address: '울산광역시 울주군 두동면' }
    };
    
    // Find all potential map containers and Flutter WebView containers
    const mapSelectors = [
      '[id*="map"]', '[id*="Map"]', '[class*="map"]', '[class*="Map"]',
      'flt-glass-pane', 'flutter-view', '[flt-renderer]', 
      '.flutter-web-canvas-container', '[id*="wedding-map"]'
    ];
    
    const mapContainers = document.querySelectorAll(mapSelectors.join(', '));
    
    console.log(`🔍 Found ${mapContainers.length} potential map containers`);
    
    mapContainers.forEach((container, index) => {
      const isEmpty = container.innerHTML.trim() === '' || 
                     container.innerHTML.includes('Loading') ||
                     container.innerHTML.includes('wedding venue map') ||
                     !container.innerHTML.includes('<img') && !container.innerHTML.includes('iframe');
      
      if (isEmpty && container.offsetHeight > 100) { // Only replace if container has reasonable height
        console.log(`🔄 Replacing map container ${index}:`, container.id || container.className);
        
        // Try to determine which venue this should be
        let venue = venues.korea; // Default to Korea
        
        // Check URL parameters or content for hints
        const urlParams = new URLSearchParams(window.location.search);
        const venueParam = urlParams.get('venue');
        
        if (venueParam === 'sg' || window.location.href.includes('singapore')) {
          venue = venues.singapore;
        } else if (venueParam === 'my' || window.location.href.includes('malaysia')) {
          venue = venues.malaysia;
        }
        
        const fallbackOptions = {
          latitude: venue.lat,
          longitude: venue.lng,
          venue: venue.name,
          address: venue.address,
          zoom: 15
        };
        
        // Ensure container has ID for replacement
        if (!container.id) {
          container.id = `ios-map-${Date.now()}-${index}`;
        }
        
        this.createStaticMapFallback(container.id, fallbackOptions);
      }
    });
    
    // Also specifically target empty Flutter canvas containers
    const flutterContainers = document.querySelectorAll('flt-glass-pane > *');
    flutterContainers.forEach((container, index) => {
      if (container.offsetHeight > 200 && container.innerHTML.trim() === '') {
        console.log(`🔄 Replacing empty Flutter container ${index}`);
        container.id = `flutter-map-${Date.now()}-${index}`;
        this.createStaticMapFallback(container.id, {
          latitude: venues.korea.lat,
          longitude: venues.korea.lng,
          venue: venues.korea.name,
          address: venues.korea.address,
          zoom: 15
        });
      }
    });
  },
  
  // Initialize Naver Map for iOS
  initIOSNaverMap: function(elementId, options) {
    console.log('🍎 Initializing iOS Naver map for:', elementId);
    
    return new Promise((resolve, reject) => {
      const checkNaverMaps = () => {
        if (window.naver && window.naver.maps && window.naver.maps.Map) {
          try {
            const mapElement = document.getElementById(elementId);
            if (!mapElement) {
              reject(new Error('Map element not found'));
              return;
            }
            
            // Force visibility and dimensions
            mapElement.style.display = 'block';
            mapElement.style.width = '100%';
            mapElement.style.height = '100%';
            mapElement.style.minHeight = '300px';
            
            setTimeout(() => {
              try {
                const map = new naver.maps.Map(elementId, {
                  center: new naver.maps.LatLng(options.latitude || 37.5665, options.longitude || 126.9780),
                  zoom: options.zoom || 15,
                  zoomControl: true,
                  zoomControlOptions: {
                    position: naver.maps.Position.TOP_RIGHT
                  },
                  mapTypeControl: false
                });
                
                const marker = new naver.maps.Marker({
                  position: new naver.maps.LatLng(options.latitude, options.longitude),
                  map: map
                });
                
                console.log('✅ iOS Naver map initialized');
                resolve({ map, marker });
                
              } catch (error) {
                console.error('Error creating iOS Naver map:', error);
                reject(error);
              }
            }, 100);
            
          } catch (error) {
            reject(error);
          }
        } else {
          setTimeout(checkNaverMaps, 100);
        }
      };
      
      checkNaverMaps();
    });
  }
};

console.log('✅ iOS Map Helper loaded. iOS Safari detected:', window.iOSMapHelper.isIOSSafari());

// Auto-run iOS map replacement on page load
if (window.iOSMapHelper.isIOSSafari()) {
  console.log('🍎 iOS detected - setting up automatic map replacement');
  
  // Run immediately if DOM is ready
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', function() {
      setTimeout(function() {
        window.iOSMapHelper.replaceAllMapsOnIOS();
      }, 2000); // Wait 2 seconds for Flutter to render
    });
  } else {
    setTimeout(function() {
      window.iOSMapHelper.replaceAllMapsOnIOS();
    }, 2000);
  }
  
  // Also run periodically to catch dynamically created maps
  setInterval(function() {
    window.iOSMapHelper.replaceAllMapsOnIOS();
  }, 5000);
}