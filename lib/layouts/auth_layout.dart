import 'package:flutter/material.dart';
import 'package:wifiber/components/app_logo.dart';
import 'package:wifiber/components/system_ui_wrapper.dart';
import 'package:wifiber/config/app_colors.dart';
import 'package:wifiber/helpers/system_ui_helper.dart';

class AuthLayout extends StatefulWidget {
  final Widget? child;
  final Widget? header;
  final Widget? footer;

  const AuthLayout({super.key, this.child, this.header, this.footer});

  @override
  State<AuthLayout> createState() => _AuthLayoutState();
}

class _AuthLayoutState extends State<AuthLayout> {
  @override
  Widget build(BuildContext context) {
    final appTheme = Theme.of(context);
    final canPop = ModalRoute.of(context)?.canPop ?? false;

    return SystemUiWrapper(
      style: SystemUiHelper.duotone(
        statusBarColor: AppColors.primary,
        navigationBarColor: appTheme.colorScheme.surface,
      ),
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                Stack(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 48),
                      child: Center(
                        child: AppLogo(logoType: LogoType.white),
                      ),
                    ),
                    if (canPop)
                      Positioned(
                        left: 16,
                        top: 72,
                        child: IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24.0),
                        topRight: Radius.circular(24.0),
                      ),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: constraints.maxHeight.isFinite
                                ? BoxConstraints(minHeight: constraints.maxHeight)
                                : const BoxConstraints(),
                            child: IntrinsicHeight(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (widget.header != null) ...[
                                    widget.header!,
                                    const SizedBox(height: 16),
                                  ],
                                  if (widget.child != null) widget.child!,
                                  if (widget.footer != null) ...[
                                    const Spacer(),
                                    widget.footer!,
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}