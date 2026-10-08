-- =====================================================================
-- 995 - banko_oturum.vardiya 30 -> 60 karakter
--
-- Vardiya metni sunucuda uretiliyor: "Gece / nöbet · 18:00-08:00 (+1 gün)"
--   = 35 karakter. 987'de kolon varchar(30) acilmisti (serbest metin
--   dusunulmustu); uretilen metin kirpiliyordu ("... (+1").
--
-- Ertesi gune tasan vardiya damgasi (+1 gun) metnin PARCASI: tutanakta
--   "18:00-08:00" tek basina hangi gune ait oldugunu soylemiyor.
-- =====================================================================

-- GORUNUM KOLONA BAGLI (v_banko_oturum_ozet): PG kolon tipini gorunum
--   varken degistirmiyor. Gorunum dusurulup ayni tanimla yeniden kuruluyor.
drop view if exists public.v_banko_oturum_ozet;

alter table public.banko_oturum alter column vardiya type varchar(60);

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

do $$
begin
  raise notice '995: banko_oturum.vardiya varchar(60)';
end $$;
