import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class TemplateModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final String thumbnail;
  final Color primaryColor;
  final Map<String, dynamic> defaultSettings;
  final bool isActive;

  const TemplateModel({
    required this.id,
    required this.name,
    required this.description,
    required this.thumbnail,
    required this.primaryColor,
    required this.defaultSettings,
    required this.isActive,
  });

  factory TemplateModel.fromJson(Map<String, dynamic> json) {
    return TemplateModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      thumbnail: json['thumbnail'] as String,
      primaryColor: Color(json['primary_color'] as int),
      defaultSettings: json['default_settings'] as Map<String, dynamic>? ?? {},
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'thumbnail': thumbnail,
      'primary_color': primaryColor.value,
      'default_settings': defaultSettings,
      'is_active': isActive,
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        thumbnail,
        primaryColor,
        defaultSettings,
        isActive,
      ];
}
