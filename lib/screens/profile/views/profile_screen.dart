import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:ecommerce/route/route_constants.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;

        return Scaffold(
          backgroundColor: Colors.grey.shade100,
          body: Column(
            children: [
              _ProfileHero(
                name: user?.displayName ?? 'Guest',
                email: user?.email ?? 'guest@example.com',
                imageUrl: user?.photoURL,
                onAvatarTap: () {
                  Navigator.pushNamed(
                    context,
                    user != null ? userInfoScreenRoute : logInScreenRoute,
                  );
                },
                onEditTap: () {
                  Navigator.pushNamed(
                    context,
                    user != null ? userInfoScreenRoute : logInScreenRoute,
                  );
                },
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: ListView(
                    children: [
                      const _Section("Account"),
                      _MenuTile(
                        icon: 'assets/icons/Order.svg',
                        label: "Orders",
                        onTap: () => Navigator.pushNamed(context, orderListScreenRoute),
                      ),
                      _MenuTile(
                        icon: 'assets/icons/Wishlist.svg',
                        label: "Wishlist",
                        onTap: () => Navigator.pushNamed(context, WishlistScreenRoute),
                      ),
                      _MenuTile(
                        icon: 'assets/icons/Address.svg',
                        label: "Addresses",
                        onTap: () => Navigator.pushNamed(context, addressesScreenRoute),
                      ),
                      _MenuTile(
                        icon: 'assets/icons/card.svg',
                        label: "Payments",
                        onTap: () => Navigator.pushNamed(context, paymentScreenRoute),
                      ),
                       _MenuTile(
                        icon: 'assets/icons/Help.svg',
                        label: "preferences",
                        onTap: () => Navigator.pushNamed(context, preferencesScreenRoute),
                      ),
                      const _Section("Support"),
                      _MenuTile(
                        icon: 'assets/icons/Help.svg',
                        label: "Get Help",
                        onTap: () => Navigator.pushNamed(context, getHelpScreenRoute),
                      ),
                      
                      _MenuTile(
                        icon: 'assets/icons/FAQ.svg',
                        label: "FAQ",
                        onTap: () => Navigator.pushNamed(context, faqScreenRoute),
                      ),
                      const SizedBox(height: 30),
                      user != null
                          ? ElevatedButton.icon(
                              onPressed: () => _logout(context),
                              icon: const Icon(Icons.logout),
                              label: const Text("Log Out"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.error,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 50),
                              ),
                            )
                          : ElevatedButton.icon(
                              onPressed: () => Navigator.pushNamed(context, logInScreenRoute),
                              icon: const Icon(Icons.login),
                              label: const Text("Log In / Sign Up"),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 50),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, logInScreenRoute, (_) => false);
    }
  }
}

class _ProfileHero extends StatelessWidget {
  final String name;
  final String email;
  final String? imageUrl;
  final VoidCallback onAvatarTap;
  final VoidCallback onEditTap;

  const _ProfileHero({
    required this.name,
    required this.email,
    required this.imageUrl,
    required this.onAvatarTap,
    required this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 190,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 50),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF7C5CFC), Color(0xFF2861DE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: onAvatarTap,
            child: CircleAvatar(
              radius: 50,
             backgroundImage: (imageUrl != null && imageUrl!.isNotEmpty)
  ? NetworkImage(imageUrl!)
  : const AssetImage('assets/images/avatar.png') as ImageProvider,

            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: onEditTap,
                  child: Row(
                    children: const [
                      Icon(Icons.edit, color: Colors.white70, size: 18),
                      SizedBox(width: 4),
                      Text(
                        "Edit Profile",
                        style: TextStyle(
                          color: Colors.white70,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;

  const _Section(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;

  const _MenuTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: SvgPicture.asset(icon, height: 24, width: 24),
        title: Text(label),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
