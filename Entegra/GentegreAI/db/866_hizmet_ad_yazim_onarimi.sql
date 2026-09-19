-- ============================================================================
--  Gentegre AI — HİZMET / TETKİK ADLARINDA YAZIM ONARIMI (866)
--  866_hizmet_ad_yazim_onarimi.sql
--
--  Kullanıcı: *"hizmet ve tetkik adlarında da aynı taramayı yap"*.
--  865 ilaç adlarını taramıştı; aynı yöntem `hizmet` (10.123 ad) ve
--  `lab_tetkik` (64 ad) üzerinde çalıştırıldı.
--
--  ============ YÖNTEM ===============================================
--  İlaç taramasındaki sözlük burada işe yaramaz (anatomi/girişim
--  sözcükleri sözlükte yok). Bunun yerine KATALOĞUN KENDİ SÖZVARLIĞI
--  çıkarıldı: 10.187 adda geçen 5.972 tekil sözcük sayildı.
--    · YAPIŞIK: nadir (≤2 geçen) bir sözcük, SIK geçen iki sözcüğe
--      bölünebiliyorsa aday.
--    · YAZIM HATASI: nadir sözcük, SIK geçen bir sözcüğe 1 harf
--      uzaklıktaysa aday.
--  152 aday çıktı, hepsi TEK TEK bağlamıyla okundu; 15 satır onarıldı.
--
--  ============ ONARILANLAR ==========================================
--    Rezeksizyonu → Rezeksiyonu          (2)  Ortodondik → Ortodontik (1)
--    Anastamoz → Anastomoz               (2)  Stend → Stent          (1)
--    Birliktevsd → Birlikte VSD          (2)  Streotaktik → Stereotaktik (2)
--    Üst Ektremite → Üst Ekstremite      (2)  Kontraslı → Kontrastlı  (1)
--    Dizi Analzi → Dizi Analizi          (1)  Komposit → Kompozit     (1)
--
--  ============ ADAY OLUP DOKUNULMAYANLAR ============================
--    · ORGANİZMA / ÖZEL ADLAR: Anaplasma, Toxoplasma, Mycoplasma,
--      Ureaplasma, "Plasma Protein A", "Castillo Moraks Apareyi",
--      "Myotoni Konjenita" (Lat. myotonia congenita), "Wood Işığı",
--      "Digital" (hizmetin adı aynen bu), "CMV Early Antigen".
--    · GEÇERLİ ÇEKİM/VARYANT: ablasyona, kistin, mutasyonu, sütürü,
--      diseksiyon/disseksiyon, küretaj/kürtaj, debridman, çölyak,
--      sakroiliak, protetik… - hata değil.
--    · SUT'un kendi yazımı: "Ekstended Akciğer Rezeksiyonları",
--      "Korrekte Tga Da / Tgada" - kaynak metinle aynı kalsın diye
--      bırakıldı.
--    · `lab_tetkik` (64 ad): aday çıkmadı.
--
--  ============ DİKKAT: SUT KATALOĞU ==================================
--  Onarılan satırların çoğu SUT kodlu (402460, 605230, R101490…).
--  Faturalama KOD üzerinden yürür, ad değişmesi ödemeyi etkilemez;
--  ancak yeni bir SUT aktarımı eski yazımı geri getirebilir - o zaman
--  dosya yeniden çalıştırılır.
--
--  ============ GÜVENLİK ==============================================
--  Yedek `hizmet_ad_yedek_866`; eski ad aşağıdaki listenin kendisinden
--  yazılır. Güncelleme id + eski metin eşleştirir, ikinci çalıştırma
--  0 satır.
-- ============================================================================
\set ON_ERROR_STOP on
begin;

create table if not exists public.hizmet_ad_yedek_866 (
    id           integer primary key,
    ad           character varying(200) not null,
    yedek_tarihi timestamptz not null default now()
);

