import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

import 'package:ke_qr/ke_qr.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

class GenerateQR extends StatefulWidget {
  const GenerateQR({super.key});

  @override
  State<GenerateQR> createState() => _GenerateQRState();
}

class _GenerateQRState extends State<GenerateQR> {
  TextEditingController amountController = TextEditingController();
    final GlobalKey globalKey = GlobalKey();
  bool ammounMode =false;
    Future<Uint8List> captureWidget() async {
    try {
      final RenderObject? boundary =
          globalKey.currentContext?.findRenderObject();
      if (boundary != null && boundary is RenderRepaintBoundary) {
        final double devicePixelRatio = ui.window.devicePixelRatio;
        final ui.Size logicalSize = ui.Size(
            boundary.paintBounds.size.width * devicePixelRatio,
            boundary.paintBounds.size.height * devicePixelRatio);
        final ui.Image image =
            await boundary.toImage(pixelRatio: devicePixelRatio);
        final ByteData? byteData =
            await image.toByteData(format: ui.ImageByteFormat.png);
        final Uint8List? pngBytes = byteData?.buffer.asUint8List();

        return pngBytes ?? Uint8List(0);
      } else {
        print('Boundary not found or is not a RenderRepaintBoundary');
        return Uint8List(0);
      }
    } catch (e) {
      print('Error capturing widget: $e');
      return Uint8List(0);
    }
  }
  @override
  Widget build(BuildContext context) {
    QrBuild qrBuild =QrBuild();

     Map<String, String> buildingData = {
    "00": "01", // Don't change this
    "01": "11", // switch beween static and dynamic 11/12
    // "02": "12345678", // global PSPs visa mastercard etc 
    "28": "0798391330",//paymentAddress
    // "52": "4900",
    "53": "404", 
    "54": "${amountController.text}.00",
    // "55": "",
    // "56": "",
    // "57": "",
    "58": "KE",
    "59": "JAPHETH KASINYA",
    "60": "NAIROBI",

    "82": DateTime.now().toString(),
  };
  

  RxBool isQRCodeReady = RxBool(true);

    qrBuild.generateQr(buildingData, "46");
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text("Scan qr code"),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(duration: const Duration(
              microseconds: 500,
            ),
            child: ammounMode==false?SizedBox(
              width: 320,
              child: RepaintBoundary(
                key: globalKey,
                child: Container(
                  color:  Colors.white,
                  child: QrImageView(
                    data: qrBuild.generateQr(buildingData, "46"),
                    version: QrVersions.auto,
                    gapless: true,
                    embeddedImage: const AssetImage('./assets/images/qr_logo.png'),
                    embeddedImageStyle: const QrEmbeddedImageStyle(
                      size: Size(40, 40)
                    ),
                    ),
                    
                ),
              ),
            ):
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                FilteringTextInputFormatter.allow(RegExp(r'^\d+')),
              ],
              decoration: const InputDecoration(
                labelText: "Enter Amount",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),

                )
              ),
            )
            
            )
          ],
        ),
      ),
      actions: [
        (amountController.text.isNotEmpty&& ammounMode == false)? Text(
          "Ksh ${NumberFormat("#,##0.00").
          format(int.parse(amountController.text))}"
          ):
          TextButton(onPressed: ((){
            setState(() {
              ammounMode =!ammounMode;
            });
            print(buildingData);
            
          }), 
          
          child: Text(ammounMode? "Generate QR Code" : "Specify ammount"),),
          Obx((){
            return ammounMode == false?TextButton(
              onPressed: isQRCodeReady.isTrue?(){
                shareQrCode("buildingData");
              }:null, child: Text("Share QR")):const SizedBox();
          })
          
      ],
    );
  }

 Future<void> shareQrCode(String data) async {
    var image = await captureWidget();
    final dir = await getExternalStorageDirectory();
    // final imgFile = await File('${dir!.path}/qr.png').create(recursive: true);
    final imgFile =  XFile('${dir!.path}/qr.png');

    

    // Logger.log('QR Code Image Path: ${imgFile.path}');

    Share.shareXFiles([imgFile]);
  }
  
}