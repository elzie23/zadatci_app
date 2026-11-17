// ignore_for_file: unused_element, unused_field
// (obrišite ovaj redak kad dovršite zadatke)
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'forma_ekran.dart';
import 'memorijski_izvor.dart';
import 'statistika_ekran.dart';
import 'zadatci_izvor.dart';
import 'zadatci_viewmodel.dart';
import 'supabase_izvor.dart';
import 'zadatak.dart';

// Vrijednosti dolaze iz env.json: flutter run --dart-define-from-file=env.json
const _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const _supabaseKljuc = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final ZadatciIzvor izvor;
  if (_supabaseUrl.isEmpty || _supabaseKljuc.isEmpty) {
    izvor = MemorijskiIzvor();
  } else {
    await Supabase.initialize(
      url: _supabaseUrl,
      publishableKey: _supabaseKljuc,
    );
    izvor = SupabaseIzvor(Supabase.instance.client);
  }
  runApp(ZadatciApp(izvor: izvor));
}

class ZadatciApp extends StatelessWidget {
  final ZadatciIzvor izvor;

  const ZadatciApp({super.key, required this.izvor});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Zadatci',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: ZadatciEkran(izvor: izvor),
    );
  }
}

class ZadatciEkran extends StatefulWidget {
  final ZadatciIzvor izvor;

  const ZadatciEkran({super.key, required this.izvor});

  @override
  State<ZadatciEkran> createState() => _ZadatciEkranState();
}

class _ZadatciEkranState extends State<ZadatciEkran> {
  late final _vm = ZadatciViewModel(widget.izvor);

  @override
  void initState() {
    super.initState();
    _vm.ucitaj();
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  void _poruka(String tekst) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tekst)));
  }

  Future<void> _dodaj() async {
    final naslov = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const FormaEkran()),
    );
    if (!mounted || naslov == null) return;
    final uspjeh = await _vm.dodaj(naslov);
    if (!mounted) return;
    _poruka(uspjeh ? 'Dodano: $naslov' : _vm.poruka);
  }

  Future<void> _promijeni(int id) async {
    final uspjeh = await _vm.promijeniZavrsen(id);
    if (!mounted || uspjeh) return;
    _poruka(_vm.poruka);
  }

  Future<void> _obrisi(int id) async {
    final uspjeh = await _vm.obrisi(id);
    if (!mounted) return;
    _poruka(uspjeh ? 'Obrisano' : _vm.poruka);
  }

  void _otvoriStatistiku() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => StatistikaEkran(vm: _vm)),
    );
  }

  Future<void> _urediNaslov(Zadatak zadatak) async {
    final naslov = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => FormaEkran(pocetniNaslov: zadatak.naslov),
      ),
    );
    if (!mounted || naslov == null) return;
    final uspjeh = await _vm.promijeniNaslov(zadatak.id, naslov);
    if (!mounted) return;
    _poruka(uspjeh ? 'Promijenjeno: $naslov' : _vm.poruka);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zadatci'),
        actions: [
          IconButton(
            onPressed: _otvoriStatistiku,
            tooltip: 'Statistika',
            icon: const Icon(Icons.bar_chart),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _dodaj,
        tooltip: 'Novi zadatak',
        child: const Icon(Icons.add),
      ),
      body: ListenableBuilder(
        listenable: _vm,
        builder: (context, _) {
          switch (_vm.stanje) {
            case Stanje.ucitavanje:
              return const Center(child: CircularProgressIndicator());
            case Stanje.greska:
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 8),
                    Text(_vm.poruka),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: _vm.ucitaj,
                      child: const Text('Pokušaj ponovno'),
                    ),
                  ],
                ),
              );
            case Stanje.uspjeh:
              if (_vm.zadatci.isEmpty) {
                return const Center(child: Text('Nema zadataka'));
              }
              return RefreshIndicator(
                onRefresh: _vm.ucitaj,
                child: ListView.builder(
                  itemCount: _vm.zadatci.length,
                  itemBuilder: (context, i) {
                    final z = _vm.zadatci[i];
                    return ListTile(
                      onLongPress: () => _urediNaslov(z),
                      leading: Checkbox(
                        value: z.zavrsen,
                        onChanged: (_) => _promijeni(z.id),
                      ),
                      title: Text(
                        z.naslov,
                        style: TextStyle(
                          decoration: z.zavrsen
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      trailing: IconButton(
                        onPressed: () => _obrisi(z.id),
                        tooltip: 'Obriši',
                        icon: const Icon(Icons.delete_outline),
                      ),
                    );
                  },
                ),
              );
          }
        },
      ),
    );
  }
}
