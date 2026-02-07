import 'package:flutter/material.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/theme/app_colors.dart';

/// Página de política de privacidad in-app
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(s.privacyPolicy),
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              _SectionTitle(s.privacySection1Title),
              _Body(s.privacySection1Body),

              _SectionTitle(s.privacySection2Title),
              _Body(s.privacySection2Body),

              _SectionTitle(s.privacySection3Title),
              _Body(s.privacySection3Body),

              _SectionTitle(s.privacySection4Title),
              _Body(s.privacySection4Body),

              _SectionTitle(s.privacySection5Title),
              _Body(s.privacySection5Body),

              _SectionTitle(s.privacySection6Title),
              _Body(s.privacySection6Body),

              _SectionTitle(s.privacySection7Title),
              _Body(s.privacySection7Body),

              const SizedBox(height: 16),
              Text(
                s.privacyLastUpdated,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 6),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: AppColors.primaryLight,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final String text;
  const _Body(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: AppColors.textSecondary,
        height: 1.6,
      ),
    );
  }
}
