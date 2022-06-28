import 'package:flutter/material.dart';
import 'package:tinycinema/config.dart';

var page = PageController();

final pageViewChildren = menu.map((item) => item['widget'] as Widget).toList();
