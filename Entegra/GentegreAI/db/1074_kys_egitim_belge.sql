-- =============================================================================
--  1074  KURUMSAL KALİTE - EĞİTİM LİSTESİ BELGE KOLONU (Kalite2/egitim.html)
--
--  Kullanıcı (12.10.2026): "eğitim listesini mockup gibi yap". Belge kolonu
--  mockup'taki gibi belgenin TÜRÜNÜ yazar ("📎 katılım listesi",
--  "📎 sertifika"): belge_ozet = eğitime eklenmiş belgelerin türleri (tür
--  girilmemişse "belge"). Yeni kolon görünümün SONUNA eklenir. İdempotent.
-- =============================================================================

begin;

create or replace view public.v_kalite_egitim as
select min(e.id)                                       as id,
       e.ad,
       e.tur,
       case e.tur when 2 then 'Sertifika' else 'Eğitim' end as tur_adi,
       e.kurum                                         as egitmen,
       e.tarih                                         as tarih_metin,
       public.fn_kys_egitim_tarih(e.tarih)             as tarih,
       max(e.gecerlilik)                               as gecerlilik,
       e.sube_id,
       count(*)::integer                               as katilimci,
       string_agg(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), ', '
                  order by t.ad, t.soyad)              as katilimcilar,
       case when z.var then 1 else 0 end::smallint     as zorunlu,
       case when not z.var then 'İsteğe bağlı'
            when z.birim is not null then 'Zorunlu · ' || z.birim
            else 'Zorunlu' end                         as zorunlu_adi,
       (select count(*) from public.dokuman dk
         where dk.kaynak = 'kys-egitim' and dk.kaynak_id = min(e.id))::integer as belge_sayisi,
       (select string_agg(distinct lower(coalesce(nullif(dk.belge_turu, ''), 'belge')), ', ')
          from public.dokuman dk
         where dk.kaynak = 'kys-egitim' and dk.kaynak_id = min(e.id))::varchar(200) as belge_ozet
  from public.personel_egitim e
  join public.taraf t on t.id = e.taraf_id
  cross join lateral (
        select count(*) > 0 as var,
               min(d.ad) filter (where zz.departman_id is not null) as birim
          from public.kalite_zorunlu_egitim zz
          left join public.departman d on d.id = zz.departman_id
         where zz.aktif = 1 and public.fn_kys_egitim_anahtar(zz.egitim_adi) = public.fn_kys_egitim_anahtar(e.ad)) z
 where e.tur in (2, 3)
 group by e.ad, e.tur, e.kurum, e.tarih, e.sube_id, z.var, z.birim;

commit;
