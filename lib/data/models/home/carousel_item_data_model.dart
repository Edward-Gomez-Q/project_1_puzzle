import 'package:flutter/material.dart';

class CarouselItemData {
  final String title;
  final IconData icon;
  final String description;
  final String code;
  final String? route;

  CarouselItemData(
    this.title,
    this.icon,
    this.description,
    this.code, {
    this.route,
  });
}
