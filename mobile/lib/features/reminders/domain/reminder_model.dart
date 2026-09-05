// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class ReminderModel {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final String type; // 'medicine', 'water', 'walk', 'cognitive', 'custom'
  final String? category;
  final String priority; // 'high', 'normal', 'low'
  final String time; // '08:30 AM'
  final String? assetUrl;
  final String status; // 'pending', 'done', 'missed'
  final String? completedAt;
  final String createdAt;
  final String updatedAt;
  final String hlcTimestamp;
  final bool isDeleted;
  final String syncStatus;

  const ReminderModel({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.type,
    this.category,
    this.priority = 'normal',
    required this.time,
    this.assetUrl,
    this.status = 'pending',
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.hlcTimestamp,
    this.isDeleted = false,
    this.syncStatus = 'pending',
  });

  IconData get icon {
    switch (type.toLowerCase()) {
      case 'medication': return Icons.medication_outlined;
      case 'doctor appointment': return Icons.medical_services_outlined;
      case 'meal': return Icons.restaurant_outlined;
      case 'water': return Icons.water_drop_outlined;
      case 'exercise/walk': return Icons.directions_walk_rounded;
      case 'cognitive activity': return Icons.psychology_outlined;
      case 'sleep': return Icons.bedtime_outlined;
      case 'custom': return Icons.push_pin_outlined;
      default: return Icons.alarm_outlined;
    }
  }

  Color get accentColor {
    switch (type.toLowerCase()) {
      case 'medication': return AppColors.warmTerracotta;
      case 'doctor appointment': return Colors.redAccent;
      case 'meal': return Colors.orange;
      case 'water': return AppColors.mutedTeal;
      case 'exercise/walk': return AppColors.deepSageGreen;
      case 'cognitive activity': return const Color(0xFFE9C46A);
      case 'sleep': return Colors.indigo;
      case 'custom': return Colors.grey;
      default: return AppColors.gentleAmber;
    }
  }

  ReminderModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? type,
    String? category,
    String? priority,
    String? time,
    String? assetUrl,
    String? status,
    String? completedAt,
    String? createdAt,
    String? updatedAt,
    String? hlcTimestamp,
    bool? isDeleted,
    String? syncStatus,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      time: time ?? this.time,
      assetUrl: assetUrl ?? this.assetUrl,
      status: status ?? this.status,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      hlcTimestamp: hlcTimestamp ?? this.hlcTimestamp,
      isDeleted: isDeleted ?? this.isDeleted,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'type': type,
      'category': category,
      'priority': priority,
      'time': time,
      'asset_url': assetUrl,
      'status': status,
      'completed_at': completedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'hlc_timestamp': hlcTimestamp,
      'is_deleted': isDeleted ? 1 : 0,
      'sync_status': syncStatus,
    };
  }

  factory ReminderModel.fromMap(Map<String, dynamic> map) {
    return ReminderModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      type: map['type'] as String,
      category: map['category'] as String?,
      priority: map['priority'] as String? ?? 'normal',
      time: map['time'] as String,
      assetUrl: map['asset_url'] as String?,
      status: map['status'] as String? ?? 'pending',
      completedAt: map['completed_at'] as String?,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
      hlcTimestamp: map['hlc_timestamp'] as String? ?? '',
      isDeleted: (map['is_deleted'] as int? ?? 0) == 1,
      syncStatus: map['sync_status'] as String? ?? 'pending',
    );
  }
}
