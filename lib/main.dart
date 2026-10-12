import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Vsebina se izriše tudi pod statusno in navigacijsko vrstico;
  // SafeArea na posameznih zaslonih poskrbi za pravilne odmike.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(const CertmoreApp());
}
