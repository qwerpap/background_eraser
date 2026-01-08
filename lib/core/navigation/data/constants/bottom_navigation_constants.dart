import '../../../../constants/image_source.dart';
import '../models/navigation_item.dart';
import 'navigation_constants.dart';
import 'navigation_labels.dart';

class BottomNavigationConstants {
  BottomNavigationConstants._();

  static const List<NavigationItem> navigationItems = [
    NavigationItem(
      iconPath: ImageSource.home,
      label: NavigationLabels.home,
      route: NavigationConstants.home,
    ),
    NavigationItem(
      iconPath: ImageSource.eraser,
      label: NavigationLabels.eraser,
      route: NavigationConstants.eraser,
    ),
    NavigationItem(
      iconPath: ImageSource.profile,
      label: NavigationLabels.profile,
      route: NavigationConstants.profile,
    ),
  ];
}
