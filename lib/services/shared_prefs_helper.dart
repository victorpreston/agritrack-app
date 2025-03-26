import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/farm.dart';
import '../models/user_profile.dart';

class SharedPrefsHelper {
  static const String _farmKey = 'farm_details';
  static const String _userProfileKey = 'user_profile';
  static const String _chatHistoryKey = 'chat_history';

  static Future<bool> saveFarmDetails(Farm farm) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(_farmKey, jsonEncode(farm.toJson()));
  }

  static Future<Farm?> getFarmDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final farmJson = prefs.getString(_farmKey);

    if (farmJson == null) {
      return null;
    }

    try {
      return Farm.fromJson(jsonDecode(farmJson));
    } catch (e) {
      return null;
    }
  }

  static Future<bool> saveUserProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(_userProfileKey, jsonEncode(profile.toJson()));
  }

  static Future<UserProfile?> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = prefs.getString(_userProfileKey);

    if (profileJson == null) {
      return null;
    }

    try {
      return UserProfile.fromJson(jsonDecode(profileJson));
    } catch (e) {
      return null;
    }
  }

  static Future<bool> saveChatHistory(List<Map<String, dynamic>> messages) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(_chatHistoryKey, jsonEncode(messages));
  }

  static Future<List<Map<String, dynamic>>?> getChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final chatJson = prefs.getString(_chatHistoryKey);

    if (chatJson == null) {
      return null;
    }

    try {
      final List<dynamic> decoded = jsonDecode(chatJson);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      return null;
    }
  }

  static Future<bool> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.clear();
  }
}