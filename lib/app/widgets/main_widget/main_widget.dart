import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:webinar/app/models/currency_model.dart';
import 'package:webinar/common/components.dart';
import 'package:webinar/common/data/api_public_data.dart';
import 'package:webinar/common/data/app_data.dart';
import 'package:webinar/common/data/app_language.dart';
import 'package:webinar/common/utils/currency_utils.dart';
import 'package:webinar/locator.dart';

import '../../../common/common.dart';
import '../../../common/enums/page_name_enum.dart';
import '../../../common/utils/app_text.dart';
import '../../../config/assets.dart';
import '../../../config/colors.dart';
import '../../../config/styles.dart';
import '../../providers/app_language_provider.dart';


class MainWidget{

  
  static showLanguageDialog() async {
    
    return await showDialog(
      context: navigatorKey.currentContext!, 
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: padding(horizontal: 25),
          child: directionality(
            child: Container(
              width: getSize().width,
              padding: padding(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: borderRadius(radius: 25)
              ),
              child: StatefulBuilder(
                builder: (context,state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
            
                      space(19),
            
                      Text(
                        appText.selectlanguage,
                        style: style16Bold(),
                      ),
          
                      space(16),
          
                      // country list
                      SizedBox(
                        width: getSize().width,
                        height: 100,
                        child: ListView.builder(
                          itemCount: locator<AppLanguage>().appLanguagesData.length,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () async {
          
                                await locator<AppLanguage>().saveLanguage(locator<AppLanguage>().appLanguagesData[index].code!.toLowerCase());
                                locator<AppLanguageProvider>().changeState();

                                navigatorKey.currentState!.pop(locator<AppLanguage>().appLanguagesData[index]);
                              },
                              behavior: HitTestBehavior.opaque,
                              child: Container(
                                padding: padding(horizontal: 12),
                                margin: const EdgeInsets.only(bottom: 24),
                                width: getSize().height,
          
                                child: Row(
                                  children: [
          
                                    ClipRRect(
                                      borderRadius: borderRadius(radius: 50),
                                      child: Image.asset(
                                        locator<AppLanguage>().appLanguagesData[index].flagUri ?? '',
                                        width: 24,
                                        height: 24,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
          
                                    space(0,width: 14),

                                    Expanded(
                                      child: Text(
                                        locator<AppLanguage>().appLanguagesData[index].name ?? '',
                                        style: style14Regular(),
                                      ),
                                    )
          
          
                                  ],
                                ),
                              ),
                            );
          
                          },
                        ),
                      ),
          
                      space(12),
          
                      button(
                        onTap: (){
                          backRoute();
                        }, 
                        width: getSize().width, 
                        height: 52, 
                        text: appText.cancel, 
                        bgColor: mainColor(),
                        textColor: Colors.white, 
                        borderColor: mainColor()
                      ),
          
                      space(11),
          
                    ],
                  );
                }
              ),
            ),
          ),
        );
      },
    );
  }

  static showCurrencyDialog() async {
    
    TextEditingController searchController = TextEditingController();
    FocusNode searchNode = FocusNode();

    List<CurrencyModel> searchList = PublicData.currencyListData.toList();

    return await showDialog(
      context: navigatorKey.currentContext!, 
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: padding(horizontal: 25),
          child: directionality(
            child: StatefulBuilder(
              builder: (context,state) {
                return Container(
                  width: getSize().width,
                  padding: padding(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: borderRadius(radius: 25)
                  ),
                  child: StatefulBuilder(
                    builder: (context,state) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                
                          space(19),
                
                          Text(
                            appText.selectACurrency,
                            style: style16Bold(),
                          ),
                          
                          space(16),

                          Center(
                            child: input(searchController, searchNode, appText.searchACurrency,iconPathLeft: AppAssets.searchSvg, isBorder: true, radius: 15,onChange: (text) {
                                    
                              if(text.trim().isEmpty){
                                searchList = PublicData.currencyListData.toList();
                              }else{
                                searchList = [];
                                PublicData.currencyListData.forEach((element) {
                                  if(element.currency?.toLowerCase().contains(text.trim().toLowerCase()) ?? false){
                                    searchList.add(element);
                                  }
                                });
                              }
                                    
                              state((){});
                                    
                            },),
                          ),
          
                          space(24),
          
                          // country list
                          SizedBox(
                            width: getSize().width,
                            height: 100,
                            child: ListView.builder(
                              itemCount: searchList.length,
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () async {
          
                                    await AppData.saveCurrency(searchList[index].currency ?? '');
                                    CurrencyUtils.userCurrency = await AppData.getCurrency();

                                    
                                    locator<AppLanguageProvider>().changeState();

                                    navigatorKey.currentState!.pop(searchList[index]);
                                  },
                                  behavior: HitTestBehavior.opaque,
                                  child: Container(
                                    padding: padding(horizontal: 12),
                                    margin: const EdgeInsets.only(bottom: 24),
                                    width: getSize().height,
          
                                    child: Row(
                                      children: [
          
                                        Container(
                                          width: 25,
                                          height: 25,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: const Color(0xffF8F8F8),
                                            borderRadius: borderRadius(radius: 5)
                                          ),
                                          child: Text(
                                            CurrencyUtils.getSymbol(searchList[index].currency ?? ''),
                                            style: style12Regular(),
                                          ),
                                        ),
          
                                        space(0,width: 14),
          
                                        Expanded(
                                          child: Text(
                                            searchList[index].currency ?? '',
                                            style: style14Regular(),
                                          ),
                                        )
          
          
                                      ],
                                    ),
                                  ),
                                );
          
                              },
                            ),
                          ),
          
                          space(25),
          
                          button(
                            onTap: (){
                              backRoute();
                            }, 
                            width: getSize().width, 
                            height: 52, 
                            text: appText.cancel, 
                            bgColor: mainColor(),
                            textColor: Colors.white, 
                            borderColor: mainColor()
                          ),
          
                          space(11),
          
                        ],
                      );
                    }
                  ),
                );
              }
            ),
          ),
        );
      },
    );
  }

  static showExitDialog() async {

    return await showDialog(
      context: navigatorKey.currentContext!, 
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: padding(horizontal: 25),
          child: directionality(
            child: StatefulBuilder(
              builder: (context,state) {
                return Container(
                  width: getSize().width,
                  padding: padding(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: borderRadius(radius: 25)
                  ),
                  child: StatefulBuilder(
                    builder: (context,state) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                
                          space(22),
                
                          Text(
                            appText.exit,
                            style: style16Bold(),
                          ),
                          
                          space(16),

                          Text(
                            appText.exitDesc,
                            style: style16Regular().copyWith(color: grey5E),
                          ),
                          
                          space(30),
          
                          Row(
                            children: [

                              Expanded(
                                child: button(
                                  onTap: (){
                                    exit(0);
                                  }, 
                                  width: getSize().width, 
                                  height: 52, 
                                  text: appText.yes, 
                                  bgColor: mainColor(),
                                  textColor: Colors.white, 
                                  borderColor: mainColor()
                                )
                              ),

                              Expanded(
                                child: button(
                                  onTap: (){
                                    backRoute();
                                  }, 
                                  width: getSize().width, 
                                  height: 52, 
                                  text: appText.cancel, 
                                  bgColor: Colors.transparent, 
                                  textColor: Colors.grey, 
                                  borderColor: Colors.transparent
                                )
                              ),
                              
                            ],
                          ),
          
                          space(11),
          
                        ],
                      );
                    }
                  ),
                );
              }
            ),
          ),
        );
      },
    );
  }


  static Widget menuButton(String iconPath,bool isBadegBadge,Color iconColor,Color bgColor,Function onTap){
    return GestureDetector(
      onTap: (){
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 40,
        height: 40,

        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: borderRadius(radius: 15),
        ),


        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: SvgPicture.asset(iconPath,
              colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
              ),
            ),

            if(isBadegBadge)...{

              Positioned(
                top: 11,
                right: 7,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: red49
                  ),
                )
              )
              
            }

          ],
        ),
      ),
    );

  }




