-- ============================================================================
--  Gentegre AI — DIŞ KURUM: KLİNİK ve YÖNETİCİ ROLLERİ
--  824_dis_kurum_rolleri.sql
--
--  Kullanıcı: *"anlaşmalı kurumdan hasta gönderen doktor ve hesapları kontrol
--  eden yönetici var"* → *"kurum kapsamı olsun, fatura satırında hasta adı
--  görünmesin"*.
--
--  ============ AYNI KAPSAM, AYRI YETKİ ==============================
--  İkisi de KURUMUN işlerini görür (`portal_turu = 2`, kapsam kimliği 819'daki
--  `portal_taraf_id`) - kapsam kuralları DEĞİŞMİYOR. Değişen tek şey hangi
--  ekranların açık olduğu:
--
--    KLİNİK   : hasta · lab istem/numune/sonuç · görüntü isteği · yazışma
--    YÖNETİCİ : kurumun faturaları · cari ekstresi · yazışma
--
--  Yönetici TIBBİ EKRAN GÖRMEZ. Muhasebeyi tutan kişinin hastanın tetkik
--  sonucunu görmesinin savunması yok; "nasılsa aynı kurum" demek, KVKK'da
--  kapsamı kurumun tamamına açmak demektir.
--
--  ============ FATURADA HASTA ADI YOK ===============================
--  Kurum içi belge listesi `hastaAdi`, `doktor`, `poliklinik` kolonları
--  taşıyor. Bu ekranı portala açıp kolon gizlemek yerine PORTALA ÖZEL DAR
--  KAYNAK yazıldı (`kurum-belge`, `kurum-ekstre`): orada o kolonlar HİÇ YOK.
--  Gizlenen kolon, bir gün varsayılan görünüme geri eklendiğinde sessizce
--  açılır; olmayan kolon açılamaz.
--
--  Aynı sebeple ekstrede `aciklama` kolonu da yok - başvuru faturasının
--  açıklaması hasta adı taşıyabiliyor.
-- ============================================================================
\set ON_ERROR_STOP on

-- --------------------------------------------------------------- yetki ----
-- MALİ EKRANLAR AYRI KUTU: klinik rol bunu taşımaz. `belge` yetkisini
--   vermek, kurum içi belge listesinin tamamını açardı.
insert into public.yetki (kod, ad, grup, tur, sira, aktif, urun_modu)
select 'portal.mali', 'Portal: kurumun faturaları ve ekstresi', 'portal', 0, 10, 1, 0
 where not exists (select 1 from public.yetki y where y.kod = 'portal.mali');

-- ------------------------------------------------- mevcut rol = KLİNİK ----
-- 795'teki rol zaten klinik ekranları taşıyor; adı işini söylesin.
update public.rol
   set ad = 'Dış Kurum · Klinik (portal)', degistirme_tarihi = now()
 where kod = 'dis_istem_kurumu' and ad <> 'Dış Kurum · Klinik (portal)';

-- ------------------------------------------------------ YÖNETİCİ rolü ----
insert into public.rol (kod, ad, amac, portal_turu, aktif, sistem)
select 'dis_kurum_yonetici', 'Dış Kurum · Yönetici (portal)',
       'Anlaşmalı kurumun mali işleri: fatura ve ekstre. Tıbbi ekran YOK.',
       2, 1, 0
 where not exists (select 1 from public.rol r where r.kod = 'dis_kurum_yonetici');

insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil)
select r.id, y.id, 1, 0, 0, 0
  from public.rol r
  join public.yetki y on y.kod in ('portal.mali', 'ai.rehber')
 where r.kod = 'dis_kurum_yonetici'
   and not exists (select 1 from public.rol_yetki x
                    where x.rol_id = r.id and x.yetki_id = y.id);

-- YAZIŞMA: kurumla aramızdaki iş yazışması (806) - yöneticinin de fatura
--   hakkında soru sorabilmesi gerekir.
insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil)
select r.id, y.id, 1, 1, 0, 0
  from public.rol r
  join public.yetki y on y.kod = 'mesaj'
 where r.kod = 'dis_kurum_yonetici'
   and not exists (select 1 from public.rol_yetki x
                    where x.rol_id = r.id and x.yetki_id = y.id);

do $$
declare v_klinik integer; v_yonetici integer;
begin
    select count(*) into v_klinik
      from public.rol_yetki ry join public.rol r on r.id = ry.rol_id
     where r.kod = 'dis_istem_kurumu';
    select count(*) into v_yonetici
      from public.rol_yetki ry join public.rol r on r.id = ry.rol_id
     where r.kod = 'dis_kurum_yonetici';
    raise notice '824 tamam: Klinik % yetki · Yonetici % yetki (tibbi ekran YOK). '
                 'Kapsam ikisinde de KURUM (portal_turu 2).', v_klinik, v_yonetici;
end $$;
