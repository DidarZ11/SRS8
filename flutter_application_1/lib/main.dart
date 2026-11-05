import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import 'core/config/app_config.dart';
import 'core/network/dio_client.dart';
import 'data/local/app_cache.dart';
import 'data/remote/henrik_api.dart';
import 'data/remote/notes_api.dart';
import 'data/repositories/match_repository.dart';
import 'data/repositories/notes_repository.dart';
import 'presentation/screens/matches_screen.dart';
import 'presentation/state/matches_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  final cache = await AppCache.open();

 
  final dio = DioClient().dio;
  final matchRepository = MatchRepositoryImpl(api: HenrikApi(dio), cache: cache);
  final notesRepository = NotesRepositoryImpl(
    api: NotesApi(dio, baseUrl: AppConfig.notesBaseUrl),
    cache: cache,
  );

  runApp(ValorantExplorerApp(matchRepository: matchRepository, notesRepository: notesRepository));
}

class ValorantExplorerApp extends StatelessWidget {
  const ValorantExplorerApp({super.key, required this.matchRepository, required this.notesRepository});

  final MatchRepository matchRepository;
  final NotesRepository notesRepository;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<MatchRepository>.value(value: matchRepository),
        RepositoryProvider<NotesRepository>.value(value: notesRepository),
      ],
      child: BlocProvider(
        create: (_) => MatchesCubit(matchRepository)..start(),
        child: MaterialApp(
          title: 'Valorant Explorer',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(colorSchemeSeed: const Color(0xFFFF4655), useMaterial3: true),
          darkTheme: ThemeData(
            colorSchemeSeed: const Color(0xFFFF4655),
            brightness: Brightness.dark,
            useMaterial3: true,
          ),
          home: const MatchesScreen(),
        ),
      ),
    );
  }
}
