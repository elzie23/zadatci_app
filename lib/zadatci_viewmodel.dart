import 'dart:collection';

import 'package:flutter/foundation.dart';

import 'zadatak.dart';
import 'zadatci_izvor.dart';

enum Stanje { ucitavanje, uspjeh, greska }

class ZadatciViewModel extends ChangeNotifier {
  final ZadatciIzvor _izvor;

  ZadatciViewModel(this._izvor);

  final List<Zadatak> _zadatci = [];
  Stanje _stanje = Stanje.ucitavanje;
  String _poruka = '';

  UnmodifiableListView<Zadatak> get zadatci => UnmodifiableListView(_zadatci);
  Stanje get stanje => _stanje;

  /// Zadnja poruka o pogrešci (učitavanje ili izmjena).
  String get poruka => _poruka;

  int get ukupno => _zadatci.length;
  int get zavrseno => _zadatci.where((z) => z.zavrsen).length;
  int get preostalo => ukupno - zavrseno;

  Future<void> ucitaj() async {
    _stanje = Stanje.ucitavanje;
    notifyListeners();
    try {
      final podaci = await _izvor.dohvati();
      _zadatci
        ..clear()
        ..addAll(podaci);
      _stanje = Stanje.uspjeh;
    } on ZadatciException catch (e) {
      _poruka = e.poruka;
      _stanje = Stanje.greska;
    }
    notifyListeners();
  }

  /// Dodaje zadatak. Vraća false ako naslov nije valjan ili izvor javi pogrešku
  /// (u tom slučaju je razlog u [poruka]).
  Future<bool> dodaj(String naslov) async {
    final tekst = naslov.trim();
    if (tekst.length < 3) {
      _poruka = 'Naslov mora imati najmanje 3 znaka';
      return false;
    }
    return _izvedi(() async {
      _zadatci.add(await _izvor.dodaj(tekst));
    });
  }

  Future<bool> promijeniZavrsen(int id) async {
    final i = _zadatci.indexWhere((z) => z.id == id);
    if (i == -1) return false;
    final novo = !_zadatci[i].zavrsen;
    return _izvedi(() async {
      await _izvor.postaviZavrsen(id, novo);
      final j = _zadatci.indexWhere((z) => z.id == id);
      if (j != -1) _zadatci[j] = _zadatci[j].kopiraj(zavrsen: novo);
    });
  }

  Future<bool> obrisi(int id) {
    return _izvedi(() async {
      await _izvor.obrisi(id);
      _zadatci.removeWhere((z) => z.id == id);
    });
  }

  /// Izvršava promjenu na izvoru; lokalni popis se mijenja tek nakon uspjeha.
  Future<bool> _izvedi(Future<void> Function() posao) async {
    try {
      await posao();
      notifyListeners();
      return true;
    } on ZadatciException catch (e) {
      _poruka = e.poruka;
      return false;
    }
  }

  Future<bool> promijeniNaslov(int id, String naslov) async {
    final i = _zadatci.indexWhere((z) => z.id == id);
    if (i == -1) return false;
    final tekst = naslov.trim();
    if (tekst.length < 3) {
      _poruka = 'Naslov mora imati najmanje 3 znaka';
      return false;
    }
    return _izvedi(() async {
      await _izvor.postaviNaslov(id, tekst);
      final j = _zadatci.indexWhere((z) => z.id == id);
      if (j != -1) _zadatci[j] = _zadatci[j].kopiraj(naslov: tekst);
    });
  }
}
