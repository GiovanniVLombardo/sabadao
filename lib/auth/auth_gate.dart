import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sabadao/controllers/user_controller.dart';
import 'package:sabadao/screens/auth/login_screen.dart';
import 'package:sabadao/screens/profile/create_profile_screen.dart';
import 'package:sabadao/screens/tabs_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  // Guarda a última sessão processada para evitar recargas desnecessárias
  Session? _lastSession;

  void _onSessionChanged(Session? session) {
    if (session == null) {
      // Usuário deslogou: limpa o controller sem chamar signOut de novo
      context.read<UserController>().clearPlayer();
      _lastSession = null;
      return;
    }

    // Só carrega se a sessão mudou (novo login ou app reiniciado)
    if (session.user.id != _lastSession?.user.id) {
      _lastSession = session;
      context.read<UserController>().loadPlayerProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<UserController>();

    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // Stream ainda conectando
        if (snapshot.connectionState != ConnectionState.active) {
          return _loadingScaffold();
        }

        final session = snapshot.data?.session;

        // Dispara efeito colateral FORA do build tree, sem causar rebuild em cadeia
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _onSessionChanged(session);
        });

        // Sem sessão → Login
        if (session == null) {
          return const LoginScreen();
        }

        // Com sessão, aguardando carregar player
        if (controller.isLoading) {
          return _loadingScaffold();
        }

        // Sessão válida, sem perfil de jogador → Complete Profile
        if (!controller.hasPlayer) {
          return const CreateProfileScreen();
        }

        // Tudo pronto → App
        return const TabsScreen();
      },
    );
  }

  Widget _loadingScaffold() => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
}