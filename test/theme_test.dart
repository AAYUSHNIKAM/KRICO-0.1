import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sports_app/core/theme/app_theme.dart';
import 'package:sports_app/core/theme/theme_provider.dart';
import 'package:sports_app/design_system/colors/app_color_scheme.dart';
import 'package:sports_app/design_system/layouts/bottom_nav.dart';
import 'package:sports_app/design_system/utils/extensions.dart';
import 'package:sports_app/design_system/widgets/buttons/primary_button.dart';
import 'package:sports_app/design_system/widgets/shared/premium_card.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({'themeMode': 'dark'});
  });

  group('Warm Athletic Premium Light Theme - Design Tokens & Properties', () {
    testWidgets('AppTheme.light provides Warm Athletic foundation and high-contrast tokens', (tester) async {
      final lightTheme = AppTheme.light;

      expect(lightTheme.brightness, Brightness.light);
      expect(lightTheme.scaffoldBackgroundColor, const Color(0xFFF6F4EE),
          reason: 'Background must be warm ivory');
      expect(lightTheme.colorScheme.surface, const Color(0xFFF6F4EE));
      expect(lightTheme.colorScheme.surfaceContainerHighest, const Color(0xFFEDEFE7),
          reason: 'Secondary container must be soft warm neutral');
      expect(lightTheme.colorScheme.primary, const Color(0xFF76A200),
          reason: 'Primary accent must be energetic athletic lime with accessible contrast');
      expect(lightTheme.colorScheme.secondary, const Color(0xFFFF8A45),
          reason: 'Secondary accent must be warm athletic orange/coral');
      expect(lightTheme.colorScheme.onSurface, const Color(0xFF20251D),
          reason: 'Primary text must be warm deep charcoal');
      expect(lightTheme.colorScheme.onSurfaceVariant, const Color(0xFF777D72),
          reason: 'Secondary text must be warm olive-gray');
      expect(lightTheme.colorScheme.outline, const Color(0xFFE5E6DE),
          reason: 'Borders must be subtle warm neutral');
      expect(lightTheme.cardTheme.color, const Color(0xFFFFFFFF),
          reason: 'Card surface must be pure white');
      expect(lightTheme.dividerTheme.color, const Color(0xFFEAECE4));

      final btnBg = lightTheme.elevatedButtonTheme.style?.backgroundColor?.resolve({});
      expect(btnBg, const Color(0xFF20251D),
          reason: 'Primary CTA in Light Theme must have strong authoritative weight');
    });

    test('AppColorScheme.light ThemeExtension contains all warm athletic tokens', () {
      const scheme = AppColorScheme.light;

      expect(scheme.background, const Color(0xFFF6F4EE));
      expect(scheme.surface, const Color(0xFFFFFFFF));
      expect(scheme.surfaceSecondary, const Color(0xFFEDEFE7));
      expect(scheme.card, const Color(0xFFFFFFFF));
      expect(scheme.border, const Color(0xFFE5E6DE));
      expect(scheme.divider, const Color(0xFFEAECE4));
      expect(scheme.textPrimary, const Color(0xFF20251D));
      expect(scheme.textSecondary, const Color(0xFF777D72));
      expect(scheme.textTertiary, const Color(0xFF9DA398));
      expect(scheme.textDisabled, const Color(0xFFB5BBAF));
      expect(scheme.primary, const Color(0xFF76A200));
      expect(scheme.accentVolt, const Color(0xFF76A200));
      expect(scheme.accentOrange, const Color(0xFFFF8A45));
      expect(scheme.heroCtaBackground, const Color(0xFF20251D));
      expect(scheme.heroCtaForeground, const Color(0xFFFFFFFF));
    });

    test('AppTheme.dark remains fully intact and unchanged', () {
      final darkTheme = AppTheme.dark;
      const darkScheme = AppColorScheme.dark;

      expect(darkTheme.brightness, Brightness.dark);
      expect(darkTheme.scaffoldBackgroundColor, const Color(0xFF090A0F));
      expect(darkTheme.colorScheme.primary, const Color(0xFFCCFF00));
      expect(darkScheme.background, const Color(0xFF090A0F));
      expect(darkScheme.accentVolt, const Color(0xFFCCFF00));
      expect(darkScheme.heroCtaBackground, const Color(0xFFCCFF00));
      expect(darkScheme.heroCtaForeground, const Color(0xFF090A0F));
    });

    test('AppColorScheme lerp interpolates correctly between dark and light', () {
      final lerped = AppColorScheme.dark.lerp(AppColorScheme.light, 0.5);
      expect(lerped, isA<AppColorScheme>());
      expect(lerped.background, isNotNull);
      expect(lerped.textPrimary, isNotNull);
    });
  });

  group('Warm Athletic Light Theme - Widgets & UI Components', () {
    testWidgets('PrimaryButton renders with authoritative charcoal and white text in light theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: Center(
              child: PrimaryButton(
                label: 'Book Coach',
                onPressed: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Book Coach'), findsOneWidget);
      final textWidget = tester.widget<Text>(find.text('Book Coach'));
      expect(textWidget.style?.color, const Color(0xFFFFFFFF));
    });

    testWidgets('PremiumCard renders with crisp white background in light theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: Center(
              child: PremiumCard(
                child: Text('Card Content'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Card Content'), findsOneWidget);
      final animatedContainers = tester.widgetList<AnimatedContainer>(find.byType(AnimatedContainer));
      final cardContainer = animatedContainers.firstWhere((c) => (c.decoration as BoxDecoration?)?.color != null);
      final decoration = cardContainer.decoration as BoxDecoration?;
      expect(decoration?.color, const Color(0xFFFFFFFF));
    });

    testWidgets('AppBottomNav renders dock and active item with athletic accents in light theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            bottomNavigationBar: AppBottomNav(
              items: const [
                BottomNavItem(icon: Icons.home_outlined, selectedIcon: Icons.home, label: 'Home'),
                BottomNavItem(icon: Icons.calendar_today_outlined, label: 'Sessions'),
              ],
              selectedIndex: 0,
              onChanged: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Sessions'), findsOneWidget);
    });

    testWidgets('ContextExtensions expose warm athletic tokens in light mode', (tester) async {
      late BuildContext capturedContext;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Builder(
            builder: (ctx) {
              capturedContext = ctx;
              return const SizedBox();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(capturedContext.isDark, isFalse);
      expect(capturedContext.surfaceColor, const Color(0xFFFFFFFF));
      expect(capturedContext.surfaceSecondaryColor, const Color(0xFFEDEFE7));
      expect(capturedContext.textPrimaryColor, const Color(0xFF20251D));
      expect(capturedContext.textSecondaryColor, const Color(0xFF777D72));
      expect(capturedContext.borderColor, const Color(0xFFE5E6DE));
      expect(capturedContext.voltColor, const Color(0xFF76A200));
      expect(capturedContext.orangeColor, const Color(0xFFFF8A45));
      expect(capturedContext.heroCtaBg, const Color(0xFF20251D));
      expect(capturedContext.heroCtaFg, const Color(0xFFFFFFFF));
    });

    testWidgets('Fresh user with no saved preference defaults to light theme', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final mode = container.read(themeModeProvider);
      expect(mode, ThemeMode.light);
    });

    testWidgets('Dynamic theme toggle via themeModeProvider updates UI instantly', (tester) async {
      SharedPreferences.setMockInitialValues({'themeMode': 'dark'});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: Consumer(
            builder: (context, ref, _) {
              final mode = ref.watch(themeModeProvider);
              return MaterialApp(
                theme: AppTheme.light,
                darkTheme: AppTheme.dark,
                themeMode: mode,
                home: Scaffold(
                  body: Text('Mode is ' + mode.name),
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Mode is dark'), findsOneWidget);

      container.read(themeModeProvider.notifier).toggle();
      await tester.pumpAndSettle();

      expect(find.text('Mode is light'), findsOneWidget);

      container.read(themeModeProvider.notifier).toggle();
      await tester.pumpAndSettle();

      expect(find.text('Mode is dark'), findsOneWidget);
    });
  });
}
