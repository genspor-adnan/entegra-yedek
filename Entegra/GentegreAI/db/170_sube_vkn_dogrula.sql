-- ============================================================================
--  Gentegre AI — FIRMA VKN / TCKN DOGRULAMASI
--  170_sube_vkn_dogrula.sql
--
--  Mockup ipucu (Ekranlar/firma_bilgileri.html, Kimlik sekmesi):
--    "VKN 10 hane, gerçek kişide TCKN 11 hane olarak OnValidate ile denetlenir.
--     e-Belge sekmesindeki tüm işlemler bu VKN üzerinden yürür."
--
--  NEDEN TRIGGER: ayni kayit karttan, gocten ve betikten yazilabiliyor; kontrol
--  yalniz arayuzde olsaydi digerlerinden hatali numara girerdi ve hata ancak
--  GIB reddinde ortaya cikardi.
--
--  KONTROL SADECE HANE SAYISI ve rakam olmasi. VKN/TCKN CHECKSUM'i BILEREK YOK:
--  gecerli algoritmayi gecen ama gercekte olmayan numara da kabul edilir - asil
--  dogrulama entegratorun mukellef sorgusudur. Checksum, dogru numaralari yanlis
--  reddetme riski tasir (or. yurt disi kurumlarin ozel numaralari).
--
--  GK422: uygulama bu SQLSTATE'i "is kurali" olarak 422 ile kullaniciya gosterir
--  (VeriHatasi.Cevir). Ciplak `raise exception` 500 olurdu.
-- ============================================================================
\set ON_ERROR_STOP on

create or replace function public.tg_sube_vkn_dogrula()
returns trigger language plpgsql as $$
declare
    v_ham  text := regexp_replace(coalesce(new.vkno, ''), '\D', '', 'g');
    v_asil text := btrim(coalesce(new.vkno, ''));
begin
    if v_asil = '' then
        return new;                       -- bos birakilabilir (zorunluluk kartta)
    end if;

    -- Rakam disi karakter: "1234567890 " gibi kopyala-yapistir artiklari da dahil.
    if v_ham <> v_asil then
        -- Sessizce temizlenir: kullaniciya hata gostermek yerine dogru degeri
        --   yazmak daha faydali - nokta/bosluk yazim aliskanligi.
        new.vkno := v_ham;
    end if;

    if length(v_ham) not in (10, 11) then
        raise exception 'Vergi numarası 10, TC kimlik numarası 11 hane olmalı (girilen: % hane).',
              length(v_ham)
        using errcode = 'GK422';
    end if;

    return new;
end $$;

comment on function public.tg_sube_vkn_dogrula() is
  'Firma/sube VKN-TCKN hane kontrolu; rakam disi karakterleri temizler (170).';

drop trigger if exists tr_sube_vkn_dogrula on public.sube;
create trigger tr_sube_vkn_dogrula
    before insert or update of vkno on public.sube
    for each row execute function public.tg_sube_vkn_dogrula();

do $$
declare v_bozuk integer;
begin
    -- Mevcut kayitlarda hatali numara var mi - tetikleyici gecmise dokunmaz,
    --   kullanici duzeltene kadar o subeden e-Belge gonderilemez.
    select count(*) into v_bozuk
      from public.sube
     where coalesce(btrim(vkno), '') <> ''
       and length(regexp_replace(vkno, '\D', '', 'g')) not in (10, 11);
    if v_bozuk > 0 then
        raise notice '170 UYARI: % subede VKN hane sayisi hatali - Firma Bilgileri''nden duzeltilmeli.', v_bozuk;
    end if;
    raise notice '170 tamam: sube VKN/TCKN hane dogrulamasi.';
end $$;
