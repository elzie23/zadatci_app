import 'package:flutter/material.dart';

import 'zadatci_viewmodel.dart';

class StatistikaEkran extends StatelessWidget {
  final ZadatciViewModel vm;

  const StatistikaEkran({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistika')),
      body: ListenableBuilder(
        listenable: vm,
        builder: (context, _) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ukupno: ${vm.ukupno}'),
                Text('Završeno: ${vm.zavrseno}'),
                Text('Preostalo: ${vm.preostalo}'),
              ],
            ),
          );
        },
      ),
    );
  }
}
