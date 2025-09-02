// Naver Maps implementation for Flutter web
class NaverMapController {
  constructor() {
    this.map = null;
    this.marker = null;
    this.isInitialized = false;
  }

  async initialize(elementId, options) {
    try {
      // Wait for Naver Maps to load
      await this.waitForNaverMaps();
      
      const mapElement = document.getElementById(elementId);
      if (!mapElement) {
        throw new Error(`Element with id ${elementId} not found`);
      }

      // Clear any existing content
      mapElement.innerHTML = '';
      
      // Create map instance with proper error handling
      this.map = new naver.maps.Map(elementId, {
        center: new naver.maps.LatLng(options.latitude || 37.5665, options.longitude || 126.9780),
        zoom: options.zoom || 15,
        zoomControl: options.showControls !== false,
        zoomControlOptions: {
          position: naver.maps.Position.TOP_RIGHT
        },
        mapTypeControl: options.showControls !== false,
        scaleControl: false,
        logoControl: false
      });
      
      console.log('🗺️ Naver map created successfully');

      // Add custom marker similar to Google Maps style
      if (options.showMarker !== false) {
        this.marker = new naver.maps.Marker({
          position: new naver.maps.LatLng(options.latitude, options.longitude),
          map: this.map,
          title: options.venue || 'Wedding Venue',
          icon: {
            url: 'data:image/svg+xml;base64,' + btoa(`
              <svg width="24" height="30" viewBox="0 0 24 30" xmlns="http://www.w3.org/2000/svg">
                <defs>
                  <filter id="shadow" x="-50%" y="-50%" width="200%" height="200%">
                    <feDropShadow dx="0" dy="1" stdDeviation="1" flood-color="rgba(0,0,0,0.3)"/>
                  </filter>
                </defs>
                <!-- Main marker body -->
                <path d="M12 0C5.4 0 0 5.4 0 12c0 9 12 18 12 18s12-9 12-18C24 5.4 18.6 0 12 0z" 
                      fill="#ff4757" filter="url(#shadow)"/>
                <!-- White circle background for icon -->
                <circle cx="12" cy="10.5" r="6" fill="white"/>
                <!-- Heart icon (smaller) -->
                <path d="M12 16c-0.5 0-1-0.4-1-1 0-0.3 0.1-0.5 0.3-0.7L13.5 12.4c0.5-0.5 0.5-1.4 0-1.9s-1.4-0.5-1.9 0l-1 1-1-1c-0.5-0.5-1.4-0.5-1.9 0s-0.5 1.4 0 1.9l2.6 2.8c0.2 0.1 0.3 0.4 0.3 0.7 0 0.5-0.4 1-1 1z" 
                      fill="#ff4757"/>
              </svg>
            `),
            size: new naver.maps.Size(24, 30),
            scaledSize: new naver.maps.Size(24, 30),
            anchor: new naver.maps.Point(12, 30),
            origin: new naver.maps.Point(0, 0)
          }
        });

        // Enhanced info window with better styling
        if (options.venue) {
          // Determine the correct navigation URL based on venue
          let naverMapUrl = 'https://map.naver.com/v5/directions/-,-/-,' + options.latitude + ',' + options.longitude;
          if (options.venue === '일월의정원') {
            naverMapUrl = 'https://map.naver.com/p/entry/place/1391329941?c=15.00,0,0,0,dh&placePath=/home?from=map&fromPanelNum=1&additionalHeight=76&timestamp=202508311942&locale=ko&svcName=map_pcv5';
          }
          
          // Get address info if available
          const addressInfo = options.address || '울산광역시 울주군 두동면 은편리 891';
          
          const infoWindow = new naver.maps.InfoWindow({
            content: `
              <div style="
                padding: 14px; 
                min-width: 220px; 
                max-width: 280px;
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Malgun Gothic', 'Apple SD Gothic Neo', sans-serif;
                border-radius: 8px;
                box-shadow: 0 4px 12px rgba(0,0,0,0.15);
                background: white;
              ">
                <h4 style="
                  margin: 0 0 8px 0; 
                  font-size: 15px; 
                  font-weight: 600; 
                  color: #2c3e50;
                  text-align: center;
                ">${options.venue}</h4>
                <div style="
                  padding: 8px; 
                  background: #f8f9fa; 
                  border-radius: 6px; 
                  font-size: 12px; 
                  color: #495057;
                  line-height: 1.4;
                  text-align: center;
                ">
                  <div style="margin-bottom: 2px;">
                    울산광역시 울주군 두동면
                  </div>
                  <div style="font-size: 11px; color: #6c757d;">
                    은편리 891
                  </div>
                </div>
                <div style="
                  text-align: center; 
                  margin-top: 10px; 
                  padding-top: 10px; 
                  border-top: 1px solid #e9ecef;
                ">
                  <button onclick="window.open('${naverMapUrl}', '_blank')" 
                    style="
                      background: #1ec800; 
                      color: white; 
                      border: none; 
                      padding: 8px 16px; 
                      border-radius: 4px; 
                      font-size: 12px;
                      cursor: pointer;
                      font-weight: 500;
                      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Malgun Gothic', sans-serif;
                    ">
                    길찾기
                  </button>
                </div>
              </div>
            `,
            borderWidth: 0,
            disableAnchor: false,
            backgroundColor: 'transparent',
            borderColor: 'transparent',
            anchorSize: new naver.maps.Size(10, 10),
            anchorSkew: false,
            anchorColor: '#ff4757'
          });

          // Open info window by default
          infoWindow.open(this.map, this.marker);
          
          // Add bounce animation on marker click
          naver.maps.Event.addListener(this.marker, 'click', () => {
            // Toggle info window
            if (infoWindow.getMap()) {
              infoWindow.close();
            } else {
              infoWindow.open(this.map, this.marker);
            }
            
            // Add bounce animation
            this.marker.setAnimation(naver.maps.Animation.BOUNCE);
            setTimeout(() => {
              this.marker.setAnimation(null);
            }, 1500);
          });
        }
      }

      this.isInitialized = true;
      return true;
    } catch (error) {
      console.error('Failed to initialize Naver Map:', error);
      return false;
    }
  }

