-- =============================================================================
--  1137  PERSONEL BELGE TAKİBİ - HATIRLATMA ŞABLONLARI
--
--  Kullanıcı (22.10.2026): "Belge Takip Listesini mockup'a göre yap" -
--  mockup Ekranlar/IK/personel_belge_takibi.html (2) "📤 Seçililere hatırlat".
--  İK listede personeli seçer; eksik / süresi dolan / yaklaşan belgeleri
--  personele bildirim kuyruğundan gider (e-postası varsa e-posta, yoksa SMS).
--  Aynı personele 24 saat içinde ikinci hatırlatma konmaz (uçta).
--  bildirim.kaynak_tur 49 = personel belge takibi.
--  Kurum metni değiştirdiyse dokunulmaz. İdempotent.
-- =============================================================================

begin;

insert into public.bildirim_sablon (kod, ad, kanal, konu, govde, degiskenler, durum, aciklama, ekleyen)
select v.kod, v.ad, v.kanal, v.konu, v.govde, v.degiskenler::jsonb, 1, v.aciklama, 0 from (values
    ('personel.belge.hatirlatma', 'Personel belge hatırlatma (SMS)', 1::smallint, '',
     'Sayın {{personel_ad}}, özlük dosyanızda tamamlanması gereken belgeler: {{belgeler}}. İnsan Kaynakları - {{kurum}}',
     '{"personel_ad":"Personel adı","belgeler":"Eksik / süresi dolan / yaklaşan belgeler","kurum":"Kurum adı"}',
     'İK › Belge Takibi › Seçililere hatırlat'),
    ('personel.belge.hatirlatma.eposta', 'Personel belge hatırlatma (e-posta)', 2::smallint,
     '{{kurum}} - özlük dosyanızda eksik belgeler',
     E'Sayın {{personel_ad}},\n\nÖzlük dosyanızda tamamlanması ya da yenilenmesi gereken belgeler:\n\n{{belgeler}}\n\nBelgelerinizi İnsan Kaynakları birimine iletmenizi rica ederiz.\n\n{{kurum}} - İnsan Kaynakları',
     '{"personel_ad":"Personel adı","belgeler":"Eksik / süresi dolan / yaklaşan belgeler (satır satır)","kurum":"Kurum adı"}',
     'İK › Belge Takibi › Seçililere hatırlat'))
  as v(kod, ad, kanal, konu, govde, degiskenler, aciklama)
 where not exists (select 1 from public.bildirim_sablon s where s.kod = v.kod);

commit;
