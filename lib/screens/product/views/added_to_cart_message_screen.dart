import 'package:flutter/material.dart';
import 'package:ecommerce/constants.dart';
import 'package:ecommerce/route/route_constants.dart';

class AddedToCartMessageScreen extends StatelessWidget {
  const AddedToCartMessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
          child: Column(
            children: [
              const Spacer(),
              Image.asset(
                isLight
                    ? "assets/Illustration/success.png"
                    : "assets/Illustration/success_dark.png",
                height: MediaQuery.of(context).size.height * 0.3,
              ),
              const Spacer(flex: 2),
              Text(
                "Added to cart",
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall!
                    .copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: defaultPadding / 2),
              const Text(
                "Click the checkout button to complete the purchase process.",
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 2),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                onPressed: () {
                  // Pop back to entry point or home
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    entryPointScreenRoute,
                    (route) => false,
                  );
                },
                child: const Text("Continue shopping"),
              ),
              const SizedBox(height: defaultPadding),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                onPressed: () {
                  // Push to Cart Screen directly
                  Navigator.pushNamed(context, cartScreenRoute);
                },
                child: const Text("Checkout"),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
