import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:background_eraser/core/shared/widgets/custom_scaffold.dart';
import 'package:background_eraser/core/shared/widgets/custom_popup.dart';
import 'package:background_eraser/core/shared/widgets/custom_snackbar.dart';
import 'package:background_eraser/core/shared/widgets/cubit/snackbar_cubit.dart';
import 'package:background_eraser/core/bloc/bloc_providers.dart';
import 'package:background_eraser/features/profile/widgets/profile_app_bar.dart';
import 'package:background_eraser/features/profile/widgets/profile_settings_card.dart';
import 'package:background_eraser/features/profile/widgets/profile_info_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _handleClearCache(BuildContext context) {
    CustomPopup.show(
      context: context,
      title: 'Clear cache',
      message:
          'Are you sure you want to clear all cached data? This action cannot be undone.',
      confirmText: 'Clear',
      cancelText: 'Cancel',
      isDanger: true,
      onConfirm: () {
        // TODO: Add clear cache logic
        CustomSnackbar.show(
          context: context,
          message: 'Cache cleared successfully',
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<SnackbarCubit>(),
      child: CustomScaffold(
        body: SafeArea(
          child: Stack(
            children: [
              ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  const ProfileAppBar(title: 'Profile'),
                  Padding(
                    padding: const EdgeInsets.only(top: 40, bottom: 20),
                    child: ProfileSettingsCard(
                      title: 'App Information',
                      icon: Icons.info_outline,
                      subtitle: 'Version 1.0.0',
                      onTap: () {
                        // TODO: Show app info
                      },
                    ),
                  ),
                  // App Information Section
                  ListView.separated(
                    itemCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    separatorBuilder: (context, index) =>
                        const Divider(color: Colors.white12, height: 1),
                    itemBuilder: (context, index) {
                      final items = [
                        ProfileInfoCard(
                          title: 'App name',
                          icon: Icons.apps,
                          value: 'Background Eraser',
                        ),
                        ProfileInfoCard(
                          title: 'Version',
                          icon: Icons.tag,
                          value: 'v1.0.0',
                        ),
                        ProfileSettingsCard(
                          title: 'About us',
                          icon: Icons.info,
                          onTap: () {
                            // TODO: Show about us
                          },
                        ),
                      ];
                      return items[index];
                    },
                  ),
                  const SizedBox(height: 20),

                  // Storage & Cache Section
                  ListView.separated(
                    itemCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    separatorBuilder: (context, index) =>
                        const Divider(color: Colors.white12, height: 1),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return ProfileInfoCard(
                          title: 'Saved images',
                          icon: Icons.photo_library,
                          value: '12',
                        );
                      } else if (index == 1) {
                        return ProfileInfoCard(
                          title: 'Used storage',
                          icon: Icons.storage,
                          value: '45.2 MB',
                        );
                      } else {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: ProfileActionCard(
                            title: 'Clear cache',
                            icon: Icons.delete_outline,
                            onPressed: () => _handleClearCache(context),
                            isDanger: true,
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 20),

                  // Preferences Section
                  ListView.separated(
                    itemCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    separatorBuilder: (context, index) =>
                        const Divider(color: Colors.white12, height: 1),
                    itemBuilder: (context, index) {
                      final items = [
                        ProfileSettingsCard(
                          title: 'Save history',
                          icon: Icons.history,
                          onTap: null, // Disabled
                        ),
                        ProfileSettingsCard(
                          title: 'Auto-save results',
                          icon: Icons.save_alt,
                          onTap: null, // Disabled
                        ),
                      ];
                      return Opacity(opacity: 0.5, child: items[index]);
                    },
                  ),
                  const SizedBox(height: 20),

                  // Legal Section
                  ListView.separated(
                    itemCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    separatorBuilder: (context, index) =>
                        const Divider(color: Colors.white12, height: 1),
                    itemBuilder: (context, index) {
                      final items = [
                        ProfileSettingsCard(
                          title: 'Privacy Policy',
                          icon: Icons.privacy_tip,
                          onTap: () {
                            // TODO: Navigate to privacy policy
                          },
                        ),
                        ProfileSettingsCard(
                          title: 'Terms of Service',
                          icon: Icons.description,
                          onTap: () {
                            // TODO: Navigate to terms of service
                          },
                        ),
                      ];
                      return items[index];
                    },
                  ),
                  const SizedBox(height: 150),
                ],
              ),
              const CustomSnackbar(),
            ],
          ),
        ),
      ),
    );
  }
}
