import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDarkMode = false;

  // get the saved theme mode
  void getThemeMode() async {
    // get the saved theme mode
    final savedThemeMode = await AdaptiveTheme.getThemeMode();
    // check if the saved theme mod is dark
    if (savedThemeMode == AdaptiveThemeMode.dark) {
      // set the isDarkMode to true
      setState(() {
        isDarkMode = true;
      });
    } else {
      // set the isDarkMode to falsee
      setState(() {
        isDarkMode = false;
      });
    }
  }

  @override
  void initState() {
    getThemeMode();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Card(
          child: SwitchListTile(
            title: const Text('Change Theme'),
            secondary: Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
              child: Icon(
                isDarkMode ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                color: isDarkMode ? Colors.black : Colors.white,
              ),
            ),
            value: isDarkMode,
            onChanged: (value) {
              // set the isDarkMode to the value
              setState(() {
                isDarkMode = value;
              });
              // check if the value is true
              if (value) {
                // set the theme mode to dark
                AdaptiveTheme.of(context).setDark();
              } else {
                AdaptiveTheme.of(context).setLight();
              }
            },
          ),
        ),
      ),
    );
  }
}