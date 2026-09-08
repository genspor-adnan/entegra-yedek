# -*- coding: utf-8 -*-
"""
STOK AKTARIM.xlsx -> SQL (ERP kurulumu, gentegre_erp).

Excel'deki HER DOLU KOLON stok kartinda bir alana yazilir:
  A kod · B ad · C kategori · D tipi · E barkod(stok_birim) · F marka ·
  G model · I ozellik · J ana birim · M kdv · P izleme · V icerik(NOTLAR)
Bos kolonlar (grubu, 2.birim, OTV, garanti, web satisi, ozel kod, ekipman,
fiyat, para birimi, fiyat adi, urun no, bildirim) yazilmaz - bos deger
yazmak, "girilmis ama bos" ile "hic girilmemis"i ayirt edilemez yapar.

KOD LISTELERI VERIDEN URETILIR: marka/model/ozellik/icerik musteriye ozeldir,
sabit liste olamaz. Ayni ad ikinci kez gecerse ayni koda baglanir.
"""
import io, re, sys, zipfile
from xml.etree import ElementTree as ET

NS = '{http://schemas.openxmlformats.org/spreadsheetml/2006/main}'
XLSX = r'C:\Users\HP\Entegra\Entegra\Dosya\STOK AKTARIM.xlsx'

z = zipfile.ZipFile(XLSX)
ss = [''.join(t.text or '' for t in si.iter(NS + 't'))
      for si in ET.fromstring(z.read('xl/sharedStrings.xml')).findall(NS + 'si')]
rows = []
for r in ET.fromstring(z.read('xl/worksheets/sheet1.xml')).iter(NS + 'row'):
    h = {}
    for c in r.findall(NS + 'c'):
        sut = re.match(r'[A-Z]+', c.get('r')).group()
        v = c.find(NS + 'v'); t = c.get('t')
        h[sut] = (''.join(x.text or '' for x in c.iter(NS + 't')) if t == 'inlineStr'
                  else ('' if v is None else (ss[int(v.text)] if t == 's' else v.text)))
    rows.append(h)
veri = rows[1:]

def al(r, k):
    return (r.get(k) or '').strip()

def tirnak(x):
    return "'" + str(x).replace("'", "''") + "'"

# --- kod listelerine girecek essiz degerler (gorulme sirasinda) -------------
def essiz(kol):
    g, s = [], set()
    for r in veri:
        d = al(r, kol)
        if d and d not in s:
            s.add(d); g.append(d)
    return g

LISTE = {
    'stok.marka':    essiz('F'),
    'stok.model':    essiz('G'),
    'stok.ozellik':  essiz('I'),
    'stok.icerik':   essiz('V'),
}

o = []
o.append('-- STOK AKTARIM.xlsx -> gentegre_erp. Tekrar calistirilabilir:')
o.append('-- kod degerleri ada gore, stoklar KOD\'a gore eslenir.')
o.append('begin;')
o.append("set local client_min_messages = warning;")

# Kategori (Excel: TOZ) - stok agacinda (tur = 1)
for kat in essiz('C'):
    o.append(f"""insert into public.kategori (kod, ad, aktif, tur)
select {tirnak(kat)}, {tirnak(kat)}, 1, 1
 where not exists (select 1 from public.kategori where ad = {tirnak(kat)} and tur = 1);""")

# Kod listeleri + degerler
for liste, degerler in LISTE.items():
    if not degerler:
        continue
    o.append(f"""do $$
declare v_liste integer; v_sira integer;
begin
    select id into v_liste from public.kod_liste where kod = {tirnak(liste)};
    if v_liste is null then return; end if;""")
    for ad in degerler:
        o.append(f"""    if not exists (select 1 from public.kod_deger
                    where liste_id = v_liste and ad = {tirnak(ad)}) then
        select coalesce(max(deger), 0) + 1 into v_sira
          from public.kod_deger where liste_id = v_liste;
        insert into public.kod_deger (liste_id, deger, ad, aktif)
        values (v_liste, v_sira, {tirnak(ad)}, 1);
    end if;""")
    o.append('end $$;')

# --- stok satirlari --------------------------------------------------------
def kodla(liste, ad):
    """Ad -> kod_deger.deger alt sorgusu (yoksa null)."""
    return (f"(select k.deger from public.kod_deger k join public.kod_liste l "
            f"on l.id = k.liste_id where l.kod = {tirnak(liste)} and k.ad = {tirnak(ad)} limit 1)")

IZLEME = {'Yok': 0, 'Seri No': 1, 'Lot No': 2, 'SKT': 3, 'Karekod': 4,
          'Lot No + SKT': 5, 'Seri No + Lot No': 6}
BIRIM = {'ADET': 51, 'ADET.': 51, 'KG': 57, 'KUTU': 56, 'KOLI': 53, 'LT': 72, 'METRE': 52}

for r in veri:
    kod = al(r, 'A'); ad = al(r, 'B')
    if not kod or not ad:
        continue
    kat  = al(r, 'C'); tipi = al(r, 'D'); barkod = al(r, 'E')
    marka = al(r, 'F'); model = al(r, 'G'); ozellik = al(r, 'I')
    birim = al(r, 'J'); kdv = al(r, 'M'); izleme = al(r, 'P'); icerik = al(r, 'V')

    alanlar = {
        'kod': tirnak(kod[:25]),
        'ad': tirnak(ad[:100]),
        'kategori': (f"(select id from public.kategori where ad = {tirnak(kat)} and tur = 1 limit 1)"
                     if kat else 'null'),
        'tipi': kodla('stok.tipi', tipi) if tipi else '0',
        'marka': kodla('stok.marka', marka) if marka else '0',
        'model': kodla('stok.model', model) if model else '0',
        'ozellik': kodla('stok.ozellik', ozellik) if ozellik else '0',
        'icerik': kodla('stok.icerik', icerik) if icerik else '0',
        'ana_birim': str(BIRIM.get(birim.upper(), 51)),
        'kdv': str(int(float(kdv))) if kdv else '0',
        'izleme': str(IZLEME.get(izleme, 0)),
        'durum': '1',
        'satilan': '1',
        'alinan': '1',
        'sube_id': '(select min(id) from public.sube)',
    }
    kolonlar = ', '.join(alanlar.keys())
    degerler = ', '.join(str(v) for v in alanlar.values())
    # `stok.kod` uzerinde BENZERSIZ INDEKS YOK: on conflict kullanilamaz.
    #   "yoksa ekle" deseni hem tekrar calistirilabilir hem de kullanicinin
    #   sonradan elle duzelttigi karti EZMEZ.
    o.append(f"""insert into public.stok ({kolonlar})
select {degerler}
 where not exists (select 1 from public.stok where kod = {alanlar['kod']});""")

    # BARKOD ana birim satirinda (145): kutunun barkodu ile adedin barkodu
    #   farklidir, dogru yeri ambalaj birimi satiridir.
    if barkod:
        o.append(f"""insert into public.stok_birim (stok_id, birim, carpan, barkod, durum)
select s.id, {alanlar['ana_birim']}, 1, {tirnak(barkod[:30])}, 1
  from public.stok s where s.kod = {tirnak(kod[:25])}
   and not exists (select 1 from public.stok_birim b
                    where b.stok_id = s.id and b.barkod = {tirnak(barkod[:30])});""")

o.append('commit;')
o.append("select 'stok=' || count(*) from public.stok;")
io.open(sys.argv[1], 'w', encoding='utf-8', newline='\n').write('\n'.join(o) + '\n')
print('satir:', len(veri), '-> sql yazildi')
