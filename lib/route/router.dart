import 'package:flutter/material.dart';
import 'package:shop/entry_point.dart';
import 'package:shop/models/param_product.dart';
import 'package:shop/screens/my_product/views/my_product_screen.dart';
import 'package:shop/screens/product/create/create_product_screen.dart';
import 'package:shop/screens/product/views/product_details_screen.dart';
import 'package:shop/screens/profile/edit/change_password_screen.dart';
import 'package:shop/screens/profile/edit/edit_user_screen.dart';

import '../screens/home/all_product/all_product_screen.dart';
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
    case allProductScreen:
      return MaterialPageRoute(
        builder: (context) {
          return const AllProductScreen();
        },
      );
    case homeScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const HomeScreen(),
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
    case editProfile:
      return MaterialPageRoute(
        builder: (context) => EditUserScreen(),
      );
    case changePassword:
      return MaterialPageRoute(
        builder: (context) => ChangePasswordScreen(),
      );
    case userInfoScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const UserInfoScreen(),
      );
    default:
      return MaterialPageRoute(
        // Make a screen for undefine
        builder: (context) => const OnBordingScreen(),
      );
  }
}
