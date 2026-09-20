-- =====================================================================
--  876_dis_enabiz_agiz_dis.sql
--  ADSM AĞIZ VE DİŞ SAĞLIĞI VERİ PAKETİ (KTS denetim maddesi D18:
--  "DHBS'ye ADSM'den Ağız ve Diş Sağlığı veri paketi gönderiliyor mu?")
--
--  PAKET KAPALI KURULUR (`aktif = 0`) VE BU BİLİNÇLİDİR.
--
--  105 (Laboratuvar Sonuç) ile aynı durumdayız: e-Nabız rehberi paketin
--  ADINI veriyor, USS paket numarasını ve eleman adlarını vermiyor -
--  102/103/106'nın şeması da kılavuzdan değil, servisin hata
--  mesajlarından çıkmıştı (paket gönderilir, USS eksik elemanları ADIYLA
--  sayar, şema o yanıttan yazılır). Numarasını bilmeden paketi açık
--  kurmak, kuyruğa doğuştan reddedilecek satır doğurmak olurdu.
--
--  AÇMADAN ÖNCE YAPILACAK İKİ ŞEY (kurulum işi, kod işi değil):
--    1. `uss_paket_kodu` rehberdeki gerçek numara ile güncellenir.
--    2. `aktif = 1` yapılır; ilk paket gönderilir ve USS'nin saydığı eksik
--       eleman adları `EnabizPaketUretici.Sorgular.cs` içindeki
--       ADSM_AGIZ_DIS dalına yazılır.
--
--  İÇERİK BUGÜNDEN HAZIR: `v_dis_agiz_dis_paket` görünümü, bir başvuruya
--  ait ağız-diş verisini (yapılan diş işlemleri, diş/yüzey, mevcut durum
--  özeti, DMFT) tek satırda toplar. Eleman adları öğrenildiğinde yazılacak
--  tek şey, bu görünümün kolonlarını USS yollarına bağlamaktır - veriyi o
--  gün toplamaya başlamak, paketi bir tur daha geciktirirdi.
-- =====================================================================

-- ------------------------------------------------------- paket türü ----
insert into public.enabiz_paket_turu
       (kod, ad, uss_paket_kodu, uss_surum, tetik_olay, sure_siniri_saat, zorunlu_alanlar, aktif)
select 'ADSM_AGIZ_DIS', 'Ağız ve Diş Sağlığı (ADSM)', '000', '2.2',
       'dis_seansi_bitti', 24, '["HASTA_TAKIP_BILGISI/SYSTakipNo"]'::jsonb, 0
 where not exists (select 1 from public.enabiz_paket_turu t where t.kod = 'ADSM_AGIZ_DIS');

comment on table public.enabiz_paket_turu is
  'e-Nabiz paket turleri. ADSM_AGIZ_DIS (876) KAPALI kurulur: uss_paket_kodu '
  '000 yer tutucudur, rehberdeki gercek numarayla degistirilip aktif = 1 '
  'yapilmadan paket uretilmez.';

-- --------------------------------------------- paket içeriği (hazır) ----
--  BAŞVURU BAŞINA TEK SATIR. Diş işlemleri tekrarlı gruptur; grubun
--  elemanları USS'den öğrenilene kadar burada JSON olarak durur - yarım
--  bir grup göndermek, olmayan bir işlemi bildirmek olurdu ("açılan grubun
--  içi tam olmalı" kuralı, 105'te öğrenildi).
create or replace view public.v_dis_agiz_dis_paket as
select b.id                                          as belge_id,
       b.taraf_id                                    as hasta_id,
       bb.personel_id                                as hekim_id,
       b.sube_id,
       b.belge_tarihi,
       bb.sys_takip_no,
       -- Bu başvuruda yapılan diş işlemleri (seans işlemleri).
       coalesce((
         select jsonb_agg(jsonb_build_object(
                  'hizmet_kod', hz.kod, 'hizmet_ad', hz.ad,
                  'dis_no', si.dis_no, 'yuzeyler', si.yuzeyler,
                  'zaman', to_char(s.baslangic, 'YYYY-MM-DD"T"HH24:MI:SS'),
                  'tamamlandi', si.tamamlandi)
                order by s.baslangic, si.id)
           from public.dis_seans s
           join public.dis_seans_islem si on si.seans_id = s.id
           join public.hizmet hz on hz.id = si.hizmet_id
          where s.belge_id = b.id), '[]'::jsonb)     as islemler,
       -- Ağzın o günkü mevcut durumu: diş × durum (katman 1, aktif).
       coalesce((
         select jsonb_agg(jsonb_build_object('dis_no', o.dis_no, 'yuzeyler', o.yuzeyler,
                                             'durum_kod', o.durum_kod)
                order by o.dis_no)
           from public.dis_odontogram o
          where o.hasta_id = b.taraf_id and o.katman = 1 and o.aktif = 1), '[]'::jsonb)
                                                     as mevcut_durum,
       -- DMFT: son diş muayenesinden. Denetimin ağız-diş göstergesi budur.
       (select jsonb_build_object('d', dm.dmft_d, 'm', dm.dmft_m, 'f', dm.dmft_f)
          from public.dis_muayene dm
         where dm.hasta_id = b.taraf_id order by dm.id desc limit 1)
                                                     as dmft
  from public.belge b
  join public.belge_basvuru bb on bb.id = b.id
 where b.tur = 19;

comment on view public.v_dis_agiz_dis_paket is
  '876: ADSM Agiz ve Dis Sagligi paketinin icerigi - basvuru basina yapilan '
  'dis islemleri, mevcut odontogram durumu ve DMFT. USS eleman adlari '
  'ogrenilince bu kolonlar paket yollarina baglanir.';

do $$
declare v_aktif smallint;
begin
    select aktif into v_aktif from public.enabiz_paket_turu where kod = 'ADSM_AGIZ_DIS';
    raise notice '876 tamam: ADSM_AGIZ_DIS paket turu kurulu (aktif = %; '
                 'uss_paket_kodu rehberden yazilmadan acilmamali)', v_aktif;
end $$;
