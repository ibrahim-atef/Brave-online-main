import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:headset_connection_event/headset_event.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webinar/app/pages/main_page/categories_page/filter_category_page/filter_category_page.dart';
import 'package:webinar/app/providers/drawer_provider.dart';
import 'package:webinar/app/services/guest_service/course_service.dart';
import 'package:webinar/app/services/user_service/user_service.dart';
import 'package:webinar/app/widgets/main_widget/home_widget/home_widget.dart';
import 'package:webinar/common/common.dart';
import 'package:webinar/common/data/app_data.dart';
import 'package:webinar/common/shimmer_component.dart';
import 'package:webinar/common/utils/app_text.dart';
import 'package:webinar/config/assets.dart';
import 'package:webinar/config/colors.dart';
import 'package:webinar/config/styles.dart';
import '../../../../common/enums/error_enum.dart';
import '../../../../common/utils/tablet_detector.dart';
import '../../../../locator.dart';
import '../../../models/course_model.dart';
import '../../../models/purchase_course_model.dart';
import '../../../models/user_model.dart';
import '../../../providers/app_language_provider.dart';
import '../../../../common/components.dart';
import '../../../providers/filter_course_provider.dart';
import '../../../providers/providers_provider.dart';
import '../../../services/guest_service/providers_service.dart';
import '../../authentication_page/login_page.dart';
import '../providers_page/providers_page.dart';
import '../providers_page/user_profile_page/user_profile_page.dart';
import 'support_message_page/support_message_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  String token = '';
  String name = '';

  TextEditingController searchController = TextEditingController();
  FocusNode searchNode = FocusNode();

  late AnimationController appBarController;
  late Animation<double> appBarAnimation;

  double appBarHeight = 230;

  ScrollController scrollController = ScrollController();

  PageController sliderPageController = PageController();
  int currentSliderIndex = 0;

  PageController adSliderPageController = PageController();
  int currentAdSliderIndex = 0;

  bool isLoadingFeaturedListData = false;
  List<CourseModel> featuredListData = [];

  bool isLoadingNewsetListData = false;
  List<CourseModel> newsetListData = [];

  bool isLoadingBestRatedListData = false;
  List<CourseModel> bestRatedListData = [];

  bool isLoadingBestSellingListData = false;
  List<CourseModel> bestSellingListData = [];

  bool isLoadingDiscountListData = false;
  List<CourseModel> discountListData = [];

  bool isLoadingFreeListData = false;
  List<CourseModel> freeListData = [];

  bool isLoadingBundleData = false;
  List<CourseModel> bundleData = [];

  bool isLoadingPurchaseCourse = false;
    List<CourseModel> myClasses = [];
  List<PurchaseCourseModel> purchases = [];

  @override
  void initState() {

    locator<ProvidersProvider>().clearFilter();

    getInstructors();

    super.initState();

    getToken();

    appBarController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    appBarAnimation = Tween<double>(
      begin: 150 + MediaQuery.of(navigatorKey.currentContext!).viewPadding.top,
      end: 80 + MediaQuery.of(navigatorKey.currentContext!).viewPadding.top,
    ).animate(appBarController);

    scrollController.addListener(() {
      if (scrollController.position.pixels > 100) {
        if (!appBarController.isAnimating) {
          if (appBarController.status == AnimationStatus.dismissed) {
            appBarController.forward();
          }
        }
      } else if (scrollController.position.pixels < 50) {
        if (!appBarController.isAnimating) {
          if (appBarController.status == AnimationStatus.completed) {
            appBarController.reverse();
          }
        }
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (ModalRoute.of(context)!.settings.arguments != null) {
        if (AppData.canShowFinalizeSheet) {
          AppData.canShowFinalizeSheet = false;

          // finalize signup
          HomeWidget.showFinalizeRegister(
                  (ModalRoute.of(context)!.settings.arguments as int))
              .then((value) {
            if (value) {
              getToken();
            }
          });
        }
      }
    });

    getData();
  }


  getData() {
    isLoadingPurchaseCourse = true;
    isLoadingFeaturedListData = true;
    isLoadingNewsetListData = true;
    isLoadingBundleData = true;
    isLoadingBestRatedListData = true;
    isLoadingBestSellingListData = true;
    isLoadingDiscountListData = true;
    isLoadingFreeListData = true;

    UserService.getPurchaseCourse().then((value){
      setState(() {
        isLoadingPurchaseCourse = false;
        purchases = value;
      });
    });


    CourseService.featuredCourse().then((value) {
      setState(() {
        isLoadingFeaturedListData = false;
        featuredListData = value;
      });
    });

    CourseService.getAll(offset: 0, bundle: true).then((value) {
      setState(() {
        isLoadingBundleData = false;
        bundleData = value;
      });
    });

    CourseService.getAll(offset: 0, sort: 'newest').then((value) {
      setState(() {
        isLoadingNewsetListData = false;
        newsetListData = value;
      });
    });

    CourseService.getAll(offset: 0, sort: 'best_rates').then((value) {
      setState(() {
        isLoadingBestRatedListData = false;
        bestRatedListData = value;
      });
    });

    CourseService.getAll(offset: 0, sort: 'bestsellers').then((value) {
      setState(() {
        isLoadingBestSellingListData = false;
        bestSellingListData = value;
      });
    });

    CourseService.getAll(offset: 0, discount: true).then((value) {
      setState(() {
        isLoadingDiscountListData = false;
        discountListData = value;
      });
    });

    CourseService.getAll(offset: 0, free: true).then((value) {
      setState(() {
        isLoadingFreeListData = false;
        freeListData = value;
      });
    });
  }

     bool hasAccess({bool canRedirect=false}){
    if(token.isEmpty){
      showSnackBar(ErrorEnum.alert, appText.youHaveNotAccess);
      if(canRedirect){
        nextRoute(LoginPage.pageName,isClearBackRoutes: false);
      }
      return false;
    }else{
      return true;
    }
  }

  getToken() async {
    AppData.getAccessToken().then((value) {
      setState(() {
        token = value;
      });

      if (token.isNotEmpty) {
        // get profile and save naem
        UserService.getProfile().then((value) async {
          if (value != null) {
            await AppData.saveName(value.fullName ?? '');
            getUserName();
          }
        });
      }
    });

    getUserName();
  }

  getUserName() {
    AppData.getName().then((value) {
      setState(() {
        name = value;
      });
    });
  }

  List<UserModel> instructorsData = [];
  bool isLoading = true;

  getInstructors() async {
    setState(() {
      isLoading = true;
    });

    instructorsData = await ProvidersService.getInstructors(
        availableForMeetings: locator<ProvidersProvider>().availableForMeeting,
        freeMeetings: locator<ProvidersProvider>().free,
        discount: locator<ProvidersProvider>().discount,
        downloadable: locator<ProvidersProvider>().downloadable,
        sort: locator<ProvidersProvider>().sort,
        categories: locator<ProvidersProvider>().categorySelected);

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppLanguageProvider>(
        builder: (context, languageProvider, _) {
      return directionality(child:
          Consumer<DrawerProvider>(builder: (context, drawerProvider, _) {
        return ClipRRect(
          borderRadius:
              borderRadius(radius: drawerProvider.isOpenDrawer ? 20 : 0),
          child: Scaffold(
            floatingActionButton: Stack(
              children: [
                Positioned(
                  left: 10, // Adjust as needed
                  bottom: 90, // Adjust height as needed
                  child: FloatingActionButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        builder: (BuildContext context) {
                          return  Padding(
                            padding:  EdgeInsets.all(50.0),
                            child:  GestureDetector(
                              onTap: () {
                                if(hasAccess(canRedirect: true)){
                              nextRoute(SupportMessagePage.pageName);
                            }
                              },
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        appText.support,
                                        style: style20Bold(),
                                      ),
                                      const  SizedBox(width: 10),
                                      Icon(Icons.support_agent,
                                          size: 35, color: mainColor()),
                                    
                                      
                                    ],
                                  ),
                                
                                SizedBox(height: 20,),

                                  GestureDetector(
                                    onTap: ()async{
                                      await launchUrl(Uri.parse("https://wa.me/+201067694305"));
                                    },
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          appText.whatsapp,
                                          style: style20Bold(),
                                        ),
                                        const  SizedBox(width: 10),
                                        FaIcon(FontAwesomeIcons.whatsapp,
                                        size: 35, color: Colors.green),
                                        
                                      
                                        
                                      ],
                                    ),
                                  ),
                                

                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    backgroundColor: mainColor(),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.support_agent,
                      size: 28,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            body: Column(
              children: [
                // app bar
                HomeWidget.homeAppBar(appBarController, appBarAnimation, token,
                    searchController, searchNode, name),

                // body
                Expanded(
                    child: CustomScrollView(
                  controller: scrollController,
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        children: [

SizedBox(
  width: getSize().width,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      HomeWidget.titleAndMore(appText.instrcutors, onTapViewAll: () {
        nextRoute(ProvidersPage.pageName);
      }),
      !isLoading && instructorsData.isEmpty
          ? emptyState(
              AppAssets.providersEmptyStateSvg,
              appText.noInstructor,
              appText.noInstructorDesc)
          : SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 21),
                itemCount: isLoading ? 6 : instructorsData.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 15),
                    child: isLoading
                        ? userProfileCardShimmer()
                        : userProfileCard(
                            instructorsData[index],
                            () {
                              nextRoute(
                                UserProfilePage.pageName,
                                arguments: instructorsData[index].id,
                              );
                            },
                          ),
                  );
                },
              ),
            ),
    ],
  ),
),


                          // // Featured Classes
                          // Column(
                          //   children: [
                          //     HomeWidget.titleAndMore(appText.featuredClasses,
                          //         isViewAll: false),
                          //     if (featuredListData.isNotEmpty ||
                          //         isLoadingFeaturedListData) ...{
                          //       SizedBox(
                          //         width: getSize().width,
                          //         height: 215,
                          //         child: PageView(
                          //           controller: sliderPageController,
                          //           onPageChanged: (value) async {
                          //             await Future.delayed(
                          //                 const Duration(milliseconds: 500));
                          //
                          //             setState(() {
                          //               currentSliderIndex = value;
                          //             });
                          //           },
                          //           physics: const BouncingScrollPhysics(),
                          //           children: List.generate(
                          //               isLoadingFeaturedListData
                          //                   ? 1
                          //                   : featuredListData.length, (index) {
                          //             return isLoadingFeaturedListData
                          //                 ? courseSliderItemShimmer()
                          //                 : courseSliderItem(
                          //                     featuredListData[index]);
                          //           }),
                          //         ),
                          //       ),
                          //
                          //       space(10),
                          //
                          //       // indecator
                          //       SizedBox(
                          //         width: getSize().width,
                          //         height: 15,
                          //         child: Row(
                          //           mainAxisAlignment: MainAxisAlignment.center,
                          //           children: [
                          //             ...List.generate(featuredListData.length,
                          //                 (index) {
                          //               return AnimatedContainer(
                          //                 duration:
                          //                     const Duration(milliseconds: 200),
                          //                 width: currentSliderIndex == index
                          //                     ? 16
                          //                     : 7,
                          //                 height: 7,
                          //                 margin: padding(horizontal: 2),
                          //                 decoration: BoxDecoration(
                          //                     color: mainColor(),
                          //                     borderRadius: borderRadius()),
                          //               );
                          //             }),
                          //           ],
                          //         ),
                          //       )
                          //     },
                          //   ],
                          // ),

                          // Newest Classes
                          Column(
                            children: [
                              HomeWidget.titleAndMore(appText.newestClasses,
                                  onTapViewAll: () {
                                locator<FilterCourseProvider>().clearFilter();
                                locator<FilterCourseProvider>().sort = 'newest';
                                nextRoute(FilterCategoryPage.pageName);
                              }),
                              SizedBox(
                                width: getSize().width,
                                child: SingleChildScrollView(
                                  physics: const BouncingScrollPhysics(),
                                  padding: padding(),
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: List.generate(
                                        isLoadingNewsetListData
                                            ? 3
                                            : newsetListData.length, (index) {
                                      return isLoadingNewsetListData
                                          ? courseItemShimmer()
                                          : courseItem(
                                              newsetListData[index],
                                            );
                                    }),
                                  ),
                                ),
                              )
                            ],
                          ),

                          // Bundle
                          // Column(
                          //   children: [
                          //     HomeWidget.titleAndMore(appText.latestBundles, onTapViewAll: (){
                          //       locator<FilterCourseProvider>().clearFilter();
                          //       locator<FilterCourseProvider>().bundleCourse = true;
                          //       nextRoute(FilterCategoryPage.pageName);
                          //     }),
                          //
                          //     SizedBox(
                          //       width: getSize().width,
                          //       child: SingleChildScrollView(
                          //         physics: const BouncingScrollPhysics(),
                          //         padding: padding(),
                          //         scrollDirection: Axis.horizontal,
                          //         child: Row(
                          //           children: List.generate( isLoadingBundleData ? 3 : bundleData.length, (index) {
                          //             return isLoadingBundleData
                          //               ? courseItemShimmer()
                          //               : courseItem(
                          //                   bundleData[index]
                          //                 );
                          //           }),
                          //         ),
                          //       ),
                          //     )
                          //
                          //   ],
                          // ),

                          // Best Rated
                          // Column(
                          //   children: [
                          //     HomeWidget.titleAndMore(appText.bestRated,
                          //         onTapViewAll: () {
                          //       locator<FilterCourseProvider>().clearFilter();
                          //       locator<FilterCourseProvider>().sort =
                          //           'best_rates';
                          //       nextRoute(FilterCategoryPage.pageName);
                          //     }),
                          //     SizedBox(
                          //       width: getSize().width,
                          //       child: SingleChildScrollView(
                          //         physics: const BouncingScrollPhysics(),
                          //         padding: padding(),
                          //         scrollDirection: Axis.horizontal,
                          //         child: Row(
                          //           children: List.generate(
                          //               isLoadingBestRatedListData
                          //                   ? 3
                          //                   : bestRatedListData.length,
                          //               (index) {
                          //             return isLoadingBestRatedListData
                          //                 ? courseItemShimmer()
                          //                 : courseItem(
                          //                     bestRatedListData[index]);
                          //           }),
                          //         ),
                          //       ),
                          //     )
                          //   ],
                          // ),




// My Courses Section
if (purchases.isNotEmpty || isLoadingPurchaseCourse) ...{
  Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      HomeWidget.titleAndMore(appText.myCourses, isViewAll: false),
      SizedBox(
        width: getSize().width,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: padding(),
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(
              isLoadingPurchaseCourse ? 3 : purchases.length,
              (index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 15),
                  child: isLoadingPurchaseCourse
                      ? courseItemShimmer()
                      : courseItem(
                          purchases[index].webinar!, // تأكد أن هذا موجود في النموذج
                        ),
                );
              },
            ),
          ),
        ),
      )
    ],
  ),
},





                          /* Image Slider 
                
                                  // Image Slider
                                  Column(
                                    children: [
                                      // slider
                                      SizedBox(
                                        width: getSize().width,
                                        height: 200,
                                        child: PageView.builder(
                                          itemCount: 3,
                                          controller: adSliderPageController,
                                          onPageChanged: (value) {
                                            setState(() {
                                              currentAdSliderIndex = value;
                                            });
                                          },
                                          physics: const BouncingScrollPhysics(),
                                          itemBuilder: (context, index) {
                                            return HomeWidget.sliderItem('https://anthropologyandculture.com/wp-content/uploads/2021/03/61632315.jpg',(){
                
                                            });
                                          },
                                        ),
                                      ),
                
                                      space(16),
                
                                      // indecator
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          ...List.generate(3, (index) {
                                            return AnimatedContainer(
                                              duration: const Duration(milliseconds: 300),
                                              width: currentAdSliderIndex == index ? 16 : 7,
                                              height: 7,
                                              margin: padding(horizontal: 2),
                                              decoration: BoxDecoration(
                                                color: green77(),
                                                borderRadius: borderRadius()
                                              ),
                                            );
                
                                          }),
                                        ],
                                      ),
                
                                    ],
                                  ),
                                  */

                          space(22),

                          // by spending points
                          // Container(
                          //   padding: padding(horizontal: 16),
                          //   margin: padding(),
                          //   width: getSize().width,
                          //   height: 165,
                          //   decoration: BoxDecoration(
                          //     color: Colors.white,
                          //     borderRadius: borderRadius(),
                          //   ),
                          //   child: Row(
                          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //     children: [
                          //       Column(
                          //         crossAxisAlignment: CrossAxisAlignment.start,
                          //         mainAxisAlignment: MainAxisAlignment.center,
                          //         children: [
                          //           Text(
                          //             appText.freeCourses,
                          //             style: style20Bold(),
                          //           ),
                          //           space(4),
                          //           Text(
                          //             appText.bySpendingPoints,
                          //             style: style12Regular()
                          //                 .copyWith(color: greyB2),
                          //           ),
                          //           space(8),
                          //           button(
                          //               onTap: () {
                          //                 locator<FilterCourseProvider>()
                          //                     .clearFilter();
                          //                 locator<FilterCourseProvider>()
                          //                     .rewardCourse = true;
                          //                 nextRoute(
                          //                     FilterCategoryPage.pageName);
                          //               },
                          //               width: 75,
                          //               height: 32,
                          //               text: appText.view,
                          //               bgColor: mainColor(),
                          //               textColor: Colors.white,
                          //               raduis: 10)
                          //         ],
                          //       ),
                          //       SvgPicture.asset(AppAssets.pointsMedalSvg)
                          //     ],
                          //   ),
                          // ),

                          // space(10),

                          // // Best Selling
                          // Column(
                          //   children: [
                          //     HomeWidget.titleAndMore(appText.bestSelling, onTapViewAll: (){
                          //       locator<FilterCourseProvider>().clearFilter();
                          //       locator<FilterCourseProvider>().sort = 'bestsellers';
                          //       nextRoute(FilterCategoryPage.pageName);
                          //     }),
                          //
                          //     SizedBox(
                          //       width: getSize().width,
                          //       child: SingleChildScrollView(
                          //         physics: const BouncingScrollPhysics(),
                          //         padding: padding(),
                          //         scrollDirection: Axis.horizontal,
                          //         child: Row(
                          //           children: List.generate( isLoadingBestSellingListData ? 3 : bestSellingListData.length, (index) {
                          //             return isLoadingBestSellingListData
                          //               ? courseItemShimmer()
                          //               : courseItem(
                          //                   bestSellingListData[index]
                          //                 );
                          //           }),
                          //         ),
                          //       ),
                          //     )
                          //
                          //   ],
                          // ),
                          //

                          if (isLoadingDiscountListData ||
                              discountListData.isNotEmpty) ...{
                            // Discounted Classes
                            Column(
                              children: [
                                HomeWidget.titleAndMore(
                                    appText.discountedClasses,
                                    onTapViewAll: () {
                                  locator<FilterCourseProvider>().clearFilter();
                                  locator<FilterCourseProvider>().discount =
                                      true;
                                  nextRoute(FilterCategoryPage.pageName);
                                }),
                                SizedBox(
                                  width: getSize().width,
                                  child: SingleChildScrollView(
                                    physics: const BouncingScrollPhysics(),
                                    padding: padding(),
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: List.generate(
                                          isLoadingDiscountListData
                                              ? 3
                                              : discountListData.length,
                                          (index) {
                                        return isLoadingDiscountListData
                                            ? courseItemShimmer()
                                            : courseItem(
                                                discountListData[index],
                                              );
                                      }),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          },

                          // // Free Classes
                          // Column(
                          //   children: [
                          //     HomeWidget.titleAndMore(appText.freeClasses, onTapViewAll: (){
                          //       locator<FilterCourseProvider>().clearFilter();
                          //       locator<FilterCourseProvider>().free = true;
                          //       nextRoute(FilterCategoryPage.pageName);
                          //     }),
                          //
                          //     SizedBox(
                          //       width: getSize().width,
                          //       child: SingleChildScrollView(
                          //         physics: const BouncingScrollPhysics(),
                          //         padding: padding(),
                          //         scrollDirection: Axis.horizontal,
                          //         child: Row(
                          //           children: List.generate( isLoadingFreeListData ? 3 : freeListData.length, (index) {
                          //             return isLoadingFreeListData
                          //               ? courseItemShimmer()
                          //               : courseItem(
                          //                   freeListData[index]
                          //                 );
                          //           }),
                          //         ),
                          //       ),
                          //     )
                          //
                          //   ],
                          // ),
                          //
                          //

                          space(150),
                        ],
                      ),
                    )
                  ],
                ))
              ],
            ),
          ),
        );
      }));
    });
  }
}
