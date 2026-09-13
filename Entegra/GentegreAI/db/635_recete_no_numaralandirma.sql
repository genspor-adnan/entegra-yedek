-- =====================================================================
--  635_recete_no_numaralandirma.sql
--  REÇETE NO da Hasta Belgeleri numaralandırmasına girdi (kullanici:
--  "hasta belgeleri ne Muayene No ve Reçete No da ekle").
--
--  `recete.recete_no` kolonu vardı ama HİÇ DOLDURULMUYORDU - muayene no ve
--  radyoloji accession no ile aynı durum (634). Reçete kartında ve hasta
--  reçete listesinde salt okunur bir kolon olarak duruyor, hep boş.
--
--  TÜR 905, sıra 4: reçete muayenenin çıktısıdır - hastanın yolunda
--  muayeneden hemen sonra gelir, tetkiklerden (lab/radyoloji) önce. Sıra
--  görünümde tutulur; grid alfabetik dizilseydi bu akış bozulurdu.
--
--  ŞABLONSUZ BOŞ KALIR (634'teki kural): numarası olmayan bir alana
--  kendiliğinden numara basmak, kurumun istemediği bir kimliği kayıtlara
--  yazmak olurdu. MEDULA reçete numarası AYRI bir şeydir - o dışarıdan
--  gelir, buradaki numara kurumun kendi takip numarasıdır.
-- =====================================================================

create or replace view public.v_numara_turu_kimlik as
 select 900 as id, 'Hasta Dosya No'::varchar as ad, 1::smallint as aktif,
        1::smallint as sira
union all
 select  19, 'Başvuru Protokol No'::varchar,  1::smallint, 2::smallint
union all
 select 902, 'Muayene No'::varchar,           1::smallint, 3::smallint
union all
 select 905, 'Reçete No'::varchar,            1::smallint, 4::smallint
union all
 select 901, 'Laboratuvar İstem No'::varchar, 1::smallint, 5::smallint
union all
 select 903, 'Radyoloji İstem No'::varchar,   1::smallint, 6::smallint
union all
 select 904, 'e-Nabız Paket No'::varchar,     1::smallint, 7::smallint;

comment on view public.v_numara_turu_kimlik is
  '635: hasta belgelerinin numara turleri. `sira` hastanin izledigi yolu '
  'verir (dosya > protokol > muayene > recete > lab > radyoloji > e-Nabiz).';

do $kontrol$
begin
    raise notice '635 tamam: % kimlik numara turu', 
        (select count(*) from public.v_numara_turu_kimlik);
end $kontrol$;
