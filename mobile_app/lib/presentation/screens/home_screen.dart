import 'package:flutter/material.dart';
import '../widgets/map/map_view.dart';
import '../widgets/navigation/navigation_panel.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: const [
          Expanded(
            flex: 6, // 60%
            child: MapView(),
          ),
          Expanded(
            flex: 4, // 40%
            child: NavigationPanel(),
          ),
        ],
      ),
    );
  }
}
