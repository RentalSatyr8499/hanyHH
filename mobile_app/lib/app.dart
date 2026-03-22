import 'package:flutter/material.dart';
import 'presentation/screens/home_screen.dart';
import 'data/repositories/route_repository.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final routeRepository = RouteRepository(
      baseUrl: "http://127.0.0.1:5001/hany-hh/us-central1/route",
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Accessibilly compass',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: HomeScreen(routeRepository: routeRepository),
    );
  }
}
