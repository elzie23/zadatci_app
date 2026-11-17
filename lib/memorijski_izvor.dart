import 'zadatak.dart';
import 'zadatci_izvor.dart';

/// Izvor u memoriji: radi bez mreže, za razvoj i testove.
class MemorijskiIzvor implements ZadatciIzvor {
  /// Koliko prvih poziva dohvata treba završiti pogreškom.
  int neuspjeha;

  /// Ako je true, počinje s praznim popisom.
  final bool prazno;

  /// Simulirano trajanje mreže.
  final Duration odgoda;

  MemorijskiIzvor({
    this.neuspjeha = 0,
    this.prazno = false,
    this.odgoda = const Duration(milliseconds: 800),
  });

  late final List<Zadatak> _redovi = prazno
      ? []
      : [
          const Zadatak(id: 1, naslov: 'Instalacija okruženja', zavrsen: true),
          const Zadatak(id: 2, naslov: 'Prvi commit', zavrsen: true),
          const Zadatak(id: 3, naslov: 'Dart: Future i Stream'),
          const Zadatak(id: 4, naslov: 'Prvi zaslon s popisom'),
        ];
  int _sljedeciId = 5;

  @override
  Future<List<Zadatak>> dohvati() async {
    await Future.delayed(odgoda);
    if (neuspjeha > 0) {
      neuspjeha--;
      throw ZadatciException('Nema veze s poslužiteljem');
    }
    return List.of(_redovi);
  }

  @override
  Future<Zadatak> dodaj(String naslov) async {
    await Future.delayed(odgoda);
    final novi = Zadatak(id: _sljedeciId++, naslov: naslov);
    _redovi.add(novi);
    return novi;
  }

  @override
  Future<void> postaviZavrsen(int id, bool zavrsen) async {
    await Future.delayed(odgoda);
    final i = _redovi.indexWhere((z) => z.id == id);
    if (i != -1) _redovi[i] = _redovi[i].kopiraj(zavrsen: zavrsen);
  }

  @override
  Future<void> obrisi(int id) async {
    await Future.delayed(odgoda);
    _redovi.removeWhere((z) => z.id == id);
  }

  @override
  Future<void> postaviNaslov(int id, String naslov) async {
    await Future.delayed(odgoda);
    final i = _redovi.indexWhere((z) => z.id == id);
    if (i != -1) _redovi[i] = _redovi[i].kopiraj(naslov: naslov);
  }
}
