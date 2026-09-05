-- ============================================================================
--  401 - ONAM / BILDIRIM / KATALOG YETKILERI (Faz 0)
--
--  398-400 ile gelen kaynaklarin yetki kodlari. Yetki kodu YOKSA kaynak
--  hicbir role verilemez; ekran acilir ama her istek 403 doner - sessiz bir
--  "calismiyor" hali. Bu yuzden sema ile ayni fazda aciliyor.
--
--  Yonetici rolune (id 1) otomatik tam yetki verilir; diger roller ekrandan
--  yetkilendirilir.
-- ============================================================================

insert into public.yetki (kod, ad, grup, sira, urun_modu)
select v.kod, v.ad, v.grup, v.sira, 0
  from (values
    ('onam',            'Onam (metin ve kayıtlar)', 'belge',   37),
    ('bildirim',        'Bildirim (kuyruk)',        'yonetim', 71),
    ('bildirim_sablon', 'Bildirim şablonları',      'yonetim', 72),
    ('katalog',         'Klinik kataloglar (ICD / ilaç)', 'yonetim', 73)
  ) as v(kod, ad, grup, sira)
 where not exists (select 1 from public.yetki y where y.kod = v.kod);

-- Yonetici rolu: yeni kaynaklarda tam yetki (rol_yetki duzeni: rol + yetki + islem).
insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil)
select 1, y.id, 1, 1, 1, 1
  from public.yetki y
 where y.kod in ('onam', 'bildirim', 'bildirim_sablon', 'katalog')
   and not exists (select 1 from public.rol_yetki r
                    where r.rol_id = 1 and r.yetki_id = y.id);

-- Yetki surumu ilerlesin: jetondaki surum eskiyince istemci yetkileri tazeler.
update public.rol set yetki_surumu = yetki_surumu + 1 where id = 1;
