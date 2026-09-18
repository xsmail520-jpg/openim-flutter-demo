import 'package:flutter_test/flutter_test.dart';
import 'package:openim/routes/app_pages.dart';

void main() {
  test('legacy navigation entries resolve to registered pages', () {
    final routeNames = AppPages.routes.map((route) => route.name).toSet();

    expect(routeNames, contains(AppRoutes.expandChatHistory));
    expect(routeNames, contains(AppRoutes.selectContactsFromTag));
  });
}
