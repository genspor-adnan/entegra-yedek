-- ============================================================================
--  Gentegre AI — ROL AĞACI VERİTABANINDA (üst rol bağı + ağaç lookup)
--  847_rol_agac_lookup.sql
--
--  Kullanıcı: *"kartta ana rol ve kadro geçmişindeki ana rol comboları ağaç
--  şeklinde olsun"*.
--
--  Rol combosu düz alfabetik listeydi; 70+ rol arasından "Başhekim
--  Yardımcısı"nı bulmak zordu. Kadro ağacı 843'ten beri VAR ama yalnız
--  sunucu kodunda (`StandartRolUclari.SablonKadro`) - jenerik kart çizici
--  ağacı `KodTablosu` görünümünden okur (`ust_id` kolonu), oraya erişemiyordu.
--
--  ============ YENİ KOLON YOK ========================================
--  `rol.ust_rol_id` zaten vardı (rol kartında "Üst Rol" alanı) ve BOŞTU
--  (79 rolün 0'ında dolu). Yetkiye karışmıyor - yalnız silme engeli
--  ("altında rol var") ona bakıyor. Kadro ağacı bu kolona yazılır: tek
--  kaynak, yeni şema yok.
--
--  <b>Hiyerarşi YETKİ DEĞİL GÖRÜNÜMDÜR</b> (843): üst rolün yetkisi altını
--  kapsamaz. Ağaç yalnız combo/listeyi okunur kılar.
--
--  Yalnız BOŞ olan bağlar doldurulur: kurumun elle kurduğu bir hiyerarşi
--  varsa üzerine yazılmaz.
-- ============================================================================
\set ON_ERROR_STOP on

-- Şablon kadro haritası (StandartRolUclari.SablonKadro) - kod çifti olarak.
--   Haritada olmayan rol köke düşer, gizlenmez.
with harita(kod, ust_kod) as (values
        ('yonetici_sekreteri', 'ust_yonetim'),
        ('hastane_muduru', 'ust_yonetim'),
        ('rapor_goruntuleyici', 'ust_yonetim'),
        ('birim_amiri', 'ust_yonetim'),
        ('bashekim_yardimcisi', 'bashekim'),
        ('hekim', 'bashekim_yardimcisi'),
        ('pratisyen_doktor', 'bashekim_yardimcisi'),
        ('acil_hekimi', 'bashekim_yardimcisi'),
        ('att', 'acil_hekimi'),
        ('dis_hekimi', 'bashekim_yardimcisi'),
        ('goz_hekimi', 'bashekim_yardimcisi'),
        ('ftr_uzmani', 'bashekim_yardimcisi'),
        ('radyolog', 'bashekim_yardimcisi'),
        ('lab_uzmani', 'bashekim_yardimcisi'),
        ('isyeri_hekimi', 'bashekim_yardimcisi'),
        ('anestezi_uzmani', 'bashekim_yardimcisi'),
        ('teleradyoloji_hekim', 'bashekim'),
        ('medula_sorumlu', 'bashekim'),
        ('hemsire', 'bashemsire'),
        ('yatan_hemsire', 'bashemsire'),
        ('ameliyathane_hemsire', 'bashemsire'),
        ('yogun_bakim_hemsire', 'bashemsire'),
        ('enfeksiyon_hemsire', 'bashemsire'),
        ('ebe', 'bashemsire'),
        ('dis_asistan', 'bashemsire'),
        ('dsp', 'bashemsire'),
        ('sterilizasyon', 'bashemsire'),
        ('kayit_kabul', 'kayit_kabul_sorumlu'),
        ('vezne', 'kayit_kabul_sorumlu'),
        ('yatis_ofisi', 'kayit_kabul_sorumlu'),
        ('tedavi_danismani', 'kayit_kabul_sorumlu'),
        ('osgb_sekreter', 'kayit_kabul_sorumlu'),
        ('cagri_supervizor', 'kayit_kabul_sorumlu'),
        ('cagri_operator', 'cagri_supervizor'),
        ('tibbi_sekreter', 'kayit_kabul_sorumlu'),
        ('doktor_sekreteri', 'kayit_kabul_sorumlu'),
        ('hasta_haklari', 'kayit_kabul_sorumlu'),
        ('cagri_ajani', 'cagri_sorumlu'),
        ('muhasebe', 'muhasebe_sorumlu'),
        ('medikal_muhasebe', 'muhasebe_sorumlu'),
        ('ik_personel', 'erp_ik'),
        ('kalite_gorevli', 'kalite'),
        ('bilgi_islem_personel', 'bilgi_islem'),
        ('eczane_teknisyen', 'eczaci'),
        ('eczane_depo', 'eczaci'),
        ('erp_servis_gorevli', 'erp_servis')
), hedef as (
    select r.id, u.id ust_id
      from harita h
      join public.rol r on r.kod = h.kod
      join public.rol u on u.kod = h.ust_kod
     where r.ust_rol_id is null
       and r.id <> u.id
)
update public.rol r
   set ust_rol_id = hedef.ust_id, degistirme_tarihi = now()
  from hedef where hedef.id = r.id;

-- ------------------------------------------------------- ağaç lookup ----
-- Jenerik kart çizicinin beklediği biçim: id · ad · aktif · ust_id
--   (bkz. v_gorev_agac_lookup). PORTAL ROLLERİ DIŞARIDA (829): personelin
--   kadrosunda yeri yok, listeyi uzatıp yanlış seçime davet ederdi.
create or replace view public.v_rol_agac_lookup as
select r.id, r.ad,
       (case when r.aktif = 1 then 1 else 0 end)::smallint as aktif,
       r.ust_rol_id as ust_id
  from public.rol r
 where coalesce(r.portal_turu, 0) = 0;

do $$
declare v_ustlu integer; v_kok integer;
begin
    select count(ust_rol_id), count(*) filter (where ust_rol_id is null)
      into v_ustlu, v_kok from public.rol where coalesce(portal_turu, 0) = 0;
    raise notice '847 tamam: % rol bir uste bagli, % rol kokte.', v_ustlu, v_kok;
end $$;
