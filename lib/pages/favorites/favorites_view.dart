import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  late List<Map<String, dynamic>> _items;

  @override
  void initState() {
    super.initState();
    _items = DataSp.getFavoriteItems();
  }

  Future<void> _remove(Map<String, dynamic> item) async {
    final id = '${item['id'] ?? ''}';
    _items.removeWhere((entry) => '${entry['id'] ?? ''}' == id);
    await DataSp.putFavoriteItems(_items);
    if (mounted) setState(() {});
    IMViews.showToast(StrRes.favoriteRemoved);
  }

  String _time(dynamic value) {
    final date = DateTime.tryParse('$value');
    if (date == null) return '';
    return date.toLocal().toString().substring(0, 16);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleBar.back(title: StrRes.favorites, showUnderline: true),
      backgroundColor: Styles.background,
      body: _items.isEmpty
          ? Center(
              child: Text(StrRes.favoritesEmpty, style: Styles.ts_8E9AB0_14sp),
            )
          : ListView.separated(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              itemCount: _items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, index) {
                final item = _items[index];
                final content = '${item['content'] ?? ''}';
                return Container(
                  color: Styles.surface,
                  child: ListTile(
                    title: Text(
                      content.isEmpty ? StrRes.favorite : content,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${item['sender'] ?? ''}  ${_time(item['createdAt'])}',
                      style: Styles.ts_8E9AB0_12sp,
                    ),
                    trailing: IconButton(
                      tooltip: StrRes.remove,
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _remove(item),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
