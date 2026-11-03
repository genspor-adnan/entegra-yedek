-- =============================================================================
--  1252  MUHASEBE EŞLEŞTİRMESİ HİÇ OLMAYAN KURULUMDA OTOMATİK FİŞ KAPALI
--
--  Kullanıcı 03.11.2026 (ZONE): tahsilat "Muhasebe eşlemesi bulunamadı (bacak 44936, hesap türü "B", rol "ana").
--  Hesap planı eşleştirmesini tanımlayın."
--
--  TEŞHİS. Delphi'den aktarılan kurulumlar (ZONE, MEDX: kur.ps1 -SadeceSema -AktarimIcin) standart
--  muhasebe_eslestirme kurallarını almıyor: 0 kural, hiç muhasebe fişi yok. muhasebe.otomatik_fis tanımsız =
--  varsayılan '1' olduğundan her kasa işlemi ve fatura kaydı (fn_kasa_islem_kesinlestir, fn_belge_fisle) fiş
--  kesmeye çalışıyor, fn_muh_hesap_coz eşleme bulamayıp kaydı düşürüyordu. Kullanıcı kararı: bu kurulumlarda
--  otomatik fiş kapalı (standart eşlemeler yüklenmez).
--
--  YALNIZ KANITLANABİLİR kurulumda: hiç aktif eşleştirme kuralı YOK, hiç muhasebe fişi YOK ve ayar henüz
--  TANIMLANMAMIŞ. Muhasebesi kurulu kurulumlar (FETA, yeni kurulumlar - standart 37 kural) değişmez; ayarı
--  bilinçli koymuş kurulumun değeri ezilmez. Eşleme tanımlanınca ayar '1' yapılarak açılır; toplu fişleme
--  (fn_belge_fisle_toplu) ayardan bağımsız çalışır. İdempotent.
-- =============================================================================
\set ON_ERROR_STOP on

insert into public.referans (anahtar, deger, tip, kapsam, aciklama)
select 'muhasebe.otomatik_fis', '0', 'metin', 'firma',
       '1252: muhasebe eşleştirmesi tanımsız kurulumda kayıtta otomatik fiş kesilmez (eşleme tanımlanınca 1 yapın)'
 where not exists (select 1 from public.muhasebe_eslestirme where aktif = 1)
   and not exists (select 1 from public.muhasebe_fis)
   and not exists (select 1 from public.referans where anahtar = 'muhasebe.otomatik_fis');

do $$ begin
  raise notice '1252: muhasebe.otomatik_fis = %',
    coalesce((select deger from public.referans where anahtar = 'muhasebe.otomatik_fis'), 'tanımsız (açık)');
end $$;
