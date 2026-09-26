import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nectar/app/session_app.dart';

/// Reproduces the app's sign-out situation: a signed-in session with extra
/// routes, a dialog and a bottom sheet (with a dropdown and a text field) on
/// the Navigator, while the auth state flips to signed-out.
class _Harness extends StatefulWidget {
  const _Harness();

  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  String? sessionId = 'user-1';

  void setSession(String? id) => setState(() => sessionId = id);

  @override
  Widget build(BuildContext context) {
    return SessionApp(
      sessionId: sessionId,
      home: sessionId == null ? const _LoginPage() : _SignedInShell(onSignOut: () => setSession(null)),
    );
  }
}

class _LoginPage extends StatelessWidget {
  const _LoginPage();

  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('login-page')));
}

class _SignedInShell extends StatelessWidget {
  const _SignedInShell({required this.onSignOut});

  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        children: [
          Column(
            children: [
              ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(builder: (_) => const Scaffold(body: Center(child: Text('pushed-page')))),
                ),
                child: const Text('push'),
              ),
              ElevatedButton(
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  builder: (_) => const _SheetContent(),
                ),
                child: const Text('sheet'),
              ),
              ElevatedButton(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => const AlertDialog(content: TextField()),
                ),
                child: const Text('dialog'),
              ),
              ElevatedButton(onPressed: onSignOut, child: const Text('sign-out')),
            ],
          ),
        ],
      ),
    );
  }
}

class _SheetContent extends StatelessWidget {
  const _SheetContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DropdownButton<String>(
          value: 'a',
          items: const [
            DropdownMenuItem(value: 'a', child: Text('a')),
            DropdownMenuItem(value: 'b', child: Text('b')),
          ],
          onChanged: (_) {},
        ),
        const TextField(),
      ],
    );
  }
}

void main() {
  Future<void> openAndSignOut(WidgetTester tester, String openerLabel) async {
    await tester.pumpWidget(const _Harness());
    await tester.tap(find.text('push'));
    await tester.pumpAndSettle();
    expect(find.text('pushed-page'), findsOneWidget);

    Navigator.of(tester.element(find.text('pushed-page'))).pop();
    await tester.pumpAndSettle();

    await tester.tap(find.text(openerLabel));
    await tester.pumpAndSettle();

    final harness = tester.state<_HarnessState>(find.byType(_Harness));
    harness.setSession(null);
    await tester.pumpAndSettle();
  }

  testWidgets('sign-out with a bottom sheet open leaves no live overlays', (tester) async {
    await openAndSignOut(tester, 'sheet');

    expect(tester.takeException(), isNull);
    expect(find.text('login-page'), findsOneWidget);
    expect(find.byType(DropdownButton<String>), findsNothing);
  });

  testWidgets('sign-out with a dialog open leaves no live overlays', (tester) async {
    await openAndSignOut(tester, 'dialog');

    expect(tester.takeException(), isNull);
    expect(find.text('login-page'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('sign-out with a pushed route on top returns to the login page', (tester) async {
    await tester.pumpWidget(const _Harness());
    await tester.tap(find.text('push'));
    await tester.pumpAndSettle();

    tester.state<_HarnessState>(find.byType(_Harness)).setSession(null);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('login-page'), findsOneWidget);
    expect(find.text('pushed-page'), findsNothing);
  });

  testWidgets('switching users rebuilds the whole session', (tester) async {
    await tester.pumpWidget(const _Harness());
    final harness = tester.state<_HarnessState>(find.byType(_Harness));

    await tester.tap(find.text('push'));
    await tester.pumpAndSettle();
    harness.setSession('user-2');
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('pushed-page'), findsNothing);
    expect(find.text('sign-out'), findsOneWidget);
  });
}
