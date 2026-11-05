-- =============================================================================
--  1269  CARİ İCMALİ: KÜÇÜK BAKİYE EŞİĞİ + KURUŞ FARKI KAPATMA  (kullanıcı 05.11.2026: "Cari İcmali'nde 10 kuruştan
--        küçük bakiyeli kayıtlar var, kalabalık oluyor" -> "1 ve 2")
--
--  ZONE'da 75 cari 10 kuruşun altında (toplam -0,16 TL); sebep Delphi'de girilmiş tahsilat ile fatura arasındaki
--  kuruş farkı (120.01.570: 24.410,08 tahsilat / 24.410,09 fatura) - hesap doğru, fark gerçek.
--
--  1) EŞİK: `cari.icmal_esik` (varsayılan 0,10 TL). İcmal mutlak bakiyesi eşiğin altındaki carileri ayrı sayar;
--     ekran gizler, dipte "N cari eşik altında, toplam X" yazar. Bakiye silinmez, ekstre / mutabakat aynen.
--  2) KURUŞ FARKI KAPATMA: iki kasa işlem türü (hesapsız, cari + kalem bacağı; motor 076/393 'masraf' / 'kalem'
--     rolleri):
--        60 Kuruş Farkı Gideri  - müşteri borcu küçükse: cari ALACAK (kapanır), gider kalemi BORÇ  (masraf_id)
--        62 Kuruş Farkı Geliri  - cari alacaklıysa:       cari BORÇ (kapanır),   gelir kalemi ALACAK (hizmet_id)
--     Cari İcmali'ndeki "Kuruş farklarını kapat" aksiyonu (yetki finans.kurus_kapat; Cari İcmali'ni DEĞİŞTİRebilen
--     rollere açık) eşik altındaki her cariye bir işlem yazar - normal kasa işlemi: loglu, ekstrede görünür,
--     iptal edilebilir. Varsayılan kalemler `cari.kurus_gider_id` / `cari.kurus_gelir_id` (Genel Ayarlar).
--  İdempotent.
-- =============================================================================
\set ON_ERROR_STOP on

begin;

-- ---------------------------------------------------------------- ayarlar --
insert into public.referans (anahtar, deger, tip, aciklama)
select v.anahtar, v.deger, v.tip, v.aciklama
  from (values
    ('cari.icmal_esik',     '0,10', 'metin', 'Cari İcmali: mutlak bakiyesi bu tutarın altındaki cariler "küçük bakiye" sayılır, TL (boş = 0,10)'),
    ('cari.kurus_gider_id', '',     'sayi',  'Kuruş farkı kapatma: gider kalemi (masraf) no - müşteri borcu silinirken'),
    ('cari.kurus_gelir_id', '',     'sayi',  'Kuruş farkı kapatma: gelir kalemi (hizmet) no - cari alacağı silinirken')) v(anahtar, deger, tip, aciklama)
 where not exists (select 1 from public.referans r where r.anahtar = v.anahtar);

-- --------------------------------------------------------- işlem türleri --
insert into public.kasa_islem_turu (kod, ad, grup, yon, ana_hesap_turu, karsi_hesap_turu, cari_zorunlu,
                                    kalem_turu, plan_mi, cari_ekstre, hesap_ekstre, bakiye_dahil, fis_mi,
                                    fis_turu, sablon, makbuz_basligi, makbuz_seri, sira, aktif, stok_etkiler, cari_etkiler)
values
 (60, 'Kuruş Farkı Gideri', 'kurfarki', 0, '', '', 1, 1, 0, 1, 0, 1, 1, 1,
  '[{"rol":"cari","yon":"A","tutar":"@tutar"},{"rol":"masraf","yon":"B","tutar":"@tutar"}]',
  'Kurus Farki Fisi', 'V', 360, 1, 0, 1),
 (62, 'Kuruş Farkı Geliri', 'kurfarki', 0, '', '', 1, 2, 0, 1, 0, 1, 1, 1,
  '[{"rol":"cari","yon":"B","tutar":"@tutar"},{"rol":"kalem","yon":"A","tutar":"@tutar"}]',
  'Kurus Farki Fisi', 'V', 361, 1, 0, 1)
on conflict (kod) do update set ad = excluded.ad, grup = excluded.grup, cari_zorunlu = excluded.cari_zorunlu,
    kalem_turu = excluded.kalem_turu, sablon = excluded.sablon, cari_etkiler = excluded.cari_etkiler, aktif = 1;

-- ------------------------------------------------------------ yetki (aksiyon) --
insert into public.yetki (kod, ad, grup, tur, sira, urun_modu, modul)
select 'finans.kurus_kapat', 'Kuruş farklarını kapat (Cari İcmali)', 'Finans', 1, ye.sira, ye.urun_modu, ye.modul
  from public.yetki ye where ye.kod = 'finans.cari_icmali'
on conflict (kod) do update set ad = excluded.ad, grup = excluded.grup, tur = excluded.tur, aktif = 1;

-- Cari İcmali'ni DEĞİŞTİRebilen roller aksiyonu alır (1186 deseni).
insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, deger, kapsam, ekleyen)
select ry.rol_id, yn.id, 1, 0, 0, 0, ry.deger, ry.kapsam, 0
  from public.yetki ye
  join public.yetki yn     on yn.kod = 'finans.kurus_kapat'
  join public.rol_yetki ry on ry.yetki_id = ye.id
 where ye.kod = 'finans.cari_icmali' and coalesce(ry.degistir, 0) = 1
on conflict (rol_id, yetki_id) do nothing;

update public.rol r set yetki_surumu = yetki_surumu + 1
 where exists (select 1 from public.rol_yetki ry join public.yetki y on y.id = ry.yetki_id
                where ry.rol_id = r.id and y.kod = 'finans.kurus_kapat');

commit;
