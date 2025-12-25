import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:logbook/logbook.dart';

import 'src/common/widget/app.dart';

@pragma('vm:entry-point')
void main([List<String>? args]) => runZonedGuarded<Future<void>>(() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SoLoud.instance.init(sampleRate: 44100, bufferSize: 1024, channels: Channels.mono);

  SoLoud.instance.setVisualizationEnabled(true);

  runApp(const App());
}, l.s);
