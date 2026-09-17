-- ============================================================================
--  Gentegre AI — ANTET TEK KAYNAKTAN, LOGOSUYLA BİRLİKTE
--  772_sube_antet_ve_logo.sql
--
--  Kullanıcı: "antette logoyu da göster" (kalan iş 3.10).
--
--  ============ LOGO ZATEN VARDI, ÇIKTIYA HİÇ GİRMEMİŞTİ ===============
--  Şube logosu 234'ten beri duruyor ve üst şeritte ÇİZİLİYOR: `dokuman`
--  kaynağı `sube`, `belge_turu` "Logo" (yoksa adı "logo" ile başlayan ilk
--  resim). Kâğıda basılan beş çıktının hiçbiri bunu kullanmıyordu - göz
--  şeması, döküm baskısı, lab raporu, radyoloji raporu ve belge talebi
--  yazısı yalnız METİN antet çiziyordu; lab ve radyoloji logonun yerine
--  emoji koymuştu (🧪 / 🏥).
--
--  Resmî yazıda kurum logosu beklenir; üstelik ekranda görünen logo ile
--  kâğıtta görünmeyen logo, aynı kurumun iki farklı kimliği demekti.
--
--  ============ ASIL SORUN: ANTET BEŞ YERE KOPYALANMIŞTI ===============
--  `coalesce(nullif(s.unvan,''), s.ad) as unvan, s.adres, s.ilce, ...`
--  sorgusu BEŞ dosyada birebir tekrar ediyordu (DokumDeposu, GozUclari,
--  LabUclari.Rapor, RadyolojiUclari.Rapor, 768'in yazı ucu). Logoyu beşine
--  ayrı ayrı eklemek kopyayı altıya çıkarmak olurdu.
--
--  `v_sube_antet` antedi TEK yerde tanımlar; logo da onun bir kolonudur.
--  Yarın anteda "web adresi" eklenirse beş yeri gezmek gerekmeyecek.
--
--  ============ LOGO SEÇME KURALI TEK YAZAN ============================
--  Kural `KullaniciDeposu.SubeleriAsync` içinde satır içi SQL olarak
--  duruyordu; görünüm onu aynen alıyor ve o kod da buraya bağlanıyor.
--  İki kopya kalsaydı üst şeritteki logo ile kâğıttaki logo bir gün
--  farklı dosyayı gösterebilirdi.
--
--  Sıralama: önce `belge_turu = Logo` işaretliler, sonra varsayılan işaretli
--  olan, sonra en eski. "Kaşe" ve "İmza" DIŞARIDA: onlar antet değil, imza
--  bloğunun malzemesidir ve yeri geldiğinde ayrı çağrılır.
-- ============================================================================
\set ON_ERROR_STOP on

create or replace view public.v_sube_antet as
select s.id                                   as sube_id,
       coalesce(nullif(s.unvan, ''), s.ad)    as unvan,
       s.ad                                   as sube_ad,
       s.adres,
       s.ilce,
       s.il,
       s.telefon,
       s.eposta,
       s.web,
       s.mersis_no,
       s.vkno,
       s.vd,
       -- LOGO: `sube` kaynaklı, RESİM olan, "Logo" işaretli doküman.
       --   `belge_turu` boş bırakılmışsa adı "logo" ile başlayan resim de
       --   kabul edilir - kullanıcı dosyayı türünü seçmeden yükleyebiliyor
       --   ve o dosyanın görünmemesi "logoyu yükledim ama çıkmıyor" demekti.
       (select d.id
          from public.dokuman d
         where d.kaynak = 'sube' and d.kaynak_id = s.id and d.durum = 1
           and d.content_type like 'image/%'
           and (d.belge_turu ilike 'logo%' or d.ad ilike 'logo%')
         order by (d.belge_turu ilike 'logo%') desc, d.varsayilan desc, d.id
         limit 1)                             as logo_dokuman_id
  from public.sube s;

comment on view public.v_sube_antet is
  '772: cikti antedinin TEK kaynagi (unvan/adres/iletisim/vergi + logo '
  'dokuman id). Ayni sorgu bes dosyada kopyalanmisti. Logo kurali '
  'KullaniciDeposu ile ayni: kaynak sube, resim, belge_turu Logo (yoksa '
  'adi logo ile baslayan). Kase ve Imza bilerek disarida - onlar antet '
  'degil imza blogu malzemesi.';

do $$
declare v_sube int; v_logo int;
begin
    select count(*), count(logo_dokuman_id) into v_sube, v_logo
      from public.v_sube_antet;
    raise notice '772 tamam: % sube, %''sinde logo var.', v_sube, v_logo;
end $$;
