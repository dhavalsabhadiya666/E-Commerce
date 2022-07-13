import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:prabodham/data/api_response_model.dart';
import 'package:prabodham/data/exceptions.dart';
import 'package:prabodham/data/services/category_api.dart';
import 'package:prabodham/global/functions/global_functions.dart';
import 'package:prabodham/global/variable/custom_app_theme.dart';
import 'package:prabodham/model/category.dart';
import 'package:prabodham/screen/product_catalog_screen.dart';
import 'package:prabodham/screen/search_screen.dart';
import 'package:prabodham/widgets/component_widgets/loader.dart';
import 'package:prabodham/widgets/custom_app_bar.dart';
import 'package:prabodham/widgets/custom_image.dart';
import 'package:prabodham/widgets/dialog_widget/show_custom_dialog.dart';

class ShopScreen extends StatefulWidget {
  @override
  _ShopScreenState createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  CategoryApi _categoryApi = CategoryApi();
  List<Category> categoryList = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    print("Shop Screen");
    getCategories(context: context);
  }

  void setLoading(bool value) {
    if (mounted)
      setState(() {
        isLoading = value;
      });
  }

  Future<void> getCategories({@required BuildContext context}) async {
    Functions.checkConnectivity().then((value) async {
      if (value != null && value == true) {
        FormData data = new FormData.fromMap({});
        setLoading(true);
        try {
          ApiResponseModel apiResponse =
              await _categoryApi.getCategory(context: context, data: data);
          print("Get Categories Api response data :- ");
          print(apiResponse.response);

          if (apiResponse.success == true && apiResponse.response != null) {
            var list = apiResponse.response as List;
            categoryList = list.map((element) {
              return Category.fromJson(element);
            }).toList();
            setLoading(false);
          } else {
            setLoading(false);
            Functions.toast(apiResponse.message);
          }
        } catch (e) {
          setLoading(false);
          print(e.toString());
          final errorMessage = DioExceptions.fromDioError(e).toString();
          showCustomDialog(context, 'Error', errorMessage);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: CustomAppBar(
            title: Text("Categories"),
            centerTitle: true,
            elevation: 5,
            leading: Container(),
            actions: [
              GestureDetector(
                onTap: () {
                  print("Search");
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SearchScreen()));
                },
                child: Container(
                  height: 40,
                  padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                  margin: EdgeInsets.only(top: 10, right: 15, bottom: 10),
                  alignment: Alignment.center,
                  child: Icon(Icons.search),
                ),
              ),
            ]),
        backgroundColor: Theme.of(context).canvasColor,
        body: Container(
          decoration: BoxDecoration(
              // image: DecorationImage(
              //     image: AssetImage(Images.SPLASH_BG), fit: BoxFit.fill)
              ),
          child: Stack(
            children: [
              GridView.builder(
                padding: EdgeInsets.all(30),
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1,
                  mainAxisSpacing: 30,
                  crossAxisSpacing: 30.0,
                  mainAxisExtent: 215,
                ),
                scrollDirection: Axis.vertical,
                itemCount: categoryList.length,
                itemBuilder: (BuildContext context, int index) {
                  return categoryCard(categoryList[index]);
                },
              ),
              Container(
                child: isLoading
                    ? Loader(
                        bgColor: CustomAppTheme.white,
                        loaderColor: Theme.of(context).primaryColor,
                      )
                    : Container(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget categoryCard(Category category) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ProductCatalogScreen(
                      category: category,
                    )));
      },
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Card(
                margin: EdgeInsets.all(0),
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                elevation: 2,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                        child: CustomImage(
                          imgURL: category.categoryImage,
                          height: 140,
                        ),
                        // child: CustomImage(
                        //   imgURL: category.categoryImage,
                        //   fit: BoxFit.fill,
                        // ),
                      ),
                      Container(
                        padding:
                            EdgeInsets.only(bottom: 15, left: 10, right: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        child: FittedBox(
                          child: Text(
                            category.categoryName.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.body1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              height: 32,
              width: 25,
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      topRight: Radius.circular(12))),
            ),
          )
        ],
      ),
    );
  }
}