  async waitForNaverMaps() {
    const maxAttempts = 100;
    let attempts = 0;
    
    while (attempts < maxAttempts) {
      if (window.naver && window.naver.maps && window.naver.maps.Map) {
        console.log('✅ Naver Maps API is ready');
        return true;
      }
      console.log(`⏳ Waiting for Naver Maps API... (${attempts}/100)`);
      await new Promise(resolve => setTimeout(resolve, 100));
      attempts++;
    }
    
    throw new Error('Naver Maps API failed to load after 10 seconds');
  }

  setCenter(latitude, longitude) {
    if (this.map) {
      this.map.setCenter(new naver.maps.LatLng(latitude, longitude));
    }
  }

  setZoom(zoom) {
    if (this.map) {
      this.map.setZoom(zoom);
    }
  }

  updateMarker(latitude, longitude, title) {
    if (this.marker) {
      this.marker.setPosition(new naver.maps.LatLng(latitude, longitude));
      if (title) {
        this.marker.setTitle(title);
      }
      
      // Update marker with custom icon if needed
      this.marker.setIcon({
        url: 'data:image/svg+xml;base64,' + btoa(`
          <svg width="24" height="30" viewBox="0 0 24 30" xmlns="http://www.w3.org/2000/svg">
            <defs>
              <filter id="shadow" x="-50%" y="-50%" width="200%" height="200%">
                <feDropShadow dx="0" dy="1" stdDeviation="1" flood-color="rgba(0,0,0,0.3)"/>
              </filter>
            </defs>
            <!-- Main marker body -->
            <path d="M12 0C5.4 0 0 5.4 0 12c0 9 12 18 12 18s12-9 12-18C24 5.4 18.6 0 12 0z" 
                  fill="#ff4757" filter="url(#shadow)"/>
            <!-- White circle background for icon -->
            <circle cx="12" cy="10.5" r="6" fill="white"/>
            <!-- Heart icon (smaller) -->
            <path d="M12 16c-0.5 0-1-0.4-1-1 0-0.3 0.1-0.5 0.3-0.7L13.5 12.4c0.5-0.5 0.5-1.4 0-1.9s-1.4-0.5-1.9 0l-1 1-1-1c-0.5-0.5-1.4-0.5-1.9 0s-0.5 1.4 0 1.9l2.6 2.8c0.2 0.1 0.3 0.4 0.3 0.7 0 0.5-0.4 1-1 1z" 
                  fill="#ff4757"/>
          </svg>
        `),
        size: new naver.maps.Size(24, 30),
        scaledSize: new naver.maps.Size(24, 30),
        anchor: new naver.maps.Point(12, 30),
        origin: new naver.maps.Point(0, 0)
      });
    }
  }

  destroy() {
    if (this.marker) {
      this.marker.setMap(null);
      this.marker = null;
    }
    if (this.map) {
      this.map.destroy();
      this.map = null;
    }
    this.isInitialized = false;
  }
}

// Global map for storing controller instances
window.naverMapControllers = window.naverMapControllers || {};

// Flutter web channel functions
window.createNaverMap = async function(elementId, options) {
  try {
    console.log('🚀 Creating Naver Map with options:', options);
    
    const controller = new NaverMapController();
    const success = await controller.initialize(elementId, options);
    
    if (success) {
      window.naverMapControllers[elementId] = controller;
      console.log('✅ Naver Map controller created successfully');
      return { success: true };
    } else {
      console.error('❌ Failed to initialize Naver Map');
      return { success: false, error: 'Failed to initialize map' };
    }
  } catch (error) {
    console.error('❌ Naver Map creation error:', error);
    
    // Check for specific authentication errors
    if (error.message.includes('인증') || error.message.includes('auth')) {
      return { success: false, error: `Authentication failed: ${error.message}` };
    }
    
    return { success: false, error: error.message };
  }
};

window.updateNaverMap = function(elementId, options) {
  const controller = window.naverMapControllers[elementId];
  if (!controller || !controller.isInitialized) {
    return { success: false, error: 'Map not initialized' };
  }

  if (options.latitude !== undefined && options.longitude !== undefined) {
    controller.setCenter(options.latitude, options.longitude);
    if (controller.marker) {
      controller.updateMarker(options.latitude, options.longitude, options.venue);
    }
  }

  if (options.zoom !== undefined) {
    controller.setZoom(options.zoom);
  }

  return { success: true };
};

window.destroyNaverMap = function(elementId) {
  const controller = window.naverMapControllers[elementId];
  if (controller) {
    controller.destroy();
    delete window.naverMapControllers[elementId];
  }
  return { success: true };
};