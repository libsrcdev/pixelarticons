import 'package:flutter/material.dart';

void main() {
  runApp(const HomePage());
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  static const _kAndroidColor = Color(0xFF3ADD85);
  static const _kBackgroundColor = Color(0xFF000000);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: _kBackgroundColor,
            body: Center(
              child: Transform.scale(
                scale: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Pixel.android, color: _kAndroidColor),
                    Icon(Pixel.article, color: _kAndroidColor),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
