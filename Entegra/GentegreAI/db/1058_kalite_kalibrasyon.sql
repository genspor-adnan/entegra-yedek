-- =============================================================================
--  1058  KURUMSAL KALİTE - ÖLÇÜM CİHAZLARI & KALİBRASYON (SADE, ISO 9001 7.1.5)
--
--  Kullanıcı (12.10.2026): "Kalite 2 ile devam et" - mockup
--  Ekranlar/Kalite2/kalibrasyon.html: cihaz, periyot, son / sonraki tarih,
--  sertifika. "Cihaz kaydı Sabit Varlıklar (demirbaş) kartı ise oradan gelir;
--  ayrı envanter tutulmaz."
--
--  YENİDEN KULLANIM: cihaz = public.demirbas (periyot, son kalibrasyon,
--    geçerlilik 723), kayıt = public.demirbas_kalibrasyon (tetik 723 cihaz
--    künyesini günceller). Yeni tablo YOK. Kalite menüsündeki ekran kendi
--    kodunu (kys.kalibrasyon) alır - Sabit Varlıklar › Kalibrasyon
--    (demirbas.kalibrasyon) dokunulmaz; bir kod tek menü ekranı açar (1003).
--
--  KALİBRASYONA TÂBİ (728 ile aynı ölçüt): periyot > 0 VEYA geçerlilik
--    yazılmış VEYA kalibrasyon (tur 1) kaydı var. Hurda (durum 4) hariç.
--  SONRAKİ: cihazdaki geçerlilik; yoksa son kalibrasyon + periyot.
--  DURUM (pano 1055 bu sözleşmeyle sayar): 1 uygun · 2 yaklaşıyor (30 gün) ·
--    3 süresi geçti (tarih yok = hiç kalibre edilmemiş, o da 3).
--  SERTİFİKA: demirbaş belgelerinde (dokuman kaynak 'demirbas') adı / türü
--    kalibrasyon ya da sertifika geçen bir dosya.
--  İdempotent.
-- =============================================================================

begin;

create or replace view public.v_kalite_kalibrasyon as
select d.id,
       d.sube_id,
       d.kod                                  as no,
       d.ad,
       d.seri_no,
       d.departman_id,
       coalesce(dp.ad, '')::varchar(200)      as birim_adi,
       d.kalibrasyon_periyot_ay               as periyot_ay,
       d.son_kalibrasyon,
       x.sonraki,
       (x.sonraki - current_date)             as kalan_gun,
       (case when x.sonraki is null or x.sonraki < current_date then 3
             when x.sonraki <= current_date + 30 then 2
             else 1 end)::smallint            as durum,
       (case when x.sonraki is null then 'Kalibrasyon yok'
             when x.sonraki < current_date then 'Süresi geçti'
             when x.sonraki <= current_date + 30 then 'Yaklaşıyor'
             else 'Uygun' end)::varchar(20)   as durum_adi,
       sk.id                                  as son_kayit_id,
       sk.sonuc                               as son_sonuc,
       (case sk.sonuc when 0 then 'Açık' when 1 then 'Uygun' when 2 then 'Uygun değil'
                      when 3 then 'Şartlı uygun' else '' end)::varchar(20) as son_sonuc_adi,
       coalesce(fr.unvan, '')::varchar(200)   as firma_adi,
       (case when exists (select 1 from public.dokuman o
                           where o.kaynak = 'demirbas' and o.kaynak_id = d.id
                             and (o.ad ilike '%kalib%' or o.ad ilike '%sertifika%'
                                  or o.belge_turu ilike '%kalib%' or o.belge_turu ilike '%sertifika%'))
             then 1 else 0 end)::smallint     as sertifika
  from public.demirbas d
  left join public.departman dp on dp.id = d.departman_id
  left join lateral (
        select k.id, k.sonuc, k.firma_id
          from public.demirbas_kalibrasyon k
         where k.demirbas_id = d.id and k.tur = 1
         order by k.tarih desc, k.id desc
         limit 1) sk on true
  left join public.taraf fr on fr.id = sk.firma_id
 cross join lateral (
        select coalesce(d.kalibrasyon_gecerlilik,
                        case when d.son_kalibrasyon is not null and d.kalibrasyon_periyot_ay > 0
                             then (d.son_kalibrasyon + make_interval(months => d.kalibrasyon_periyot_ay))::date
                        end) as sonraki) x
 where d.durum <> 4
   and (d.kalibrasyon_periyot_ay > 0 or d.kalibrasyon_gecerlilik is not null or sk.id is not null);

comment on view public.v_kalite_kalibrasyon is
  'Kurumsal Kalite (1058): kalibrasyona tabi demirbaslar - durum 1 uygun / 2 yaklasiyor (30 gun) / 3 suresi gecti. Pano (1055) sayar.';

-- ---------------------------------------------------------------- yetki --
insert into public.yetki (kod, ad, grup, tur, sira, aktif, modul)
select 'kys.kalibrasyon', 'Ölçüm cihazları ve kalibrasyon', 'Kalite', 0, 11, 1, 'kys'
 where not exists (select 1 from public.yetki where kod = 'kys.kalibrasyon');

insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, ekleyen)
select r.id, y.id, 1, 1, 1, 1, 0
  from public.rol r cross join public.yetki y
 where r.kod = 'yonetici' and y.kod = 'kys.kalibrasyon'
   and not exists (select 1 from public.rol_yetki ry where ry.rol_id = r.id and ry.yetki_id = y.id);
update public.rol set yetki_surumu = yetki_surumu + 1 where kod = 'yonetici';

-- ---------------------------------------------------------- yardım kataloğu --
insert into public.ai_rehber_ekran (kaynak, rota, baslik, yol, menu_grup, menu_ad,
                                    yetki_kodu, urun_modu, modul, anahtar, aciklama, aksiyon_ekrani, kart_yolu)
select 'kys-kalibrasyon', '/kys-kalibrasyon', 'Ölçüm Cihazları & Kalibrasyon', 'Kalite › Kalibrasyon',
       'Kalite', 'Kalibrasyon', 'kys.kalibrasyon', 0, 'kys',
       'kalibrasyon ölçüm cihazı izleme ölçme kaynakları iso 7.1.5 periyot sertifika sonraki kalibrasyon süresi geçti yaklaşan',
       'Kalibrasyona tâbi cihazlar (Sabit Varlıklar demirbaş kaydından): periyot, son ve sonraki kalibrasyon, durum (uygun / yaklaşıyor / süresi geçti), sertifika. Satırı açıp Kalibrasyon kayıtlarına yeni satır eklenir; sonuç ve geçerlilik cihaza yazılır.',
       'kys-kalibrasyon-liste', '/kys-kalibrasyon'
 where not exists (select 1 from public.ai_rehber_ekran e where e.kaynak = 'kys-kalibrasyon');

commit;
