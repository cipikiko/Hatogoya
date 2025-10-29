import 'package:flutter/material.dart';
import 'src/scanner_page.dart';
import 'src/integration.dart'; // your colleagues' code hooks live here

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Scanner',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: ScannerPage(
        onScan: (code) async {
          // Single integration point. Make this call into your colleague’s Dart.
          await handleScan(code);
        },
      ),
    );
  }
}
