// Wedding Invitation Google Map Styles and Implementation
// Based on the piano school project's elegant map design

window.WeddingMapStyles = {
  // Elegant wedding-themed map styling
  mapStyles: [
    {
      "featureType": "all",
      "elementType": "geometry.fill",
      "stylers": [{"weight": "2.00"}]
    },
    {
      "featureType": "all",
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#746855"}]
    },
    {
      "featureType": "all",
      "elementType": "labels.text.stroke",
      "stylers": [{"color": "#ede7f0"}]
    },
    {
      "featureType": "administrative",
      "elementType": "geometry.fill",
      "stylers": [{"color": "#d6b2d9"}]
    },
    {
      "featureType": "administrative",
      "elementType": "geometry.stroke",
      "stylers": [{"color": "#9c5da5"}]
    },
    {
      "featureType": "landscape",
      "elementType": "geometry.fill",
      "stylers": [{"color": "#faf4f5"}]
    },
    {
      "featureType": "poi",
      "elementType": "geometry.fill",
      "stylers": [{"color": "#e8d5ea"}]
    },
    {
      "featureType": "poi.park",
      "elementType": "geometry.fill",
      "stylers": [{"color": "#d4e5d7"}]
    },
    {
      "featureType": "road",
      "elementType": "geometry.fill",
      "stylers": [{"color": "#ffffff"}]
    },
    {
      "featureType": "road.arterial",
      "elementType": "geometry.fill",
      "stylers": [{"color": "#f5f1f6"}]
    },
    {
      "featureType": "road.highway",
      "elementType": "geometry.fill",
      "stylers": [{"color": "#e8d5ea"}]
    },
    {
      "featureType": "water",
      "elementType": "geometry.fill",
      "stylers": [{"color": "#b3d9f2"}]
    }
  ],

  // Create info window content for venue
  createInfoWindow: function(venueData) {
    return `
      <div style="padding: 16px; max-width: 300px; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;">
        <div style="text-align: center; margin-bottom: 12px;">
          <h3 style="margin: 0 0 8px 0; color: #d63384; font-size: 18px; font-weight: 600;">
            ${venueData.name}
          </h3>
          <div style="width: 40px; height: 2px; background: linear-gradient(90deg, #d63384, #fd7e14); margin: 0 auto;"></div>
        </div>
        
        <div style="margin-bottom: 16px;">
          <div style="display: flex; align-items: flex-start; margin-bottom: 8px;">
            <span style="color: #6c757d; font-size: 14px; margin-right: 8px;">📍</span>
            <span style="color: #495057; font-size: 14px; line-height: 1.4;">
              ${venueData.address}
            </span>
          </div>
          
          ${venueData.date ? `
          <div style="display: flex; align-items: center; margin-bottom: 8px;">
            <span style="color: #6c757d; font-size: 14px; margin-right: 8px;">📅</span>
            <span style="color: #495057; font-size: 14px;">
              ${venueData.date}
            </span>
          </div>
          ` : ''}
          
          ${venueData.time ? `
          <div style="display: flex; align-items: center; margin-bottom: 8px;">
            <span style="color: #6c757d; font-size: 14px; margin-right: 8px;">🕐</span>
            <span style="color: #495057; font-size: 14px;">
              ${venueData.time}
            </span>
          </div>
          ` : ''}
        </div>
        
        <div style="text-align: center;">
          <a href="https://maps.google.com/maps?q=${venueData.lat},${venueData.lng}" 
             target="_blank"
             style="display: inline-block; background: linear-gradient(135deg, #d63384, #fd7e14); 
                    color: white; text-decoration: none; padding: 10px 20px; 
                    border-radius: 25px; font-size: 13px; font-weight: 500;
                    box-shadow: 0 2px 8px rgba(214, 51, 132, 0.3);
                    transition: all 0.3s ease;">
            <span style="margin-right: 6px;">🧭</span>
            Get Directions
          </a>
        </div>
        
        <div style="text-align: center; margin-top: 12px; padding-top: 12px; border-top: 1px solid #e9ecef;">
          <span style="color: #6c757d; font-size: 12px;">
            💒 Wedding Venue
          </span>
        </div>
      </div>
    `;
  },

  // Initialize map with wedding styling
  initMap: function(containerId, venueData, options = {}) {
    const defaultOptions = {
      zoom: 15,
      scrollwheel: false,
      mapTypeControl: false,
      streetViewControl: true,
      fullscreenControl: true,
      zoomControl: true,
      ...options
    };

    const map = new google.maps.Map(document.getElementById(containerId), {
      center: { lat: venueData.lat, lng: venueData.lng },
      styles: this.mapStyles,
      ...defaultOptions
    });

    // Create custom marker icon (heart shape for wedding)
    const markerIcon = {
      path: 'M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z',
      fillColor: '#d63384',
      fillOpacity: 1,
      strokeColor: '#ffffff',
      strokeWeight: 2,
      scale: 1.2,
      anchor: new google.maps.Point(12, 21)
    };

    const marker = new google.maps.Marker({
      position: { lat: venueData.lat, lng: venueData.lng },
      map: map,
      title: venueData.name,
      icon: markerIcon,
      animation: google.maps.Animation.DROP
    });

    const infoWindow = new google.maps.InfoWindow({
      content: this.createInfoWindow(venueData),
      disableAutoPan: false
    });

    marker.addListener('click', () => {
      infoWindow.open(map, marker);
    });

    // Open info window by default for wedding venues
    setTimeout(() => {
      infoWindow.open(map, marker);
    }, 1000);

    return { map, marker, infoWindow };
  }
};

console.log('✅ Wedding Map Styles Loaded');