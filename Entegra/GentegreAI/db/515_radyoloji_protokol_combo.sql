-- =====================================================================
--  515_radyoloji_protokol_combo.sql
--  Radyoloji protokolü gridinde alanlar COMBO - seçenekler kod listesinden.
--
--  Kullanıcı: "radyoloji protokolü griddeki alanları combo yap, seçenekler
--  ekle". Bugün modalite ve kontrast combo, geri kalan üçü SERBEST METİN:
--  süre elle yazılıyor, hazırlık talimatı ve personel uyarısı her tetkikte
--  yeniden yazılıyordu. Aynı talimatın on ayrı yazımı çıkıyor, hastaya giden
--  metin tetkike göre değişiyordu.
--
--  KOD + METİN BİRLİKTE: seçim kodla yapılır, metin kolonu KODUN METNİYLE
--  DOLDURULUR (tetik). Böylece
--    * kullanıcı listeden seçer (yazım birliği),
--    * istem/çekim ekranı ve hasta çıktısı eskisi gibi METNİ okumaya devam
--      eder - o tarafta hiçbir şey değişmez,
--    * gerekirse metin elle düzenlenebilir (kod "Özel" seçilir).
--
--  Süre `smallint` olduğu için doğrudan sabit kodlarla combo olur; ayrı
--  liste gerekmez (kart tarafında SabitKodlar).
-- =====================================================================

-- --------------------------------------------------------- kod listeleri --
do $$
declare
    v_haz integer;
    v_uya integer;
    v_ser integer;
begin
    -- Hazırlık talimatı listesi ZATEN VAR (rad.hazirlik, 8 metin) - modalite
    --   bazlı varsayılan olarak kullanılıyor; protokolde de aynı liste seçilir.
    select id into v_haz from public.kod_liste where kod = 'rad.hazirlik';

    -- PERSONEL UYARISI (hastaya verilen hazırlıktan AYRI): çekim öncesi
    --   sorulacak / kontrol edilecek şeyler.
    insert into public.kod_liste (kod, ad)
    select 'rad.uyari', 'Radyoloji Personel Uyarısı'
     where not exists (select 1 from public.kod_liste where kod = 'rad.uyari');
    select id into v_uya from public.kod_liste where kod = 'rad.uyari';

    insert into public.kod_deger (liste_id, deger, ad, sira, aktif)
    select v_uya, d.deger, d.ad, d.sira, 1
      from (values
        (1, 'Gebelik sorgusu yapılacak (son adet tarihi kaydedilsin)', 10),
        (2, 'Kreatinin / eGFR sonucu görülmeden kontrast verilmez', 20),
        (3, 'Kalp pili, koklear implant, nörostimülatör sorgulanacak', 30),
        (4, 'Klostrofobi öyküsü - sedasyon gerekebilir, hekime danışın', 40),
        (5, 'Kontrast alerjisi öyküsü - premedikasyon protokolü uygulanır', 50),
        (6, 'Metformin kullanımı - kontrast sonrası 48 saat kesilir', 60),
        (7, 'Pediatrik hasta - doz ayarı (ALARA) ve refakatçi kurşun önlük', 70),
        (8, 'Damar yolu açık olmalı (18-20 G, antekübital)', 80),
        (9, 'Uyarı yok', 90)
      ) as d(deger, ad, sira)
     where not exists (select 1 from public.kod_deger x
                        where x.liste_id = v_uya and x.deger = d.deger);

    -- SERİ / SEKANS ŞABLONU: "nasıl çekilecek" - modaliteden bağımsız ortak
    --   şablonlar; kuruma özel olanlar listeye eklenir.
    insert into public.kod_liste (kod, ad)
    select 'rad.seri', 'Radyoloji Seri / Sekans Şablonu'
     where not exists (select 1 from public.kod_liste where kod = 'rad.seri');
    select id into v_ser from public.kod_liste where kod = 'rad.seri';

    insert into public.kod_deger (liste_id, deger, ad, sira, aktif)
    select v_ser, d.deger, d.ad, d.sira, 1
      from (values
        (1,  'Rutin - kontrastsız', 10),
        (2,  'Kontrastlı (tek faz)', 20),
        (3,  'Kontrastsız + kontrastlı', 30),
        (4,  'Dinamik / çok fazlı (arteriyel, portal, geç)', 40),
        (5,  'Anjiyografi (BTA / MRA)', 50),
        (6,  'Difüzyon ağırlıklı (DWI/ADC)', 60),
        (7,  'Yüksek çözünürlük (ince kesit)', 70),
        (8,  'Fonksiyonel / perfüzyon', 80),
        (9,  'Doppler (renkli + spektral)', 90),
        (10, 'İki yönlü (AP + lateral)', 100),
        (11, 'Tek yön (AP)', 110),
        (99, 'Özel - metin elle yazılır', 990)
      ) as d(deger, ad, sira)
     where not exists (select 1 from public.kod_deger x
                        where x.liste_id = v_ser and x.deger = d.deger);

    raise notice 'Radyoloji kod listeleri hazır (hazirlik=%, uyari=%, seri=%).',
                 v_haz, v_uya, v_ser;
