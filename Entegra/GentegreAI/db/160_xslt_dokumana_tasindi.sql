-- ============================================================================
--  Gentegre AI — XSLT sablonlari `dokuman`a tasindi, ebelge_xslt kaldirildi
--  160_xslt_dokumana_tasindi.sql
--
--  Kullanici: "dokuman'da belge turu zaten varmis; alan yon (gelen/giden) ekle
--  ve dokuman'i kullan sadece."
--
--  DOGRU KARAR: 159'da acilan `ebelge_xslt` tablosu `dokuman`in yaptigi isi
--  ikinci kez yapiyordu - ad, boyut, hash, varsayilan, audit hepsi orada var;
--  ustelik dosya YUKLEME/INDIRME altyapisi (dokuman_icerik + galeri ekrani)
--  hazirken XSLT icerigi yalniz aktarim betigiyle doldurulabiliyordu.
--
--  ESLEME
--      kaynak      = 'ebelge-xslt'
--      kaynak_id   = belge turu kodu (1 e-Fatura · 2 e-Arsiv · 7 e-Irsaliye · 8 e-SMM)
--      belge_turu  = turun okunur adi ("e-Fatura")
--      yon         = 1 gelen · 2 giden            <-- BU DOSYADA EKLENIYOR
--      ad          = sablon adi
--      icerik      = dokuman_icerik (bytea, hash ile dedup)
--
--  VARSAYILAN KISITI - DIKKAT: mevcut `ux_dokuman_varsayilan` (kaynak, kaynak_id)
--    basina TEK varsayilan diyor; bu, kartin ana gorselini tekil tutan kural.
--    XSLT'de gelen ve giden AYRI varsayilan ister. Indeks (kaynak, kaynak_id,
--    yon) olarak yeniden kuruldu: yon diger kaynaklarda hep 0 kaldigi icin
--    onlarin davranisi DEGISMEZ, XSLT'de ise gelen/giden ayri ayri secilebilir.
-- ============================================================================
\set ON_ERROR_STOP on

-- ------------------------------------------------------------- yon alani ---
alter table public.dokuman
    add column if not exists yon smallint not null default 0;

comment on column public.dokuman.yon is
  'Belge yonu: 0 uygulanmaz (varsayilan) · 1 gelen · 2 giden. e-Belge XSLT sablonlarinda gelen/giden ayrimi icin (160).';

-- Varsayilan kisiti yon ile genisletildi (gerekce yukarida).
drop index if exists public.ux_dokuman_varsayilan;
create unique index ux_dokuman_varsayilan
    on public.dokuman (kaynak, kaynak_id, yon) where varsayilan = 1;

-- ----------------------------------------------------------- durum ---------
-- Dokumanin AKTIFLIGI: pasif sablon/dosya listede durur ama kullanilmaz
--   (or. eski XSLT surumu). Silmek yerine pasife almak, gecmis belgelerin
--   hangi sablonla uretildigi bilgisini korur.
alter table public.dokuman
    add column if not exists durum smallint not null default 1;

comment on column public.dokuman.durum is
  '1 aktif · 0 pasif. Pasif dokuman listede gorunur ama kullanilmaz (160).';

create index if not exists ix_dokuman_durum on public.dokuman (kaynak, kaynak_id, durum);

-- ------------------------------------------------- ebelge_xslt -> dokuman ---
do $$
declare
    r         record;
    v_hash    varchar(64);
    v_veri    bytea;
    v_sube    integer;
    v_tasinan integer := 0;
begin
    if not exists (select 1 from information_schema.tables where table_name = 'ebelge_xslt') then
        raise notice '160: ebelge_xslt yok, tasima atlandi.';
        return;
    end if;

    -- Dokuman satiri sube ister (FK). XSLT firma genelidir; en kucuk sube.
    select min(id) into v_sube from public.sube;

    for r in select * from public.ebelge_xslt order by id loop
        -- Zaten tasinmissa (betik tekrar calisti) atla.
        if exists (select 1 from public.dokuman d
                    where d.kaynak = 'ebelge-xslt' and d.kaynak_id = r.belge_turu
                      and d.yon = r.yon and d.ad = r.ad) then
            continue;
        end if;

        v_veri := convert_to(r.icerik, 'UTF8');
        v_hash := encode(sha256(v_veri), 'hex');

        -- Icerik dedup: ayni hash varsa yalniz referans sayaci artar.
        insert into public.dokuman_icerik (hash, icerik, content_type, boyut, referans_sayisi)
        values (v_hash, v_veri, 'application/xslt+xml', octet_length(v_veri), 1)
        on conflict (hash) do update
           set referans_sayisi = public.dokuman_icerik.referans_sayisi + 1;

        insert into public.dokuman (kaynak, kaynak_id, ad, content_type, boyut, hash,
                                    sira, varsayilan, yon, belge_turu, durum, sube_id,
                                    ekleyen, ekleme_tarihi)
        values ('ebelge-xslt', r.belge_turu, r.ad, 'application/xslt+xml',
                octet_length(v_veri), v_hash, 0,
                case when r.durum = 1 then r.varsayilan else 0 end,   -- pasif sablon varsayilan olamaz
                r.yon,
                case r.belge_turu when 1 then 'e-Fatura' when 2 then 'e-Arşiv'
                                  when 7 then 'e-İrsaliye' when 8 then 'e-SMM' else '' end,
                r.durum,
                v_sube, 0, coalesce(r.ekleme_tarihi, now()::timestamp));
        v_tasinan := v_tasinan + 1;
    end loop;

    raise notice '160: % XSLT sablonu dokumana tasindi.', v_tasinan;
end $$;

-- ------------------------------------------------- gecerli sablonu bul ------
-- Imza korunuyor; artik dokuman uzerinden okuyor.
create or replace function public.fn_ebelge_xslt_bul(p_belge_turu integer, p_yon integer)
returns integer
language sql stable as $$
    select d.id
      from public.dokuman d
     where d.kaynak = 'ebelge-xslt'
       and d.kaynak_id = p_belge_turu
       and d.yon = coalesce(p_yon, 2)
       and d.durum = 1
     order by d.varsayilan desc, d.id
     limit 1
$$;

comment on function public.fn_ebelge_xslt_bul(integer, integer) is
  'Belge turu + yon icin kullanilacak XSLT dokumaninin kimligi; varsayilan yoksa ilk satir (160).';

-- --------------------------------------------------------- eski tablo -------
-- Veri tasindi; ikinci bir dogruluk kaynagi birakilmiyor.
drop table if exists public.ebelge_xslt;

do $$
declare v_dokuman integer; v_boy bigint;
begin
    select count(*), coalesce(sum(boyut), 0) into v_dokuman, v_boy
      from public.dokuman where kaynak = 'ebelge-xslt';
    raise notice '160 tamam: % XSLT dokumani (% bayt), ebelge_xslt tablosu kaldirildi.',
                 v_dokuman, v_boy;
end $$;
