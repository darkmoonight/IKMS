import 'package:flutter/material.dart';
import 'package:project_cdis/app/modules/home/view.dart';
import 'package:project_cdis/app/modules/settings/view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int _selectedIndex = 0;
  final List<Widget> _widgetOptions = <Widget>[
    const HomePage(),
    const Text('Screen'),
    const SettingsPage(),
  ];

  void _onItemTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: theme.primaryColor,
        showUnselectedLabels: false,
        selectedItemColor: Colors.blue,
        enableFeedback: true,
        items: [
          BottomNavigationBarItem(
            label: AppLocalizations.of(context)!.schedule,
            icon: const Icon(Icons.apps_sharp),
          ),
          const BottomNavigationBarItem(
            label: "",
            icon: Icon(Icons.person),
          ),
          BottomNavigationBarItem(
            label: AppLocalizations.of(context)!.settings,
            icon: const Icon(Icons.settings),
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTap,
      ),
    );
  }
}
