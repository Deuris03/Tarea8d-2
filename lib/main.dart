// ignore_for_file: prefer_const_constructors, unnecessary_late, prefer_final_fields
/*
Nombre: Deuris Andres Estevez Bueno
Matricula: 2022-0233
*/

import 'package:flutter/material.dart';
import 'Controllers/AcercaDe.dart';
import 'Controllers/DatabaseHelper.dart';
import 'Controllers/Eventos.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper().initDB();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const appTitle = 'Tarea 8 - Asignación P2';

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: appTitle,
      home: MyAppPage(title: appTitle),
    );
  }
}

class MyAppPage extends StatefulWidget {
  const MyAppPage({super.key, required this.title});

  final String title;

  @override
  State<MyAppPage> createState() => _MyAppPage();
}

class _MyAppPage extends State<MyAppPage> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController(initialPage: 0);

  static List<Widget> _widgetOptions = [
    EventListPage(),
    AcercaView()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        itemCount: _widgetOptions.length,
        itemBuilder: (context, index) {
          return Center(child: _widgetOptions[index]);
        },
      ),
      drawer: _buildDrawer(),
    );
  }

  Drawer _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: _buildDrawerItems(),
      ),
    );
  }

  List<Widget> _buildDrawerItems() {
    return [
      DrawerHeader(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.centerRight,
            colors: const [
              Color.fromARGB(255, 7, 220, 89),
              Color.fromARGB(255, 4, 142, 57),
            ],
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const <Widget>[
            CircleAvatar(
              radius: 30.0,
              backgroundImage: AssetImage('assets/img/Photo.jpg'),
            ),
            SizedBox(width: 10.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Nombre: Deuris Andres',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                Text(
                  'Matricula: 2022-0233',
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
      _buildListTile(0, Icons.home, 'Home'),
      _buildListTile(6, Icons.contact_phone_sharp, 'Acerca De'),
    ];
  }

  ListTile _buildListTile(int index, IconData icon, String title) {
    return ListTile(
      onTap: () {
        _onItemTapped(index);
        Navigator.pop(context);
      },
      title: Row(
        children: [
          Icon(icon, color: _selectedIndex == index ? Colors.blue : null),
          const SizedBox(width: 8.0),
          Text(title),
        ],
      ),
      selected: _selectedIndex == index,
    );
  }
}
