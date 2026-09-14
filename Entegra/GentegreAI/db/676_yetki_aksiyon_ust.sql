-- ============================================================================
--  Gentegre AI — AKSİYON YETKİLERİNİN ÜST MODÜLÜ
--  676_yetki_aksiyon_ust.sql
--
--  668 aksiyon yetkilerini "kodun noktadan önceki parçası" ile modülüne
--  bağlıyordu. Çoğunda çalışır (lab.onay → lab) ama bir grup aksiyonun öneki
--  modül koduyla aynı değil: `kasa.kapat`ın modülü `kasa_islem`,
--  `rad.rapor_yaz`ınki `radyoloji`, `ebelge.gonder`inki `e_belge`.
--
--  Sonuç: bu satırlar matris ağacında modülünün altına giremeyip eski kısa
--  grup adlarıyla ("mali", "genel", "radyoloji") kendi başlıklarını açıyordu -
--  kullanıcı menüde olmayan beş ayrı başlık görüyordu.
--
--  Burada önek → modül kodu eşlemesi açıkça yazılır; eşleme ileride bir
--  aksiyon eklenirken de tek yerdedir.
-- ============================================================================
\set ON_ERROR_STOP on

drop table if exists gecici_aksiyon_ust;
create temporary table gecici_aksiyon_ust (onek varchar(30) primary key,
                                           ust varchar(60) not null);
insert into gecici_aksiyon_ust (onek, ust) values
    ('rad',      'radyoloji'),
    ('kasa',     'kasa_islem'),
    ('ebelge',   'e_belge'),
    ('ceksenet', 'cek_senet'),
    ('muhasebe', 'muhasebe_fis'),
    ('fis',      'muhasebe_fis'),
    -- Başvuru = Kayıt Kabul'ün belge ekranı; iskonto tavanı oraya aittir.
    ('basvuru',  'belge'),
    ('veri',     'ayar'),
    ('log',      'islem_log');

update public.yetki a
   set grup = u.grup,
       modul = case when a.modul = '' then u.modul else a.modul end,
       sira = (u.sira + 1)::smallint
  from gecici_aksiyon_ust m
  join public.yetki u on u.kod = m.ust and u.tur = 0
 where a.kod like '%.%'
   and split_part(a.kod, '.', 1) = m.onek;

drop table if exists gecici_aksiyon_ust;

do $$
begin
    raise notice '676 tamam: aksiyon yetkileri modullerinin grubuna tasindi.';
end $$;
