import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../constants.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        children: [
          // Full Name Field
          TextFormField(
            key: const Key('nameField'),
            controller: widget.nameController,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.name],
            onFieldSubmitted: (_) =>
                FocusScope.of(context).requestFocus(_emailFocusNode),
            decoration: InputDecoration(
              hintText: "Full name",
              prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(vertical: defaultPadding * 0.75),
                child: SvgPicture.asset(
                  "assets/icons/User.svg",
                  height: 24,
                  width: 24,
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.3),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: defaultPadding),

          // Email Field
          TextFormField(
            key: const Key('signUpEmailField'),
            controller: widget.emailController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
              if (!emailRegex.hasMatch(value)) {
                return 'Enter a valid email address';
              }
              return null;
            },
            keyboardType: TextInputType.emailAddress,
            textCapitalization: TextCapitalization.none,
            autofillHints: const [AutofillHints.email],
            textInputAction: TextInputAction.next,
            focusNode: _emailFocusNode,
            onFieldSubmitted: (_) =>
                FocusScope.of(context).requestFocus(_passwordFocusNode),
            decoration: InputDecoration(
              hintText: "Email address",
              prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(vertical: defaultPadding * 0.75),
                child: SvgPicture.asset(
                  "assets/icons/Message.svg",
                  height: 24,
                  width: 24,
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.3),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: defaultPadding),

          // Password Field
          TextFormField(
            key: const Key('signUpPasswordField'),
            controller: widget.passwordController,
            validator: (value) {
              if (value == null || value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
            obscureText: _obscurePassword,
            enableSuggestions: false,
            autocorrect: false,
            autofillHints: const [AutofillHints.newPassword],
            textInputAction: TextInputAction.next,
            focusNode: _passwordFocusNode,
            onFieldSubmitted: (_) =>
                FocusScope.of(context).requestFocus(_confirmPasswordFocusNode),
            decoration: InputDecoration(
              hintText: "Password",
              prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(vertical: defaultPadding * 0.75),
                child: SvgPicture.asset(
                  "assets/icons/Lock.svg",
                  height: 24,
                  width: 24,
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.3),
                    BlendMode.srcIn,
                  ),
                ),
              ),
              suffixIcon: IconButton(
                tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey.withOpacity(0.6),
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
          ),

          const SizedBox(height: defaultPadding),

          // Confirm Password Field
          TextFormField(
            key: const Key('confirmPasswordField'),
            controller: widget.confirmPasswordController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }
              if (value != widget.passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
            obscureText: _obscureConfirmPassword,
            enableSuggestions: false,
            autocorrect: false,
            autofillHints: const [AutofillHints.newPassword],
            textInputAction: TextInputAction.done,
            focusNode: _confirmPasswordFocusNode,
            decoration: InputDecoration(
              hintText: "Confirm password",
              prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(vertical: defaultPadding * 0.75),
                child: SvgPicture.asset(
                  "assets/icons/Lock.svg",
                  height: 24,
                  width: 24,
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.3),
                    BlendMode.srcIn,
                  ),
                ),
              ),
              suffixIcon: IconButton(
                tooltip: _obscureConfirmPassword ? 'Show password' : 'Hide password',
                icon: Icon(
                  _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey.withOpacity(0.6),
                ),
                onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
