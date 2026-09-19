-- ============================================================================
--  Gentegre AI — ETKEN MADDE YERİNE ATC SINIF ADI YAZILMIŞ KAYITLAR (860)
--  860_etken_madde_atc_sinif_onarimi.sql
--
--  Kullanıcı: *"ATC sınıf adı yazanları da onar"*.
--  `etken_madde` alanında 336 satırda etkin madde yerine WHO ATC SINIF
--  METNİ duruyor: "carbohydrates", "electrolytes with carbohydrates",
--  "other cold preparations", "peritoneal dialytics", "various"…
--
--  ============ 84 SATIR ONARILDI, GERİ KALANI DEĞİL ==================
--  İki ispat yolu kullanıldı; ikisi de tutmayan satıra DOKUNULMADI.
--
--  (1) ÜRÜN ADI BİLEŞİMİ YAZIYOR + ATC SINIFIYLA TUTARLI  (74 satır)
--      B05BA03 "carbohydrates" = yalnız karbonhidrat içerir; ürün adında
--      hangi şeker olduğu yazılı: "NEOFLEKS %10 DEKSTROZ SUDAKI
--      ÇÖZELTİSİ" → dekstroz, "BIOFLEKS %5 FRUKTOZ" → fruktoz.
--      B05BB02 "electrolytes with carbohydrates" = elektrolit + karbonhidrat;
--      yalnız ADINDA HER İKİSİ DE geçen satır onarıldı ("%20 MEQ/L
--      POTASYUM KLORÜR … %5 DEKSTROZ" → potasyum klorür, dekstroz).
--      Adında elektrolit geçmeyen 10 satır (ISOSOL-P, IZOMIX, NEOFLEKS
--      LAKTATLI RINGER) ATLANDI: bileşim ADDA TAM DEĞİL, eksik yazmak
--      sınıf metninden kötü olurdu.
--
--  (2) AYNI ATC KODUNDA TEK BİR BULUNAN BİLEŞİM VAR  (10 satır)
--      R06AA11 → dimenhidrinat (ANTI-EM), M01AG → etofenamat (FLEXO),
--      R02AA15 → povidon iyodin (BATIODIN), R01AX10 → sodyum klorür
--      (SERUM FİZYOLOJİK), N02AJ06 → parasetamol, kodein fosfat (PAROL-K).
--      Karşılaştırma yazım farkına duyarsız yapıldı (INN'e çevirip
--      sözcükleri sıralayarak), kodda tek bileşim kalmıyorsa ATLANDI.
--
--  ============ ONARILMAYAN 252 SATIR ==================================
--  Bileşim ne ürün adından ne de katalogdan çıkarılabiliyor:
--    · R05X  "other cold preparations" (38) - soğuk algınlığı
--      kombinasyonları, her ürün farklı.
--    · B05D  "peritoneal dialytics" / "hypertonic solutions" (62) -
--      periton diyaliz çözeltileri; bileşen listesi aynı ama
--      derişimler ürüne göre değişiyor, komşu satırdan kopyalamak
--      yanıltıcı olur.
--    · B05BA10 / B05BA01 "combinations" / "amino acids" (37) - AMINOMIX,
--      AMINOVEN: 15-18 amino asitlik listeler ürüne göre değişiyor.
--    · B05Z* hemodiyaliz çözeltileri (24), vitamin/mineral karışımları,
--      "various" (8) ve benzerleri.
--  Bunların doğrusu ürünün kendi formülünden (KUB/TİTCK) gelmeli.
--
--  ============ GÜVENLİK ==============================================
--  · Etkilenen satırlar `ilac_etken_yedek_860` tablosuna kopyalanır.
--  · Güncelleme hem ID hem ESKİ METNİ eşleştirir; ikinci çalıştırma
--    0 satır günceller.
-- ============================================================================
\set ON_ERROR_STOP on
begin;

create table if not exists public.ilac_etken_yedek_860 (
    id           integer primary key,
    etken_madde  character varying(300) not null,
    yedek_tarihi timestamptz not null default now()
);

with d(id, eski, yeni) as (values
    (1049, 'other antiemetics', 'dimenhidrinat'),
    (1050, 'other antiemetics', 'dimenhidrinat'),
    (1051, 'other antiemetics', 'dimenhidrinat'),
    (1052, 'other antiemetics', 'dimenhidrinat'),
    (1737, 'various', 'povidon iyodin'),
    (2073, 'electrolytes with carbohydrates', 'potasyum klorür, dekstroz'),
    (2074, 'electrolytes with carbohydrates', 'potasyum klorür, dekstroz'),
    (2077, 'electrolytes with carbohydrates', 'potasyum klorür, dekstroz'),
    (2078, 'electrolytes with carbohydrates', 'potasyum klorür, dekstroz'),
    (2079, 'electrolytes with carbohydrates', 'potasyum klorür, dekstroz'),
    (2080, 'electrolytes with carbohydrates', 'potasyum klorür, dekstroz'),
    (2083, 'electrolytes with carbohydrates', 'sodyum klorür, dekstroz'),
    (2088, 'electrolytes with carbohydrates', 'sodyum klorür, dekstroz'),
    (2094, 'electrolytes with carbohydrates', 'sodyum klorür, dekstroz'),
    (2095, 'electrolytes with carbohydrates', 'sodyum klorür, dekstroz'),
    (2096, 'electrolytes with carbohydrates', 'sodyum klorür, dekstroz'),
    (2097, 'electrolytes with carbohydrates', 'sodyum klorür, dekstroz'),
    (2111, 'carbohydrates', 'fruktoz'),
    (2112, 'carbohydrates', 'fruktoz'),
    (2113, 'carbohydrates', 'fruktoz'),
    (2114, 'carbohydrates', 'fruktoz'),
    (2115, 'carbohydrates', 'fruktoz'),
    (2116, 'carbohydrates', 'fruktoz'),
    (2117, 'electrolytes with carbohydrates', 'potasyum klorür, dekstroz'),
    (2118, 'electrolytes with carbohydrates', 'potasyum klorür, dekstroz'),
    (2119, 'electrolytes with carbohydrates', 'potasyum klorür, dekstroz'),
    (2120, 'electrolytes with carbohydrates', 'potasyum klorür, dekstroz'),
    (2121, 'electrolytes with carbohydrates', 'potasyum klorür, dekstroz'),
    (2122, 'electrolytes with carbohydrates', 'potasyum klorür, dekstroz'),
    (2123, 'electrolytes with carbohydrates', 'potasyum klorür, dekstroz'),
    (2124, 'electrolytes with carbohydrates', 'potasyum klorür, dekstroz'),
    (2125, 'electrolytes with carbohydrates', 'potasyum klorür, dekstroz'),
    (2126, 'electrolytes with carbohydrates', 'potasyum klorür, dekstroz'),
    (5682, 'fenamates', 'etofenamat'),
    (5683, 'fenamates', 'etofenamat'),
    (5927, 'carbohydrates', 'fruktoz'),
    (5928, 'carbohydrates', 'fruktoz'),
    (5929, 'carbohydrates', 'fruktoz'),
    (5930, 'carbohydrates', 'fruktoz'),
    (5931, 'carbohydrates', 'fruktoz'),
    (5932, 'carbohydrates', 'fruktoz'),
    (7220, 'various', 'povidon iyodin'),
    (10167, 'carbohydrates', 'dekstroz'),
    (10168, 'carbohydrates', 'dekstroz'),
    (10169, 'carbohydrates', 'dekstroz'),
    (10170, 'carbohydrates', 'dekstroz'),
    (10171, 'carbohydrates', 'dekstroz'),
    (10172, 'carbohydrates', 'dekstroz'),
    (10173, 'carbohydrates', 'dekstroz'),
    (10174, 'carbohydrates', 'dekstroz'),
    (10175, 'carbohydrates', 'dekstroz'),
    (10176, 'carbohydrates', 'dekstroz'),
    (10177, 'carbohydrates', 'dekstroz'),
    (10178, 'carbohydrates', 'dekstroz'),
    (10179, 'carbohydrates', 'dekstroz'),
    (10180, 'carbohydrates', 'dekstroz'),
    (10181, 'carbohydrates', 'dekstroz'),
    (10182, 'carbohydrates', 'dekstroz'),
    (10183, 'carbohydrates', 'dekstroz'),
    (10184, 'carbohydrates', 'dekstroz'),
    (10185, 'carbohydrates', 'dekstroz'),
    (10186, 'carbohydrates', 'dekstroz'),
    (10204, 'carbohydrates', 'dekstroz'),
    (10205, 'carbohydrates', 'dekstroz'),
    (10206, 'carbohydrates', 'dekstroz'),
    (10207, 'carbohydrates', 'dekstroz'),
    (10208, 'carbohydrates', 'dekstroz'),
    (10209, 'carbohydrates', 'dekstroz'),
    (10210, 'carbohydrates', 'dekstroz'),
    (10211, 'carbohydrates', 'dekstroz'),
    (10212, 'carbohydrates', 'dekstroz'),
    (10213, 'carbohydrates', 'dekstroz'),
    (10214, 'electrolytes with carbohydrates', 'sodyum klorür, dekstroz'),
    (10215, 'electrolytes with carbohydrates', 'sodyum klorür, dekstroz'),
    (10216, 'electrolytes with carbohydrates', 'sodyum klorür, dekstroz'),
    (10217, 'electrolytes with carbohydrates', 'sodyum klorür, dekstroz'),
    (10218, 'electrolytes with carbohydrates', 'sodyum klorür, dekstroz'),
    (10219, 'electrolytes with carbohydrates', 'sodyum klorür, dekstroz'),
    (10220, 'electrolytes with carbohydrates', 'sodyum klorür, dekstroz'),
    (10221, 'electrolytes with carbohydrates', 'sodyum klorür, dekstroz'),
    (10234, 'carbohydrates', 'dekstroz'),
    (10235, 'carbohydrates', 'dekstroz'),
    (11568, 'other cold preparations', 'parasetamol, kodein fosfat'),
    (14109, 'various', 'sodyum klorür')
)
, y as (
    insert into public.ilac_etken_yedek_860 (id, etken_madde)
    select i.id, i.etken_madde from public.ilac i join d on d.id = i.id
     where i.etken_madde = d.eski
    on conflict (id) do nothing
    returning 1
)
update public.ilac i set etken_madde = d.yeni, guncelleme = now()
  from d where i.id = d.id and i.etken_madde = d.eski;

do $$
declare v_yedek integer; v_kalan integer;
begin
    select count(*) into v_yedek from public.ilac_etken_yedek_860;
    select count(*) into v_kalan from public.ilac
     -- Sinif metni listesi acikca yazilir: LIKE kalibi baska satirlari da yakaliyordu.
     where lower(etken_madde) in ('amino acids', 'amino acids, incl. combinations with polypeptides', 'carbohydrates', 'combinations', 'edetates', 'electrolytes', 'electrolytes in combination with other drugs', 'electrolytes with carbohydrates', 'fat emulsions', 'fenamates', 'gelatin agents', 'hemodialytics and hemofiltrates', 'hemodialytics, concentrates', 'hemofiltrates', 'hypertonic solutions', 'immunoglobulins, normal human, for intravascular adm.', 'multivitamins and trace elements', 'multivitamins, minerals', 'multivitamins, plain', 'other antiemetics', 'other cold preparations', 'other preparations, combinations', 'other respiratory system products', 'peritoneal dialytics', 'various', 'vitamins', 'vitamins with minerals', 'vitamins, other combinations', 'wart and anti-corn preparations');
    raise notice '860 tamam: onarilan % satir. ATC sinif metni kalan: %.', v_yedek, v_kalan;
end $$;

commit;
