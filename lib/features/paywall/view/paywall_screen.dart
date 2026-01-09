import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:talker_flutter/talker_flutter.dart';
import '../../../core/shared/widgets/custom_scaffold.dart';
import '../../../core/shared/widgets/custom_elevated_button.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/subscription/subscription_product.dart';
import '../../../core/bloc/bloc_providers.dart' show getIt;
import '../../../core/services/analytics/analytics_service.dart';
import '../../../core/subscription/apphud_service.dart';
import '../bloc/paywall_bloc.dart';
import '../bloc/paywall_event.dart';
import '../bloc/paywall_state.dart';

class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = PaywallBloc(
          appHudService: getIt<AppHudService>(),
          analyticsService: getIt<AnalyticsService>(),
          talker: getIt<Talker>(),
        );
        bloc.add(const PaywallLoadProducts());
        return bloc;
      },
      child: const _PaywallScreenContent(),
    );
  }
}

class _PaywallScreenContent extends StatelessWidget {
  const _PaywallScreenContent();

  @override
  Widget build(BuildContext context) {
    return BlocListener<PaywallBloc, PaywallState>(
      listener: (context, state) {
        if (state is PaywallPurchaseSuccess || state is PaywallRestoreSuccess) {
          context.pop(true);
        } else if (state is PaywallError) {
          // Показываем ошибку в SnackBar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'OK',
                textColor: Colors.white,
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
            ),
          );
        } else if (state is PaywallPurchasing) {
          // Можно показать индикатор загрузки, но он уже показывается в UI
        }
      },
      child: CustomScaffold(
        appBar: AppBar(
          title: const Text('Premium'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.pop(),
          ),
        ),
        body: SafeArea(
          child: BlocBuilder<PaywallBloc, PaywallState>(
            builder: (context, state) {
              if (state is PaywallLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is PaywallLoaded) {
                if (state.products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          'No products available',
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Please check your AppHud configuration',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        CustomElevatedButton(
                          text: 'Retry',
                          onPressed: () {
                            context.read<PaywallBloc>().add(const PaywallLoadProducts());
                          },
                        ),
                      ],
                    ),
                  );
                }
                return _buildPaywallContent(context, state.products);
              }

              if (state is PaywallError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        state.message,
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      CustomElevatedButton(
                        text: 'Retry',
                        onPressed: () {
                          context.read<PaywallBloc>().add(const PaywallLoadProducts());
                        },
                      ),
                    ],
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPaywallContent(BuildContext context, List<SubscriptionProduct> products) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 32),
          Text(
            'Unlock Premium',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Remove backgrounds without limits',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          ...products.map((product) => _buildProductCard(context, product)),
          const SizedBox(height: 24),
          CustomElevatedButton(
            text: 'Restore Purchases',
            onPressed: () {
              context.read<PaywallBloc>().add(const PaywallRestore());
            },
            transparent: true,
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, SubscriptionProduct product) {
    final isPurchasing = context.select<PaywallBloc, bool>(
      (bloc) => bloc.state is PaywallPurchasing &&
          (bloc.state as PaywallPurchasing).product.id == product.id,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.editPhotoBtnColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.white032Color,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            product.price,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.aquaColor,
                ),
          ),
          const SizedBox(height: 16),
          CustomElevatedButton(
            text: isPurchasing ? 'Processing...' : 'Subscribe',
            onPressed: isPurchasing
                ? null
                : () {
                    context.read<PaywallBloc>().add(PaywallPurchase(product));
                  },
            width: double.infinity,
          ),
        ],
      ),
    );
  }
}
