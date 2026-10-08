-- =====================================================================
-- 994 - BANKO OTURUMU: vardiya SECENEKLI + formatli saatler
--
-- Kullanici 08.10.2026: "Banko Oturumu kartinda vardiya secenekli olsun,
--   tum gun opsiyonu da olabilir, saatler formatli olsun".
--
-- NEDEN KOD + SAAT: vardiya serbest metindi ("Sabah", "sabah vardiyasi",
--   "08-16" hepsi ayni seyi anlatiyordu) ve bu haliyle ne suzulebiliyor ne
--   de iki oturum karsilastirilabiliyordu. Kod sabit, saatler 'HH:MM'
--   (semanin diger saat kolonlariyla ayni bicim).
--
-- GORUNEN METIN (`vardiya`) DURUYOR ve sunucuda uretiliyor: "Sabah ·
--   08:00-16:00". Tutanak ve listeler onu basiyor - iki yerde bicim
--   kurmamak icin tek kaynak.
-- =====================================================================

alter table public.banko_oturum
    -- 1 Sabah · 2 Ogleden sonra · 3 Aksam · 4 Gece/Nobet · 9 Tum gun
    add column if not exists vardiya_kod smallint not null default 0,
    add column if not exists vardiya_bas varchar(5) not null default '',
    add column if not exists vardiya_bit varchar(5) not null default '';

-- Ozet gorunumu yeni kolonlari tasir (kolon EKLENDIGI icin yeniden kurulur).
drop view if exists public.v_banko_oturum_ozet;
create view public.v_banko_oturum_ozet as
select o.id,
       o.banko_id, b.kod as banko_kod, b.ad as banko_ad, b.hesap_id,
       b.acilis_onay, b.gun_sonu_onay, b.kupur_dokumu, b.devir_tutar as banko_devir_hedef,
       o.sube_id, o.kullanici_id, o.vardiya, o.vardiya_kod, o.vardiya_bas, o.vardiya_bit,
       o.durum,
       o.acilis_talep_ts, o.acilis_ts, o.kapanis_talep_ts, o.kapanis_ts,
       o.devir_tutar, o.acilis_sayim, o.acilis_fark, o.acilis_not,
       o.acilis_onay_id, o.acilis_onay_ts, o.red_neden,
       o.kapanis_sayim, o.kapanis_beklenen, o.kapanis_fark, o.fark_neden,
       o.fark_aciklama, o.fark_islem_id, o.kasada_birakilan, o.teslim_edilen,
       o.teslim_alan_id, o.kapanis_onay_id, o.kapanis_onay_ts, o.tutanak_no,
       coalesce(h.nakit, 0)::numeric(18,2)   as nakit_tahsilat,
       coalesce(h.nakit_iade, 0)::numeric(18,2) as nakit_iade,
       coalesce(h.pos, 0)::numeric(18,2)     as pos_tutar,
       coalesce(h.banka, 0)::numeric(18,2)   as banka_tutar,
       coalesce(h.cek, 0)::numeric(18,2)     as cek_tutar,
       coalesce(h.adet, 0)                   as islem_adet,
       (o.devir_tutar + o.acilis_fark + coalesce(h.nakit, 0) - coalesce(h.nakit_iade, 0))
         ::numeric(18,2)                     as beklenen_nakit
  from public.banko_oturum o
  join public.banko b on b.id = o.banko_id
  left join (
        select k.oturum_id,
               sum(case when t.ana_hesap_turu = 'K' and t.yon > 0 then k.yerel_tutar else 0 end) as nakit,
               sum(case when t.ana_hesap_turu = 'K' and t.yon < 0 then k.yerel_tutar else 0 end) as nakit_iade,
               sum(case when t.ana_hesap_turu = 'P' then k.yerel_tutar else 0 end)               as pos,
               sum(case when t.ana_hesap_turu = 'B' then k.yerel_tutar else 0 end)               as banka,
               sum(case when t.grup = 'ceksenet' then k.yerel_tutar else 0 end)                  as cek,
               count(*)                                                                          as adet
          from public.kasa_islem k
          join public.kasa_islem_turu t on t.kod = k.tur
         where k.oturum_id is not null and k.durum <> 9
           and k.kaynak_tur is distinct from 1385
         group by k.oturum_id) h on h.oturum_id = o.id;

-- VARDIYA SAATLERI KURUM AYARI: varsayilanlar burada, kurum kendi
--   mesaisine gore degistirebilir. Bicim "bas-bit" ('HH:MM-HH:MM').
insert into public.referans (anahtar, deger, aciklama)
select v.anahtar, v.deger, v.aciklama
  from (values
    ('banko.vardiya1', '08:00-16:00', 'Sabah vardiyası saatleri'),
    ('banko.vardiya2', '12:00-20:00', 'Öğleden sonra vardiyası saatleri'),
    ('banko.vardiya3', '16:00-24:00', 'Akşam vardiyası saatleri'),
    ('banko.vardiya4', '00:00-08:00', 'Gece / nöbet vardiyası saatleri'),
    ('banko.vardiya9', '08:00-22:00', 'Tüm gün seçeneğinin saatleri')
  ) as v(anahtar, deger, aciklama)
 where not exists (select 1 from public.referans r where r.anahtar = v.anahtar);

do $$
begin
  raise notice '994: vardiya_kod/bas/bit kolonlari + vardiya saati ayarlari hazir';
end $$;
