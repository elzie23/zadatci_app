//ignore_for_file: avoid_print
import 'package:zadatci_app/repozitorij.dart';

import 'dart:async';

Future<void> main() async {
  final repo = ZadatakRepozitorij(neuspjeha: 1);

  try {
    final zadaci = await repo.dohvati().timeout(
      const Duration(milliseconds: 300),
    );

    for (final z in zadaci) {
      print('- ${z.naslov}');
    }
  } on TimeoutException {
    print('Isteklo vrijeme');
  }

  final repo2 = ZadatakRepozitorij();
  final vrijeme = Stopwatch()..start();
  final rezultati = await Future.wait([repo2.dohvati(), repo2.dohvati()]);
  vrijeme.stop();
  print(
    'Prvi dohvat: ${rezultati[0].length} zadataka, drugi dohvat: ${rezultati[1].length} zadataka',
  );
  print('Ukupno vrijeme: ${vrijeme.elapsedMilliseconds} ms');

  for (var pokusaj = 1; pokusaj <= 2; pokusaj++) {
    try {
      print('Pokušaj $pokusaj: dohvaćam...');
      final zadaci = await repo.dohvati();
      for (final z in zadaci) {
        print('- ${z.naslov} (${z.zavrsen ? 'gotovo' : 'u tijeku'})');
      }
      break;
    } on ZadatciException catch (e) {
      print('Pogreška: ${e.poruka}');
    } finally {
      print('Pokušaj $pokusaj završen');
    }
  }
}
