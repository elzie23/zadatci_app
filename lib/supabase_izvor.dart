// ignore_for_file: unused_element, unused_field
// (obrišite ovaj redak kad dovršite zadatke)
import 'package:supabase_flutter/supabase_flutter.dart';

import 'zadatak.dart';
import 'zadatci_izvor.dart';

/// Izvor podataka koji čita i mijenja tablicu public.zadatci na Supabaseu.
class SupabaseIzvor implements ZadatciIzvor {
  final SupabaseClient _db;

  SupabaseIzvor(this._db);

  /// Pretvara pogreške biblioteke u pogrešku koju razumije ViewModel.
  Future<T> _izvedi<T>(Future<T> Function() posao) async {
    try {
      return await posao();
    } on PostgrestException catch (e) {
      throw ZadatciException(e.message);
    } catch (e) {
      throw ZadatciException('Nema veze s poslužiteljem');
    }
  }

  // TODO 3: implementirajte četiri metode pomoću _db i _izvedi(...).
  // Primjer za dohvati: _izvedi(() async { ... _db.from('zadatci').select() ... });

  @override
  Future<List<Zadatak>> dohvati() async {
    // select() uz order('id'); redove pretvorite u Zadatak.fromJson
    throw UnimplementedError('dohvati');
  }

  @override
  Future<Zadatak> dodaj(String naslov) async {
    // insert({'naslov': naslov}) uz select().single()
    throw UnimplementedError('dodaj');
  }

  @override
  Future<void> postaviZavrsen(int id, bool zavrsen) async {
    // update({'zavrsen': zavrsen}) uz eq('id', id)
    throw UnimplementedError('postaviZavrsen');
  }

  @override
  Future<void> obrisi(int id) async {
    // delete() uz eq('id', id)
    throw UnimplementedError('obrisi');
  }
}
