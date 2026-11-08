import 'package:flutter_test/flutter_test.dart';
import 'package:zadatci_app/repozitorij.dart';
import 'package:zadatci_app/zadatci_viewmodel.dart';

void main() {
  test('ucitaj puni popis i postavlja stanje uspjeh', () async {

    final vm = ZadatciViewModel(ZadatakRepozitorij());
    await vm.ucitaj();
    expect(vm.stanje, Stanje.uspjeh);
    expect(vm.ukupno, 4);
    expect(vm.zavrseno, 2);
  });
  test('ucitaj javlja pogresku kad repozitorij ne uspije', () async {
    final vm = ZadatciViewModel(ZadatakRepozitorij(neuspjeha: 1));
    await vm.ucitaj();
    expect(vm.stanje, Stanje.greska);
    expect(vm.poruka, 'Nema veze s poslužiteljem');
  });
  test('dodaj odbija prekratak naslov i obavještava slušatelje', () async {
    final vm = ZadatciViewModel(ZadatakRepozitorij(prazno: true));
    await vm.ucitaj();
    var pozivi = 0;
    vm.addListener(() => pozivi++);
    expect(vm.dodaj('ab'), isFalse);
    expect(pozivi, 0);
    expect(vm.dodaj('Novi zadatak'), isTrue);
    expect(pozivi, 1);
    expect(vm.ukupno, 1);
  });
  test('promijeniZavrsen mijenja broj završenih', () async {
    final vm = ZadatciViewModel(ZadatakRepozitorij());
    await vm.ucitaj();
    vm.promijeniZavrsen(3);
    expect(vm.zavrseno, 3);
  });
}