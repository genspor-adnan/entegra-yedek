-- =====================================================================
--  750_tatil_duzeltmeleri.sql
--  749'un iki kusuru.
--
--  ============= 1) İKİ `fn_izin_gun` YAN YANA KALDI ===================
--  743 fonksiyonu üç parametreliydi; 749 dördüncüyü (şube) ekleyince
--  PostgreSQL ikisini de tuttu ve üç argümanlı her çağrı
--  "function is not unique" ile DÜŞTÜ - izin talebi açan uç dahil.
--  Eski imza kaldırılıyor: kalsaydı daha kötüsü olurdu, çağrı sessizce
--  TATİLİ BİLMEYEN sürüme düşebilir ve gün sayısı yanlış hesaplanırdı.
--
--  ============= 2) GÜN ADI SUNUCU YERELİNE BAĞLIYDI ===================
--  `to_char(tarih, 'TMDay')` `lc_time` ayarına bakar; kurulumda İngilizce
--  ("Thursday") çıkıyordu. Ekranda görünen bir metnin sunucu ayarına göre
--  değişmesi, aynı ürünün iki kurulumda farklı görünmesi demektir.
-- =====================================================================

-- ============================ ESKİ İMZA KALDIRILIR (3 parametreli)
drop function if exists public.fn_izin_gun(date, date, smallint);

-- ================================================= GÜN ADI TÜRKÇE
create or replace view public.v_resmi_tatil as
select t.id,
       t.tarih,
       t.ad,
       t.tur,
       t.yarim_gun,
       t.calisma_var,
       t.aciklama,
       t.sube_id,
       coalesce(s.ad, '')                                   as sube_ad,
       t.aktif,
       extract(year from t.tarih)::int                      as yil,
       (extract(isodow from t.tarih) >= 6)::int             as hafta_sonu,
       -- GÜN ADI SABİT: sunucunun `lc_time` ayarına bırakılmaz.
       case extract(isodow from t.tarih)
            when 1 then 'Pazartesi' when 2 then 'Salı' when 3 then 'Çarşamba'
            when 4 then 'Perşembe'  when 5 then 'Cuma' when 6 then 'Cumartesi'
            else 'Pazar' end                                as gun_adi,
       t.ekleme_tarihi,
       t.degistirme_tarihi
  from public.resmi_tatil t
  left join public.sube s on s.id = t.sube_id;

comment on view public.v_resmi_tatil is
  '749/750: resmi tatil listesi. Gun adi sabit - sunucunun lc_time '
  'ayarina birakilsa ayni urun iki kurulumda farkli gorunurdu.';
