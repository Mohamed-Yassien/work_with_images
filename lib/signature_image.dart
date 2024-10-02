import 'package:flutter/material.dart';
import 'package:work_with_images/add_signature_to_image.dart';

class SignatureOnImage extends StatefulWidget {
  const SignatureOnImage({super.key});

  @override
  SignatureOnImageState createState() => SignatureOnImageState();
}

class SignatureOnImageState extends State<SignatureOnImage> {
  GlobalKey imageKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Signature on Image'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddSignatureToImage(
                    imageUrl:
                        "https://i.pinimg.com/originals/d0/12/35/d01235030b7080ff149f62fe349398a7.jpg",
                  ),
                ),
              );
            },
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
          ],
        ),
      ),
    );
  }
}
