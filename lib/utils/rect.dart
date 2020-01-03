import 'package:flutter/material.dart';

Rect getRect(renderObject) {
  var pos = renderObject.getTransformTo(null).getTranslation();
  var size = renderObject.paintBounds.size;
  return Rect.fromLTWH(pos[0], pos[1], size.width, size.height);
}
