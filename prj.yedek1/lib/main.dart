import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  runApp(MyApp(cameras: cameras));
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;
  const MyApp({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Renk Tespiti',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CameraScreen(cameras: cameras),
    );
  }
}

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const CameraScreen({super.key, required this.cameras});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  String detectedColorName = "Renk Bekleniyor...";
  bool isDetecting = false;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.cameras[0],
      ResolutionPreset.medium,
      enableAudio: false,
    );
    _initializeControllerFuture = _controller.initialize().then((_) {
      _startColorDetection();
    });
  }

  void _startColorDetection() {
    _controller.startImageStream((CameraImage image) {
      if (!isDetecting) {
        isDetecting = true;
        _detectColor(image);
      }
    });
  }

  void _detectColor(CameraImage image) async {
    try {
      final img.Image convertedImage = _convertYUV420ToImageColor(image);
      final List<int> color =
          _detectMostFrequentColorInCenterSquare(convertedImage);

      final String colorName =
          _getColorNameFromHSV(color[0], color[1], color[2]);

      setState(() {
        detectedColorName = colorName;
      });

      isDetecting = false;
    } catch (e) {
      setState(() {
        detectedColorName = "Renk tespiti hatası";
      });
      isDetecting = false;
    }
  }

  img.Image _convertYUV420ToImageColor(CameraImage image) {
    final int width = image.width;
    final int height = image.height;
    final img.Image rgbImage = img.Image(width, height);

    final int uvRowStride = image.planes[1].bytesPerRow;
    final int uvPixelStride = image.planes[1].bytesPerPixel!;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int uvIndex = (y ~/ 2) * uvRowStride + (x ~/ 2) * uvPixelStride;

        final int yValue = image.planes[0].bytes[y * width + x];
        final int uValue = image.planes[1].bytes[uvIndex] - 128;
        final int vValue = image.planes[2].bytes[uvIndex] - 128;

        final int r = (yValue + 1.370705 * vValue).clamp(0, 255).toInt();
        final int g = (yValue - 0.337633 * uValue - 0.698001 * vValue)
            .clamp(0, 255)
            .toInt();
        final int b = (yValue + 1.732446 * uValue).clamp(0, 255).toInt();

        rgbImage.setPixel(x, y, img.getColor(r, g, b));
      }
    }
    return rgbImage;
  }

  List<int> _detectMostFrequentColorInCenterSquare(img.Image image) {
    final int centerX = image.width ~/ 2;
    final int centerY = image.height ~/ 2;
    const int squareSize = 100;
    Map<int, int> colorCount = {};

    for (int y = centerY - squareSize ~/ 2;
        y < centerY + squareSize ~/ 2;
        y++) {
      for (int x = centerX - squareSize ~/ 2;
          x < centerX + squareSize ~/ 2;
          x++) {
        final int pixel = image.getPixel(x, y);
        if (colorCount.containsKey(pixel)) {
          colorCount[pixel] = colorCount[pixel]! + 1;
        } else {
          colorCount[pixel] = 1;
        }
      }
    }

    int mostFrequentColor = colorCount.keys.first;
    int maxCount = colorCount[mostFrequentColor]!;
    colorCount.forEach((color, count) {
      if (count > maxCount) {
        mostFrequentColor = color;
        maxCount = count;
      }
    });

    return [
      img.getRed(mostFrequentColor),
      img.getGreen(mostFrequentColor),
      img.getBlue(mostFrequentColor)
    ];
  }

  List<double> _rgbToHsv(int r, int g, int b) {
    double red = r / 255.0;
    double green = g / 255.0;
    double blue = b / 255.0;

    double max = [red, green, blue].reduce((a, b) => a > b ? a : b);
    double min = [red, green, blue].reduce((a, b) => a < b ? a : b);
    double delta = max - min;

    double hue = 0.0;
    if (delta != 0.0) {
      if (max == red) {
        hue = (green - blue) / delta;
      } else if (max == green) {
        hue = 2.0 + (blue - red) / delta;
      } else {
        hue = 4.0 + (red - green) / delta;
      }
      hue *= 60.0;
      if (hue < 0.0) hue += 360.0;
    }

    double saturation = (max == 0.0) ? 0.0 : (delta / max);
    double value = max;

    return [hue, saturation, value];
  }

  String _getColorNameFromHSV(int r, int g, int b) {
    final hsv = _rgbToHsv(r, g, b);
    double hue = hsv[0];
    double saturation = hsv[1];
    double value = hsv[2];

    String hueFormatted = hue.toStringAsFixed(3);

    if (saturation < 0.2 && value > 0.8) return "Beyaz";
    if (saturation < 0.2 && value < 0.2) return "Siyah";

    if (hue >= 0 && hue <= 20) return "Kırmızı $hueFormatted";
    if (hue > 20 && hue <= 40)
      return "Sarı $hueFormatted"; // Sarı (eski Turuncu)
    if (hue > 40 && hue <= 65) return "Sarı $hueFormatted";
    if (hue > 65 && hue <= 170) return "Yeşil $hueFormatted";
    if (hue > 170 && hue <= 260) return "Mavi $hueFormatted";
    if (hue > 260 && hue <= 290) return "Mavi $hueFormatted";
    if (hue > 290 && hue <= 360) return "Kırmızı $hueFormatted";

    return "Bilinmeyen Renk";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Canlı Renk Tespiti'),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                CameraPreview(_controller),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.3,
                  left: MediaQuery.of(context).size.width * 0.3,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    color: Colors.white.withOpacity(0.8),
                    child: Text(
                      detectedColorName,
                      style: const TextStyle(fontSize: 20, color: Colors.black),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
