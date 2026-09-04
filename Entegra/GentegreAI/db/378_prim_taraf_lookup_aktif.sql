-- ============================================================================
--  378 - v_prim_taraf_lookup: HERKES COZULEBILIR (aktif = 1)
--
--  Kullanici "ekleniyor gibi ama satir gelmiyor" dedi. Satir GELIYORDU; Kişi
--  hucresi BOS gorunuyordu.
--
--  Kod listesi `where aktif = 1` ile suzuluyor (KartDeposu.KodTablosuSecenekleri).
--  377'de gorunume `durum` bazli bir aktif kolonu koymustum: 371 kisinin 212'si
--  aktif=0 dondugu icin kod listesine hic girmiyordu. Jenerik arama ise durum
--  suzgeci uygulamiyor - kullanici arayip sectigi kisi listede olmayinca satir
--  ADSIZ ciziliyordu.
--
--  IKI AYRI SORU KARISMISTI:
--      "kimi ARAYIP SECEBILIRIM"   -> arama ekraninin isi
--      "id'yi ADA CEVIREBILIYOR MUYUM" -> kod listesinin isi
--  Ikincisinde suzmek YANLIS: bugun aktif olan kisi yarin pasife alininca
--  PLANDA DURAN eski satir da adsiz kalirdi - kayit bozulmadan okunamaz hale
--  gelirdi.
--
--  Bu yuzden gorunum artik herkesi aktif=1 dondurur. Pasif kisiyi plana ekleme
--  karari kullanicinin; gridde "Prim Rolü" kolonu zaten uyariyor.
-- ============================================================================

create or replace view public.v_prim_taraf_lookup as
select t.id,
       t.unvan as ad,
       1 as aktif
  from public.taraf t
  join public.taraf_personel p on p.id = t.id;

comment on view public.v_prim_taraf_lookup is
  'Prim planina eklenebilecek kisiler (377/378): tum personel + dis hekim. '
  'aktif HEP 1 - bu gorunum "id -> ad" cevrimi icin kullaniliyor ve suzmek, '
  'pasife alinan kisinin PLANDA DURAN satirini da adsiz birakirdi.';
