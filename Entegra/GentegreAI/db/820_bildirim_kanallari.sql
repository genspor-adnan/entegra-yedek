-- ============================================================================
--  Gentegre AI — BİLDİRİM KANALLARI: SMTP E-POSTA + AYYILDIZ SMS
--  820_bildirim_kanallari.sql
--
--  Kullanıcı: *"sms ve eposta entegrasyonu da yap"* (hesap bilgilerini verdi).
--
--  ============ BU DOSYADA PAROLA YOKTUR =============================
--  Hesap İSKELETİ açılır: adres, port, gövde şablonu, başlık. Kullanıcı adı,
--  parola ve bayi kodu KURULUMDA girilir (Yönetim › Entegrasyon Hesapları).
--  Göç dosyaları depoya girer ve müşteriden müşteriye taşınır - içine bir
--  kurumun SMTP parolasını yazmak, o parolayı bütün kurulumlara dağıtmak
--  olurdu.
--
--  ============ ŞABLON AYARDA, KOD DEĞİL =============================
--  Ayyıldız (`SendSmsMulti.aspx`) XML POST istiyor; sağlayıcıların çoğu
--  JSON, bir kısmı form-encoded. 399'daki tasarım kararı: "yeni sağlayıcı
--  bağlamak KOD DEĞİL AYAR işidir". Gövde `ayarlar.govde` içinde durur ve
--  yer tutucularla doldurulur:
--    {{alici}} {{mesaj}} {{kullanici}} {{sifre}} {{baslik}} {{bayi}} {{zaman}}
--
--  `tip = xml` bu göçle birlikte destekleniyor (HttpSmsGonderici); mesaj
--  CDATA içine konur, içindeki `]]>` bölünerek etkisizleştirilir.
--
--  ============ KANAL ANAHTARI =======================================
--  Kuyruk sağlayıcıyı `ayarlar.bildirim_kanal` ile bulur: 1 SMS · 2 e-posta.
--  Bu anahtar olmadan hesap tanımlı olsa bile kanal KAYIT MODUNDA kalır
--  (gönderim günlüğe yazılır, mesaj gitmez).
-- ============================================================================
\set ON_ERROR_STOP on

-- --------------------------------------------------------------- e-posta ----
insert into public.entegrasyon_hesap
       (kod, ad, aktif, test_mi, url, ayarlar, aciklama)
select 'EPOSTA', 'E-Posta (SMTP)', 1, 0, 'srvm08.trwww.com',
       jsonb_build_object(
         'bildirim_kanal', '2',
         'port', '587',
         -- 587 = STARTTLS: `EnableSsl` .NET'te STARTTLS'i de açar.
         'ssl', '1',
         -- GÖNDEREN: boş bırakılırsa kullanıcı adı kullanılır; kurulumda
         --   gönderen adresi kullanıcı adından farklıysa buraya yazılır.
         'gonderen', ''),
       'Gönderen hesap kurulumda girilir (kullanıcı adı + parola).'
 where not exists (select 1 from public.entegrasyon_hesap e where e.kod = 'EPOSTA');

-- ------------------------------------------------------------------- SMS ----
-- XML GÖVDESİ sağlayıcının kendi örneğidir; SDate/EDate anlık gönderimde
--   ETİKETİ YAZILIR ama BOŞ kalır (sağlayıcı böyle istiyor).
insert into public.entegrasyon_hesap
       (kod, ad, aktif, test_mi, url, ayarlar, aciklama)
select 'SMS', 'SMS (Ayyıldız)', 1, 0, 'http://sms.ayyildiz.net/SendSmsMulti.aspx',
       jsonb_build_object(
         'bildirim_kanal', '1',
         'tip', 'xml',
         'baslik', 'GENYAZILIM',
         'bayi', '',
         'govde',
         '<?xml version="1.0" encoding="UTF-8"?>' || E'\n' ||
         '<MainmsgBody>' || E'\n' ||
         '  <UserName>{{kullanici}}</UserName>' || E'\n' ||
         '  <PassWord>{{sifre}}</PassWord>' || E'\n' ||
         '  <CompanyCode>{{bayi}}</CompanyCode>' || E'\n' ||
         '  <Type>12</Type>' || E'\n' ||
         '  <Developer></Developer>' || E'\n' ||
         '  <Version>xVer.2016.0</Version>' || E'\n' ||
         '  <Originator><![CDATA[{{baslik}}]]></Originator>' || E'\n' ||
         '  <Messages>' || E'\n' ||
         '    <Message>' || E'\n' ||
         '      <Mesgbody><![CDATA[{{mesaj}}]]></Mesgbody>' || E'\n' ||
         '      <Number>{{alici}}</Number>' || E'\n' ||
         '      <SDate>{{zaman}}</SDate>' || E'\n' ||
         '      <EDate>{{zaman}}</EDate>' || E'\n' ||
         '    </Message>' || E'\n' ||
         '  </Messages>' || E'\n' ||
         '</MainmsgBody>'),
       'Kullanıcı adı / parola / bayi kodu kurulumda girilir. Numara biçimi 905XXXXXXXXX.'
 where not exists (select 1 from public.entegrasyon_hesap e where e.kod = 'SMS');

-- ------------------------------------------------------------- kod adları ----
insert into public.kod_deger (liste_id, deger, ad, sira, aktif, ekleyen)
select l.id, v.deger, v.ad, v.deger * 10, 1, 0
  from public.kod_liste l
  join (values (1, 'SMS'), (2, 'E-Posta')) as v(deger, ad) on true
 where l.kod = 'bildirim.kanal'
   and not exists (select 1 from public.kod_deger d
                    where d.liste_id = l.id and d.deger = v.deger and d.dil = 0);

do $$
declare v_eposta text; v_sms text;
begin
    select case when coalesce(kullanici_adi, '') = '' then 'KIMLIK EKSIK' else 'hazir' end
      into v_eposta from public.entegrasyon_hesap where kod = 'EPOSTA' limit 1;
    select case when coalesce(kullanici_adi, '') = '' then 'KIMLIK EKSIK' else 'hazir' end
      into v_sms from public.entegrasyon_hesap where kod = 'SMS' limit 1;
    raise notice '820 tamam: e-posta % · sms %. Kimlik bilgileri KURULUMDA '
                 'girilir (Yonetim > Entegrasyon Hesaplari).',
                 coalesce(v_eposta, 'yok'), coalesce(v_sms, 'yok');
end $$;
