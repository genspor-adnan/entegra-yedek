-- ============================================================================
--  Gentegre AI — ESKİ ONAY TABLOLARI DÜŞÜYOR
--  759_eski_onay_tablolari_dusuyor.sql
--
--  Kullanıcı: "satinalma_onay ve dokuman_onay tablolarını düşür."
--
--  738 satınalmanın zincirini, 758 dokümanınkini omurgaya taşımıştı; iki
--  göç de eski tabloyu YERİNDE BIRAKMIŞ ve başlığına "veri korunuyor; yeni
--  yazma buraya YAPILMAZ, bir dahaki sürümde düşer" notunu düşmüştü. Bu
--  dosya o adımı atıyor.
--
--  ============ DÜŞÜRMEDEN ÖNCE KANIT ARANIR ===========================
--  Tablo silmek geri alınamaz. Bu yüzden dosya önce OMURGADA KARŞILIĞININ
--  BULUNDUĞUNU doğruluyor: eski tablodaki her kayıt için `onay` satırı ve
--  her adım için `onay_adim` satırı olmalı. Sayılar tutmuyorsa göç eksik
--  demektir ve dosya HATA VEREREK DURUR - yarım göçün üstüne silmek,
--  onay geçmişini tamamen yok ederdi.
--
--  Kontrol sayıya değil EŞLEŞMEYE bakıyor: "aynı sayıda satır var" ile
--  "aynı kayıtlar var" farklı şeylerdir.
--
--  ============ `dokuman_surum.onay_id` YENİDEN EŞLENİR ================
--  Bu kolon eski `dokuman_onay.id`'yi gösteriyordu. Tablo düşünce hiçbir
--  şeye işaret etmeyen bir sayı kalırdı; omurgadaki `onay.id`'ye çevriliyor.
--  Kolonu tamamen düşürmüyoruz: zincir zaten `kaynak_tur 976 + kaynak_id`
--  ile bulunabiliyor ama kolon kartta ve liste kaynağında okunuyor.
-- ============================================================================
\set ON_ERROR_STOP on

-- ---------------------------------------------------------------------------
--  1) GÖÇÜN TAM OLDUĞU DOĞRULANIR
-- ---------------------------------------------------------------------------
do $$
declare
  v_eksik_talep  int;
  v_eksik_surum  int;
  v_eksik_adim   int;
begin
    -- Satınalma: her talebin omurgada bir zinciri olmalı.
    select count(*) into v_eksik_talep
      from (select distinct talep_id from public.satinalma_onay) o
     where not exists (select 1 from public.onay n
                        where n.kaynak_tur = 1241 and n.kaynak_id = o.talep_id);

    -- Doküman: her sürecin omurgada bir zinciri olmalı.
    select count(*) into v_eksik_surum
      from public.dokuman_onay o
     where o.surum_id is not null
       and not exists (select 1 from public.onay n
                        where n.kaynak_tur = 976 and n.kaynak_id = o.surum_id);

    -- ...ve her adımın bir basamağı.
    select count(*) into v_eksik_adim
      from public.dokuman_onay_adim a
      join public.dokuman_onay o on o.id = a.onay_id
     where o.surum_id is not null
       and not exists (select 1 from public.onay_adim x
                        join public.onay n on n.id = x.onay_id
                       where n.kaynak_tur = 976 and n.kaynak_id = o.surum_id
                         and x.sira = a.sira);

    if v_eksik_talep > 0 or v_eksik_surum > 0 or v_eksik_adim > 0 then
        raise exception
          'GOC EKSIK - tablolar DUSURULMEDI. Omurgada karsiligi olmayan: '
          '% satinalma talebi, % dokuman sureci, % dokuman adimi. '
          'Once 738 ve 758 gocleri uygulanmali.',
          v_eksik_talep, v_eksik_surum, v_eksik_adim
          using errcode = 'GK422';
    end if;

    raise notice '759: goc dogrulandi, eski tablolar dusurulebilir.';
end $$;

-- ---------------------------------------------------------------------------
--  2) `dokuman_surum.onay_id` OMURGAYI GÖSTERSİN
-- ---------------------------------------------------------------------------
update public.dokuman_surum s
   set onay_id = n.id
  from public.onay n
 where n.kaynak_tur = 976 and n.kaynak_id = s.id
   and s.onay_id is distinct from n.id;

comment on column public.dokuman_surum.onay_id is
  '419/759: ARTIK onay.id (onceden dokuman_onay.id). Zincir kaynak_tur 976 + '
  'kaynak_id = surum.id ile de bulunabilir.';

-- ---------------------------------------------------------------------------
--  3) TABLOLAR DÜŞÜYOR
--     `dokuman_onay_adim` `dokuman_onay`ın çocuğu - ayrı bir anlamı yok,
--     onunla birlikte gider. `satinalma_onay`ın `satinalma_talep` ve `taraf`a
--     giden FK'ları var; onlar DÜŞEN tarafta olduğu için kısıt kendiliğinden
--     kalkar, hedef tablolara dokunulmaz.
--
--     `dokuman_akis` / `dokuman_akis_adim` BU DOSYADA DÜŞMÜYOR: kullanıcı
--     onları saymadı ve akış tanımı, yürüyen süreçten ayrı bir karardır.
--     Artık hiçbir kod onlara bakmıyor (758'de `onay_akis`e taşındılar);
--     istendiğinde ayrı bir dosyayla düşerler.
-- ---------------------------------------------------------------------------
drop table if exists public.dokuman_onay_adim;
drop table if exists public.dokuman_onay;
drop table if exists public.satinalma_onay;

do $$
declare v_kalan int;
begin
    select count(*) into v_kalan from information_schema.tables
     where table_schema = 'public'
       and table_name in ('satinalma_onay', 'dokuman_onay', 'dokuman_onay_adim');
    raise notice '759 tamam: eski onay tablolari dusuruldu (kalan %).', v_kalan;
end $$;
