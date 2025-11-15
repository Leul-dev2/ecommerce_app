import 'package:flutter/material.dart';

import 'package:ecommerce/components/Banner/S/banner_s_style_1.dart';
import 'package:ecommerce/components/Banner/S/banner_s_style_5.dart';
import 'package:ecommerce/constants.dart';
import 'package:ecommerce/route/screen_export.dart';

import 'components/best_sellers.dart';
import 'components/flash_sale.dart';
import 'components/most_popular.dart';
import 'components/offer_carousel_and_categories.dart';
import 'components/popular_products.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Simulated refresh function (replace with actual logic as needed)
  Future<void> _refreshData() async {
    await Future.delayed(const Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    Theme.of(context);

    return Scaffold(
     
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              const SliverToBoxAdapter(child: OffersCarouselAndCategories()),
              const SliverToBoxAdapter(child: PopularProducts()),
              const SliverPadding(
                padding: EdgeInsets.symmetric(vertical: defaultPadding * 1.5),
                sliver: SliverToBoxAdapter(child: FlashSale()),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: defaultPadding),
                  child: BannerSStyle1(
                    title: "New \narrival",
                    subtitle: "SPECIAL OFFER",
                    discountPercent: 50,
                    press: () {
                      Navigator.pushNamed(context, onSaleScreenRoute);
                    },
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: BestSellers()),
              const SliverToBoxAdapter(child: MostPopular()),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: defaultPadding),
                  child: BannerSStyle5(
                    title: "Black \nfriday",
                    subtitle: "50% Off",
                    bottomText: "COLLECTION",
                    press: () {
                      Navigator.pushNamed(context, onSaleScreenRoute);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
