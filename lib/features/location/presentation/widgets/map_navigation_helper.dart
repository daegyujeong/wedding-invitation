import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

class MapNavigationHelper {
  // Kakao Map Navigation
  static Future<void> openKakaoMap({
    required double latitude,
    required double longitude,
    required String venue,
  }) async {
    // Kakao Map URL scheme
    final kakaoMapUrl = 'kakaomap://look?p=$latitude,$longitude';
    final webUrl = 'https://map.kakao.com/link/map/$venue,$latitude,$longitude';
    
    try {
      if (await canLaunchUrl(Uri.parse(kakaoMapUrl))) {
        await launchUrl(Uri.parse(kakaoMapUrl));
      } else {
        // Fallback to web version
        await launchUrl(
          Uri.parse(webUrl),
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      debugPrint('Could not launch Kakao Map: $e');
    }
  }

  // Naver Map Navigation
  static Future<void> openNaverMap({
    required double latitude,
    required double longitude,
    required String venue,
  }) async {
    // Naver Map URL scheme
    final naverMapUrl = 'nmap://place?lat=$latitude&lng=$longitude&name=$venue&appname=com.example.wedding_invitation';
    final webUrl = 'https://map.naver.com/v5/search/$venue/place?c=$longitude,$latitude,15,0,0,0,dh';
    
    try {
      if (await canLaunchUrl(Uri.parse(naverMapUrl))) {
        await launchUrl(Uri.parse(naverMapUrl));
      } else {
        // Fallback to web version
        await launchUrl(
          Uri.parse(webUrl),
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      debugPrint('Could not launch Naver Map: $e');
    }
  }

  // Google Maps Navigation
  static Future<void> openGoogleMaps({
    required double latitude,
    required double longitude,
    required String venue,
  }) async {
    // Google Maps URL scheme
    final googleMapsUrl = 'google.navigation:q=$latitude,$longitude';
    final webUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    
    try {
      if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
        await launchUrl(Uri.parse(googleMapsUrl));
      } else {
        // Fallback to web version
        await launchUrl(
          Uri.parse(webUrl),
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      debugPrint('Could not launch Google Maps: $e');
    }
  }

  // Open map based on provider
  static Future<void> openMap({
    required String provider,
    required double latitude,
    required double longitude,
    required String venue,
  }) async {
    switch (provider.toLowerCase()) {
      case 'kakao':
        await openKakaoMap(
          latitude: latitude,
          longitude: longitude,
          venue: venue,
        );
        break;
      case 'naver':
        await openNaverMap(
          latitude: latitude,
          longitude: longitude,
          venue: venue,
        );
        break;
      case 'google':
      default:
        await openGoogleMaps(
          latitude: latitude,
          longitude: longitude,
          venue: venue,
        );
        break;
    }
  }
}
