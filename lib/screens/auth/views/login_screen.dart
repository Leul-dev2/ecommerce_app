import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import 'package:ecommerce/constants.dart';
import 'package:ecommerce/route/route_constants.dart';
import 'components/login_form.dart';
import 'package:ecommerce/providers/login_provider.dart'; // Adjust if needed

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }

  Future<void> handleEmailLogin(LoginProvider loginProvider) async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        await loginProvider.signInWithEmailPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            entryPointScreenRoute,
            (route) => false,
          );
        }
      } catch (e) {
        debugPrint('Email login error: $e');
        showError(e.toString().replaceAll('Exception: ', ''));
      }
    }
  }

  Future<void> handleGoogleLogin(LoginProvider loginProvider) async {
    try {
      await loginProvider.signInWithGoogle();

      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          entryPointScreenRoute,
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint('Google login error: $e');
      showError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Consumer<LoginProvider>(
        builder: (context, loginProvider, child) {
          return Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    Lottie.asset(
                      'assets/animation/loganime.json',
                      width: size.width,
                      height: size.height * 0.35,
                      fit: BoxFit.contain,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(defaultPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Welcome back!",
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: defaultPadding / 2),
                          const Text(
                            "Log in with your data that you entered during your registration.",
                          ),
                          const SizedBox(height: defaultPadding),
                          LogInForm(
                            formKey: _formKey,
                            emailController: _emailController,
                            passwordController: _passwordController,
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  forgotPasswordScreenRoute,
                                );
                              },
                              child: const Text("Forgot password?"),
                            ),
                          ),
                          SizedBox(
                            height: size.height > 700
                                ? size.height * 0.05
                                : defaultPadding,
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              key: const Key('emailLoginButton'),
                              onPressed: loginProvider.isLoading
                                  ? null
                                  : () => handleEmailLogin(loginProvider),
                              child: const Text("Log in"),
                            ),
                          ),
                          const SizedBox(height: defaultPadding),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              key: const Key('googleLoginButton'),
                              onPressed: loginProvider.isLoading
                                  ? null
                                  : () => handleGoogleLogin(loginProvider),
                              icon: Image.asset(
                                'assets/icons/google.png',
                                height: 24,
                                width: 24,
                              ),
                              label: const Text("Sign in with Google"),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Don't have an account?"),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    signUpScreenRoute,
                                  );
                                },
                                child: const Text("Sign up"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (loginProvider.isLoading)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
