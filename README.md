# zadatci_app

## Manuela Kurtović

### Provedene izmjene i odgovori na pitanja:
Odgovori na pitanja:
1. Tri stvari koje u vježbi 3 ne pripadaju ekranu prema MVVM obrascu su: učitavanje zadataka, provjera naslova zadatka, te kreiranje zadatka.
Učitavanje zadataka (_ucitaj()), trebalo bi premjestiti u ViewModel jer upravlja učitavanjem podataka.
Provjera ispravnosti naslova (_provjeriNaslov()), treba premjestiti u ViewModel jer je to logika provjere unesenih podataka.
Dodjeljivanje novog id-a i kreiranje zadatka (_spremi()), treba premjestiti u ViewModel jer je to logika stvaranja zadatka.

2. Kada bi StatistikaEkran u svom initState stvorio novi
ZadatciViewModel(ZadatakRepozitorij()), imao bi vlastito, odvojeno stanje nepovezano s ViewModelom ekrana popisa, zbog čega promjene zadataka, poput označavanja zadatka kao završenog ili dodavanja novog zadatka, ne bi bile automatski prikazane u statistici. Boje je da oba ekrana koriste isti ViewModel kako bi dijelili iste podatke i kako bi statistika uvijek prikazivala točne brojeve zadataka.
3. ViewModel izlaže UnmodifiableListView umjesto obične liste kako bi se spriječio direktno mijenjanje zadataka izvan ViewModela. Kada bi izložio običnu listu, View bi mogao samostalno dodavati ili brisati zadatke bez pozivanja metoda ViewModela i bez notifyListeners(), pa bi moglo doći do toga da se na ekranu ne prikažu promjene ili da statistika prikazuje netočne podatke.
Kada se promjene rade kroz ViewModel, nakon promjene se obavještava slušatelje pomoću notifyListeners(). 
4. Ako iz metode promijeniZavrsen izostavimo notifyListeners(), zadatak će promijeniti svoje stanje u ViewModelu, ali se ekran neće automatski osvježiti. Ako izostavimo notifyListeners() i oprobamo označiti zadatak kao završen, kvačica se ne mijenja i promjena se ne prikazuje na ekranu. Nakon ponovnog otvaranja ili osvježavanja ekrana promjena se prikazuje jer se tada ponovno učitaju podaci iz ViewModela.

Izmjene:
1. Dodana je metoda:
<code>
  void ukloni(int id) {
    _zadatci.removeWhere((z) => z.id == id);
    notifyListeners();
  }
</code>
Omotan je CheckboxListTile u Dismissible na sljedeći način:
<code>
return Dismissible( 
                key: ValueKey(z.id),
                direction: DismissDirection.endToStart,
                onDismissed: (_) => _vm.ukloni(z.id),
                child: CheckboxListTile(
                value: z.zavrsen,
                onChanged: (_) => _vm.promijeniZavrsen(z.id),
                title: Text(
                  z.naslov,
                  style: TextStyle(
                    decoration: z.zavrsen ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              );
</code>
Te je napravljen test uklanjanja zadatka koji provjerava smanjuje li se broj zadataka za 1:
<code>
 test('ukloni smanjuje broj zadataka', () async {
    final vm = ZadatciViewModel(ZadatakRepozitorij());
    await vm.ucitaj();
    final prije =vm.ukupno;
    expect(prije, 4);
    vm.ukloni(3);
    expect(vm.ukupno, prije - 1);
  });
</code>

2. U ViewModel dodano je polje samoNezavrseni:
<code>
  bool samoNezavrseni = false;
</code>
kao i getter:
<code>
Iterable<Zadatak> get odabrani =>
    _zadatci.where((z) => !samoNezavrseni || !z.zavrsen);
</code>
pomoću kojeg biramo koji će zadatci biti prikazani.
Kako bi se to na ekranu prikazalo, unutar main-a u AppBar dodano je sljedeće unutar actions:
<code>
Switch(
            value: _vm.samoNezavrseni,
            onChanged: (v) => setState(() => _vm.samoNezavrseni = v),
            activeThumbColor: Colors.purple,
          ),
</code>
također je promijenjele linija
<code>
      if (_vm.zadatci.isEmpty) 
</code>
u
<code>
    if (_vm.odabrani.isEmpty) 
</code>
kao i izmjena zadatci u odabrani unutar sljedeće linije:
<code>
itemCount: _vm.odabrani.length,
</code>