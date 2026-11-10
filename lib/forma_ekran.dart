import 'package:flutter/material.dart';

class FormaEkran extends StatefulWidget {
  const FormaEkran({super.key});

  @override
  State<FormaEkran> createState() => _FormaEkranState();
}

class _FormaEkranState extends State<FormaEkran> {
  final _kljuc = GlobalKey<FormState>();
  final _naslov = TextEditingController();

  @override
  void dispose() {
    _naslov.dispose();
    super.dispose();
  }

  String? _provjeriNaslov(String? vrijednost) {
    final tekst = vrijednost?.trim() ?? '';
    if (tekst.isEmpty) return 'Unesite naslov';
    if (tekst.length < 3) return 'Naslov mora imati najmanje 3 znaka';
    return null;
  }

  void _spremi() {
    if (!_kljuc.currentState!.validate()) return;
    Navigator.pop(context, _naslov.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novi zadatak')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _kljuc,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _naslov,
                decoration: const InputDecoration(
                  labelText: 'Naslov',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.done,
                validator: _provjeriNaslov,
                onFieldSubmitted: (_) => _spremi(),
              ),
              const SizedBox(height: 16),
              FilledButton(onPressed: _spremi, child: const Text('Spremi')),
            ],
          ),
        ),
      ),
    );
  }
}
