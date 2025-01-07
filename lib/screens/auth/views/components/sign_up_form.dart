import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../constants.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({
    super.key,
    required this.formKey,
  });

  final GlobalKey<FormState> formKey;

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  bool _passwordVisible = false; // Trạng thái mật khẩu

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        children: [
          // Trường Email
          TextFormField(
            onSaved: (email) {
              // Email
            },
            validator: emaildValidator.call,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: "Email address",
              prefixIcon: Padding(
                padding:
                const EdgeInsets.symmetric(vertical: defaultPadding * 0.75),
                child: SvgPicture.asset(
                  "assets/icons/Message.svg",
                  height: 24,
                  width: 24,
                  colorFilter: ColorFilter.mode(
                    Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .color!
                        .withOpacity(0.3),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: defaultPadding),
          // Trường Password
          TextFormField(
            onSaved: (pass) {
              // Password
            },
            validator: passwordValidator.call,
            obscureText: !_passwordVisible, // Xử lý ẩn/hiện mật khẩu
            decoration: InputDecoration(
              hintText: "Password",
              prefixIcon: Padding(
                padding:
                const EdgeInsets.symmetric(vertical: defaultPadding * 0.75),
                child: SvgPicture.asset(
                  "assets/icons/Lock.svg",
                  height: 24,
                  width: 24,
                  colorFilter: ColorFilter.mode(
                    Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .color!
                        .withOpacity(0.3),
                    BlendMode.srcIn,
                  ),
                ),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _passwordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Theme.of(context).primaryColor,
                ),
                onPressed: () {
                  setState(() {
                    _passwordVisible = !_passwordVisible; // Chuyển trạng thái
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
