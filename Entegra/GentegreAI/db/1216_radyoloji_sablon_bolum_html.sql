-- =============================================================================
--  1216  RADYOLOJİ ŞABLON BÖLÜMÜ - BİÇİMLİ VARSAYILAN METİN
--
--  Kullanıcı (01.11.2026): "rapor şablonları aktarılmamış". Eski HBYS (GEN3000) şablonları Word belgesi
--  (HAZOLE): başlıklar, kalın / altı çizili, ölçüm tabloları. Bölümün varsayılanı yalnız düz metindi -
--  tablo ve biçim kaybolurdu. `varsayilan_html` (RaporHtml beyaz listesinden geçmiş HTML) doluysa rapor
--  ekranı şablonu bu haliyle açar; boşsa eskisi gibi `varsayilan_metin`.
--
--  Şablon kartı yalnız düz metni düzenler: varsayilan_metin elle değişip HTML aynı kalırsa HTML boşaltılır
--  (yoksa yapılan düzeltme rapora hiç yansımazdı). İdempotent.
-- =============================================================================

begin;

alter table public.radyoloji_sablon_bolum add column if not exists varsayilan_html text;

comment on column public.radyoloji_sablon_bolum.varsayilan_html is
  'Biçimli varsayılan (1216): doluysa rapor ekranı bunu açar. varsayilan_metin elle değişince boşaltılır.';

create or replace function public.fn_radyoloji_sablon_bolum_html_bosalt() returns trigger
language plpgsql as $$
begin
    if new.varsayilan_metin is distinct from old.varsayilan_metin
       and new.varsayilan_html is not distinct from old.varsayilan_html then
        new.varsayilan_html := null;
    end if;
    return new;
end $$;

drop trigger if exists tg_radyoloji_sablon_bolum_html on public.radyoloji_sablon_bolum;
create trigger tg_radyoloji_sablon_bolum_html
    before update on public.radyoloji_sablon_bolum
    for each row execute function public.fn_radyoloji_sablon_bolum_html_bosalt();

commit;
