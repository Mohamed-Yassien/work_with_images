import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

class SignatureOnImage extends StatefulWidget {
  const SignatureOnImage({super.key});

  @override
  _SignatureOnImageState createState() => _SignatureOnImageState();
}

class _SignatureOnImageState extends State<SignatureOnImage> {
  late SignatureController _controller;
  bool _isDrawing = false;
  Uint8List? _signature;
  Offset _signaturePosition = const Offset(0, 0);
  GlobalKey imageKey = GlobalKey();
  final GlobalKey signatureKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _controller = SignatureController(
      penStrokeWidth: 5,
      penColor: Colors.black,
      exportBackgroundColor: Colors.transparent,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _toggleDrawing() async {
    if (_isDrawing) {
      final signature = await _controller.toPngBytes();
      setState(() {
        _signature = signature;
      });
    }
    setState(() {
      _isDrawing = !_isDrawing;
    });
  }

  void _handlePanUpdate(DragUpdateDetails details, BuildContext context) {
    RenderBox box = imageKey.currentContext!.findRenderObject() as RenderBox;
    final imageSize = box.size;
    RenderBox box2 =
        signatureKey.currentContext!.findRenderObject() as RenderBox;
    final signatureSize = box2.size;
    final signatureWidth = _signature != null ? signatureSize.width : 0.0;
    final signatureHeight = _signature != null ? signatureSize.height : 0.0;

    Offset newPosition = _signaturePosition + details.delta;

    // Constrain the signature to stay within the image bounds
    double newX = newPosition.dx.clamp(0.0, imageSize.width - signatureWidth);
    double newY = newPosition.dy.clamp(0.0, imageSize.height - signatureHeight);
    setState(() {
      _signaturePosition = Offset(newX, newY);
    });
    debugPrint("yassien 7 $_signaturePosition");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Signature on Image'),
        actions: [
          IconButton(
            icon: Icon(_isDrawing ? Icons.check : Icons.edit),
            onPressed: _toggleDrawing,
          ),
        ],
      ),
      body: SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: Stack(
          children: [
            // Network image
            Image.network(
              'https://i.pinimg.com/originals/d0/12/35/d01235030b7080ff149f62fe349398a7.jpg',
              fit: BoxFit.cover,
              height: double.infinity,
              width: double.infinity,
              key: imageKey,
            ),
            // Signature drawing overlay on the image
            if (_isDrawing)
              Signature(
                controller: _controller,
                width: double.infinity,
                height: double.infinity,
                backgroundColor: Colors.transparent,
              ),
            // Draggable signature after drawing is finished
            if (_signature != null && !_isDrawing)
              Positioned(
                left: _signaturePosition.dx,
                top: _signaturePosition.dy,
                child: GestureDetector(
                  onPanUpdate: (details) => _handlePanUpdate(details, context),
                  // onPanUpdate: (details) {
                  //   setState(() {
                  //     _signaturePosition += details.delta;
                  //   });
                  // },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red),
                    ),
                    child: Image.memory(
                      _signature!,
                      key: signatureKey,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
