import 'package:flutter/material.dart';
import 'package:magic_maps/src/colors.dart';

import 'home/view/view.dart';

class MagicMapsApp extends StatelessWidget {
  const MagicMapsApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hello Map',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: ColorConstants.gulfStream),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}