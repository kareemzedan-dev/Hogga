import 'package:flutter/material.dart';
import 'package:hogga/core/utils/app_strings.dart';

class ServiceCategory {
  final String id;
  final String title;
  final List<ServiceItem> services;

  const ServiceCategory({
    required this.id,
    required this.title,
    required this.services,
  });
}

class ServiceItem {
  final String id;
  final String title;
  final String description;
  final IconData icon;

  const ServiceItem({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
  });
}

class SpecializationItem {
  final String id;
  final String title;
  final String description;

  const SpecializationItem({
    required this.id,
    required this.title,
    required this.description,
  });
}
