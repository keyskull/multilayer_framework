part of '../framework.dart';

const buttonPaths = [
  'profile',
  '',
  'dashboard',
  'blog',
  'projects',
  'tools',
  'about-us'
];
const buttonNames = [
  'Profile',
  'Home',
  'Dashboard',
  'Blog',
  'Projects',
  'Tools',
  'About Us'
];
const buttonIcons = [
  Icon(Icons.person),
  Icon(Icons.home),
  Icon(Icons.dashboard),
  Icon(Icons.article),
  Icon(Icons.work),
  Icon(Icons.build_circle),
  Icon(Icons.album)
];
const buttonSelectedIcons = [
  Icon(Icons.person_outline),
  Icon(Icons.home_outlined),
  Icon(Icons.dashboard_outlined),
  Icon(Icons.article_outlined),
  Icon(Icons.work_outline),
  Icon(Icons.build_circle_outlined),
  Icon(Icons.album_outlined)
];

class NavigationRailButtons {
  final List<String> buttonPaths;
  final List<String> buttonNames;
  final List<Icon> buttonIcons;
  final List<Icon> buttonSelectedIcons;

  NavigationRailButtons(this.buttonPaths, this.buttonNames, this.buttonIcons,
      this.buttonSelectedIcons);
}

final NavigationRailButtons defaultNavigationRailButtons =
    NavigationRailButtons(
        buttonPaths, buttonNames, buttonIcons, buttonSelectedIcons);
