-- ============================================================================
--  Gentegre AI — DAVET ŞABLONU PORTAL TÜRÜNE GÖRE KONUŞSUN
--  823_davet_sablonu_portal_adi.sql
--
--  Kullanıcı: *"portal erişimi ver dediğimde yine dış doktora sms/mail
--  göndersin"*. Gönderildi - ama metin yanlıştı.
--
--  ============ CANLI DENEMEDE GÖRÜLDÜ ================================
--  822'deki şablon HASTAYA göre yazılmıştı:
--    "Sayın …, {{kurum}} HASTA PORTALINDA sonuçlarınızı, raporlarınızı ve
--     randevularınızı görebilirsiniz."
--  Aynı şablon dış hekime de gidince, hekime kendi hastalarının değil
--  "sonuçlarınız" denmiş oluyordu - yanlış ve kafa karıştırıcı.
--
--  ============ ÜÇ ŞABLON DEĞİL, BİR DEĞİŞKEN ========================
--  Her portal türü için ayrı şablon açmak (hasta/hekim/kurum × SMS/e-posta =
--  altı metin), kurumun imzasını değiştirmek istediğinde altı yerde düzeltme
--  demekti. Portal ADI değişken: `{{portal}}`.
--
--  Gövde de türden bağımsız yazıldı: "hesabınızı açmak için" herkes için
--  doğru; ne göreceği portalın kendi menüsünde zaten yazıyor.
-- ============================================================================
\set ON_ERROR_STOP on

update public.bildirim_sablon
   set govde = '{{kurum}} {{portal}}: hesabinizi acmak icin {{baglanti}} '
             || '({{saat}} saat gecerli)',
       degiskenler = ('{"kurum": "Kurum adı", "portal": "Portal adı", '
                      || '"baglanti": "Davet bağlantısı", "saat": "Geçerlilik (saat)", '
                      || '"kisi": "Kişi adı"}')::jsonb,
       degistirme_tarihi = now()
 where kod = 'portal.davet';

update public.bildirim_sablon
   set konu = '{{kurum}} - {{portal}} daveti',
       govde = 'Sayın {{kisi}}, {{kurum}} {{portal}} hesabınızı aşağıdaki '
             || 'bağlantıdan açabilirsiniz.' || E'\n\n'
             || '{{baglanti}}' || E'\n'
             || 'Bağlantı {{saat}} saat geçerlidir ve bir kez kullanılır.' || E'\n\n'
             || 'Bu daveti siz istemediyseniz bağlantıyı kullanmayın.',
       degiskenler = ('{"kurum": "Kurum adı", "portal": "Portal adı", '
                      || '"baglanti": "Davet bağlantısı", "saat": "Geçerlilik (saat)", '
                      || '"kisi": "Kişi adı"}')::jsonb,
       degistirme_tarihi = now()
 where kod = 'portal.davet.eposta';

do $$
begin
    raise notice '823 tamam: davet sablonlari {{portal}} degiskeniyle konusuyor '
                 '(hasta portali / hekim portali / kurum portali).';
end $$;
