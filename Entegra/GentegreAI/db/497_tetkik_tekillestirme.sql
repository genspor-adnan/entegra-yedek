-- =====================================================================
--  497_tetkik_tekillestirme.sql
--  TEKRARLI TETKİK TEMİZLİĞİ - her tetkik katalogda BİR kez.
--
--  Kullanıcı: "4 kurum tipi için kullanılacak şekilde hizmet listesini
--  düzenle, tekrarlı tetkik olmasın".
--
--  Katalog Delphi'den aktarılırken iki ayrı sebeple çoğalmış:
--    1) PANEL/PAKET İÇERİĞİ ayrı hizmet kaydı olarak açılmış - "AST( SGOT )"
--       40 kez var (L.B.032 kanonik, P.C004.08 / P.S.012.09 ... kopya).
--       İçerik artık `hizmet_paket` (496) satırıdır.
--    2) TARİFE KOPYASI: aynı tetkik SGK/RES tarifesi için ikinci kez
--       açılmış ("Beyin MR" -> Radyoloji>MR, RES>RESMR, Radyoloji>SSK).
--       Tarife farkı FİYAT LİSTESİNİN işidir (ÖZEL / TTB-HUV / SUT), kurum
--       tipi de sözleşmesindeki listeyle çalışır - katalogda kopya gerekmez.
--
--  SINIFLANDIRMA tamamen VERİDEN çıkar, elle liste yok:
--    başlık : baslik_mi=1 ya da kodu altında TORUNU olan kod ("L.B" -> "L.B.258"
--             -> "L.B.258.01"): satılabilir kalem değil, katalog başlığı.
--    panel  : kodu "X" olan ve altında "X.NN" satırları bulunan, torunu
--             olmayan kayıt (L.B.258 "OGTT", P.C004 check-up paketi).
--    bileşen: kodu "<panel kodu>.NN" olan kayıt.
--    tetkik : geri kalan - katalogun kendisi.
--
--  KANONİK seçim: aynı ada sahip kayıtlar arasında önce İÇERİĞİ OLAN
--  (panel/paket) kayıt, sonra en çok kullanılan (fiyat/belge satırı),
--  sonra bileşen olmayan, sonra en kısa kod. Adı katalogda başka hiç
--  geçmeyen bileşen TERFİ eder (silinmez) - o tetkik yalnız panelin
--  içinde tanımlıymış demektir.
--
--  PANEL KAYDI ASLA KOPYA SAYILMAZ: "KREATİNİN ( serum )" (L.B.011) kendi
--  altında e-GFR taşıdığı için panel gibi görünür ama katalogun kendisidir;
--  iki panel aynı adı taşıyorsa (Erkek Check-Up +40 / -40) içerikleri
--  farklıdır, birleştirilmez. Ad anahtarı bu yüzden +/- işaretini korur.
--
--  Kopyalar SİLİNİR (kullanıcı kararı). Silmeden önce:
--    - tüm yabancı anahtar referansları kanonik kayda taşınır (dinamik:
--      pg_constraint'ten okunur, yeni tablo eklenince kendiliğinden kapsanır),
--    - benzersiz indeksli tablolarda (fiyat listesi satırı, hizmet fiyatı,
--      radyoloji protokolü/şablonu) kanonikte KAYIT YOKSA taşınır, VARSA
--      kopyanın satırı düşer - fiyat kaybolmasın diye taşıma önce yapılır.
--    - silinen satırların tamamı `_yedek_hizmet_497`e, eşleme
--      `_esleme_hizmet_497`e yazılır (geri dönüş ve rapor için).
--
--  Tekrar çalıştırılabilir: ikinci koşuda eşleşecek kopya kalmaz.
-- =====================================================================

-- --------------------------------------------------------------- yedek --
create table if not exists public._yedek_hizmet_497 as
    select * from public.hizmet where false;
create table if not exists public._esleme_hizmet_497 (
    kopya_id   integer primary key,
    kanonik_id integer not null,
    tip        text    not null,   -- 'bilesen' | 'tarife'
    panel_id   integer,
    sira       smallint not null default 0,
    tarih      timestamp not null default now()::timestamp
);

do $$
declare
    v_kopya    integer;
    v_terfi    integer;
    v_icerik   integer;
    r          record;
    v_kolon    text;
    v_tablo    text;
begin
    -- ------------------------------------------------- sınıflandırma --
    create temp table _sinif on commit drop as
    with ebeveyn as (
        select distinct substring(kod from '^(.*)\.[0-9]+$') as kod
          from public.hizmet
         where substring(kod from '^(.*)\.[0-9]+$') is not null
    ),
    baslik as (   -- kodunun ALTINDA TORUNU olan kod: katalog başlığı
        select e.kod from ebeveyn e
         where exists (select 1 from ebeveyn e2 where e2.kod like e.kod || '.%')
    ),
    panel as (    -- altında "X.NN" satırları olan, başlık olmayan kayıt
        select p.id, p.kod
          from public.hizmet p
          join ebeveyn e on e.kod = p.kod
         where p.baslik_mi = 0
           and e.kod not in (select kod from baslik)
    )
    select h.id,
           h.kod,
           h.ad,
           h.kategori,
           substring(h.kod from '^(.*)\.[0-9]+$')            as ust_kod,
           -- Ad anahtarı: Türkçe harfler sadeleşmiş, yalnız harf/rakam ve
           --   "+ -" (yaş sınırı: "Check-Up +40" ile "-40" AYRI pakettir).
           regexp_replace(upper(translate(h.ad, 'ıİşŞğĞüÜöÖçÇ', 'IISSGGUUOOCC')),
                          '[^A-Z0-9+-]', '', 'g')            as anahtar,
           case
             when h.baslik_mi = 1 or h.kod in (select kod from baslik) then 'baslik'
             when exists (select 1 from panel p where p.id = h.id) then 'panel'
             when exists (select 1 from panel p
                           where p.kod = substring(h.kod from '^(.*)\.[0-9]+$')) then 'bilesen'
             else 'tetkik'
           end                                               as tip,
           (select p.id from panel p
             where p.kod = substring(h.kod from '^(.*)\.[0-9]+$')) as panel_id,
           (select count(*) from public.fiyat_listesi_satir f where f.hizmet_id = h.id)
         + (select count(*) from public.belge_satir b where b.hizmet_id = h.id)
                                                             as kullanim,
           -- TARİFE DALI: kategorisi kurum/tarife adı taşıyan kayıt ("SSK",
           --   "RES", "RESBT", "RESMR"). Aynı tetkik hem klinik dalda hem
           --   burada varsa KLİNİK olan korunur - tarife farkı fiyat
           --   listesinin işi (498 bu dalları tamamen kaldırır).
           exists (select 1 from public.kategori k
                     left join public.kategori u on u.id = k.ust_id
                    where k.id = h.kategori
                      and (k.ad in ('SSK','RES','RESBT','RESMR')
                        or u.ad in ('SSK','RES')))            as tarife_dali
      from public.hizmet h;

    create index on _sinif (anahtar);
    create index on _sinif (id);

    -- ----------------------------------------------- kanonik seçimi --
    -- Başlık satırları katalogun iskeleti - ne kopya ne kanonik olurlar.
    create temp table _kanonik on commit drop as
    select distinct on (anahtar) anahtar, id as kanonik_id, tip
      from _sinif
     where tip <> 'baslik'
     order by anahtar,
              tarife_dali,              -- klinik dal, tarife kopyasına yeğlenir
              (tip = 'panel') desc,     -- içeriği taşıyan kayıt korunur
              kullanim desc,            -- fiyatı/belgesi olan korunur
              (tip <> 'bilesen') desc,  -- bileşen en son çare
              length(kod), id;

    -- --------------------------------------------------- eşleme yaz --
    insert into public._esleme_hizmet_497 (kopya_id, kanonik_id, tip, panel_id, sira)
    select s.id, k.kanonik_id,
           case when s.tip = 'bilesen' then 'bilesen' else 'tarife' end,
           s.panel_id,
           coalesce(nullif(regexp_replace(s.kod, '^.*\.([0-9]+)$', '\1'), s.kod), '0')::smallint
      from _sinif s
      join _kanonik k using (anahtar)
     where s.tip in ('tetkik', 'bilesen')   -- panel ve başlık kopya olmaz
       and s.id <> k.kanonik_id
    on conflict (kopya_id) do nothing;

    select count(*) into v_kopya from public._esleme_hizmet_497
     where exists (select 1 from public.hizmet h where h.id = kopya_id);

    -- ------------------------------------------ panel içeriği (496) --
    -- Hem kopya bileşenler (kanonik kayda) hem TERFİ EDEN bileşenler
    --   (kendileri kanonik) panelin içeriği olur.
    insert into public.hizmet_paket (paket_hizmet_id, icerik_hizmet_id, sira)
    select s.panel_id,
           coalesce(k.kanonik_id, s.id),
           coalesce(nullif(regexp_replace(s.kod, '^.*\.([0-9]+)$', '\1'), s.kod), '0')::smallint
      from _sinif s
      left join _kanonik k using (anahtar)
     where s.tip = 'bilesen'
       and s.panel_id is not null
       and coalesce(k.kanonik_id, s.id) <> s.panel_id
    on conflict (paket_hizmet_id, icerik_hizmet_id) do nothing;
    get diagnostics v_icerik = row_count;

    select count(*) into v_terfi
      from _sinif s join _kanonik k using (anahtar)
     where s.tip = 'bilesen' and k.kanonik_id = s.id;

    -- ------------------------------------------- referans taşımaları --
    -- BENZERSİZ İNDEKSLİ tablolar önce: kanonikte satır yoksa taşı, varsa
    --   kopyanınki düşer (aynı tetkikin ikinci fiyatı/protokolü).
    update public.fiyat_listesi_satir f
       set hizmet_id = e.kanonik_id
      from public._esleme_hizmet_497 e
     where f.hizmet_id = e.kopya_id
       and not exists (select 1 from public.fiyat_listesi_satir x
                        where x.liste_id = f.liste_id and x.hizmet_id = e.kanonik_id
                          and x.doviz_cinsi = f.doviz_cinsi);
    delete from public.fiyat_listesi_satir f
     using public._esleme_hizmet_497 e where f.hizmet_id = e.kopya_id;

    update public.hizmet_fiyat f
       set hizmet_id = e.kanonik_id
      from public._esleme_hizmet_497 e
     where f.hizmet_id = e.kopya_id
       and not exists (select 1 from public.hizmet_fiyat x
                        where x.hizmet_id = e.kanonik_id and x.fiyat_adi = f.fiyat_adi
                          and x.doviz_cinsi = f.doviz_cinsi);
    delete from public.hizmet_fiyat f
     using public._esleme_hizmet_497 e where f.hizmet_id = e.kopya_id;

    update public.radyoloji_protokol p
       set hizmet_id = e.kanonik_id
      from public._esleme_hizmet_497 e
     where p.hizmet_id = e.kopya_id
       and not exists (select 1 from public.radyoloji_protokol x
                        where x.hizmet_id = e.kanonik_id);
    delete from public.radyoloji_protokol p
     using public._esleme_hizmet_497 e where p.hizmet_id = e.kopya_id;

    update public.radyoloji_sablon s
       set varsayilan = 0
      from public._esleme_hizmet_497 e
     where s.hizmet_id = e.kopya_id and s.varsayilan = 1
       and exists (select 1 from public.radyoloji_sablon x
                    where x.hizmet_id = e.kanonik_id and x.varsayilan = 1);

    -- KALAN TÜM REFERANSLAR dinamik: hizmet(id)'ye bakan her yabancı
    --   anahtar kolonu kanonik kayda çevrilir. Yeni bir tablo eklenirse
    --   burası kendiliğinden kapsar - elle liste bakım borcu olurdu.
    for r in
        select c.conrelid::regclass::text as tablo, a.attname as kolon
          from pg_constraint c
          join lateral unnest(c.conkey) k(att) on true
          join pg_attribute a on a.attrelid = c.conrelid and a.attnum = k.att
         where c.contype = 'f'
           and c.confrelid = 'public.hizmet'::regclass
           and c.conrelid <> 'public.hizmet_paket'::regclass
    loop
        v_tablo := r.tablo; v_kolon := r.kolon;
        execute format(
            'update %s t set %I = e.kanonik_id
               from public._esleme_hizmet_497 e
              where t.%I = e.kopya_id', v_tablo, v_kolon, v_kolon);
    end loop;

    -- --------------------------------------------------- yedek + sil --
    insert into public._yedek_hizmet_497
    select h.* from public.hizmet h
     where h.id in (select kopya_id from public._esleme_hizmet_497)
       and not exists (select 1 from public._yedek_hizmet_497 y where y.id = h.id);

    delete from public.hizmet h
     where h.id in (select kopya_id from public._esleme_hizmet_497);

    raise notice 'Tekilleştirme: % kopya silindi, % bileşen terfi etti, % paket içerik satırı yazıldı.',
                 v_kopya, v_terfi, v_icerik;
end $$;
