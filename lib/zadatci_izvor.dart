import 'zadatak.dart';

class ZadatciException implements Exception {
  final String poruka;
  ZadatciException(this.poruka);

  @override
  String toString() => 'ZadatciException: $poruka';
}

/// Ugovor prema kojem ViewModel dohvaća i mijenja zadatke.
/// Iza njega može biti memorija, Supabase ili bilo što drugo.
abstract class ZadatciIzvor {
  Future<List<Zadatak>> dohvati();
  Future<Zadatak> dodaj(String naslov);
  Future<void> postaviZavrsen(int id, bool zavrsen);
  Future<void> obrisi(int id);
}
