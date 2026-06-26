import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kalima/core/theme/app_theme.dart';
import 'package:kalima/logic/bloc/document/document_bloc.dart';
import 'package:kalima/logic/bloc/editor/editor_bloc.dart';
import 'package:kalima/logic/bloc/format/format_bloc.dart';
import 'package:kalima/logic/cubit/ui_cubit.dart';
import 'package:kalima/ui/screens/home_screen.dart';

class KalimaApp extends StatelessWidget {
  const KalimaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<DocumentBloc>(
          create: (_) => DocumentBloc(),
        ),
        BlocProvider<EditorBloc>(
          create: (_) => EditorBloc(),
        ),
        BlocProvider<FormatBloc>(
          create: (_) => FormatBloc(),
        ),
        BlocProvider<UiCubit>(
          create: (_) => UiCubit(),
        ),
      ],
      child: MaterialApp(
        title: 'كلمة',
        debugShowCheckedModeBanner: false,

        // RTL support for Arabic
        supportedLocales: const [
          Locale('ar', 'SA'),
          Locale('en', 'US'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        localeResolutionCallback: (locale, supportedLocales) {
          // Default to Arabic if device locale is not supported
          if (locale == null) return const Locale('ar', 'SA');
          for (final supported in supportedLocales) {
            if (supported.languageCode == locale.languageCode) {
              return supported;
            }
          }
          return const Locale('ar', 'SA');
        },

        // Apply RTL theme
        theme: AppTheme.lightTheme,

        home: const HomeScreen(),
      ),
    );
  }
}
