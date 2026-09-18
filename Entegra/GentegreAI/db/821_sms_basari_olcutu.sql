-- ============================================================================
--  Gentegre AI — SMS BAŞARI ÖLÇÜTÜ (Ayyıldız)
--  821_sms_basari_olcutu.sql
--
--  Kullanıcı: *"sms testini de yap, 905336304110"*.
--
--  ============ CANLI DENEMEDE GÖRÜLDÜ ================================
--  Sağlayıcı HTTP 200 ile İKİ farklı şey dönüyor:
--    kabul  -> `ID:84134257`   (mesaj kimliği)
--    ret    -> `01`            (kullanıcı adı/parola hatalı)
--  Gövde şablonu doğru olduğu hâlde PAROLA BOZUKKEN de "gönderildi" diyorduk:
--  `ayarlar.basarili` boş bırakılınca ölçüt yalnız HTTP 2xx'ti ve sağlayıcı
--  hatayı 200 ile bildiriyordu.
--
--  Sessiz başarısızlık burada en pahalı hatadır: randevu hatırlatması ya da
--  portal davet kodu gitmediği hâlde sistem "gitti" der, kimse aramaz.
--
--  ============ ÖLÇÜT: YANITTA "ID:" =================================
--  Kabul yanıtı mesaj kimliği taşır; ret kodları taşımaz. `HttpSmsGonderici`
--  bu metni yanıtta arar (`ayarlar.basarili`), bulamazsa gönderimi BAŞARISIZ
--  sayar ve ham yanıtı hata metnine koyar - kurulumda tek ipucu o koddur.
-- ============================================================================
\set ON_ERROR_STOP on

update public.entegrasyon_hesap
   set ayarlar = ayarlar || jsonb_build_object('basarili', 'ID:')
 where kod = 'SMS'
   and coalesce(ayarlar ->> 'basarili', '') = '';

do $$
declare v text;
begin
    select ayarlar ->> 'basarili' into v
      from public.entegrasyon_hesap where kod = 'SMS' limit 1;
    raise notice '821 tamam: SMS basari olcutu = %. Yanitta bu metin yoksa '
                 'gonderim BASARISIZ sayilir.', coalesce(v, '(yok)');
end $$;
