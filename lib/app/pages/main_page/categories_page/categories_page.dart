import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:webinar/app/pages/main_page/categories_page/filter_category_page/filter_category_page.dart';
import 'package:webinar/app/providers/app_language_provider.dart';
import 'package:webinar/app/providers/drawer_provider.dart';
import 'package:webinar/app/services/guest_service/categories_service.dart';
import 'package:webinar/common/common.dart';
import 'package:webinar/common/data/app_language.dart';
import 'package:webinar/common/shimmer_component.dart';
import 'package:webinar/common/utils/app_text.dart';
import 'package:webinar/config/assets.dart';
import 'package:webinar/config/colors.dart';
import 'package:webinar/config/styles.dart';
import 'package:webinar/locator.dart';

import '../../../../common/utils/object_instance.dart';
import '../../../models/category_model.dart';
import '../../../../common/components.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  bool isLoading = true;
  List<CategoryModel> categories = [];

  @override
  void initState() {
    super.initState();
    getCategoriesData().then((value) {
      setState(() {
        isLoading = false;
      });
    });
  }

  Future getCategoriesData() async {
    categories = await CategoriesService.categories();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppLanguageProvider>(
      builder: (context, appLanguageProvider, _) {
        return directionality(
          child: Consumer<DrawerProvider>(
            builder: (context, drawerProvider, _) {
              return ClipRRect(
                borderRadius: borderRadius(radius: drawerProvider.isOpenDrawer ? 20 : 0),
                child: Scaffold(
                  backgroundColor: greyFA,
                  appBar: appbar(
                    title: appText.categories,
                    leftIcon: AppAssets.menuSvg,
                    onTapLeftIcon: () {
                      drawerController.showDrawer();
                    },
                  ),
                  body: isLoading
                      ? Center(child: CircularProgressIndicator())
                      : ListView.builder(
                    padding: padding(),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      return CategoryItem(category: categories[index], level: 0);
                    },
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class CategoryItem extends StatefulWidget {
  final CategoryModel category;
  final int level; // مستوى التداخل
  const CategoryItem({required this.category, required this.level, Key? key}) : super(key: key);

  @override
  State<CategoryItem> createState() => _CategoryItemState();
}

class _CategoryItemState extends State<CategoryItem> {
  bool isOpen = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            if (widget.category.subCategories != null && widget.category.subCategories!.isNotEmpty) {
              setState(() {
                isOpen = !isOpen;
              });
            } else {
              nextRoute(FilterCategoryPage.pageName, arguments: widget.category);
            }
          },
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: EdgeInsets.only(left: widget.level * 20.0, top: 10.0, bottom: 10.0), // التدرج حسب المستوى
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: greyF8,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Image.network(
                    widget.category.icon ?? '',
                    width: 22,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        AppAssets.appLogoPng,
                        width: 22,
                        fit: BoxFit.cover,
                      );
                      // return Icon(Icons.error, color: Colors.red[200], size: 22);
                    },
                  ),
                ),
                space(0, width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.category.title ?? '',
                      style: style14Bold(),
                    ),
                    Text(
                      '${widget.category.webinarsCount} ${appText.courses}',
                      style: style12Regular().copyWith(color: greyA5),
                    ),
                  ],
                ),
                const Spacer(),
                if (widget.category.subCategories?.isNotEmpty ?? false)
                  AnimatedRotation(
                    turns: isOpen ? 90 / 360 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: SvgPicture.asset(AppAssets.arrowRightSvg),
                  ),
              ],
            ),
          ),
        ),
        if (isOpen && widget.category.subCategories != null)
          Padding(
            padding: EdgeInsets.only(left: widget.level * 20.0), // زيادة المسافة حسب المستوى
            child: Column(
              children: widget.category.subCategories!
                  .map((subCategory) => CategoryItem(category: subCategory, level: widget.level + 1))
                  .toList(),
            ),
          ),
      ],
    );
  }
}
