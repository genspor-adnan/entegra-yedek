-- ============================================================================
--  Gentegre AI — GELEN BELGE GECMISI
--  189_gelen_mesajlar.sql
--
--  Giden belgede "Mesaj Geçmişi" vardi (178); gelen kutusunda yoktu. Kullanici
--  gelen faturada da ayni combo'yu istiyor: On Izle · PDF/HTML/XML · Mesaj
--  Gecmisi. Gecmis, kutu kaydinin kendi alanlarindan turetilir - ayri bir
--  olay tablosu tutmak icin ortada olay yok: kutudan okuma, icerik indirme ve
--  yanit, hepsi kaydin uzerinde tarihli izler birakiyor.
-- ============================================================================
\set ON_ERROR_STOP on

create or replace function public.fn_gelen_mesajlar(p_e_belge_id bigint)
returns table (sira integer, tarih timestamp, olay text, durum text,
               kod text, aciklama text)
language sql stable as $$
    select row_number() over (order by x.tarih, x.oncelik)::integer,
           x.tarih, x.olay, x.durum, x.kod, x.aciklama
      from (
        -- 1) Kutudan okundu (kaydin olusma ani).
        select e.ekleme_tarihi as tarih, 1 as oncelik,
               'Kutuya düştü'::text as olay,
               public.fn_ebelge_tur_adi(e.belge_turu)::text as durum,
               e.belge_no::text as kod,
               ('Gönderen ' || coalesce(nullif(e.gonderici_unvan, ''), e.gonderici_vkno) ||
                ' · ETTN ' || coalesce(nullif(e.uuid, ''), '-'))::text as aciklama
          from public.e_belge e where e.id = p_e_belge_id
        union all
        -- 2) GIB zarf durumu (entegratorden gelen).
        select e.ekleme_tarihi, 2,
               'GİB zarfı'::text,
               coalesce(nullif(e.gib_durum_aciklama, ''), '-')::text,
               coalesce(nullif(e.gib_zarf_kodu, ''), nullif(e.gib_durum_kodu, ''), '-')::text,
               ('Zarf ' || coalesce(nullif(e.zarf_id, ''), '-'))::text
          from public.e_belge e
         where e.id = p_e_belge_id
           and (coalesce(e.gib_zarf_kodu, '') <> '' or coalesce(e.gib_durum_kodu, '') <> '')
        union all
        -- 3) Icerik indirildi (UBL kayda yazildiysa).
        select coalesce(e.degistirme_tarihi, e.ekleme_tarihi), 3,
               'İçerik indirildi'::text, 'UBL'::text,
               (length(e.ubl_xml) || ' karakter')::text,
               'Belge içeriği kayda alındı; görüntüleme ağa çıkmadan yapılır.'::text
          from public.e_belge e
         where e.id = p_e_belge_id and coalesce(e.ubl_xml, '') <> ''
        union all
        -- 4) Yanit (kabul / red).
        select coalesce(e.degistirme_tarihi, e.ekleme_tarihi), 4,
               'Yanıt'::text,
               public.fn_gelen_durum_adi(e.durum)::text,
               coalesce(nullif(e.yanit_durum_kodu, ''), '-')::text,
               coalesce(nullif(e.yanit_aciklama, ''), '')::text
          from public.e_belge e
         where e.id = p_e_belge_id and e.durum in (101, 102)
        union all
        -- 5) Alis faturasina aktarildi.
        select coalesce(b.ekleme_tarihi, e.ekleme_tarihi), 5,
               'Faturaya aktarıldı'::text, 'Alış Faturası'::text,
               coalesce(nullif(b.belge_no, ''), b.id::text)::text,
               ('Belge #' || b.id || ' · ' || b.genel_toplam || ' ' ||
                coalesce(nullif(b.belge_dovizi, ''), 'TL'))::text
          from public.e_belge e
          join public.belge b on b.id = e.belge_id
         where e.id = p_e_belge_id
      ) x
$$;

comment on function public.fn_gelen_mesajlar(bigint) is
  'Gelen belgenin gecmisi: kutuya dusme, GIB zarfi, icerik indirme, yanit, faturaya aktarim (189).';

do $$
begin
    raise notice '189 tamam: fn_gelen_mesajlar.';
end $$;
