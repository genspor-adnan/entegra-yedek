-- 1304 - Teletıp ekranları: istem başına gönderim özeti (liste kaynağı) + ekran yetkisi + rehber
--
-- Kullanıcı 11.11.2026: "Teletıp ekranlarını yap" (mockup Ekranlar/Radyoloji/teletip_mirth.html §3 liste, §4 kart,
-- §6 istem kartı şeridi). Liste istem başına TEK satır: son ORM emri ve durumu, NW durumu, bekleyen / sorunlu sayısı,
-- son hata. Kart (/teletip/:istemId) ve şerit /api/teletip uçlarından okur.
--
-- Yetki ekran bazlı (bkz. "yetki kodu ekran bazlı olmalı"): radyoloji.teletip - liste, kart, ham mesaj, yeniden gönder.
-- `radyoloji` yetkisi olan rollere aynı haklarla verilir (radyoloji sorumlusu bugün ne görüyorsa görür).
--
-- Tekrar çalıştırılabilir.
\set ON_ERROR_STOP on
begin;

create or replace view public.v_teletip_istem as
with g as (
  select t.istem_id,
         count(*)                                                      as mesaj_sayisi,
         count(*) filter (where t.durum in (0, 5))                      as bekleyen,
         count(*) filter (where t.durum in (2, 3))                      as sorunlu,
         max(t.son_deneme)                                              as son_deneme,
         max(t.ekleme_tarihi)                                           as son_kayit,
         (array_agg(t.durum order by t.id) filter (where t.emir = 1))[1] as nw_durum_ilk,
         (array_agg(t.durum order by t.id desc) filter (where t.emir = 1))[1] as nw_durum,
         (array_agg(t.emir order by t.id desc))[1]                      as son_emir,
         (array_agg(t.durum order by t.id desc))[1]                     as son_durum,
         (array_agg(t.ack_kodu order by t.id desc))[1]                  as son_ack,
         (array_agg(nullif(t.hata_metni, '') order by t.id desc) filter (where t.durum in (2, 3, 5)))[1] as son_hata
    from public.teletip_gonderim t
   where t.istem_id is not null and t.kanal = 1
   group by t.istem_id
)
select i.id,
       i.sube_id,
       coalesce(i.kabul_tarihi, i.ekleme_tarihi)                         as kabul,
       i.accession_no,
       i.modalite,
       i.durum                                                            as istem_durum,
       i.hasta_id,
       coalesce(public.fn_taraf_ad(h.unvan, h.ad, h.soyad)::varchar(120), '') as hasta_adi,
       -- KVKK: listede maskeli; tam TCKN kartta ve ham mesajda (yetkili).
       case when coalesce(h.vkno, '') ~ '^[0-9]{11}$' then left(h.vkno, 1) || '•••••••' || right(h.vkno, 3) else '' end as tckn_maskeli,
       coalesce(hz.ad, '') || public.fn_radyoloji_yon_ek(i.yon)            as tetkik_adi,
       coalesce(public.fn_hizmet_sut_kodu(i.hizmet_id, i.yon, i.kontrast), '') as sut_kodu,
       coalesce(hz.loinc, '')                                             as loinc,
       g.mesaj_sayisi, g.bekleyen, g.sorunlu, g.son_deneme, g.son_kayit,
       coalesce(g.nw_durum, -1)::smallint                                 as nw_durum,
       g.son_emir::smallint                                               as son_emir,
       g.son_durum::smallint                                              as son_durum,
       coalesce(g.son_ack, '')                                            as son_ack,
       coalesce(g.son_hata, '')                                           as son_hata,
       -- Tek bakışta durum: 3 sorunlu (AE / gidemez) · 2 kuyrukta · 1 tamam (son mesaj AA) · 0 atlandı
       (case when g.sorunlu > 0 then 3 when g.bekleyen > 0 then 2 when g.son_durum = 1 then 1 else 0 end)::smallint as genel_durum
  from g
  join public.radyoloji_istem i on i.id = g.istem_id
  left join public.taraf h  on h.id  = i.hasta_id
  left join public.hizmet hz on hz.id = i.hizmet_id;
comment on view public.v_teletip_istem is
  '1304: Teletıp gönderim özeti - istem başına tek satır (Teletıp Gönderimleri listesi). genel_durum 3 sorunlu · 2 kuyrukta · 1 tamam · 0 atlandı.';

-- ------------------------------------------------------------------ yetki
insert into public.yetki (kod, ad, grup, tur, urun_modu, sira, aktif)
select 'radyoloji.teletip', 'Teletıp Gönderimleri (Radyoloji)', 'Radyoloji', 0, 2, 281, 1
 where not exists (select 1 from public.yetki where kod = 'radyoloji.teletip');
insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil)
select ry.rol_id, yn.id, ry.gor, ry.ekle, ry.degistir, ry.sil
  from public.yetki ye join public.rol_yetki ry on ry.yetki_id = ye.id
  join public.yetki yn on yn.kod = 'radyoloji.teletip'
 where ye.kod = 'radyoloji'
on conflict (rol_id, yetki_id) do nothing;
insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil)
select 1, y.id, 1, 1, 1, 1 from public.yetki y
 where y.kod = 'radyoloji.teletip'
   and not exists (select 1 from public.rol_yetki r where r.rol_id = 1 and r.yetki_id = y.id);
update public.rol r set yetki_surumu = yetki_surumu + 1
 where exists (select 1 from public.rol_yetki ry join public.yetki y on y.id = ry.yetki_id
                where ry.rol_id = r.id and y.kod = 'radyoloji.teletip');

-- ------------------------------------------------------------------ rehber (bağlamsal yardım / palet)
insert into public.ai_rehber_ekran (kaynak, rota, baslik, yol, menu_grup, menu_ad, yetki_kodu, urun_modu, anahtar, aciklama)
select 'teletip-gonderim', '/teletip', 'Teletıp Gönderimleri', 'Radyoloji › Teletıp Gönderimleri', 'Radyoloji',
       'Teletıp Gönderimleri', 'radyoloji.teletip', 2,
       'teletip bakanlık teleradyoloji hl7 orm oru gönderim gidemez reddedildi mirth accession',
       'Radyoloji istemlerinin Sağlık Bakanlığı Teletıp''a gönderimi: istem (ORM) mesajlarının durumu, eksikler, ACK hataları, yeniden gönder.'
 where not exists (select 1 from public.ai_rehber_ekran r where r.kaynak = 'teletip-gonderim');

commit;