static Widget navItem(PageNames thisPage, PageNames selectedPage,
 String name, String icon, Function onTap, {bool isPng = false}) {
  return Flexible(
    fit: FlexFit.loose,
    child: LayoutBuilder(
      builder: (context, constraints) {
        double iconSize = constraints.maxWidth < 70 ? 20 : 24;
        double textSize = constraints.maxWidth < 70 ? 8 : 10;
        return GestureDetector(
          onTap: () => onTap(),
          behavior: HitTestBehavior.opaque,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 80), // Limiting max width per item
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (!isPng)
                    SvgPicture.asset(
                      icon,
                      width: iconSize,
                      height: iconSize,
                      colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    ),
                  if (isPng)
                    Image.asset(icon, width: iconSize, height: iconSize),

                  SizedBox(height: 6),

                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: thisPage == selectedPage ? 1 : 0,
                    child: Text(
                      name,
                      style: style10RegularKufam().copyWith(color: Colors.white, fontSize: textSize),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),

                  SizedBox(height: 4),

                  AnimatedCrossFade(
                    firstChild: SvgPicture.asset(AppAssets.navArrowSvg, width: 10, height: 5),
                    secondChild: const SizedBox(),
                    crossFadeState: thisPage == selectedPage ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                    duration: const Duration(milliseconds: 300),
                  )
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}




static Widget homeNavItem(PageNames thisPage, PageNames selectedPage, Function onTap) {
  return Flexible(
    fit: FlexFit.loose,
    child: LayoutBuilder(
      builder: (context, constraints) {
        double outerIconSize = constraints.maxWidth < 70 ? 32 : 36;
        double innerIconSize = constraints.maxWidth < 70 ? 18 : 20;
        double textSize = constraints.maxWidth < 70 ? 8 : 10;
        return GestureDetector(
          onTap: () => onTap(),
          behavior: HitTestBehavior.opaque,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 80),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SvgPicture.asset(
                        AppAssets.homeNavSvg,
                        width: outerIconSize,
                        height: outerIconSize+10,
                        colorFilter: ColorFilter.mode(gold(), BlendMode.srcIn),
                      ),
                      SvgPicture.asset(
                        AppAssets.homeSvg,
                        width: innerIconSize,
                        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                      ),
                    ],
                  ),

                  SizedBox(height: 8),

                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: 1,
                    child: Text(
                      appText.home,
                      style: style10RegularKufam().copyWith(color: Colors.white, fontSize: textSize),
                    ),
                  ),

                  SizedBox(height: 6),

                  AnimatedCrossFade(
                    firstChild: SvgPicture.asset(AppAssets.navArrowSvg, width: 10, height: 10),
                    secondChild: const SizedBox(height: 5),
                    crossFadeState: thisPage == selectedPage ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                    duration: const Duration(milliseconds: 300),
                  )
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}




}