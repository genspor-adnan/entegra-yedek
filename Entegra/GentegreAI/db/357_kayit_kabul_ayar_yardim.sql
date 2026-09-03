-- ============================================================================
--  357 - KAYIT KABUL AYARLARI: yardim metinleri (kullanici)
--
--  "tahsilatta pos için alttaki açıklamayı help'e taşı" - ayar ekranlarinda
--  GENEL KURAL: aciklama alt paragrafta degil, editin sagindaki "?" ikonunda.
--  Dosya no / protokol no ayarlarinin metinleri de ayni yere.
-- ============================================================================
insert into public.help (anahtar, dil, baslik, metin) values
('ayar.basvuru.pos_aksiyon', 0, 'Tahsilatta POS',
 'Başvuruya POS (kredi kartı) tahsilatı işlendiğinde ne yapılacağını belirler.'
 || E'\n\n'
 || 'Aksiyon Yok: hiçbir belge üretilmez, tahsilat başvuruda durur.'
 || E'\n'
 || 'Otomatik Fiş Oluşsun: tahsilat penceresi kapanınca satış fişi kendiliğinden kesilir.'
 || E'\n'
 || 'Soru sorulsun: fiş kesilmeden önce onay istenir.'
 || E'\n\n'
 || 'Fiş TAHSİL EDİLEN TUTAR KADAR kesilir: her ücret satırında hasta payının '
 || 'kalanı ile o satıra dağıtılmış tahsilatın küçüğü alınır. Ekranda tutarlar '
 || 'KDV dahildir, fişe KDV hariç matrah olarak yazılır.'
 || E'\n\n'
 || 'Kalan tutar başvuruda AÇIK kalır; istenirse Faturalama sekmesinden '
 || 'tahakkuka çevrilir.'),
('ayar.hasta.dosya_no_otomatik', 0, 'Dosya no otomatik üretilsin',
 'Açıkken hasta kartında Dosya No boş bırakılabilir; kayıt sırasında sıradaki '
 || 'numara verilir (sıfır dolgulu 8 hane, örn. 00000123).'
 || E'\n\n'
 || 'Numara sırası mevcut sayısal dosya numaralarının en büyüğünden devam eder; '
 || 'harf içeren eski numaralar (H2026-002) sırayı etkilemez.'
 || E'\n\n'
 || 'Kapalıyken Dosya No zorunludur ve elle girilir. Ayar açıkken de elle numara '
 || 'yazılabilir - girilen numara korunur.'),
('ayar.basvuru.protokol_no_otomatik', 0, 'Protokol no otomatik üretilsin',
 'Açıkken başvurunun protokol numarası kaydederken sunucuda üretilir (belge '
 || 'serisi ve numara şablonuna göre); alan kartta salt okunur görünür.'
 || E'\n\n'
 || 'Kapalıyken kayıt kabul memuru protokol numarasını elle yazabilir. Boş '
 || 'bırakılırsa numara yine otomatik verilir - başvuru numarasız kalmaz.')
on conflict (anahtar, dil) do update
   set baslik = excluded.baslik, metin = excluded.metin;
