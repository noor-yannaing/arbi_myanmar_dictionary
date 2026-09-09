import 'package:flutter/material.dart';

import 'config/app_content.dart';
import 'screens/home_shell.dart';
import 'services/dictionary_repository.dart';
import 'theme/app_theme.dart';
import 'widgets/islamic_pattern.dart';

class DictionaryApp extends StatefulWidget {
  const DictionaryApp({super.key, this.repository});

  final DictionaryRepository? repository;

  @override
  State<DictionaryApp> createState() => _DictionaryAppState();
}

class _DictionaryAppState extends State<DictionaryApp> {
  late final DictionaryRepository _repository;
  late Future<int> _loadFuture;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? DictionaryRepository();
    _loadFuture = _repository.load().then((entries) => entries.length);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppContent.appName,
      theme: buildAppTheme(),
      home: FutureBuilder<int>(
        future: _loadFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return LoadErrorScreen(
              message: snapshot.error.toString(),
              onRetry: () => setState(() {
                _loadFuture = _repository.load().then((items) => items.length);
              }),
            );
          }
          if (!snapshot.hasData) return const SplashScreen();
          return HomeShell(
            repository: _repository,
            entryCount: snapshot.data!,
          );
        },
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PatternBackground(
        dark: true,
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 112,
                    height: 112,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.1),
                      border: Border.all(color: AppColors.gold, width: 2),
                    ),
                    child: const Icon(
                      Icons.menu_book_rounded,
                      size: 52,
                      color: AppColors.gold,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    AppContent.appName,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'စကားလုံးများမှ အသိပညာဆီသို့',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white70,
                        ),
                  ),
                  const SizedBox(height: 36),
                  const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      color: AppColors.gold,
                      strokeWidth: 2.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LoadErrorScreen extends StatelessWidget {
  const LoadErrorScreen(
      {required this.message, required this.onRetry, super.key});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 52, color: AppColors.navy),
              const SizedBox(height: 16),
              Text('The offline dictionary could not be opened.',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
