import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// Skús rozumne “uhádnuť” URL aj keď chýba schéma
Uri? _normalizeToUri(String raw) {
  final s = raw.trim();

  // Už to vyzerá na URL so schémou (http, https, mailto, tel, geo, …)
  try {
    final u = Uri.parse(s);
    if (u.hasScheme) return u;
  } catch (_) {}

  // Holý host typu example.com/foo -> pridaj https://
  final bareHost = RegExp(r'^[\w.-]+\.[a-zA-Z]{2,}(/.*)?$');
  if (bareHost.hasMatch(s)) {
    try {
      return Uri.parse('https://$s');
    } catch (_) {}
  }

  // E-mail
  final email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  if (email.hasMatch(s)) {
    return Uri.parse('mailto:$s');
  }

  // Telefón (aspoň 5 číslic)
  final digits = s.replaceAll(RegExp(r'\D'), '');
  if (digits.length >= 5) {
    return Uri.parse('tel:$s');
  }

  return null;
}

/// OTVOR ČOKOĽVEK – žiadne whitelisty.
/// - URL (http/https, mailto, tel, …) spustí cez externú appku (Chrome/Telefon)
/// - Ak to URL nie je, skopíruje obsah do schránky a povie to snackom
Future<void> handleScan(BuildContext context, String code) async {
  final trimmed = code.trim();
  dev.log('Scanned: $trimmed', name: 'qr');

  final uri = _normalizeToUri(trimmed);

  if (uri == null) {
    await Clipboard.setData(ClipboardData(text: trimmed));
    throw Exception('Nerozpoznané URL. Skopírované do schránky.');
  }

  // Externá aplikácia je najtolerantnejšia (otvorí http, deep-linky atď.)
  final ok = await launchUrl(
    uri,
    mode: LaunchMode.externalApplication,
  );

  if (!ok) {
    // Fallback: skús aspoň in-app (Custom Tabs / SFSafariViewController)
    final altOk = await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
    if (!altOk) {
      await Clipboard.setData(ClipboardData(text: trimmed));
      throw Exception('Odkaz sa nepodarilo otvoriť. Je v schránke.');
    }
  }
}
