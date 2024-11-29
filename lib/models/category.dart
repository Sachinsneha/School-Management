import 'package:flutter/material.dart';

enum Categories {
  Computerprogramming,
  Bussiness,
  Projectmanagement,
}

class Category {
  const Category(this.title, this.color);
  final String title;
  final Color color;
}
