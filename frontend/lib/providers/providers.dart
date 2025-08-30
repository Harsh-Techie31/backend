// This file exports all providers for easy access
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'auth_provider.dart';
export 'storage_provider.dart';
export 'api_provider.dart'; 

// This provider will hold the current theme state (light, dark, or system)
final themeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);
//TODO : add this on UI aswell