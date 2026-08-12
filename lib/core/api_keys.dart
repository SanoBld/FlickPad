import 'package:flutter_dotenv/flutter_dotenv.dart';

// Central place to read API keys loaded from .env
class ApiKeys {
  static String get tmdb => dotenv.env['TMDB_API_KEY'] ?? '';
  static String get rawg => dotenv.env['RAWG_API_KEY'] ?? '';
  static String get omdb => dotenv.env['OMDB_API_KEY'] ?? '';
  static String get cheapSharkBase =>
      dotenv.env['CHEAPSHARK_BASE'] ?? 'https://www.cheapshark.com/api/1.0';
}
