// Google Places API를 사용한 실시간 장소 검색 (2024+ New Places API)
window.placesSearchService = {
  autocompleteService: null,
  placesService: null,
  
  // 초기화
  initialize: function() {
    if (typeof google !== 'undefined' && google.maps && google.maps.places) {
      // Use new Places API if available, fallback to old one
      if (google.maps.places.AutocompleteService) {
        this.autocompleteService = new google.maps.places.AutocompleteService();
      }
      // PlacesService는 map이나 div가 필요하므로 나중에 초기화
      return true;
    }
    return false;
  },
  
  // 장소 자동완성 검색
  searchPlaces: function(query, callback) {
    console.log('🔍 searchPlaces called with query:', query);
    
    if (!this.autocompleteService) {
      console.log('🔄 Initializing Google Places service...');
      if (!this.initialize()) {
        console.error('❌ Google Places API not available');
        callback({ error: 'Google Places API not available' });
        return;
      }
      console.log('✅ Google Places service initialized');
    }
    
    if (!query || query.trim().length < 2) {
      console.log('⚠️ Query too short:', query);
      callback({ results: [] });
      return;
    }
    
    // 검색 옵션 설정
    const request = {
      input: query.trim(),
      types: ['establishment', 'geocode'], // 모든 장소와 주소
      fields: ['place_id', 'name', 'formatted_address', 'geometry'],
      language: 'ko', // 한국어 우선
      region: 'kr' // 한국 지역 우선
    };
    
    // 영어 쿼리인 경우 언어 설정 변경
    if (/^[a-zA-Z\s\-.,'"]+$/.test(query)) {
      request.language = 'en';
      request.region = 'us';
    }
    
    console.log('📡 Making Google Places API call with request:', request);
    
    this.autocompleteService.getPlacePredictions(request, (predictions, status) => {
      console.log('📨 API Response - Status:', status, 'Predictions:', predictions);
      
      if (status === google.maps.places.PlacesServiceStatus.OK && predictions) {
        // 결과를 우리 형식으로 변환
        const results = predictions.slice(0, 10).map(prediction => ({
          id: prediction.place_id,
          name: prediction.structured_formatting.main_text || prediction.description,
          address: prediction.description,
          placeId: prediction.place_id,
          types: prediction.types || []
        }));
        
        console.log('✅ Successfully converted results:', results);
        callback({ results: results });
      } else if (status === google.maps.places.PlacesServiceStatus.ZERO_RESULTS) {
        console.log('🔍 No results found');
        callback({ results: [] });
      } else {
        console.error('❌ Places API error:', status);
        callback({ error: `Search failed: ${status}` });
      }
    });
  },
  
  // 장소 자동완성 예측 (place picker용)
  getPlacePredictions: function(input, callback) {
    console.log('🔍 getPlacePredictions called with input:', input);
    
    if (!this.autocompleteService) {
      console.log('🔄 Initializing Google Places service...');
      if (!this.initialize()) {
        console.error('❌ Google Places API not available');
        callback({ error: 'Google Places API not available' });
        return;
      }
    }
    
    if (!input || input.trim().length < 2) {
      console.log('⚠️ Input too short:', input);
      callback({ predictions: [] });
      return;
    }
    
    const request = {
      input: input.trim(),
      types: ['establishment', 'geocode'],
      language: 'ko',
      region: 'kr'
    };
    
    // 영어 입력인 경우 언어 설정 변경
    if (/^[a-zA-Z\s\-.,'"]+$/.test(input)) {
      request.language = 'en';
      request.region = 'us';
    }
    
    console.log('📡 Making getPlacePredictions API call with request:', request);
    
    this.autocompleteService.getPlacePredictions(request, (predictions, status) => {
      console.log('📨 getPlacePredictions Response - Status:', status, 'Predictions:', predictions);
      
      if (status === google.maps.places.PlacesServiceStatus.OK && predictions) {
        // 예측 결과를 그대로 반환 (Google Places API 형식 유지)
        const formattedPredictions = predictions.slice(0, 10).map(prediction => ({
          place_id: prediction.place_id,
          description: prediction.description,
          structured_formatting: {
            main_text: prediction.structured_formatting.main_text,
            secondary_text: prediction.structured_formatting.secondary_text
          },
          types: prediction.types || []
        }));
        
        console.log('✅ Successfully formatted predictions:', formattedPredictions);
        callback({ predictions: formattedPredictions });
      } else if (status === google.maps.places.PlacesServiceStatus.ZERO_RESULTS) {
        console.log('🔍 No predictions found');
        callback({ predictions: [] });
      } else {
        console.error('❌ Places API error:', status);
        callback({ error: `Predictions failed: ${status}` });
      }
    });
  },
  
  // Place ID로 상세 정보 가져오기
  getPlaceDetails: function(placeId, callback) {
    console.log('🔍 getPlaceDetails called with placeId:', placeId);
    
    // PlacesService 초기화 (div 사용)
    if (!this.placesService) {
      const div = document.createElement('div');
      this.placesService = new google.maps.places.PlacesService(div);
    }
    
    const request = {
      placeId: placeId,
      fields: [
        'place_id', 
        'name', 
        'formatted_address', 
        'geometry', 
        'types', 
        'rating', 
        'formatted_phone_number',
        'website',
        'opening_hours'
      ]
    };
    
    console.log('📡 Making getPlaceDetails API call with request:', request);
    
    this.placesService.getDetails(request, (place, status) => {
      console.log('📨 getPlaceDetails Response - Status:', status, 'Place:', place);
      
      if (status === google.maps.places.PlacesServiceStatus.OK && place) {
        const result = {
          place_id: place.place_id,
          name: place.name,
          formatted_address: place.formatted_address,
          geometry: {
            location: {
              lat: place.geometry.location.lat(),
              lng: place.geometry.location.lng()
            }
          },
          types: place.types || [],
          rating: place.rating,
          formatted_phone_number: place.formatted_phone_number,
          website: place.website,
          opening_hours: place.opening_hours ? {
            open_now: place.opening_hours.open_now,
            weekday_text: place.opening_hours.weekday_text
          } : null
        };
        
        console.log('✅ Successfully formatted place details:', result);
        callback({ result: result });
      } else {
        console.error('❌ Place details error:', status);
        callback({ error: `Failed to get place details: ${status}` });
      }
    });
  },
  
  // 텍스트 검색 (더 포괄적인 검색)
  textSearch: function(query, callback) {
    if (!this.placesService) {
      const div = document.createElement('div');
      this.placesService = new google.maps.places.PlacesService(div);
    }
    
    const request = {
      query: query,
      fields: ['place_id', 'name', 'formatted_address', 'geometry', 'types', 'rating'],
      language: /^[a-zA-Z\s\-.,'"]+$/.test(query) ? 'en' : 'ko'
    };
    
    this.placesService.textSearch(request, (results, status) => {
      if (status === google.maps.places.PlacesServiceStatus.OK && results) {
        const formattedResults = results.slice(0, 10).map(place => ({
          id: place.place_id,
          name: place.name,
          address: place.formatted_address,
          latitude: place.geometry.location.lat(),
          longitude: place.geometry.location.lng(),
          types: place.types || [],
          rating: place.rating,
          provider: 'google'
        }));
        
        callback({ results: formattedResults });
      } else if (status === google.maps.places.PlacesServiceStatus.ZERO_RESULTS) {
        callback({ results: [] });
      } else {
        console.error('Text search error:', status);
        callback({ error: `Text search failed: ${status}` });
      }
    });
  },
  
  // 주변 장소 검색
  nearbySearch: function(latitude, longitude, radius, type, callback) {
    if (!this.placesService) {
      const div = document.createElement('div');
      this.placesService = new google.maps.places.PlacesService(div);
    }
    
    const request = {
      location: new google.maps.LatLng(latitude, longitude),
      radius: radius || 1000,
      type: type || 'establishment'
    };
    
    this.placesService.nearbySearch(request, (results, status) => {
      if (status === google.maps.places.PlacesServiceStatus.OK && results) {
        const formattedResults = results.slice(0, 10).map(place => ({
          id: place.place_id,
          name: place.name,
          address: place.vicinity,
          latitude: place.geometry.location.lat(),
          longitude: place.geometry.location.lng(),
          types: place.types || [],
          rating: place.rating,
          provider: 'google'
        }));
        
        callback({ results: formattedResults });
      } else {
        callback({ error: `Nearby search failed: ${status}` });
      }
    });
  }
};

// 페이지 로드 시 초기화
document.addEventListener('DOMContentLoaded', function() {
  console.log('🚀 DOM Content Loaded - Starting Places Service initialization');
  
  // Google Maps API가 로드될 때까지 대기
  function initializePlacesService() {
    console.log('🔄 Attempting to initialize Places Service...');
    
    if (typeof google !== 'undefined') {
      console.log('✅ Google Maps API is loaded');
      console.log('Available google.maps objects:', Object.keys(google.maps || {}));
      
      if (google.maps.places) {
        console.log('✅ Google Places API is available');
        console.log('Available Places objects:', Object.keys(google.maps.places));
      }
    } else {
      console.log('⏳ Google Maps API not yet loaded...');
    }
    
    if (window.placesSearchService.initialize()) {
      console.log('✅ Places Search Service initialized successfully');
      console.log('🔍 You can now search places in real-time!');
      console.log('📝 Try: window.placesSearchService.searchPlaces("강남역", console.log)');
      console.log('📝 Try: window.placesSearchService.searchPlaces("Starbucks Seoul", console.log)');
      
      // Test with a simple search
      console.log('🧪 Running test search...');
      window.placesSearchService.searchPlaces("서울", function(result) {
        console.log('🧪 Test search result:', result);
      });
    } else {
      console.log('⏳ Places Service not ready, retrying in 100ms...');
      // 100ms 후 다시 시도
      setTimeout(initializePlacesService, 100);
    }
  }
  
  initializePlacesService();
});

// 글로벌 헬퍼 함수 - 사용자가 콘솔에서 직접 테스트할 수 있음
window.testPlaceSearch = function(query) {
  console.log(`🔍 Searching for: "${query}"`);
  window.placesSearchService.searchPlaces(query, function(result) {
    if (result.error) {
      console.error('❌ Search failed:', result.error);
    } else {
      console.log(`✅ Found ${result.results.length} results:`);
      result.results.forEach((place, index) => {
        console.log(`${index + 1}. ${place.name} - ${place.address}`);
      });
    }
  });
};

// 빠른 테스트 함수들
window.searchKorean = () => window.testPlaceSearch('강남역');
window.searchEnglish = () => window.testPlaceSearch('Starbucks Seoul');
window.searchWedding = () => window.testPlaceSearch('wedding hall seoul');