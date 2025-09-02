// Enhanced Wedding Map with Info Window - Simple implementation to avoid LegacyJavaScriptObject errors
window.EnhancedWeddingMap = {
  
  // Wedding-themed map styles
  mapStyles: [
    {
      "featureType": "landscape",
      "elementType": "geometry.fill", 
      "stylers": [{"color": "#faf4f5"}]
    },
    {
      "featureType": "water",
      "elementType": "geometry.fill",
      "stylers": [{"color": "#b3d9f2"}]
    },
    {
      "featureType": "road",
      "elementType": "geometry.fill",
      "stylers": [{"color": "#ffffff"}]
    },
    {
      "featureType": "poi.park",
      "elementType": "geometry.fill",
      "stylers": [{"color": "#d4e5d7"}]
    }
  ],

  // Initialize map with wedding venue info window
  initWeddingMap: function(mapElementId, venueData) {
    try {
      if (typeof google === 'undefined' || !google.maps) {
        console.error('Google Maps API not loaded');
        return null;
      }

      const mapElement = document.getElementById(mapElementId);
      if (!mapElement) {
        console.error('Map element not found:', mapElementId);
        return null;
      }

      // Add comprehensive CSS to hide Google Maps info window close button
      const style = document.createElement('style');
      style.textContent = `
        /* Hide all variations of Google Maps close button */
        .gm-ui-hover-effect { display: none !important; }
        .gm-style-iw-chr { display: none !important; }
        .gm-style-iw-c button { display: none !important; }
        .gm-style-iw button { display: none !important; }
        .gm-style-iw .gm-ui-hover-effect { display: none !important; }
        button[title="Close"] { display: none !important; }
        button[aria-label="Close"] { display: none !important; }
        .gm-style-iw button[aria-label="Close"] { display: none !important; }
        .gm-style-iw-d button { display: none !important; }
        .gm-style-iw-tc button { display: none !important; }
        /* Force hide with more specific selectors */
        div.gm-style-iw button { visibility: hidden !important; opacity: 0 !important; }
        .gm-style button[title*="lose"] { display: none !important; }
      `;
      document.head.appendChild(style);

      // Create map with wedding styling
      const map = new google.maps.Map(mapElement, {
        center: { lat: venueData.lat, lng: venueData.lng },
        zoom: 15,
        styles: this.mapStyles,
        scrollwheel: true,
        zoomControl: true,
        mapTypeControl: false,
        streetViewControl: true,
        fullscreenControl: true
      });

      // Create custom marker
      const marker = new google.maps.Marker({
        position: { lat: venueData.lat, lng: venueData.lng },
        map: map,
        title: venueData.name,
        animation: google.maps.Animation.DROP
      });

      // Create elegant info window content
      const infoContent = this.createInfoWindowContent(venueData);
      
      const infoWindow = new google.maps.InfoWindow({
        content: infoContent,
        disableAutoPan: false
      });

      // Hide the close button with CSS after the info window opens
      google.maps.event.addListener(infoWindow, 'domready', function() {
        // Hide the close button
        const closeBtn = document.querySelector('.gm-ui-hover-effect');
        if (closeBtn) {
          closeBtn.style.display = 'none';
        }
        
        // Alternative selector for close button
        const closeBtnAlt = document.querySelector('button[title="Close"]');
        if (closeBtnAlt) {
          closeBtnAlt.style.display = 'none';
        }
        
        // Another alternative selector
        const closeBtnAlt2 = document.querySelector('.gm-style-iw-chr');
        if (closeBtnAlt2) {
          closeBtnAlt2.style.display = 'none';
        }
      });

      // Open info window on marker click
      marker.addListener('click', function() {
        infoWindow.open(map, marker);
      });

      // Auto-open info window after a delay
      setTimeout(function() {
        infoWindow.open(map, marker);
      }, 1500);

      console.log('✅ Enhanced wedding map initialized successfully');
      return { map: map, marker: marker, infoWindow: infoWindow };

    } catch (error) {
      console.error('❌ Enhanced wedding map error:', error);
      return null;
    }
  },

  // Get specific Google Maps link for each location
  getMapLink: function(lat, lng) {
    // Malaysia location
    if (Math.abs(lat - 3.8077) < 0.0001 && Math.abs(lng - 103.3260) < 0.0001) {
      return 'https://maps.app.goo.gl/NQh4bPQZ6Mqd45rx6';
    }
    // Singapore location
    else if (Math.abs(lat - 1.273806) < 0.0001 && Math.abs(lng - 103.817497) < 0.0001) {
      return 'https://maps.app.goo.gl/YTLSyvffXX8HFUiRA';
    }
    // Korea location
    else if (Math.abs(lat - 35.6288349) < 0.0001) {
      return 'https://maps.app.goo.gl/MEbVPxKa3UYWWGmj8';
    }
    // Fallback to generic Google Maps link
    else {
      return `https://maps.google.com/maps?q=${lat},${lng}`;
    }
  },

  // Create compact info window content
  createInfoWindowContent: function(venueData) {
    return `
      <div style="
        padding: 12px; 
        max-width: 240px; 
        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
        line-height: 1.4;
      ">
        <!-- Header -->
        <div style="text-align: center; margin-bottom: 12px;">
          <h4 style="
            margin: 0 0 6px 0; 
            color: #d63384; 
            font-size: 16px; 
            font-weight: 600;
          ">
            ${venueData.name}
          </h4>
          <div style="
            width: 30px; 
            height: 2px; 
            background: linear-gradient(90deg, #d63384, #fd7e14); 
            margin: 0 auto; 
            border-radius: 1px;
          "></div>
        </div>
        
        <!-- Venue Details -->
        <div style="margin-bottom: 12px;">
          <div style="
            text-align: center;
            margin-bottom: 8px;
            padding: 8px;
            background: #faf4f5;
            border-radius: 6px;
          ">
            <div style="
              color: #495057; 
              font-size: 13px; 
              font-weight: 500;
              display: flex;
              align-items: center;
              justify-content: center;
              gap: 6px;
            ">
              <span style="color: #d63384;">📍</span>
              <span>Wedding Venue</span>
            </div>
          </div>
        </div>
        
        <!-- Get Directions Button -->
        <div style="text-align: center;">
          <a href="${this.getMapLink(venueData.lat, venueData.lng)}" 
             target="_blank"
             style="
               display: inline-block; 
               background: linear-gradient(135deg, #d63384 0%, #fd7e14 100%); 
               color: white; 
               text-decoration: none; 
               padding: 8px 16px; 
               border-radius: 20px; 
               font-size: 12px; 
               font-weight: 600;
               box-shadow: 0 2px 8px rgba(214, 51, 132, 0.3);
               transition: all 0.3s ease;
             "
             onmouseover="this.style.transform='translateY(-1px)'; this.style.boxShadow='0 4px 12px rgba(214, 51, 132, 0.4)';"
             onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 2px 8px rgba(214, 51, 132, 0.3)';"
          >
            <span style="margin-right: 6px;">🧭</span>
            Directions
          </a>
        </div>
      </div>
    `;
  }
};

console.log('✅ Enhanced Wedding Map loaded');