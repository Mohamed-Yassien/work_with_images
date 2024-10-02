import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hand_signature/signature.dart';
import 'package:work_with_images/signature_cubit/signature_states.dart';
import 'dart:ui' as ui;

import '../my_own_signature.dart';

class SignatureCubit extends Cubit<SignatureStates> {
  SignatureCubit() : super(SignatureInitial());

  static SignatureCubit get(context) => BlocProvider.of(context);

  late SignatureController controller;
  bool isDrawing = true;
  Uint8List? signature;
  Offset signaturePosition = const Offset(0, 0);
  GlobalKey imageKey = GlobalKey();
  final GlobalKey signatureKey = GlobalKey();
  late HandSignatureControl handSignatureControl;
  int selectedColor = 0;
  List<Color> colorsList = [
    Colors.black,
    Colors.red,
    Colors.amber,
    Colors.blue,
    Colors.deepOrange,
  ];

  double sliderValue = 3;
  double maxSliderVlaue = 12;

  changeSliderValue(double value) {
    sliderValue = value;
    _updateSignatureColorAndStroke();
    emit(ChangeSliderValueState());
  }

  changeSelectedColor(int index) {
    selectedColor = index;
    _updateSignatureColorAndStroke();

    emit(ChangeSelectedColorState());
  }

  resetDrawing() {
    isDrawing = true;
    emit(ResetDrawingState());
  }

  Future<void> toggleDrawing({
    required Color penC,
    required double penW,
  }) async {
    if (isDrawing) {
      // final kSignature = await controller.toPngBytes(color: penC);
      final kSignature = await controller.toPngBytes();
      signature = kSignature;
      emit(EnableDrawAnnotationState());
    } else {
      emit(SuccessDrawTabState());
    }
    isDrawing = !isDrawing;
    emit(EnableDrawAnnotationState());
  }

  void handlePanUpdate(DragUpdateDetails details, BuildContext context) {
    RenderBox box = imageKey.currentContext!.findRenderObject() as RenderBox;
    final imageSize = box.size;
    RenderBox box2 =
        signatureKey.currentContext!.findRenderObject() as RenderBox;
    final signatureSize = box2.size;
    final signatureWidth = signature != null ? signatureSize.width : 0.0;
    final signatureHeight = signature != null ? signatureSize.height : 0.0;
    Offset newPosition = signaturePosition + details.delta;
    double newX = newPosition.dx.clamp(0.0, imageSize.width - signatureWidth);
    double newY = newPosition.dy.clamp(0.0, imageSize.height - signatureHeight);
    signaturePosition = Offset(newX, newY);
    emit(MoveSignatureAnnotationState());
  }

  // Capture signature as Uint8List and load it as ui.Image
  // Capture signature as Uint8List and load it as ui.Image
  Future<ui.Image?> _captureSignature() async {
    final Uint8List? signatureBytes = await controller.toPngBytes();
    if (signatureBytes == null) return null;

    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(signatureBytes, (ui.Image img) {
      completer.complete(img);
    });
    emit(ChangeSliderValueState());
    return completer.future;
  }

  // Apply color and stroke width changes to the signature image
  Future<Uint8List?> _applyColorAndStrokeToSignature(
      ui.Image image, Color color, double strokeWidth) async {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);

    // Set the paint object to use the new color and stroke width
    final Paint paint = Paint()
      ..colorFilter = ui.ColorFilter.mode(color, BlendMode.srcIn) // Apply color
      ..strokeWidth = strokeWidth // Change stroke width
      ..style = PaintingStyle.stroke;

    // Draw the original image with the color filter and stroke width
    canvas.drawImage(image, Offset.zero, paint);
    final ui.Picture picture = recorder.endRecording();
    final ui.Image coloredImage =
        await picture.toImage(image.width, image.height);

    // Convert the ui.Image back to Uint8List
    final ByteData? byteData =
        await coloredImage.toByteData(format: ui.ImageByteFormat.png);
    emit(ChangeSliderValueState());
    return byteData?.buffer.asUint8List();
  }

  // This method captures the signature and applies color and stroke width changes
  Future<void> _updateSignatureColorAndStroke() async {
    final ui.Image? signatureImage = await _captureSignature();
    if (signatureImage != null) {
      final Uint8List? updatedImage = await _applyColorAndStrokeToSignature(
        signatureImage,
        colorsList[selectedColor],
        sliderValue,
      );

      signature = updatedImage;
    }
    emit(ChangeSliderValueState());
  }
}
