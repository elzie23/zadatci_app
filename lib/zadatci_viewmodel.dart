import 'dart:collection';

import 'package:flutter/foundation.dart';

import 'repozitorij.dart';
import 'zadatak.dart';

enum Stanje { ucitavanje, uspjeh, greska }

class ZadatciViewModel extends ChangeNotifier {
  final ZadatakRepozitorij _repo;

  ZadatciViewModel(this._repo);

  final List<Zadatak> _zadatci = [];
  Stanje _stanje = Stanje.ucitavanje;
  String _poruka = '';

  UnmodifiableListView<Zadatak> get zadatci => UnmodifiableListView(_zadatci);
  Stanje get stanje => _stanje;
  String get poruka => _poruka;

  int get ukupno => _zadatci.length;
  int get zavrseno => _zadatci.where((z) => z.zavrsen).length;
  int get preostalo => ukupno - zavrseno;
  bool samoNezavrseni = false;

  Iterable<Zadatak> get odabrani =>
      _zadatci.where((z) => !samoNezavrseni || !z.zavrsen);

  Future<void> ucitaj() async {
    _stanje = Stanje.ucitavanje;
    notifyListeners();
    try {
      final podaci = await _repo.dohvati();
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

  /// Dodaje zadatak. Vraća false ako naslov nije valjan.
  bool dodaj(String naslov) {
    final tekst = naslov.trim();
    if (tekst.length < 3) return false;
    final noviId = _zadatci.fold<int>(0, (n, z) => z.id > n ? z.id : n) + 1;
    _zadatci.add(Zadatak(id: noviId, naslov: tekst));
    notifyListeners();
    return true;
  }

  void promijeniZavrsen(int id) {
    final i = _zadatci.indexWhere((z) => z.id == id);
    if (i == -1) return;
    _zadatci[i] = _zadatci[i].kopiraj(zavrsen: !_zadatci[i].zavrsen);
    notifyListeners();
  }

  void ukloni(int id) {
    _zadatci.removeWhere((z) => z.id == id);
    notifyListeners();
  }
}
