import os

ROOT = r'C:\Users\HP\Entegra\Entegra'
SKIP_DIRS = {'__history', '.git', '3dparty', 'Archive', 'backup.1', 'backup.2', 'Temp'}
EXT = ('.pas', '.dfm', '.sql', '.dpr')

FFFD = b'\xef\xbf\xbd'

def p(pat):
    """ASCII pattern'de '?' karakterini FFFD bytes'iyla degistir."""
    return pat.replace('?', '\x01').encode('cp1254').replace(b'\x01', FFFD)

def b(s):
    return s.encode('cp1254')

# Sadece kesin/uzun pattern'lar - false positive olmasin
# Pattern: ASCII karakter + '?' (FFFD yer tutucusu)
# Karsilik: cp1254 ile encode edilecek dogru Turkce metin
REPLACEMENTS = [
    # En cok kullanilan identifier
    ('BasitKomut?al??t?r',                 'BasitKomutÇalıştır'),
    ('Ba?lant?DizesiDe?erDe?i?tir',        'BağlantıDizesiDeğerDeğiştir'),
    ('Bo?DataSet',                          'BoşDataSet'),

    # Sik gecen sozcukler
    ('Ba?ar?l?',     'Başarılı'),
    ('Ba?ar?s?z',    'Başarısız'),
    ('ba?ar?l?',     'başarılı'),
    ('ba?ar?s?z',    'başarısız'),
    ('Ba?l?k',       'Başlık'),
    ('Ba?l?',        'Başlı'),
    ('Ba?la',        'Başla'),
    ('ba?la',        'başla'),
    ('Ba?lat',       'Başlat'),
    ('Ba?lant?',     'Bağlantı'),
    ('ba?lant?',     'bağlantı'),

    ('De?i?tir',     'Değiştir'),
    ('de?i?tir',     'değiştir'),
    ('De?i?ti',      'Değişti'),
    ('De?i?ken',     'Değişken'),
    ('de?i?ken',     'değişken'),
    ('De?er',        'Değer'),
    ('de?er',        'değer'),
    ('De?',          'Değ'),
    ('de?',          'değ'),

    ('?al??t?r',     'Çalıştır'),
    ('?al??ma',      'Çalışma'),
    ('?al?s',        'Çalış'),
    ('?al??',        'Çalış'),
    ('?al?',         'Çalı'),
    ('al??t?r',      'alıştır'),
    ('al??ma',       'alışma'),
    ('al??',         'alış'),

    ('?ifre',        'Şifre'),
    ('?ifrele',      'Şifrele'),
    ('?ifreli',      'Şifreli'),
    ('?ifrelen',     'Şifrelen'),
    ('?ekil',        'Şekil'),
    ('?ehir',        'Şehir'),
    ('?ube',         'Şube'),
    ('?ah?s',        'Şahıs'),
    ('?irket',       'Şirket'),
    ('?irket?',      'Şirketi'),

    ('M??teri',      'Müşteri'),
    ('m??teri',      'müşteri'),
    ('?nvan',        'Ünvan'),
    ('?nvanl?',      'Ünvanlı'),
    ('?lke',         'Ülke'),
    ('?lkemiz',      'Ülkemiz'),
    ('?ye',          'Üye'),
    ('?yeli',        'Üyeli'),
    ('?retim',       'Üretim'),
    ('?retici',      'Üretici'),
    ('?st',          'Üst'),
    ('?rnek',        'Örnek'),
    ('?zel',         'Özel'),
    ('?nemli',       'Önemli'),
    ('?ne',          'Öne'),
    ('?neri',        'Öneri'),
    ('?nerilen',     'Önerilen'),
    ('?nce',         'Önce'),
    ('?nceki',       'Önceki'),
    ('?nce',         'Önce'),
    ('?demi',        'Ödemi'),
    ('?deme',        'Ödeme'),
    ('?denmi?',      'Ödenmiş'),
    ('?demeli',      'Ödemeli'),
    ('?denmemi?',    'Ödenmemiş'),

    ('I?lem',        'İşlem'),
    ('i?lem',        'işlem'),
    ('I?leme',       'İşleme'),
    ('I?lemleri',    'İşlemleri'),
    ('i?lemleri',    'işlemleri'),
    ('i?aretli',     'işaretli'),

    ('a??klama',     'açıklama'),
    ('A??klama',     'Açıklama'),
    ('A??K',         'AÇIK'),
    ('a??k',         'açık'),
    ('A?',           'Aç'),

    ('s?ras?nda',    'sırasında'),
    ('s?ra',         'sıra'),
    ('s?ral?',       'sıralı'),
    ('s?n?f',        'sınıf'),
    ('s?n?r',        'sınır'),
    ('s?n?rl?',      'sınırlı'),

    ('y?ll?k',       'yıllık'),
    ('y?l',          'yıl'),
    ('y?n',          'yön'),
    ('y?net',        'yönet'),
    ('y?nlendir',    'yönlendir'),

    ('g?nderil',     'gönderil'),
    ('G?nderil',     'Gönderil'),
    ('g?nder',       'gönder'),
    ('G?nder',       'Gönder'),
    ('g?ster',       'göster'),
    ('G?ster',       'Göster'),
    ('g?n',          'gün'),
    ('G?n',          'Gün'),
    ('g?venli',      'güvenli'),
    ('G?venli',      'Güvenli'),
    ('g?ncelle',     'güncelle'),
    ('G?ncelle',     'Güncelle'),
    ('g?ncelleme',   'güncelleme'),

    ('?ek',          'çek'),
    ('?ekil',        'şekil'),  # kucuk
    ('?ekilde',      'şekilde'),
    ('?ekli',        'şekli'),
    ('?ift',         'çift'),
    ('?o?u',         'çoğu'),
    ('?ok',          'çok'),
    ('?al???r',      'çalışır'),
    ('?al???yor',    'çalışıyor'),

    ('do?ru',        'doğru'),
    ('Do?ru',        'Doğru'),
    ('do?u',         'doğu'),
    ('do?um',        'doğum'),
    ('Do?um',        'Doğum'),

    ('e?itim',       'eğitim'),
    ('E?itim',       'Eğitim'),
    ('e?ri',         'eğri'),

    ('kar??',        'karşı'),
    ('kar??la',      'karşıla'),
    ('Kar??',        'Karşı'),
    ('Kar??la',      'Karşıla'),

    ('a?ama',        'aşama'),
    ('a?a??',        'aşağı'),
    ('a?a?',         'aşağ'),
    ('A?a??',        'Aşağı'),

    ('yan?t',        'yanıt'),
    ('Yan?t',        'Yanıt'),
    ('yapt?',        'yaptı'),
    ('yan?nda',      'yanında'),

    ('b?l?m',        'bölüm'),
    ('B?l?m',        'Bölüm'),
    ('b?ylesi',      'böylesi'),
    ('b?yle',        'böyle'),
    ('B?yle',        'Böyle'),

    ('?u',           'şu'),
    ('?unu',         'şunu'),
    ('?u an',        'şu an'),
    ('?artname',     'şartname'),

    ('al?n',         'alın'),
    ('Al?n',         'Alın'),
    ('ald?',         'aldı'),
    ('al??r',        'alır'),

    ('Var?',         'Varı'),
    ('Var?lan',      'Varılan'),
    ('Vars?l',       'Varsıl'),
    ('var?lan',      'varılan'),

    ('ge?',          'geç'),
    ('Ge?',          'Geç'),
    ('ge?en',        'geçen'),
    ('ge?ti',        'geçti'),
    ('ge?ici',       'geçici'),

    ('a?',           'aç'),  # son siralarda
    ('A?',           'Aç'),
    # 2. Pass - daha spesifik patternlar
    ('hatal?',       'hatalı'),
    ('Hatal?',       'Hatalı'),
    ('hatas?',       'hatası'),
    ('Hatas?',       'Hatası'),

    ('D?k?m',        'Döküm'),
    ('d?k?m',        'döküm'),
    ('D?k?mler',     'Dökümler'),
    ('D?k?manlar',   'Dökümanlar'),
    ('D?k?man',      'Döküman'),
    ('d?k?man',      'döküman'),
    ('Klas?r',       'Klasör'),
    ('klas?r',       'klasör'),

    ('Kullan?c?',    'Kullanıcı'),
    ('kullan?c?',    'kullanıcı'),

    ('?rsaliye',     'İrsaliye'),
    ('?rsaliye',     'İrsaliye'),

    ('mesaj?n?',     'mesajını'),
    ('mesaj?',       'mesajı'),

    ('ad?n?',        'adını'),
    ('ad?',          'adı'),
    ('Ad?',          'Adı'),

    ('K?sm?',        'Kısmı'),
    ('k?sm?',        'kısmı'),
    ('K?s?m',        'Kısım'),
    ('k?s?m',        'kısım'),

    ('Sat??',        'Satış'),
    ('sat??',        'satış'),
    ('Sat?n',        'Satın'),
    ('sat?n',        'satın'),

    ('D?n??',        'Dönüş'),
    ('d?n??',        'dönüş'),
    ('d?n??t?r',     'dönüştür'),
    ('D?n??t?r',     'Dönüştür'),

    ('Onayl?yor',    'Onaylıyor'),
    ('onayl?yor',    'onaylıyor'),
    ('Onayl?',       'Onaylı'),
    ('onayl?',       'onaylı'),

    ('bulal?m',      'bulalım'),
    ('Bulal?m',      'Bulalım'),
    ('yazal?m',      'yazalım'),
    ('alal?m',       'alalım'),
    ('bakal?m',      'bakalım'),
    ('olu?tural?m',  'oluşturalım'),
    ('atar?z',       'atarız'),

    ('Hen?z',        'Henüz'),
    ('hen?z',        'henüz'),

    ('olu?mam??',    'oluşmamış'),
    ('Olu?mam??',    'Oluşmamış'),
    ('olu?tu',       'oluştu'),
    ('Olu?tu',       'Oluştu'),
    ('olu?',         'oluş'),
    ('Olu?',         'Oluş'),
    ('olu?turul',    'oluşturul'),

    ('olmal?',       'olmalı'),
    ('Olmal?',       'Olmalı'),

    ('B?RDEN FAZLA D?NM??SE','BİRDEN FAZLA DÖNMÜŞSE'),
    ('D?NM??SE',     'DÖNMÜŞSE'),

    ('y?kleniy',     'yükleniy'),
    ('Y?kleniy',     'Yükleniy'),
    ('y?kle',        'yükle'),
    ('Y?kle',        'Yükle'),

    ('Dil y?kle',    'Dil yükle'),

    ('Onayl?',       'Onaylı'),

    ('?lemi',        'şlemi'),  # eg "i?lemi" -> "işlemi"
    ('?leme',        'şleme'),  # eg "i?leme" -> "işleme"

    ('Veri',         'Veri'),  # no-op for clarity
]

