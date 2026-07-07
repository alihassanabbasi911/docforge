// lib/screens/onboarding/onboarding_screen.dart
import 'package:FlexScan/features/utils/open_links.dart';
import 'package:FlexScan/links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../router/app_router.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;
  bool _acceptedTerms = false;

  static const _pages = [
    _OnboardingPage(
      tag: 'CAPTURE',
      title: 'Scan any\ndocument',
      subtitle:
          'Point your camera at any paper, receipt, or contract — FlexScan captures and processes it instantly.',
      features: [],
    ),
    _OnboardingPage(
      tag: 'EXTRACT',
      title: 'Extract text\nwith precision',
      subtitle:
          'Industry-leading OCR engine accurately extracts text in English',
      features: [],
    ),
    _OnboardingPage(
      tag: 'PROCESS',
      title: 'Process any\nformat',
      subtitle:
          'Process your documents in PDF, DOCX, or TXT and share the text anywhere in seconds.',
      features: [],
    ),
  ];

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOut,
      );
    } else {
      if (_acceptedTerms) {
        context.go(AppRoutes.login);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Please accept the terms and conditions to continue.'),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: AppRadius.borderSm,
                        ),
                        child: const Icon(
                          Icons.description_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'FlexScan',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () => _acceptedTerms
                        ? context.go(AppRoutes.login)
                        : ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Please accept the terms and conditions to continue.'),
                            ),
                          ),
                    child: const Text('Skip'),
                  ),
                ],
              ),
            ),

            // Page view
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _pages.length,
                itemBuilder: (ctx, i) => _OnboardingPageView(
                  page: _pages[i],
                  index: i,
                ),
              ),
            ),

            // Bottom section
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: i == _currentPage ? 24 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: i == _currentPage
                              ? AppColors.primary
                              : (isDark
                                  ? AppColors.darkSurface3
                                  : AppColors.neutral300),
                          borderRadius: AppRadius.borderFull,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _TermsCheckbox(
                    accepted: _acceptedTerms,
                    onChanged: (v) => setState(() => _acceptedTerms = v),
                    onTermsTap: () async {
                      await openLink(AppLinks.terms);
                    },
                    onPrivacyTap: () async {
                      await openLink(AppLinks.privacy);
                    },
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _next,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppRadius.borderLg,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _currentPage == _pages.length - 1
                              ? 'Get Started'
                              : 'Continue',
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, size: 18),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage {
  final String tag;
  final String title;
  final String subtitle;
  final List<dynamic> features;

  const _OnboardingPage({
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.features,
  });
}

class _OnboardingPageView extends StatelessWidget {
  final _OnboardingPage page;
  final int index;

  const _OnboardingPageView({
    required this.page,
    required this.index,
  });

  static const _illustrationData = [
    _IllustrationData(
      bgColor: Color(0xFFEEF2FF),
      darkBgColor: Color(0xFF1E1B4B),
      icon: Icons.camera_alt_rounded,
      iconColor: AppColors.primary,
      features: [
        _FeatureItem(Icons.camera_enhance_rounded, 'High-quality capture',
            'Auto edge detection & deskew', AppColors.primary),
        _FeatureItem(Icons.flash_on_rounded, 'Smart flash control',
            'Optimized for all light conditions', Color(0xFFF59E0B)),
        // _FeatureItem(Icons.crop_free_rounded, 'Auto crop & align',
        //     'Precise document boundaries', Color(0xFF10B981)),
      ],
    ),
    _IllustrationData(
      bgColor: Color(0xFFF0FDF4),
      darkBgColor: Color(0xFF064E3B),
      icon: Icons.text_fields_rounded,
      iconColor: Color(0xFF059669),
      features: [
        _FeatureItem(
            Icons.translate_rounded,
            'Multi-language OCR (Coming Soon)',
            'English, Urdu, Arabic & more ',
            Color(0xFF059669)),
        _FeatureItem(
            Icons.auto_fix_high_rounded,
            'Smart correction by AI (Coming Soon)',
            'Auto-fix common OCR errors',
            AppColors.primary),
        _FeatureItem(Icons.format_align_left_rounded, 'Layout preservation',
            'Maintains document structure', Color(0xFFF59E0B)),
      ],
    ),
    _IllustrationData(
      bgColor: Color(0xFFFFF7ED),
      darkBgColor: Color(0xFF7C2D12),
      icon: Icons.swap_horiz_rounded,
      iconColor: Color(0xFFF59E0B),
      features: [
        _FeatureItem(Icons.picture_as_pdf_rounded, 'PDF processing',
            'Searchable, compressed PDFs', AppColors.pdfColor),
        _FeatureItem(Icons.article_rounded, 'Word documents',
            'Editable DOCX with formatting', AppColors.docxColor),
        _FeatureItem(Icons.share_rounded, 'Instant sharing',
            'Share text via any app or cloud', AppColors.primary),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Safety guard (prevents crash)
    if (index >= _illustrationData.length) {
      return const SizedBox();
    }

    final data = _illustrationData[index];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Illustration
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: isDark ? data.darkBgColor : data.bgColor,
                borderRadius: AppRadius.borderXxl,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: data.iconColor.withAlpha(38), // 0.15 * 255
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      data.icon,
                      color: data.iconColor,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ...data.features.map(
                    (f) => Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 8),
                      child: OnboardingFeatureRow(
                        icon: f.icon,
                        title: f.title,
                        description: f.description,
                        color: f.color,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Text
            Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: AppRadius.borderFull,
                  ),
                  child: Text(
                    page.tag,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.primary,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  page.title,
                  style: theme.textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  page.subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.7,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _IllustrationData {
  final Color bgColor;
  final Color darkBgColor;
  final IconData icon;
  final Color iconColor;
  final List<_FeatureItem> features;

  const _IllustrationData({
    required this.bgColor,
    required this.darkBgColor,
    required this.icon,
    required this.iconColor,
    required this.features,
  });
}

class _FeatureItem {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _FeatureItem(this.icon, this.title, this.description, this.color);
}

class _TermsCheckbox extends StatelessWidget {
  final bool accepted;
  final ValueChanged<bool> onChanged;
  final VoidCallback onTermsTap;
  final VoidCallback onPrivacyTap;

  const _TermsCheckbox({
    required this.accepted,
    required this.onChanged,
    required this.onTermsTap,
    required this.onPrivacyTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => onChanged(!accepted),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: accepted
              ? (isDark ? const Color(0xFF1E1B4B) : AppColors.primaryContainer)
              : (isDark ? AppColors.darkSurface2 : AppColors.neutral50),
          borderRadius: AppRadius.borderMd,
          border: Border.all(
            color: accepted
                ? AppColors.primary.withOpacity(0.5)
                : (isDark ? AppColors.darkSurface3 : AppColors.neutral200),
            width: accepted ? 1.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: Checkbox(
                value: accepted,
                onChanged: (v) => onChanged(v ?? false),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: theme.textTheme.bodySmall?.copyWith(height: 1.5),
                  children: [
                    const TextSpan(text: 'I agree to the '),
                    WidgetSpan(
                      child: GestureDetector(
                        onTap: onTermsTap,
                        child: Text(
                          'Terms of Service',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                            decorationColor: theme.colorScheme.primary,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const TextSpan(text: ' and '),
                    WidgetSpan(
                      child: GestureDetector(
                        onTap: onPrivacyTap,
                        child: Text(
                          'Privacy Policy',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                            decorationColor: theme.colorScheme.primary,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const TextSpan(text: '. Your data is safe with us.'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
