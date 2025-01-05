import 'package:flutter/material.dart';
import 'package:shop/entry_point.dart';
import 'package:shop/models/param_product.dart';
import 'package:shop/screens/my_product/views/my_product_screen.dart';
import 'package:shop/screens/product/create/create_product_screen.dart';
import 'package:shop/screens/product/views/product_details_screen.dart';

import '../screens/product/update/update_product_screen.dart';
import 'screen_export.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case onbordingScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const OnBordingScreen(),
      );
    case logInScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      );
    case signUpScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const SignUpScreen(),
      );
    case productDetailsScreenRoute:
      return MaterialPageRoute(
        builder: (context) {
          ParamProduct paramProduct = settings.arguments as ParamProduct;
          return ProductDetailsScreen(
            productId: paramProduct.productId,
            collection: paramProduct.collection,
              callBack: paramProduct?.callBack,
          );
        },
      );
    case createProduct:
      return MaterialPageRoute(
        builder: (context) {
          return CreateProductScreen();
        },
      );
    case updateProduct:
      return MaterialPageRoute(
        builder: (context) {
          final productId = settings.arguments as String;
          return UpdateProductScreen(productId: productId);
        },
      );

    case homeScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      );

    case discoverScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const DiscoverScreen(),
      );
    case myProductScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const MyProductScreen(),
      );
    case entryPointScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const EntryPoint(),
      );
    case profileScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const UserInfoScreen(),
      );
    case userInfoScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const UserInfoScreen(),
      );
    case preferencesScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const PreferencesScreen(),
      );
    default:
      return MaterialPageRoute(
        // Make a screen for undefine
        builder: (context) => const OnBordingScreen(),
      );
  }
}
