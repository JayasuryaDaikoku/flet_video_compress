import 'package:flet/flet.dart';
import 'package:flutter/material.dart';
import 'package:light_compressor/light_compressor.dart';
import 'dart:convert';

class FletVideoCompressorControl extends StatefulWidget {
  final Control? parent;
  final Control control;
  final FletControlBackend backend;

  const FletVideoCompressorControl({
    super.key,
    required this.parent,
    required this.control,
    required this.backend,
  });

  @override
  State<FletVideoCompressorControl> createState() =>
      _FletVideoCompressorControlState();
}

class _FletVideoCompressorControlState
    extends State<FletVideoCompressorControl> {
  final LightCompressor _lightCompressor = LightCompressor();

  @override
  void initState() {
    super.initState();
    _subscribeMethods();
    // Automatically start compression when widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _compress();
    });
  }

  void _subscribeMethods() {
    // Subscribe to methods from Python backend
    widget.backend.subscribeMethods(widget.control.id, _handleMethods);
  }

  Future<String?> _handleMethods(String methodName, Map<String, String> args) async {
    debugPrint('Method called: $methodName with arguments: $args');

    switch (methodName) {
      case 'compress_video':
        await _compress();
        return 'ok';
      default:
        debugPrint('Unrecognized method: $methodName');
        return null;
    }
  }

  Future<void> _compress() async {
    try {
      final sourcePath = widget.control.attrString("sourcePath", "")!;
      if (sourcePath.isEmpty) {
        throw Exception("Source path is empty");
      }
      final Result response = await _lightCompressor.compressVideo(
        path: sourcePath,
        videoQuality: VideoQuality.low,
        isMinBitrateCheckEnabled: false,
        video: Video(videoName: "compressed_video"),
        android: AndroidConfig(isSharedStorage: true, saveAt: SaveAt.Movies),
        ios: IOSConfig(saveInGallery: false),
      );

      String? outputPath;
      if (response is OnSuccess) {
        outputPath = response.destinationPath; // Get the output path
      }

      // Trigger Python callback "onCompressed" with result
      widget.backend.triggerControlEvent(
        widget.control.id,
        "onCompressed",
        json.encode({
          "success": response is OnSuccess,
          "outputPath": outputPath,
          "error": response is OnSuccess ? null : "Compression failed",
        }),
      );
    } catch (e) {
      // Trigger Python callback with error
      widget.backend.triggerControlEvent(
        widget.control.id,
        "onCompressed",
        json.encode({
          "success": false,
          "outputPath": null,
          "error": e.toString(),
        }),
      );
    }
  }

  @override
  void dispose() {
    widget.backend.unsubscribeMethods(widget.control.id);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Return an empty container since no UI elements are needed
    return Container();
  }
}