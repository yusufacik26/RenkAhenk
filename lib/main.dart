import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: HomeScreen(), // İlk açılan ekran
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ana Ekran'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Butona basıldığında 1. ekran açılacak
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FirstScreen()),
                );
              },
              child: const Text('1. Ekrana Git'),
            ),
            const SizedBox(height: 20), // Butonlar arasında boşluk
            ElevatedButton(
              onPressed: () {
                // Butona basıldığında 2. ekran açılacak
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SecondScreen()),
                );
              },
              child: const Text('2. Ekrana Git'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Butona basıldığında 3. ekran açılacak
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ThirdScreen()),
                );
              },
              child: const Text('3. Ekrana Git'),
            ),
          ],
        ),
      ),
    );
  }
}

// 1. Ekran (FirstScreen)
class FirstScreen extends StatelessWidget {
  const FirstScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('1. Ekran'),
      ),
      body: Center(
        child: const Text('Bu 1. Ekran'),
      ),
    );
  }
}

// 2. Ekran (SecondScreen)
class SecondScreen extends StatelessWidget {
  const SecondScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('2. Ekran'),
      ),
      body: Center(
        child: const Text('Bu 2. Ekran'),
      ),
    );
  }
}

// 3. Ekran (ThirdScreen)
class ThirdScreen extends StatelessWidget {
  const ThirdScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('3. Ekran'),
      ),
      body: Center(
        child: const Text('Bu 3. Ekran'),
      ),
    );
  }
}
