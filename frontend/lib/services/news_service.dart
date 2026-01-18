import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/news_item.dart';
import 'lang_service.dart';
import '../lang/strings.dart';

class NewsService {
  static const String _base = 'https://www.arboretumbaexem.com';

  static Tr _tr() => Tr(LangService.code);

  static List<NewsItem> _fallbackSmall() {
    final tr = _tr();
    return [
      NewsItem(
        title: tr.homeFallbackWalkTitle,
        subtitle: tr.homeFallbackWalkSubtitle,
        tag: tr.homeTagStory,
        url: 'https://www.arboretumbaexem.com/walk-among-wonders/',
      ),
      NewsItem(
        title: tr.homeFallbackVisionTitle,
        subtitle: tr.homeFallbackVisionSubtitle,
        tag: tr.homeTagAnnouncement,
        url: 'https://www.arboretumbaexem.com/green-vision/',
      ),
      NewsItem(
        title: tr.homeFallbackProcessTitle,
        subtitle: tr.homeFallbackProcessSubtitle,
        tag: tr.homeTagUpdate,
        url: 'https://www.arboretumbaexem.com/growing-process/',
      ),
    ];
  }

  static Future<List<NewsItem>> fetchLatest() async {
    final tr = _tr();

    // ✅ map prekladaných textov podľa slug
    final localizedBySlug = <String, NewsItem>{
      'walk-among-wonders': NewsItem(
        title: tr.homeFallbackWalkTitle,
        subtitle: tr.homeFallbackWalkSubtitle,
        tag: tr.homeTagStory,
        url: 'https://www.arboretumbaexem.com/walk-among-wonders/',
      ),
      'green-vision': NewsItem(
        title: tr.homeFallbackVisionTitle,
        subtitle: tr.homeFallbackVisionSubtitle,
        tag: tr.homeTagAnnouncement,
        url: 'https://www.arboretumbaexem.com/green-vision/',
      ),
      'growing-process': NewsItem(
        title: tr.homeFallbackProcessTitle,
        subtitle: tr.homeFallbackProcessSubtitle,
        tag: tr.homeTagUpdate,
        url: 'https://www.arboretumbaexem.com/growing-process/',
      ),
    };

    try {
      final uri = Uri.parse(
        '$_base/wp-json/wp/v2/pages?per_page=100&_fields=slug,link,modified',
      );

      final res = await http.get(uri).timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) return _fallbackSmall();

      final List data = jsonDecode(res.body) as List;

      final items = <NewsItem>[];

      for (final raw in data) {
        final slug = raw['slug']?.toString();
        if (slug == null) continue;

        // ✅ berieme iba 3 stránky čo chceš
        final localized = localizedBySlug[slug];
        if (localized == null) continue;

        // link z API ak existuje, inak fallback url
        final link = raw['link']?.toString() ?? localized.url;

        items.add(
          NewsItem(
            title: localized.title,       // ✅ preložené
            subtitle: localized.subtitle, // ✅ preložené
            tag: localized.tag,           // ✅ preložené
            url: link,
          ),
        );
      }

      if (items.isEmpty) return _fallbackSmall();

      // zachovaj poradie
      final order = ['walk-among-wonders', 'green-vision', 'growing-process'];
      items.sort((a, b) {
        final ia = order.indexWhere((s) => a.url.contains(s));
        final ib = order.indexWhere((s) => b.url.contains(s));
        return ia.compareTo(ib);
      });

      return items;
    } catch (_) {
      return _fallbackSmall();
    }
  }
}
