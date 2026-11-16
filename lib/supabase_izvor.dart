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

  // Primjer za dohvati: _izvedi(() async { ... _db.from('zadatci').select() ... });

  @override
  Future<List<Zadatak>> dohvati() => _izvedi(() async {
    final redovi = await _db.from('zadatci').select().order('id');
    return redovi.map(Zadatak.fromJson).toList();
  });

  @override
  Future<Zadatak> dodaj(String naslov) => _izvedi(() async {
    final red = await _db
        .from('zadatci')
        .insert({'naslov': naslov})
        .select()
        .single();
    return Zadatak.fromJson(red);
  });

  @override
  Future<void> postaviZavrsen(int id, bool zavrsen) => _izvedi(() async {
    await _db.from('zadatci').update({'zavrsen': zavrsen}).eq('id', id);
  });

  @override
  Future<void> obrisi(int id) => _izvedi(() async {
    await _db.from('zadatci').delete().eq('id', id);
  });
}
