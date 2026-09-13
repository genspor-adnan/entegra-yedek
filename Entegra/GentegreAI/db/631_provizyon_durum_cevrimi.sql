-- =====================================================================
--  631_provizyon_durum_cevrimi.sql
--  BAŞARISIZ PROVİZYON EKRANDA "ONAYLANDI" GÖRÜNÜYORDU.
--
--  İki ayrı sayı dizisi aynı kolona yazılıyordu:
--
--    `sigorta_provizyon.durum` (KANONİK, adapterin dili)
--      1 Taslak · 2 Gönderildi · 3 Onaylı · 4 Kısmi · 5 Red · 6 İptal
--
--    `belge_provizyon.oss_durum` (EKRAN, `provizyon.durum` kod listesi)
--      0 Alınmadı · 1 Onaylandı · 2 Reddedildi · 3 Kısmi Onay · 4 İptal
--
--  `fn_sigorta_ozet_tazele` (430) `oss_durum = p.durum` diyordu - çeviri yok.
--  Sonuç: ağ geçidi hatası yüzünden TASLAK (1) kalan provizyon ekranda
--  "Onaylandı" (1) oluyordu. Onaylı (3) "Kısmi Onay" (3), Red (5) ise
--  listede hiç olmayan bir değer olarak görünüyordu.
--
--  Para kararı veren bir alan: kurum payı ancak provizyon onaylıysa
--  faturalanmalı. Yanlış "Onaylandı" en pahalı hata yönünde yanılıyordu.
--
--  ÇEVİRİ ÖZETTE YAPILIR, kod listesi DEĞİŞTİRİLMEZ: aynı liste SGK/MEDULA
--  tarafında ELLE dolduruluyor (`sgk_durum`) ve orada 0-4 anlamı zaten
--  kullanımda; listeyi kanoniğe çevirmek girilmiş her SGK provizyonunun
--  anlamını kaydırırdı.
--
--  Gönderildi (2) ekranda "Alınmadı"dır: istek yola çıktı ama şirket henüz
--  bir karar bildirmedi - "onaylandı" demek için karar gerekir.
-- =====================================================================

create or replace function public.fn_sigorta_durum_ekran(p_kanonik smallint)
returns smallint language sql immutable as $govde$
    select case p_kanonik
               when 1 then 0::smallint   -- Taslak      -> Alınmadı
               when 2 then 0::smallint   -- Gönderildi  -> Alınmadı (karar yok)
               when 3 then 1::smallint   -- Onaylı      -> Onaylandı
               when 4 then 3::smallint   -- Kısmi       -> Kısmi Onay
               when 5 then 2::smallint   -- Red         -> Reddedildi
               when 6 then 4::smallint   -- İptal       -> İptal
               else 0::smallint
           end
$govde$;

comment on function public.fn_sigorta_durum_ekran(smallint) is
  '631: sigorta_provizyon.durum (kanonik) -> provizyon.durum kod listesi.';

create or replace function public.fn_sigorta_ozet_tazele(p_provizyon_id integer)
returns void language plpgsql as $govde$
declare p record;
begin
    select * into p from public.sigorta_provizyon where id = p_provizyon_id;
    if not found then return; end if;

    insert into public.belge_provizyon (id) values (p.belge_id)
    on conflict (id) do nothing;

    update public.belge_provizyon b
       set oss_kurum_id = coalesce((select h.kurum_id from public.sigorta_hesap h
                                     where h.id = p.hesap_id), b.oss_kurum_id),
           -- 631: kanonik durum ekran koduna çevrilir.
           oss_durum = public.fn_sigorta_durum_ekran(p.durum),
           oss_provizyon_no = p.provizyon_no,
           oss_provizyon_tarihi = p.provizyon_tarihi,
           oss_gecerlilik = p.gecerlilik,
           oss_tutar = p.sirket_payi,
           oss_karsilama = case when p.talep_toplam > 0
                                then round(p.sirket_payi * 100 / p.talep_toplam, 4)
                                else 0 end,
           oss_red_nedeni = p.red_nedeni,
           oss_police_no = coalesce((select pl.police_no from public.sigorta_police pl
                                      where pl.id = p.police_id), b.oss_police_no),
           oss_brans = p.brans_adi,
           degistiren = p.degistiren,
           degistirme_tarihi = now()
     where b.id = p.belge_id;
end $govde$;

-- ---------------------------------------------------------------- onarım
--  Yanlış yazılmış özetler düzeltilir. YALNIZ sigorta_provizyon'dan gelen
--  satırlara dokunulur: elle doldurulmuş ÖSS provizyonları (karşılığı olan
--  bir `sigorta_provizyon` kaydı yok) olduğu gibi kalır.
update public.belge_provizyon b
   set oss_durum = public.fn_sigorta_durum_ekran(p.durum)
  from (select distinct on (belge_id) belge_id, durum
          from public.sigorta_provizyon order by belge_id, id desc) p
 where p.belge_id = b.id
   and b.oss_durum <> public.fn_sigorta_durum_ekran(p.durum);

do $kontrol$
begin
    raise notice '631: ozet durumlari duzeltildi (ornek: taslak -> %, onayli -> %)',
        public.fn_sigorta_durum_ekran(1::smallint),
        public.fn_sigorta_durum_ekran(3::smallint);
end $kontrol$;
