-- ============================================================================
--  Gentegre AI — Yerel para birimi ayari + guvenlik ayarlarinin yardim metinleri
--  106_ayar_yerel_para_ve_guvenlik_help.sql
--
--  1) genel.yerel_para: FIRMANIN DEFTER PARASI. Arayuzde 'TL' olarak KODA
--     GOMULUYDU (BelgeKarti.YEREL_PARA): kalem penceresi "bu fiyat doviz mi"
--     kararini, "Yerel Para" satirini ve kur kutusunu buna gore aciyor.
--     Yurt disi/dovizle defter tutan kurulumda yanlis calisirdi.
--
--  2) 105'te acilan guvenlik ayarlarinin bir kismi zaten vardi (kurulum
--     seed'inden); hatali giris / kilit sureleri icin de yardim metni yaziliyor.
-- ============================================================================
\set ON_ERROR_STOP on

insert into public.referans (anahtar, deger, tip, kapsam, aciklama)
values ('genel.yerel_para', 'TL', 'metin', 'firma',
        'Firmanın defter (yerel) para birimi')
on conflict (anahtar) do nothing;

insert into public.help (anahtar, dil, baslik, metin) values
('ayar.genel.yerel_para', 0, 'Yerel para birimi',
 'Firmanın defter tuttuğu para birimi. Tutarlar bu para biriminde saklanır ve '
 || 'raporlanır.'
 || E'\n\n'
 || 'Belge kaleminde seçilen stokun fiyatı BAŞKA bir para biriminde ise satır '
 || '"dövizli" sayılır: kur kutusu ve altında yerel karşılık satırı açılır. '
 || 'Bu ayar hangi paranın "döviz sayılmayacağını" belirler.'
 || E'\n\n'
 || 'ISO kodu yazılır (TL, USD, EUR…). Değiştirmek geçmiş belgeleri dönüştürmez; '
 || 'kurulumda bir kez belirlenmelidir.'),

('ayar.guvenlik.hatali_giris_siniri', 0, 'Hatalı giriş sınırı',
 'Kullanıcı bu kadar kez üst üste yanlış parola girerse hesap geçici olarak '
 || 'kilitlenir. Doğru girişte sayaç sıfırlanır.'
 || E'\n\n'
 || 'Deneme-yanılma saldırısını yavaşlatır. Çok düşük değer, parolasını '
 || 'karıştıran kullanıcıyı sık sık kilitler; 3-10 arası tipiktir.'),

('ayar.guvenlik.kilit_dakika', 0, 'Kilit süresi',
 'Hatalı giriş sınırı aşıldığında hesabın kaç dakika kilitli kalacağı. '
 || 'Süre dolunca kullanıcı yeniden deneyebilir; yönetici beklemeden açabilir.')
on conflict (anahtar, dil) do update
   set baslik = excluded.baslik, metin = excluded.metin;

do $$
declare v text; n integer;
begin
    select deger into v from public.referans where anahtar = 'genel.yerel_para';
    select count(*) into n from public.help where anahtar like 'ayar.%';
    raise notice '106 tamam: yerel para = %, ayar yardim metni % adet', v, n;
end $$;
