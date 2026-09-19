-- ============================================================================
--  Gentegre AI — BİTİŞİK / BOZUK YAZILMIŞ SON 6 KAYIT (864)
--  864_etken_madde_bozuk_kayit_onarimi.sql
--
--  Kullanıcı: *"bozuk 6 satırı da düzelt"*.
--  863 sonrası ekranda Türkçe harf kalan son 6 satır. Hepsi VERİ GİRİŞ
--  HATASI; düzeltmeler metnin kendisinden ispatlanıyor, tahmin yok.
--
--    · BENOL B12 (2 satır)  "Bı Vitamini" → "B1 Vitamini"
--      Türkçe klavyede rakam 1 yerine noktasız ı yazılmış; aynı cümlede
--      "B6 Vitamini" rakamla yazılı - kendi içinde çelişki.
--    · AGNUCASTON (1)       "fructus agnı castı" → "fructus agni casti"
--      Latince tanım (Vitex agnus-castus meyvesi); i harfleri ı olmuş.
--    · INFLUVAC TETRA (2)   "ıvr-190" → "IVR-190" (DSO suş kodu, büyük
--      harf ve rakam) + suş ayraçlarındaki boşluklar ("benzeri suş-a/..."
--      → "benzeri suş - a/...") düzeltildi; suş adlarına dokunulmadı.
--    · POLİSERA (1)        bitişik yazılmış yılan antivenom tanımı
--      ("VENOMUNAKARŞI", "YILANVENOMUNA", "F(AB')2FRAGMANLARI",
--      "(ATKÖKENLİ)"). Üç yılan türü için aynı cümle üç kez tekrarlandığı
--      ve alan 300 karakterle sınırlı olduğu için türler tek cümlede
--      toplandı; İÇERİK AYNI (Macrovipera lebetina, Montivipera
--      xanthina, Vipera ammodytes · F(ab')2 fragmanları · at kökenli).
--
--  Ayrıca sözlüğe "at kökenli", "benzeri", "tip" eklenir - onarılan
--  metnin İngilizce görünümde tam çevrilmesi için.
--
--  Idempotent: sözlükte `on conflict do update`, veride id + eski metin.
-- ============================================================================
\set ON_ERROR_STOP on
begin;

insert into public.ceviri (kapsam, anahtar, dil, metin) values
    ('ilac', 'at kokenli', 1, 'equine-derived'),
    ('ilac', 'benzeri', 1, 'like'),
    ('ilac', 'tip', 1, 'type'),
    -- SOZ DIZIMI: Turkce "X'e karsi immunoglobulin" Ingilizce'de
    --   "immunoglobulin against X" olur; sozcuk sozcuk cevrilince ters
    --   duser. 856'daki gibi BILESIK anahtar yazilir (en uzun eslesme).
    ('ilac', 'yilan venomlarina karsi immunoglobulin', 1,
             'immunoglobulin against snake venoms'),
    ('ilac', 'yilan isirmalarina karsin', 1, 'against snake bites'),
    ('ilac', 'yilan isirmalarina karsi', 1, 'against snake bites'),
    ('ilac', 'isirmalarina', 1, 'bites'),
    ('ilac', 'fragmanlari', 1, 'fragments'),
    -- Antivenom tanimi sozcuk sozcuk cevrilince Ingilizce'de anlamsiz
    --   diziliyor (tur adlari + "karsi" + "fragmanlari"). TAM METIN
    --   anahtari yazilir; motor once tam eslesmeye bakar.
    ('ilac', 'macrovipera lebetina, montivipera xanthina ve vipera ammodytes yilan venomlarina karsi immunoglobulin f(ab'')2 fragmanlari (at kokenli)', 1,
             'F(ab'')2 fragments of equine immunoglobulin against Macrovipera lebetina, Montivipera xanthina and Vipera ammodytes snake venoms')
on conflict (kapsam, anahtar, dil) do update set metin = excluded.metin,
    degistirme_tarihi = now();

create table if not exists public.ilac_etken_yedek_864 (
    id           integer primary key,
    etken_madde  character varying(300) not null,
    yedek_tarihi timestamptz not null default now()
);

with d(id, eski, yeni) as (values
    (1853, 'tiamin hidroklorür (Bı Vitamini), piridoksin hidroklorür (B6 Vitamini)', 'tiamin hidroklorür (B1 Vitamini), piridoksin hidroklorür (B6 Vitamini)'),
    (1855, 'tiamin hidroklorür (Bı Vitamini), piridoksin hidroklorür (B6 Vitamini)', 'tiamin hidroklorür (B1 Vitamini), piridoksin hidroklorür (B6 Vitamini)'),
    (18610, 'fructus agnı castı kuru ekstresi', 'fructus agni casti kuru ekstresi'),
    (19219, 'a/brisbane/02/2018 (h1n1)pdm09 - (a/brisbane/02/2018, ıvr-190) benzeri suş-a/kansas/14/2017 (h3n2) - (a/kansas/14/2017, nymc x-327) benzeri suş- b/colorado/06/2017- (b/maryland/15/2016, nymc bx-69a) benzeri suş- b/phuket/3073/2013 - (b/phuket/3073/2013, yabanıl tip) benzeri suş', 'a/brisbane/02/2018 (h1n1)pdm09 - (a/brisbane/02/2018, IVR-190) benzeri suş - a/kansas/14/2017 (h3n2) - (a/kansas/14/2017, nymc x-327) benzeri suş - b/colorado/06/2017 - (b/maryland/15/2016, nymc bx-69a) benzeri suş - b/phuket/3073/2013 - (b/phuket/3073/2013, yabanıl tip) benzeri suş'),
    (19220, 'a/brisbane/02/2018 (h1n1)pdm09 - (a/brisbane/02/2018, ıvr-190) benzeri suş-a/kansas/14/2017 (h3n2) - (a/kansas/14/2017, nymc x-327) benzeri suş- b/colorado/06/2017- (b/maryland/15/2016, nymc bx-69a) benzeri suş- b/phuket/3073/2013 - (b/phuket/3073/2013, yabanıl tip) benzeri suş', 'a/brisbane/02/2018 (h1n1)pdm09 - (a/brisbane/02/2018, IVR-190) benzeri suş - a/kansas/14/2017 (h3n2) - (a/kansas/14/2017, nymc x-327) benzeri suş - b/colorado/06/2017 - (b/maryland/15/2016, nymc bx-69a) benzeri suş - b/phuket/3073/2013 - (b/phuket/3073/2013, yabanıl tip) benzeri suş'),
    (20164, 'MACROVIPERA LEBETINA YILAN VENOMUNAKARŞI İMMÜNOGLOBULİN F(AB'')2 FRAGMANLARI(AT KÖKENLİ), MONTIVIPERA XANTHINA YILANVENOMUNA KARŞI İMMÜNOGLOBULİN F(AB'')2FRAGMANLARI (AT KÖKENLİ), VIPERA AMMODYTES YILAN VENOMUNA KARŞINİMMÜNOGLOBULİN F(AB'')2 FRAGMANLARI (ATKÖKENLİ)', 'Macrovipera lebetina, Montivipera xanthina ve Vipera ammodytes yılan venomlarına karşı immünoglobulin F(ab'')2 fragmanları (at kökenli)')
)
, y as (
    insert into public.ilac_etken_yedek_864 (id, etken_madde)
    select i.id, i.etken_madde from public.ilac i join d on d.id = i.id
     where i.etken_madde = d.eski
    on conflict (id) do nothing
    returning 1
)
update public.ilac i set etken_madde = d.yeni, guncelleme = now()
  from d where i.id = d.id and i.etken_madde = d.eski;

do $$
declare v_veri integer;
begin
    select count(*) into v_veri from public.ilac_etken_yedek_864;
    raise notice '864 tamam: onarilan satir %.', v_veri;
end $$;

commit;
