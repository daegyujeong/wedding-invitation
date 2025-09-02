import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A widget that renders emojis properly across all platforms, especially Flutter Web
class EmojiWidget extends StatelessWidget {
  final String emoji;
  final double fontSize;
  final Color? textColor;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final EdgeInsets? padding;

  const EmojiWidget({
    super.key,
    required this.emoji,
    this.fontSize = 24,
    this.textColor,
    this.fontWeight,
    this.textAlign,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      // For web, use multiple fallback approaches
      return Container(
        padding: padding,
        child: _buildWebEmoji(),
      );
    } else {
      // For mobile platforms, standard Text widget works fine
      return Container(
        padding: padding,
        child: Text(
          emoji,
          style: TextStyle(
            fontSize: fontSize,
            color: textColor ?? Colors.black,
            fontWeight: fontWeight,
          ),
          textAlign: textAlign,
        ),
      );
    }
  }

  /// Builds emoji widget specifically for web with better font loading
  Widget _buildWebEmoji() {
    return Text(
      emoji,
      style: TextStyle(
        fontSize: fontSize,
        color: textColor ?? Colors.black,
        fontWeight: fontWeight,
        // Use null to let the browser handle emoji fonts naturally
        fontFamily: null,
        // Add special emoji rendering properties
        inherit: true,
      ),
      textAlign: textAlign,
    );
  }

}

/// Extension to provide easy emoji rendering for common emojis used in the app
extension EmojiExtensions on String {
  Widget toEmojiWidget({
    double fontSize = 24,
    Color? textColor,
    FontWeight? fontWeight,
    TextAlign? textAlign,
    EdgeInsets? padding,
  }) {
    return EmojiWidget(
      emoji: this,
      fontSize: fontSize,
      textColor: textColor,
      fontWeight: fontWeight,
      textAlign: textAlign,
      padding: padding,
    );
  }
}

/// Common emojis used in the wedding app as constants
class WeddingEmojis {
  // Using Unicode escape sequences for better cross-platform support
  static const String celebration = '\u{1F389}'; // 🎉
  static const String heart = '\u{1F495}'; // 💕
  static const String sparkles = '\u{2728}'; // ✨
  static const String flower = '\u{1F490}'; // 💐
  static const String yellowHeart = '\u{1F49B}'; // 💛
  static const String cherryBlossom = '\u{1F338}'; // 🌸
  static const String heartWithArrow = '\u{1F496}'; // 💖
  
  // Private constructor to prevent instantiation
  WeddingEmojis._();
}