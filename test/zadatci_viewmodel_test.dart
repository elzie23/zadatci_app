import 'package:flutter_test/flutter_test.dart';
import 'package:zadatci_app/memorijski_izvor.dart';
import 'package:zadatci_app/zadatak.dart';
import 'package:zadatci_app/zadatci_izvor.dart';
import 'package:zadatci_app/zadatci_viewmodel.dart';

MemorijskiIzvor izvor({int neuspjeha = 0, bool prazno = false}) =>
    MemorijskiIzvor(
      neuspjeha: neuspjeha,
      prazno: prazno,
      odgoda: Duration.zero,
    );

/// Izvor koji uvijek javlja pogrešku pri izmjenama.
class KvarIzvor extends MemorijskiIzvor {
  KvarIzvor() : super(odgoda: Duration.zero);

  @override
  Future<Zadatak> dodaj(String naslov) =>
      throw ZadatciException('Nema veze s poslužiteljem');

  @override
  Future<void> postaviZavrsen(int id, bool zavrsen) =>
      throw ZadatciException('Nema veze s poslužiteljem');

  @override
  Future<void> obrisi(int id) =>
      throw ZadatciException('Nema veze s poslužiteljem');

  @override
  Future<void> postaviNaslov(int id, String naslov) =>
      throw ZadatciException('Nema veze s poslužiteljem');
}

void main() {
  test('ucitaj puni popis i postavlja stanje uspjeh', () async {
    final vm = ZadatciViewModel(izvor());
    await vm.ucitaj();
    expect(vm.stanje, Stanje.uspjeh);
    expect(vm.ukupno, 4);
    expect(vm.zavrseno, 2);
  });

  test('ucitaj javlja pogresku kad izvor ne uspije', () async {
    final vm = ZadatciViewModel(izvor(neuspjeha: 1));
    await vm.ucitaj();
    expect(vm.stanje, Stanje.greska);
    expect(vm.poruka, 'Nema veze s poslužiteljem');
  });

  test('dodaj odbija prekratak naslov i ne obavještava slušatelje', () async {
    final vm = ZadatciViewModel(izvor(prazno: true));
    await vm.ucitaj();
    var pozivi = 0;
    vm.addListener(() => pozivi++);
    expect(await vm.dodaj('ab'), isFalse);
    expect(pozivi, 0);
    expect(await vm.dodaj('Novi zadatak'), isTrue);
    expect(pozivi, 1);
    expect(vm.ukupno, 1);
  });

  test('dodaj dodaje zadatak koji vrati izvor', () async {
    final vm = ZadatciViewModel(izvor());
    await vm.ucitaj();
    await vm.dodaj('Nova vježba');
    expect(vm.zadatci.last.naslov, 'Nova vježba');
    expect(vm.zadatci.last.id, 5);
  });

  test('dodaj ne mijenja popis kad izvor javi pogrešku', () async {
    final vm = ZadatciViewModel(KvarIzvor());
    await vm.ucitaj();
    expect(await vm.dodaj('Novi zadatak'), isFalse);
    expect(vm.ukupno, 4);
    expect(vm.poruka, 'Nema veze s poslužiteljem');
  });

  test('promijeniZavrsen mijenja broj završenih', () async {
    final vm = ZadatciViewModel(izvor());
    await vm.ucitaj();
    await vm.promijeniZavrsen(3);
    expect(vm.zavrseno, 3);
    await vm.promijeniZavrsen(3);
    expect(vm.zavrseno, 2);
  });

  test('obrisi uklanja zadatak i smanjuje ukupno', () async {
    final vm = ZadatciViewModel(izvor());
    await vm.ucitaj();
    expect(await vm.obrisi(1), isTrue);
    expect(vm.ukupno, 3);
    expect(vm.zadatci.any((z) => z.id == 1), isFalse);
  });

  test('promijeniZavrsen ne mijenja popis kad izvor javi pogrešku', () async {
    final vm = ZadatciViewModel(KvarIzvor());
    await vm.ucitaj();
    expect(await vm.promijeniZavrsen(3), isFalse);
    expect(vm.zavrseno, 2);
    expect(vm.poruka, 'Nema veze s poslužiteljem');
  });

  test('obrisi ne mijenja popis kad izvor javi pogrešku', () async {
    final vm = ZadatciViewModel(KvarIzvor());
    await vm.ucitaj();
    expect(await vm.obrisi(1), isFalse);
    expect(vm.ukupno, 4);
    expect(vm.poruka, 'Nema veze s poslužiteljem');
  });

  test('promijeniNaslov mijenja naslov zadataka', () async {
    final vm = ZadatciViewModel(izvor());
    await vm.ucitaj();
    expect(await vm.promijeniNaslov(3, 'Novi naslov'), isTrue);
    expect(vm.zadatci.firstWhere((z) => z.id == 3).naslov, 'Novi naslov');
  });

  test('promijeniNaslov ne mijenja popis kad izvor javi pogrešku', () async {
    final vm = ZadatciViewModel(KvarIzvor());
    await vm.ucitaj();
    expect(await vm.promijeniNaslov(3, 'Novi naslov'), isFalse);
    expect(
      vm.zadatci.firstWhere((z) => z.id == 3).naslov,
      'Dart: Future i Stream',
    );
    expect(vm.poruka, 'Nema veze s poslužiteljem');
  });
}
