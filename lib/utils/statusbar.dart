import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

//koyu arka planlarda bildirim çubuğunun rengini değiştirmek için
void setStatusBarLightIcons() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
}

//açık arka planlarda bildirim çubuğunun rengini değiştirmek için
void setStatusBarDarkIcons() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
}