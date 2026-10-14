-- ============================================================================
--  1106_basvuru_gelis_nedeni_vaka_turu.sql
--  VAKA TÜRÜ BAŞVURUDA (kullanıcı 15.10.2026: "vaka türü başvuruda olmalı..
--  başvuruda geliş nedenine vaka türündeki seçenekleri ekle ve muayeneden kaldır").
--
--  Başvurunun "Geliş Nedeni" (basvuru.gelis_nedeni) e-Nabız'a zaten SKRS VAKA TÜRÜ
--  olarak gidiyor (612/613: yerel değer -> skrs_kod). Listede yalnız Muayene /
--  Kontrol / Tetkik / Rapor / Aşı vardı; adli vaka, iş / trafik kazası gibi haller
--  muayene kartındaki ayrı "Vaka Türü" alanında soruluyordu - aynı bilgi iki yerde,
--  e-Nabız'a giden başvurudaki değildi.
--
--  1) Geliş nedenine SKRS VAKA TÜRÜ'nün kalan seçenekleri (skrs_kod ile).
--     "Normal" (1) ve "Kontrol Muayenesi" (7) zaten Muayene / Kontrol olarak var.
--  2) Muayenede elle girilmiş vaka türü varsa başvuruya taşınır - YALNIZ başvurunun
--     geliş nedeni boş ya da varsayılan "Muayene" (1) ise; kurumun bilerek seçtiği
--     değer ezilmez. muayene.vaka_turu kolonu durur (eski kayıtlar), ekrandan kalkar.
--  Tekrar çalıştırılabilir.
-- ============================================================================

-- 1) Seçenekler -----------------------------------------------------------------
do $$
declare
    v_liste integer := (select id from public.kod_liste where kod = 'basvuru.gelis_nedeni');
    v_cakisan integer;
begin
    if v_liste is null then
        raise notice '1106: basvuru.gelis_nedeni listesi yok, atlandi';
        return;
    end if;

    -- Aynı numarada FARKLI SKRS kodlu bir değer varsa (kurum eklemiş) dokunma, bildir.
    select count(*) into v_cakisan
      from public.kod_deger d
      join (values (6,'2'),(7,'3'),(8,'4'),(9,'5'),(10,'6'),(11,'12'),(12,'8'),(13,'9'),
                   (14,'10'),(15,'11'),(16,'13'),(17,'14'),(18,'15')) v(deger, skrs)
        on v.deger = d.deger
     where d.liste_id = v_liste and d.dil = 0 and d.skrs_kod <> v.skrs;
    if v_cakisan > 0 then
        raise notice '1106: % deger numarasi kurumca kullanilmis, o satirlar eklenmedi', v_cakisan;
    end if;

    insert into public.kod_deger (liste_id, deger, dil, ad, sira, aktif, skrs_kod)
    select v_liste, v.deger, 0, v.ad, v.sira, 1, v.skrs
      from (values
            (6,  'Acil',                          60,  '2'),
            (7,  'Trafik Kazası',                 70,  '3'),
            (8,  'İş Kazası',                     80,  '4'),
            (9,  'Adli Vaka',                     90,  '5'),
            (10, 'Meslek Hastalığı',              100, '6'),
            (11, 'Ev Kazası',                     110, '12'),
            (12, 'Evde Sağlık',                   120, '8'),
            (13, 'Gezici Hizmet',                 130, '9'),
            (14, 'İşe Giriş / Periyodik Muayene', 140, '10'),
            (15, 'İşyeri Normal Muayene',         150, '11'),
            (16, 'Konsültasyon Muayenesi',        160, '13'),
            (17, 'Olay / Afet',                   170, '14'),
            (18, 'Sağlık Tedbiri Kararı',         180, '15')
           ) v(deger, ad, sira, skrs)
    on conflict (liste_id, deger, dil) do nothing;
end $$;

-- 2) Muayenedeki vaka türü -> başvurunun geliş nedeni -----------------------------
--  muayene.vaka_turu kart kodları (KartKatalogu VakaTuruKodlari): 1 adli · 2 iş kazası ·
--  3 trafik kazası · 4 meslek hastalığı · 9 diğer (eşi yok, taşınmaz).
with esle(eski, yeni) as (values (1, 9), (2, 8), (3, 7), (4, 10)),
aday as (
    select distinct on (m.belge_id) m.belge_id, e.yeni
      from public.muayene m
      join esle e on e.eski = m.vaka_turu
     where m.belge_id is not null
     order by m.belge_id, m.id desc
)
update public.belge_basvuru bb
   set gelis_nedeni = a.yeni
  from aday a
 where bb.id = a.belge_id
   and (bb.gelis_nedeni is null or bb.gelis_nedeni = 1);

-- Kontrol
select d.deger, d.ad, d.skrs_kod
  from public.kod_deger d join public.kod_liste l on l.id = d.liste_id
 where l.kod = 'basvuru.gelis_nedeni' and d.dil = 0
 order by d.sira, d.deger;
