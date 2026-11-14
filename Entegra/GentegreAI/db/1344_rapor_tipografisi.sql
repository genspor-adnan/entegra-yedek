-- 1344 - Rapor tipografisi: kurum ayarı + şablon üst-seçimi + onayda DAMGA (mockup radyoloji_rapor_tipografi.html).
--
-- Kullanıcı 14.11.2026: "raporlarda / şablonlarda dünyada kullanılan font ve punto nedir" → mockup → "onayla uygula";
--   "toptan mı değiştiriyor bütün şablonları?" → hayır: şablon kayıtları değişmez, görünüm çıktı anında uygulanır;
--   "tipografi damgalama" → onay / e-imza anında geçerli tipografi rapora yazılır, arşiv çıktısı değişmez.
-- Bakanlık / SKS görünüm standardı koymaz (Teletıp kılavuzu içerik + HL7 alanları); tipografi kurum tercihidir.
--
-- Üç katman:
--   1) KURUM: referans 'radyoloji.tipografi' (json): font · punto · satır aralığı · paragraf arası · hizalama ·
--      kenar boşluğu (mm) · rapor başlığı puntosu. Varsayılan Arial 10,5 · 1,3 · 6 pt · iki yana · 18 mm · 13 pt.
--   2) ŞABLON: radyoloji_sablon.tipografi_kaynak  1 = kurum ayarı · 2 = özel (tip_* kolonları) · 3 = şablonun kendi
--      biçimi ("özgün": bugüne kadarki görünüm, Trebuchet 13 px · 1,65 - eski HBYS Word şablonları buna alınır).
--   3) RAPOR DAMGASI: radyoloji_rapor.tipografi (jsonb) onayda yazılır; onaylı raporun çıktısı ve e-imza belgesi
--      yalnız damgayı kullanır. Bugüne kadar onaylanmış raporlara "özgün" damgası basılır (arşiv değişmez).
-- Yetki: radyoloji.tipografi (ekran kodu ilkesi 1003; haklar radyoloji.sablon'dan kopyalanır - şablonu düzenleyen
--   tipografiyi de düzenler). Tekrar çalıştırılabilir.
\set ON_ERROR_STOP on
begin;

-- ------------------------------------------------------------- kurum ayarı --
insert into public.referans (anahtar, deger, tip, kapsam, aciklama)
select 'radyoloji.tipografi',
       '{"font":"arial","punto":10.5,"satir":1.3,"paragraf":6,"hiza":"iki","kenar":18,"baslikPunto":13}',
       'json', 'firma',
       'Radyoloji rapor tipografisi (1344): font, punto, satır aralığı, paragraf, hizalama, kenar, başlık puntosu; onayda damgalanır.'
 where not exists (select 1 from public.referans where anahtar = 'radyoloji.tipografi');

-- --------------------------------------------------------- şablon üst-seçimi --
alter table public.radyoloji_sablon
    add column if not exists tipografi_kaynak smallint not null default 1,
    add column if not exists tip_font     varchar(20),
    add column if not exists tip_punto    numeric(4,1),
    add column if not exists tip_satir    numeric(3,2),
    add column if not exists tip_paragraf smallint,
    add column if not exists tip_hiza     smallint;
comment on column public.radyoloji_sablon.tipografi_kaynak is '1344: 1 kurum ayarı · 2 özel (tip_* kolonları) · 3 şablonun kendi biçimi (özgün görünüm)';
comment on column public.radyoloji_sablon.tip_font     is '1344: özel tipografi - arial | calibri | times | segoe | trebuchet (boş = kurum)';
comment on column public.radyoloji_sablon.tip_punto    is '1344: özel tipografi - gövde puntosu 9-12 (boş = kurum)';
comment on column public.radyoloji_sablon.tip_satir    is '1344: özel tipografi - satır aralığı 1.0-2.0 (boş = kurum)';
comment on column public.radyoloji_sablon.tip_paragraf is '1344: özel tipografi - paragraf arası pt 0-12 (boş = kurum)';
comment on column public.radyoloji_sablon.tip_hiza     is '1344: özel tipografi - 1 sol · 2 iki yana (boş = kurum)';