end $$;

-- ----------------------------------------------------------- kod kolonlari --
alter table public.radyoloji_protokol
    add column if not exists seri_kodu     smallint not null default 0,
    add column if not exists hazirlik_kodu smallint not null default 0,
    add column if not exists uyari_kodu    smallint not null default 0;

comment on column public.radyoloji_protokol.seri_kodu is
    'rad.seri - seçim; metin kolonu tetikle bundan doldurulur (515).';
comment on column public.radyoloji_protokol.hazirlik_kodu is
    'rad.hazirlik - hastaya verilen hazırlık talimatı seçimi (515).';
comment on column public.radyoloji_protokol.uyari_kodu is
    'rad.uyari - PERSONEL uyarısı seçimi; hasta hazırlığından ayrıdır (515).';

/**
 * Kod seçilince METİN kolonu kodun metniyle dolar. Yalnız KOD DEĞİŞTİĞİNDE
 * yazar: kullanıcı metni elle düzenlediyse (kod aynı kalarak) üzerine
 * yazılmaz. "Özel" (99) seçilirse metne dokunulmaz - elle yazılacak demektir.
 */
create or replace function public.tg_radyoloji_protokol_metin() returns trigger
language plpgsql as $$
declare
    v_ad text;
begin
    if new.seri_kodu <> 0 and new.seri_kodu <> 99
       and (tg_op = 'INSERT' or new.seri_kodu is distinct from old.seri_kodu) then
        select d.ad into v_ad from public.kod_deger d
          join public.kod_liste l on l.id = d.liste_id
         where l.kod = 'rad.seri' and d.deger = new.seri_kodu;
        if v_ad is not null then new.seri_tarifi := left(v_ad, 400); end if;
    end if;

    if new.hazirlik_kodu <> 0
       and (tg_op = 'INSERT' or new.hazirlik_kodu is distinct from old.hazirlik_kodu) then
        select d.ad into v_ad from public.kod_deger d
          join public.kod_liste l on l.id = d.liste_id
         where l.kod = 'rad.hazirlik' and d.deger = new.hazirlik_kodu;
        if v_ad is not null then new.hazirlik_metni := left(v_ad, 600); end if;
    end if;

    if new.uyari_kodu <> 0 and new.uyari_kodu <> 9
       and (tg_op = 'INSERT' or new.uyari_kodu is distinct from old.uyari_kodu) then
        select d.ad into v_ad from public.kod_deger d
          join public.kod_liste l on l.id = d.liste_id
         where l.kod = 'rad.uyari' and d.deger = new.uyari_kodu;
        if v_ad is not null then new.ozel_uyari := left(v_ad, 400); end if;
    elsif new.uyari_kodu = 9 and (tg_op = 'INSERT' or new.uyari_kodu is distinct from old.uyari_kodu) then
        new.ozel_uyari := '';        -- "Uyarı yok"
    end if;

    return new;
end $$;

drop trigger if exists tg_radyoloji_protokol_metin on public.radyoloji_protokol;
create trigger tg_radyoloji_protokol_metin
    before insert or update of seri_kodu, hazirlik_kodu, uyari_kodu
    on public.radyoloji_protokol
    for each row execute function public.tg_radyoloji_protokol_metin();

-- Mevcut protokollerde metin dolu, kod boş: metinden kodu geri bul (birebir
--   eşleşiyorsa) - böylece kart açıldığında combo boş görünmez.
update public.radyoloji_protokol p
   set hazirlik_kodu = d.deger
  from public.kod_deger d
  join public.kod_liste l on l.id = d.liste_id
 where l.kod = 'rad.hazirlik' and p.hazirlik_kodu = 0
   and btrim(p.hazirlik_metni) = btrim(d.ad);
