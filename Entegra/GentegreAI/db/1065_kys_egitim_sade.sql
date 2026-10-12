-- =============================================================================
--  1065  KURUMSAL KALİTE - EĞİTİM MOCKUP'A UYDU (Kalite2/egitim.html)
--
--  Kullanıcı (12.10.2026): "eğitimi mockup gibi yap". İki sekme: Eğitimler
--  (Tarih · Eğitim · Zorunlu · Eğitmen · Katılımcı · Belge) ve Eksik Zorunlu
--  Eğitim (Personel · Birim · Eksik eğitim · Son tarih).
--    zorunlu_adi : birime özel zorunlu tanımda "Zorunlu · Depo" (mockup).
--    belge_sayisi: eğitime eklenmiş belge (katılım listesi, sertifika) -
--                  dokuman.kaynak = 'kys-egitim', kaynak_id = grup kimliği
--                  (grubun en küçük personel_egitim id'si; grup yeniden
--                  yazılıp kimlik değişirse uç belgeleri taşır).
--  Yeni kolon görünümün SONUNA eklenir. İdempotent.
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
         where dk.kaynak = 'kys-egitim' and dk.kaynak_id = min(e.id))::integer as belge_sayisi
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

update public.ai_rehber_ekran set rota = '/kys-egitimler'
 where kaynak = 'kys-egitim' and rota = '/kys-egitim';

commit;
