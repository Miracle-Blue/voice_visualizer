import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logbook/logbook.dart';

import 'src/common/widget/app.dart';

@pragma('vm:entry-point')
void main([List<String>? args]) => runZonedGuarded<Future<void>>(() async => runApp(const App()), l.s);