with d(id, eski, yeni) as (values
    (40, 'Mandibula veya Maksilladan Küçük Çaplı Tümör Rezeksizyonu', 'Mandibula veya Maksilladan Küçük Çaplı Tümör Rezeksiyonu'),
    (196, '(*) Ortodondik Ameliyat Arkı, Tek Çene', '(*) Ortodontik Ameliyat Arkı, Tek Çene'),
    (355, 'Üreterokalisiyel Anastamoz', 'Üreterokalisiyel Anastomoz'),
    (543, 'Endoskopik Biliyer Stend  Yerleştirilmesi', 'Endoskopik Biliyer Stent Yerleştirilmesi'),
    (1115, 'Korrekte Tga Da Ps ile Birliktevsd', 'Korrekte Tga Da Ps ile Birlikte VSD'),
    (1853, 'Mandibula veya Maksilladan Küçük Çaplı Tümör Rezeksizyonu', 'Mandibula veya Maksilladan Küçük Çaplı Tümör Rezeksiyonu'),
    (3217, 'Streotaktik Radyoterapi', 'Stereotaktik Radyoterapi'),
    (3908, 'Üreterokalisiyel Anastamoz', 'Üreterokalisiyel Anastomoz'),
    (5420, 'Streotaktik Meme İşaretleme', 'Stereotaktik Meme İşaretleme'),
    (6269, 'Korrekte Tgada Ps ile Birliktevsd', 'Korrekte Tgada Ps ile Birlikte VSD'),
    (9059, 'BT Anjiografi, Üst Ektremite Damarları - Sağ', 'BT Anjiografi, Üst Ekstremite Damarları - Sağ'),
    (9060, 'BT Anjiografi, Üst Ektremite Damarları - Sol', 'BT Anjiografi, Üst Ekstremite Damarları - Sol'),
    (9169, 'MRG, Kardiyak, Kontraslı', 'MRG, Kardiyak, Kontrastlı'),
    (9482, 'Otozomal Resesif Ağır Konjenital Nötropeni (Hax1 Geni Dizi Analzi)', 'Otozomal Resesif Ağır Konjenital Nötropeni (Hax1 Geni Dizi Analizi)'),
    (9873, 'Fiberle Güçlendirilmiş Komposit Restorasyon (Diş Başına)', 'Fiberle Güçlendirilmiş Kompozit Restorasyon (Diş Başına)')
)
insert into public.hizmet_ad_yedek_866 (id, ad)
select d.id, d.eski from d join public.hizmet h on h.id = d.id
 where h.ad in (d.eski, d.yeni)
on conflict (id) do nothing;

with d(id, eski, yeni) as (values
    (40, 'Mandibula veya Maksilladan Küçük Çaplı Tümör Rezeksizyonu', 'Mandibula veya Maksilladan Küçük Çaplı Tümör Rezeksiyonu'),
    (196, '(*) Ortodondik Ameliyat Arkı, Tek Çene', '(*) Ortodontik Ameliyat Arkı, Tek Çene'),
    (355, 'Üreterokalisiyel Anastamoz', 'Üreterokalisiyel Anastomoz'),
    (543, 'Endoskopik Biliyer Stend  Yerleştirilmesi', 'Endoskopik Biliyer Stent Yerleştirilmesi'),
    (1115, 'Korrekte Tga Da Ps ile Birliktevsd', 'Korrekte Tga Da Ps ile Birlikte VSD'),
    (1853, 'Mandibula veya Maksilladan Küçük Çaplı Tümör Rezeksizyonu', 'Mandibula veya Maksilladan Küçük Çaplı Tümör Rezeksiyonu'),
    (3217, 'Streotaktik Radyoterapi', 'Stereotaktik Radyoterapi'),
    (3908, 'Üreterokalisiyel Anastamoz', 'Üreterokalisiyel Anastomoz'),
    (5420, 'Streotaktik Meme İşaretleme', 'Stereotaktik Meme İşaretleme'),
    (6269, 'Korrekte Tgada Ps ile Birliktevsd', 'Korrekte Tgada Ps ile Birlikte VSD'),
    (9059, 'BT Anjiografi, Üst Ektremite Damarları - Sağ', 'BT Anjiografi, Üst Ekstremite Damarları - Sağ'),
    (9060, 'BT Anjiografi, Üst Ektremite Damarları - Sol', 'BT Anjiografi, Üst Ekstremite Damarları - Sol'),
    (9169, 'MRG, Kardiyak, Kontraslı', 'MRG, Kardiyak, Kontrastlı'),
    (9482, 'Otozomal Resesif Ağır Konjenital Nötropeni (Hax1 Geni Dizi Analzi)', 'Otozomal Resesif Ağır Konjenital Nötropeni (Hax1 Geni Dizi Analizi)'),
    (9873, 'Fiberle Güçlendirilmiş Komposit Restorasyon (Diş Başına)', 'Fiberle Güçlendirilmiş Kompozit Restorasyon (Diş Başına)')
)
update public.hizmet h set ad = d.yeni, degistirme_tarihi = now()
  from d where h.id = d.id and h.ad = d.eski;

do $$
declare v_yedek integer; v_kalan integer;
begin
    select count(*) into v_yedek from public.hizmet_ad_yedek_866;
    select count(*) into v_kalan from public.hizmet h
      join public.hizmet_ad_yedek_866 y on y.id = h.id where h.ad = y.ad;
    raise notice '866 tamam: yedek % satir, eski yazimi kalan %.', v_yedek, v_kalan;
end $$;

commit;
