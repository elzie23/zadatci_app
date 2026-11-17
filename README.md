# zadatci_app

## Manuela Kurtović

### Podatci o Oracle-u i Supabase-u

**Oracle Linux 9 image:** `Oracle-Linux-9.8-aarch64-2026.10.30-0`
</br>
**Shape:** `VM.Standard.A1.Flex` 2 OCPU, 12 GB RAM
</br>
**Korištena verzija Supabase-a:** `self-hosted/v0.8.4`
### Odgovori na pitanja:
 
1. Always Free instanca je virtualni poslužitelj na Oracle Cloudu koji ostaje trajno besplatan i nakon što istekne početno probno razdoblje (Free Trial), ako se ne pređu dopušteni limiti resursa (ukupno do 4 ARM jezgre i 24 GB RAM-a na razini računa).

      Za self-hosted Supabase se ne smije odabrati Micro shape (VM.Standard.E2.1.Micro) jer ima samo 1 GB RAM-a i 1 OCPU jezgru. Supabase se u Dockeru sastoji od desetak odvojenih kontejnera koji rade istovremeno (PostgreSQL baza, Studio, Auth, Storage i drugi) te mu za normalan rad treba barem 4 GB RAM-a i 2 jezgre. Na Micro obliku bi sustav odmah ostao bez memorije i kontejneri bi se stalno rušili, zbog čega za ovu vježbu koristimo ARM oblik 'VM.Standard.A1.Flex' (2 OCPU i 12 GB RAM-a) koji je također besplatan.

2. Docker slika (image) je zapakirani predložak aplikacije sa svim njenim kodom, bibliotekama i postavkama potrebnim za rad, slično kao klasa u programiranju ili instalacijska datoteka. Kontejner je živa, pokrenuta instanca te slike u kojoj se aplikacija stvarno izvršava. Od jedne slike možemo pokrenuti više odvojenih kontejnera i svaki radi u svom izoliranom okruženju.

      Podaci baze se moraju držati u Docker volumenu jer sve što je spremljeno unutar samog kontejnera nestaje čim se taj kontejner obriše ili ažurira na novu verziju. Volumen pohranjuje podatke izravno na disk poslužitelja izvan samog kontejnera, pa nam tablice i zadatci ostaju sačuvani čak i kad ugasimo, obrišemo ili ponovno pokrenemo Docker kontejnere.

3. Supabase servisi i gateway na portu 8000

      Postgres: Glavna relacijska baza podataka u kojoj se trajno spremaju sve naše tablice i podaci (tablica zadatci).
      REST (PostgREST): Servis koji automatski pretvara tablice iz Postgres baze u REST API, tako da Flutter aplikacija može čitati, dodavati, mijenjati i brisati podatke preko običnih HTTP zahtjeva bez pisanja vlastitog backend koda.
      Auth: Servis zadužen za upravljanje korisnicima, prijavu, registraciju te provjeru dozvola i ključeva pristupa (npr. publishable ključ i RLS pravila).
      Storage: Servis za spremanje i preuzimanje većih datoteka poput slika, dokumenata ili videa, uz korištenje pravila pristupa iz baze.
      Studio: Web sučelje kojem pristupamo preko preglednika i kroz koje možemo pregledavati i uređivati tablice, pokretati SQL upite te mijenjati postavke projekta.

      Gateway na portu 8000 (Kong ili Envoy) je jedinstvena ulazna točka za cijeli Supabase sustav. Umjesto da otvaramo različite portova za svaki pojedini servis prema internetu, svi zahtjevi izvana dolaze na port 8000, gdje gateway provjerava API ključ i preusmjerava zahtjev pravom unutarnjem servisu (npr. na Auth,REST API ili Studio).

4. Da u SQL skripti nismo dodali politiku "anon cita", aplikacija bi na ekranu prikazala poruku "Nema zadataka" (prazan popis), bez ikakve obavijesti o pogrešci.

      Razlog zašto nema poruke o pogrešci je način rada Row Level Security (RLS) u PostgreSQL bazi, kada je RLS uključen na tablici, a ne postoji nijedna politika koja dopušta čitanje (SELECT) ulozi anon, baza ne odbija upit kao grešku nego ga normalno izvrši i samo filtrira sve retke kao nedostupne, zbog čega API vraća prazan JSON niz '[]' sa statusom 200 OK, što je aplikaciji uspješan dohvat prazne tablice.

5. ViewModel najprije čeka potvrdu od izvora podataka (baze), a tek onda mijenja lokalni popis u aplikaciji kako bi stanje na ekranu uvijek odgovaralo stvarnom stanju u bazi.

      Da je obrnuto, točnije, da se lokalni popis promijeni odmah i da veza s poslužiteljem u tom trenutku padne, korisnik bi na ekranu vidio da je zadatak uspješno dodan, označen ili obrisan, ali se ta promjena uopće nije spremila u bazu. Kada bi korisnik sljedeći put osvježio popis ili ponovno pokrenuo aplikaciju, te bi promjene nestale.

6. U klijentsku aplikaciju (poput Fluttera) uvijek stavljamo publishable ključ jer je on namijenjen za javnu upotrebu i poštuje Row Level Security (RLS) pravila koja smo postavili u bazi, pa korisnici mogu raditi samo ono što im izričito dopustimo.

      Kada bi secret ključ završio u javnom repozitoriju (ili u samoj mobilnoj aplikaciji iz koje ga svatko može izvući), bilo tko tko ga pronađe dobio bi potpune administratorske ovlasti nad cijelom bazom. Taj ključ u potpunosti zaobilazi sva RLS ograničenja, što znači da bi svatko tko dođe do njega mogao pročitati, izmijeniti ili obrisati sve podatke i tablice svih korisnika.