def fix_file(path):
    with open(path, 'rb') as f:
        data = f.read()
    if FFFD not in data:
        return 0, 0
    orig = data
    fixed = 0
    for pat_ascii, correct in REPLACEMENTS:
        if '?' not in pat_ascii:
            continue
        pat_bytes = p(pat_ascii)
        c = data.count(pat_bytes)
        if c > 0:
            data = data.replace(pat_bytes, b(correct))
            fixed += c
    remaining = data.count(FFFD)
    if data != orig:
        with open(path, 'wb') as f:
            f.write(data)
    return fixed, remaining

total_files = 0
total_fixed = 0
total_remaining = 0

for dirpath, dirs, files in os.walk(ROOT):
    dirs[:] = [d for d in dirs if d not in SKIP_DIRS]
    for f in files:
        if not f.lower().endswith(EXT):
            continue
        path = os.path.join(dirpath, f)
        fixed, remaining = fix_file(path)
        if fixed > 0 or remaining > 0:
            total_files += 1
            total_fixed += fixed
            total_remaining += remaining
            if fixed > 0 or remaining > 0:
                rel = os.path.relpath(path, ROOT)
                print(f"{rel}: fixed={fixed}, remaining={remaining}")

print(f"\nTotal: {total_files} files, {total_fixed} fixes applied, {total_remaining} FFFD remaining")
