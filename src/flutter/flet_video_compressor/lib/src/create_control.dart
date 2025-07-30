import 'package:flet/flet.dart';
import 'package:flutter/material.dart';
import 'flet_video_compressor.dart';

CreateControlFactory createControl = (CreateControlArgs args) {
  switch (args.control.type) {
    case "flet_video_compressor":
      return FletVideoCompressorControl(
        parent: args.parent,
        control: args.control,
        backend: args.backend,
      );
    default:
      return null;
  }
};

void ensureInitialized() {
  // Nothing to initialize
}

