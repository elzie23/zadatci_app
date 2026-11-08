import 'package:flutter/material.dart';

import 'forma_ekran.dart';
import 'repozitorij.dart';
import 'statistika_ekran.dart';
import 'zadatci_viewmodel.dart';

void main() => runApp(const ZadatciApp());

class ZadatciApp extends StatelessWidget {
  const ZadatciApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Zadatci',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const ZadatciEkran(),
    );
  }
}

class ZadatciEkran extends StatefulWidget {
  const ZadatciEkran({super.key});

  @override
  State<ZadatciEkran> createState() => _ZadatciEkranState();
}

class _ZadatciEkranState extends State<ZadatciEkran> {
  final _vm = ZadatciViewModel(ZadatakRepozitorij());

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


  Future<void> _dodaj() async {
    final naslov = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const FormaEkran()),
    );
    if (!mounted || naslov == null) return;
    _vm.dodaj(naslov);
    ScaffoldMessenger.of(
      context,
      ).showSnackBar(SnackBar(content: Text('Dodano: $naslov')));
  }

  void _otvoriStatistiku() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => StatistikaEkran(vm: _vm)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Zadatci'),
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
          switch(_vm.stanje) {
            case Stanje.ucitavanje:
            return const Center(child: CircularProgressIndicator());
            case Stanje.greska:
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
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
            
         
          return ListView.builder(
            itemCount: _vm.zadatci.length,
            itemBuilder: (context, i) {
              final z = _vm.zadatci[i];
              return CheckboxListTile(
                value: z.zavrsen,
                onChanged: (_) => _vm.promijeniZavrsen(z.id),
                title: Text(
                  z.naslov,
                  style: TextStyle(
                    decoration: z.zavrsen ? TextDecoration.lineThrough : null,
                  ),
                ),
              );
            },
          );
        }
        },
      ),
    );
  }
}
