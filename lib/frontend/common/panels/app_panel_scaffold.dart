import 'package:flutter/material.dart';

import '../theme/app_text_styles.dart';

class AppPanelScaffold extends StatelessWidget {
  const AppPanelScaffold({
    required this.title,
    required this.subtitle,
    required this.child,
    super.key,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          MediaQuery.viewInsetsOf(context).bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.title),
              const SizedBox(height: 6),
              Text(subtitle, style: AppTextStyles.caption),
              const SizedBox(height: 18),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
