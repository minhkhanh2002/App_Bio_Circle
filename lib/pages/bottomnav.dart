import 'package:app_bio/pages/forecast.dart';
import 'package:app_bio/pages/setting.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';

import 'extend.dart';
import 'home.dart';
class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int currentTabIndex=0;
  late List<Widget> pages;
  late Widget currentPage;
  late Home homepage;
  late Extend extendpage;
  late Forecast forecastpage;
  late Setting settingpage;

  @override
  void initState() {
    // TODO: implement initState
    homepage = Home();
    extendpage = Extend();
    forecastpage = Forecast();
    settingpage = Setting();
    pages = [homepage, extendpage, forecastpage, settingpage];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
          height: 65,
          backgroundColor: Colors.white,
          color: Colors.black,
          animationDuration: Duration(milliseconds: 500),
          onTap: (int index){
            setState(() {
              currentTabIndex=index;

            });
          },
          items: [Icon(Icons.home_outlined, color: Colors.white,
      ),
        Icon(Icons.add_chart_outlined, color: Colors.white,),
        Icon(Icons.timeline_outlined, color: Colors.white,),
        Icon(Icons.settings, color: Colors.white,),
      ]
      ),
      body: pages[currentTabIndex],
    );
  }
}
