import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ui/customers/customers_page.dart';
import 'ui/home/home_page.dart';
import 'ui/sales/sales_page.dart';

void main() {
  runApp(const ProviderScope(child: SubscriptionTrackerApp()));
}

class SubscriptionTrackerApp extends StatelessWidget {
  const SubscriptionTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Subscription Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const _HomeShell(),
    );
  }
}

class _HomeShell extends StatefulWidget {
  const _HomeShell();

  @override
  State<_HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<_HomeShell> {
  int _index = 0;

  static const _pages = [HomePage(), SalesPage(), CustomersPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _pages[_index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.sell_outlined),
            label: 'Sales',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_alt_outlined),
            label: 'Customers',
          ),
        ],
        onDestinationSelected: (value) => setState(() => _index = value),
      ),
    );
  }
}
