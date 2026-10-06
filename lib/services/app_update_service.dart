import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import '../widgets/update_dialog.dart';

class AppUpdateInfo {
  final bool hasUpdate;
  final String latestVersion;
  final String currentVersion;
  final String releaseTitle;
  final String releaseNotes;
  final String downloadUrl;

  AppUpdateInfo({
    required this.hasUpdate,
    required this.latestVersion,
    required this.currentVersion,
    required this.releaseTitle,
    required this.releaseNotes,
    required this.downloadUrl,
  });
}

class AppUpdateService {
  static const String _releasesApiUrl =
      'https://api.github.com/repos/anjil06/codealpha_fitness_traker/releases/latest';

  /// Compare two semantic version strings e.g. "1.0.1" vs "1.0.0"
  static bool isNewerVersion(String latestVersionStr, String currentVersionStr) {
    try {
      final latest = latestVersionStr.toLowerCase().replaceAll('v', '').trim();
      final current = currentVersionStr.toLowerCase().replaceAll('v', '').trim();

      final latestParts = latest.split('.').map((e) => int.tryParse(e) ?? 0).toList();
      final currentParts = current.split('.').map((e) => int.tryParse(e) ?? 0).toList();

      final maxLen = math.max(latestParts.length, currentParts.length);
      for (int i = 0; i < maxLen; i++) {
        final l = i < latestParts.length ? latestParts[i] : 0;
        final c = i < currentParts.length ? currentParts[i] : 0;
        if (l > c) return true;
        if (l < c) return false;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Check GitHub Releases for newer version
  static Future<AppUpdateInfo?> checkForUpdate() async {
    try {
      final response = await http.get(
        Uri.parse(_releasesApiUrl),
        headers: {'Accept': 'application/vnd.github.v3+json'},
      ).timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final tagName = data['tag_name'] as String? ?? '';
        final cleanTag = tagName.replaceAll('v', '').trim();
        final currentVersion = AppConstants.appVersion;

        final hasUpdate = isNewerVersion(cleanTag, currentVersion);
        final title = data['name'] as String? ?? 'New FitTrack Update';
        final body = data['body'] as String? ?? 'Performance improvements and bug fixes.';

        // Look for .apk asset in release
        String downloadUrl = data['html_url'] as String? ?? '';
        final assets = data['assets'] as List<dynamic>? ?? [];
        for (final asset in assets) {
          final assetName = asset['name'] as String? ?? '';
          if (assetName.endsWith('.apk')) {
            downloadUrl = asset['browser_download_url'] as String? ?? downloadUrl;
            break;
          }
        }

        return AppUpdateInfo(
          hasUpdate: hasUpdate,
          latestVersion: cleanTag.isNotEmpty ? cleanTag : tagName,
          currentVersion: currentVersion,
          releaseTitle: title,
          releaseNotes: body,
          downloadUrl: downloadUrl,
        );
      }
    } catch (e) {
      debugPrint('App update check failed: $e');
    }
    return null;
  }

  /// Launch download URL in device browser to download & install update
  static Future<bool> launchDownload(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error launching update URL: $e');
    }
    return false;
  }

  /// Automatically prompt user if an update is available
  static Future<void> promptUpdateIfAvailable(
    BuildContext context, {
    bool showNoUpdateMessage = false,
  }) async {
    // Check if dismissed recently for automatic launch
    if (!showNoUpdateMessage) {
      final prefs = await SharedPreferences.getInstance();
      final lastDismissed = prefs.getInt('update_last_dismissed') ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      // Skip if dismissed within the last 6 hours
      if (now - lastDismissed < 6 * 3600 * 1000) {
        return;
      }
    }

    final info = await checkForUpdate();

    if (!context.mounted) return;

    if (info != null && info.hasUpdate) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => UpdateDialog(
          updateInfo: info,
          onDismiss: () async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setInt('update_last_dismissed', DateTime.now().millisecondsSinceEpoch);
            if (ctx.mounted) Navigator.pop(ctx);
          },
        ),
      );
    } else if (showNoUpdateMessage) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 FitTrack is up to date! (v${AppConstants.appVersion})'),
          backgroundColor: AppTheme.primaryDark,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
