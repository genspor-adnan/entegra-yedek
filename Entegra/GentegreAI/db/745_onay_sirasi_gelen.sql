-- =====================================================================
--  745_onay_sirasi_gelen.sql
--  GELEN KUTUSU YALNIZ SIRASI GELMİŞ BASAMAĞI GÖSTERİR.
--
--  738'deki `v_onay_bekleyen` "kararı verilmemiş her basamak" diyordu.
--  Beş basamaklı bir talep kutuda BEŞ satır olarak çıkıyordu - oysa dördü
--  henüz sıraya girmemişti.
--
--  Yalnız kalabalık değil, YANLIŞ İMZA sebebi: karar ucu kararı bekleyen EN
--  KÜÇÜK basamağa yazar (zincirin anlamı sıradır, basamak atlanamaz). Üst
--  yönetim üyesi kutuda gördüğü "Üst Yönetim" satırına onay verdiğinde karar
--  birinci basamağa - birim sorumlusunun basamağına - yazılıyordu. Kimin
--  neyi imzaladığı, onay zincirinde vazgeçilemeyecek tek bilgidir.
--
--  SIRASI GELMEMİŞ BASAMAK KAYBOLMAZ: kaydın kendi ekranındaki "Onay
--  Zinciri" sekmesi bütün basamakları gösterir. Kutu "şimdi ne yapmalıyım"
--  sorusunu yanıtlar, "bu kayıt kimlerden geçecek" sorusunu değil.
-- =====================================================================

create or replace view public.v_onay_bekleyen as
select a.id                                   as adim_id,
       o.id                                   as onay_id,
       o.kaynak_tur,
       o.kaynak_id,
       o.sube_id,
       o.olcu,
       o.baslatan_id,
       o.baslama,
       k.kod                                  as akis_kod,
       k.ad                                   as akis_ad,
       k.olcu_adi,
       a.sira,
       a.ad                                   as adim_ad,
       a.sahip_turu,
       a.rol,
       a.atanan_kullanici_id,
       a.durum,
       a.gerekce,
       a.termin,
       case when a.termin is not null and a.termin < now()
            then (date_part('day', now() - a.termin))::int else 0 end as gecikme_gun
  from public.onay_adim a
  join public.onay o on o.id = a.onay_id
  left join public.onay_akis k on k.id = o.akis_id
 where o.durum = 0
   and a.durum in (0, 3)
   -- SIRASI GELMİŞ TEK BASAMAK: kararı verilmemiş en küçük sıra.
   and a.sira = (select min(x.sira) from public.onay_adim x
                  where x.onay_id = o.id and x.durum in (0, 3));

comment on view public.v_onay_bekleyen is
  '738/745: yuruyen zincirlerin SIRASI GELMIS basamagi - tek gelen kutusu. '
  'Sirasi gelmemis basamak kaydin kendi onay sekmesinde gorunur.';
