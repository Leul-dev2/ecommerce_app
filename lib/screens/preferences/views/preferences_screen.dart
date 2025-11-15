import 'package:flutter/material.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  final Map<String, bool> _preferences = {
    "Analytics": true,
    "Personalization": false,
    "Marketing": false,
    "Social Media": false,
  };

  final Map<String, String> _descriptions = {
    "Analytics":
        "Analytics cookies help us improve our app by tracking usage, anonymously.",
    "Personalization":
        "Personalization cookies make content and recommendations relevant to you.",
    "Marketing":
        "Marketing cookies allow us to show you tailored promotions and ads.",
    "Social Media":
        "Social media cookies enable sharing content with your friends and networks.",
  };

  final Map<String, IconData> _icons = {
    "Analytics": Icons.analytics,
    "Personalization": Icons.person,
    "Marketing": Icons.campaign,
    "Social Media": Icons.share,
  };

  void _resetPreferences() {
    setState(() {
      _preferences.updateAll((key, value) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Cookie Preferences"),
        elevation: 1,
        backgroundColor: theme.scaffoldBackgroundColor,
        actions: [
          TextButton(
            onPressed: _resetPreferences,
            child: const Text(
              "Reset",
              style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _preferences.length,
        itemBuilder: (context, index) {
          final key = _preferences.keys.elementAt(index);
          final value = _preferences[key]!;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.blueAccent.withOpacity(0.1),
                  child: Icon(
                    _icons[key],
                    color: Colors.blueAccent,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        key,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _descriptions[key]!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: value,
                  activeColor: Colors.blueAccent,
                  onChanged: (newVal) {
                    setState(() {
                      _preferences[key] = newVal;
                    });
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
