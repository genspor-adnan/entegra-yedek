-- =====================================================================
--  739_onay_gelen_kutusu.sql
--  Onay omurgasının (738) ekran tarafı: talep kartının onay sekmesi,
--  tek gelen kutusu ve bildirim şablonları.
-- =====================================================================

-- ============================== TALEP KARTININ ONAY SEKMESİ GÖRÜNÜMÜ
-- Kart detayları ÜST KOLONA göre süzülür (`talep_id`); omurga ise kaydı
--   `kaynak_tur + kaynak_id` ile tutuyor. Görünüm ikisini bağlar - kart
--   kataloğuna "kaynak_tur = 1241" koşulu yazdırmak, kartın omurganın iç
--   düzenini bilmesi olurdu.
create or replace view public.v_satinalma_talep_onay as
select a.id,
       o.kaynak_id                              as talep_id,
       a.sira                                   as basamak,
       a.ad                                     as adim_ad,
       a.rol,
       a.karar_veren_id                         as onaylayan_id,
       a.durum,
       a.karar_zamani,
       a.gerekce,
       a.yazili_son,
       a.termin,
       a.ekleme_tarihi,
       a.degistirme_tarihi
  from public.onay_adim a
  join public.onay o on o.id = a.onay_id
 where o.kaynak_tur = 1241;

comment on view public.v_satinalma_talep_onay is
  '739: satinalma talebinin onay zinciri (738 omurgasi uzerinde). Kart '
  'detayi talep_id ile suzer; omurga kaydi kaynak_tur+kaynak_id ile tutar.';

-- ===================================================== GELEN KUTUSU
-- TEK KUTU: "onayımda ne var" sorusu tür tür ekran gezerek yanıtlanmasın.
--   Kaydın KONUSU ve SAHİBİ burada çözülür - liste her tür için ayrı sorgu
--   yazsaydı yeni bir talep türü eklemek listeyi de değiştirmek olurdu.
--
--   Yeni tür eklemek = buraya bir `when` dalı. Bilinmeyen tür "#id" olarak
--   görünür ve kaybolmaz: konusu çözülemeyen bir onay, görünmeyen bir onaydan
--   iyidir.
create or replace view public.v_onay_kutusu as
select v.adim_id                                as id,
       v.onay_id,
       v.kaynak_tur,
       v.kaynak_id,
       v.sube_id,
       v.akis_kod,
       v.akis_ad,
       v.olcu,
       v.olcu_adi,
       v.sira,
       v.adim_ad,
       v.rol,
       v.atanan_kullanici_id,
       v.durum,
       v.gerekce,
       v.baslama,
       v.termin,
       v.gecikme_gun,
       case v.kaynak_tur
            when 1241 then coalesce(nullif(t.talep_no, ''), '#' || v.kaynak_id::text)
            else '#' || v.kaynak_id::text
       end                                      as kayit_no,
       case v.kaynak_tur
            when 1241 then coalesce(nullif(t.gerekce, ''), 'Satınalma talebi')
            else ''
       end                                      as konu,
       case v.kaynak_tur
            when 1241 then coalesce(d.ad, '')
            else ''
       end                                      as birim,
       case v.kaynak_tur
            when 1241 then coalesce(p.unvan, '')
            else ''
       end                                      as talep_eden
  from public.v_onay_bekleyen v
  left join public.satinalma_talep t
         on v.kaynak_tur = 1241 and t.id = v.kaynak_id
  left join public.departman d on d.id = t.departman_id
  left join public.taraf p     on p.id = t.isteyen_id;

comment on view public.v_onay_kutusu is
  '739: butun modullerin bekleyen onaylari, kaydin konusu cozulmus halde. '
  'Yeni tur eklemek = bir case dali.';

-- ================================================= BİLDİRİM ŞABLONLARI
-- Onay sırası gelen kişi haberdar olmalı; kutuyu açmayı beklemek, onayı
--   kişinin alışkanlığına bırakmaktır. Gönderim `bildirim` kuyruğundan
--   (mevcut altyapı) geçer.
insert into public.bildirim_sablon (kod, ad, kanal, konu, govde, durum, ekleyen)
select x.kod, x.ad, 1, x.konu, x.govde, 1, 0
  from (values
    ('onay.istek', 'Onay İsteği',
     'Onayınızda: {kayitNo}',
     'Sayın {alici},'||chr(10)||chr(10)||
     '{akisAd} için onayınız bekleniyor.'||chr(10)||
     'Kayıt: {kayitNo}'||chr(10)||'Konu: {konu}'||chr(10)||
     '{olcuAdi}: {olcu}'||chr(10)||'Basamak: {adimAd}'||chr(10)||
     'Termin: {termin}'),
    ('onay.hatirlatma', 'Onay Hatırlatma',
     'Bekleyen onay: {kayitNo}',
     '{kayitNo} kaydı {gecikmeGun} gündür onayınızda bekliyor.'||chr(10)||
     'Basamak: {adimAd}'||chr(10)||'Konu: {konu}'),
    ('onay.sonuc', 'Onay Sonucu',
     '{kayitNo} {sonucAd}',
     '{kayitNo} kaydınız {sonucAd}.'||chr(10)||
     '{gerekce}')
  ) as x(kod, ad, konu, govde)
 where not exists (select 1 from public.bildirim_sablon b where b.kod = x.kod);