alter table public.radyoloji_sablon drop constraint if exists ck_radyoloji_sablon_tipografi;
alter table public.radyoloji_sablon add constraint ck_radyoloji_sablon_tipografi
    check (tipografi_kaynak in (1, 2, 3)
           and (tip_punto is null or tip_punto between 9 and 12)
           and (tip_satir is null or tip_satir between 1.0 and 2.0)
           and (tip_paragraf is null or tip_paragraf between 0 and 12)
           and (tip_hiza is null or tip_hiza in (1, 2)));

-- Geçiş (bir kez): eski HBYS Word şablonları kendi biçimini korur.
do $$
begin
  if not exists (select 1 from public.referans where anahtar = 'radyoloji.tipografi_gecis_1344') then
    update public.radyoloji_sablon
       set tipografi_kaynak = 3
     where aciklama like 'Eski HBYS şablonu%' and tipografi_kaynak = 1;
    insert into public.referans (anahtar, deger, tip, kapsam) values ('radyoloji.tipografi_gecis_1344', '1', 'metin', 'firma')
    on conflict (anahtar) do nothing;
  end if;
end $$;

-- ------------------------------------------------------------- rapor damgası --
alter table public.radyoloji_rapor add column if not exists tipografi jsonb;
comment on column public.radyoloji_rapor.tipografi is
  '1344: onay / e-imza anında damgalanan tipografi (font, punto, satir, paragraf, hiza, kenar, baslikPunto, kaynak). Onaylı raporun çıktısı yalnız bunu kullanır; taslak damgasızdır.';

-- Bugüne kadar onaylanmış raporlar: özgün görünüm damgası (arşiv çıktısı değişmesin).
update public.radyoloji_rapor
   set tipografi = '{"font":"trebuchet","punto":9.75,"satir":1.65,"paragraf":0,"hiza":"sol","kenar":14,"baslikPunto":12,"kaynak":"ozgun"}'::jsonb
 where tipografi is null and (kilit = 1 or durum = 3);

-- ---------------------------------------------------------------- ekran kodu --
do $$ begin
  if not exists (select 1 from public.yetki where kod = 'radyoloji.sablon') then
    raise exception '1344: kaynak kod radyoloji.sablon yetki tablosunda yok';
  end if;
end $$;

insert into public.yetki (kod, ad, grup, tur, sira, urun_modu, modul)
select 'radyoloji.tipografi', 'Rapor Tipografisi (Radyoloji)', ye.grup, 0,
       coalesce((select max(sira) from public.yetki where grup = ye.grup), ye.sira), ye.urun_modu, 'radyoloji'
  from public.yetki ye
 where ye.kod = 'radyoloji.sablon'
on conflict (kod) do update
   set ad = excluded.ad, grup = excluded.grup, tur = 0, modul = excluded.modul, aktif = 1;

insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, deger, kapsam, ekleyen)
select ry.rol_id, yn.id, ry.gor, ry.ekle, ry.degistir, ry.sil, ry.deger, ry.kapsam, 0
  from public.yetki ye
  join public.yetki yn     on yn.kod = 'radyoloji.tipografi'
  join public.rol_yetki ry on ry.yetki_id = ye.id
 where ye.kod = 'radyoloji.sablon'
on conflict (rol_id, yetki_id) do nothing;

update public.rol r set yetki_surumu = yetki_surumu + 1
 where exists (select 1 from public.rol_yetki ry
                 join public.yetki y on y.id = ry.yetki_id
                where ry.rol_id = r.id and y.kod = 'radyoloji.tipografi');

-- ---------------------------------------------------- rehber ekran kataloğu --
insert into public.ai_rehber_ekran (kaynak, rota, baslik, yol, menu_grup, menu_ad, yetki_kodu, urun_modu, modul,
                                    anahtar, aciklama)
select 'radyoloji-tipografi', '/radyoloji-tipografi', 'Rapor Tipografisi', 'Radyoloji › Ayarlar › Rapor Tipografisi',
       'Radyoloji', 'Rapor Tipografisi', 'radyoloji.tipografi', 2::smallint, 'radyoloji',
       'rapor tipografisi font punto yazı tipi satır aralığı kenar boşluğu arial calibri times çıktı görünümü damga',
       'Radyoloji raporunun font, punto, satır aralığı, hizalama ve kenar boşluğu (kurum varsayılanı; şablon kartı '
       || 'üstüne yazabilir). Onayda rapora damgalanır: eski raporların çıktısı değişmez.'
 where not exists (select 1 from public.ai_rehber_ekran e where e.kaynak = 'radyoloji-tipografi');

commit;
