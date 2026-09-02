-- 340: İL / İLÇE / ÜLKE için SKRS KOD KOLONU (SKRS senkronu bu tabloları da tazeler).
--
-- Kullanıcı: "il ilçe, sigorta türü, branş ve ülke listelerini de ekle."
--
-- Branş ve sigorta türü KOD LİSTESİDİR (`kod_liste`/`kod_deger`: hekim.brans,
-- taraf.sigorta_turu) - onlar için şema değişikliği gerekmez, SKRS kodu
-- doğrudan `kod_deger.deger` olur (K58). Kod tarafında yalnız eşleme dizisine
-- iki satır eklendi.
--
-- İL / İLÇE / ÜLKE ise GERÇEK TABLOLARDIR ve DOLUDUR (81 il, 970 ilçe,
-- 232 ülke) - üstelik referans veriyor (`ilce.il_id`, `stok_uts.mensei_ulke`,
-- adres kayıtları). Bu yüzden SKRS kodu `id` YERİNE GEÇMEZ; ayrı kolonda
-- tutulur:
--   * mevcut kayıtların id'si ve ona bağlı her şey yerinde kalır,
--   * eNabız / MEDULA gönderiminde `skrs_kod` okunur,
--   * SKRS'de olup bizde olmayan satır YENİ kayıt olarak eklenir.
-- Eşleme ADA göre yapılır (`fn_ara_metin` ile Türkçe-duyarsız normalize);
-- ilçede ad tek başına benzersiz değildir (17 "MERKEZ"), o yüzden eşleme
-- (il, ad) çiftiyle yapılır - il önce senkronlanıp `skrs_kod`u dolar.
\set ON_ERROR_STOP on

alter table public.il   add column if not exists skrs_kod smallint;
alter table public.ilce add column if not exists skrs_kod integer;
alter table public.ulke add column if not exists skrs_kod smallint;

comment on column public.il.skrs_kod   is 'SKRS il kodu (340) - id yerine gecmez, esleme kolonudur.';
comment on column public.ilce.skrs_kod is 'SKRS ilce kodu (340).';
comment on column public.ulke.skrs_kod is 'SKRS ulke kodu (340).';

-- Aynı SKRS kodu iki satıra yazılamaz; boş (null) satır serbest.
create unique index if not exists ux_il_skrs   on public.il   (skrs_kod) where skrs_kod is not null;
create unique index if not exists ux_ilce_skrs on public.ilce (skrs_kod) where skrs_kod is not null;
create unique index if not exists ux_ulke_skrs on public.ulke (skrs_kod) where skrs_kod is not null;

-- Ad üzerinden eşleme senkronda her satır için sorgulanıyor; normalize edilmiş
--   ad indekslenir (fn_ara_metin IMMUTABLE - ifade indeksi kurulabilir).
create index if not exists ix_il_ad_norm   on public.il   (public.fn_ara_metin(ad));
create index if not exists ix_ilce_ad_norm on public.ilce (il_id, public.fn_ara_metin(ad));
create index if not exists ix_ulke_ad_norm on public.ulke (public.fn_ara_metin(ad));

-- ------------------------------------------------------------ kod listeleri -
-- Branş listesi 306'da, sigorta türü daha önce kurulmuştu; SKRS senkronu
--   bunlara YAZACAĞI için var olduklarından emin olunur (yoksa senkron kendi
--   açar ama listenin Türkçe adı 'hekim.brans' gibi ham kalırdı).
insert into public.kod_liste (kod, ad)
select v.kod, v.ad
  from (values ('hekim.brans',        'Hekim Branşı'),
               ('taraf.sigorta_turu', 'Sigorta Türü')) v(kod, ad)
 where not exists (select 1 from public.kod_liste kl where kl.kod = v.kod);

do $$
declare v_il integer; v_ilce integer; v_ulke integer;
begin
    select count(*) into v_il   from public.il;
    select count(*) into v_ilce from public.ilce;
    select count(*) into v_ulke from public.ulke;
    raise notice '340 tamam: skrs_kod kolonlari (il %, ilce %, ulke %) - '
                 'kodlar ilk SKRS senkronunda ad eslemesiyle dolar.',
                 v_il, v_ilce, v_ulke;
end $$;
