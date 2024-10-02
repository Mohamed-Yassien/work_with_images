import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:work_with_images/my_own_signature.dart';
import 'package:work_with_images/signature_cubit/signature_states.dart';

import 'signature_cubit/signature_cubit.dart';

class AddSignatureToImage extends StatefulWidget {
  const AddSignatureToImage({super.key, required this.imageUrl});

  final String imageUrl;

  @override
  AddSignatureToImageState createState() => AddSignatureToImageState();
}

class AddSignatureToImageState extends State<AddSignatureToImage> {
  @override
  void initState() {
    var cubit = SignatureCubit.get(context);
    cubit.controller = SignatureController(
      penStrokeWidth: cubit.sliderValue,
      penColor: cubit.colorsList[cubit.selectedColor],
      exportBackgroundColor: Colors.transparent,
      strokeJoin: StrokeJoin.round,
      strokeCap: StrokeCap.round,
    );
    cubit.resetDrawing();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignatureCubit, SignatureStates>(
      builder: (context, state) {
        var cubit = SignatureCubit.get(context);
        return Scaffold(
          appBar: AppBar(
            title: const Text('Annotation'),
            actions: [
              IconButton(
                icon: Icon(cubit.isDrawing ? Icons.check : Icons.save),
                onPressed: () {
                  cubit.toggleDrawing(
                    penC: cubit.colorsList[cubit.selectedColor],
                    penW: cubit.sliderValue,
                  );
                  // cubit.isDrawing ? null : cubit.updateSignatureData();
                },
              ),
            ],
          ),
          body: SizedBox(
            height: MediaQuery.sizeOf(context).height,
            width: MediaQuery.sizeOf(context).width,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Row(
                        children: List.generate(
                          cubit.colorsList.length,
                          (index) {
                            bool isSelected = index == cubit.selectedColor;

                            return GestureDetector(
                              onTap: () {
                                cubit.changeSelectedColor(index);
                                cubit.controller = SignatureController(
                                  penStrokeWidth:
                                      cubit.controller.penStrokeWidth,
                                  penColor: cubit.colorsList[index],
                                  exportBackgroundColor: Colors.transparent,
                                  strokeJoin: StrokeJoin.round,
                                  strokeCap: StrokeCap.round,
                                  points: cubit.controller.points,
                                );
                                // setState(() {});

                                // cubit.updateSignatureData();
                              },
                              child: Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 1.5),
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: cubit.colorsList[index],
                                  border: isSelected
                                      ? Border.all(color: Colors.amber)
                                      : null,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Expanded(
                        child: Slider(
                          value: cubit.sliderValue,
                          max: cubit.maxSliderVlaue,
                          min: 1.0,
                          onChanged: (value) {
                            cubit.changeSliderValue(value);
                            cubit.controller = SignatureController(
                              penStrokeWidth: value,
                              penColor: cubit.colorsList[cubit.selectedColor],
                              exportBackgroundColor: Colors.transparent,
                              strokeJoin: StrokeJoin.round,
                              strokeCap: StrokeCap.round,
                              points: cubit.controller.points,
                            );
                            // setState(() {});
                            // cubit.updateSignatureData();
                          },
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Image.network(
                            'https://i.pinimg.com/originals/d0/12/35/d01235030b7080ff149f62fe349398a7.jpg',
                            fit: BoxFit.cover,
                            height: double.infinity,
                            width: double.infinity,
                            key: cubit.imageKey,
                          ),
                          if (cubit.isDrawing)
                            MyNewSignature(
                              controller: cubit.controller,
                              width: constraints.maxWidth,
                              height: constraints.maxHeight,
                              backgroundColor: Colors.transparent,
                              penW: cubit.sliderValue,
                              penC: cubit.colorsList[cubit.selectedColor],
                              // penW: cubit.sliderValue,
                              // penC: cubit.colorsList[cubit.selectedColor],
                            ),
                          if (cubit.signature != null && !cubit.isDrawing)
                            Positioned(
                              left: cubit.signaturePosition.dx,
                              top: cubit.signaturePosition.dy,
                              child: GestureDetector(
                                onPanUpdate: (details) =>
                                    cubit.handlePanUpdate(details, context),
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.red),
                                  ),
                                  child: Image.memory(
                                    cubit.signature!,
                                    key: cubit.signatureKey,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
