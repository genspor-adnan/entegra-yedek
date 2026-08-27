-- ============================================================================
--  Gentegre AI — BELGE SILME
--  181_belge_sil.sql
--
--  Kullanici: "belge listelerine belgeyi ac saginda sil butonu ekle."
--
--  SILME ILE IPTAL FARKI:
--    SIL  : belge hic olmamis gibi kaldirilir. Yalniz IZI OLMAYAN belgede
--           mumkun - e-Belge hazirlanmamis, kasa tahsilati baglanmamis,
--           baska belgeye donusturulmemis olmali.
--    IPTAL: belge KALIR, durumu 2 olur; hareketleri ters kayitla geri alinir.
--           Kesin ve izli belgenin tek dogru yolu budur (muhasebe/GIB izi).
--
--  Bu fonksiyon SILME on-kosullarini tek yerde toplar: hem uc hem arayuz ayni
--  cevabi alsin, kural iki yerde ayrisip "buton aktif ama sunucu reddediyor"
--  durumu olusmasin.
-- ============================================================================
\set ON_ERROR_STOP on

create or replace function public.fn_belge_silinebilir(p_belge_id integer)
returns text
language plpgsql stable as $$
declare
    b       record;
    v_adet  integer;
begin
    select bl.durum, bl.efatura_durum, bl.belge_no, bl.kapanma_durum
      into b from public.belge bl where bl.id = p_belge_id;
    if not found then
        return 'Belge bulunamadı.';
    end if;

    -- e-BELGE: hazirlanmis belgenin numarasi seri sayacindan alinmistir;
    --   silinirse numara bosa duser ve GIB'e giden/gidecek belge izi kaybolur.
    if coalesce(b.efatura_durum, 0) in (2, 12, 52) then
        return 'e-Belge gönderilmiş; belge silinemez. Düzeltme için iade faturası kesin.';
    end if;
    if coalesce(b.efatura_durum, 0) <> 0 then
        return 'e-Belge hazırlanmış; önce "Hazırı Geri Al" ile e-Belge kaydını kaldırın.';
    end if;

    -- IPTAL EDILMIS belge muhasebe izidir, silinmez.
    if coalesce(b.durum, 0) = 2 then
        return 'İptal edilmiş belge silinemez; iptal kaydı belgenin izidir.';
    end if;

    -- DONUSUM: bu belgeden uretilmis irsaliye/fatura varsa silme zinciri kirar.
    select count(*) into v_adet
      from public.belge_satir hs
      join public.belge_satir ks on ks.id = hs.kaynak_id and hs.kaynak_tur = 30
      join public.belge hb on hb.id = hs.belge_id and hb.durum <> 2
     where ks.belge_id = p_belge_id;
    if v_adet > 0 then
        return 'Bu belgeden dönüştürülmüş belge var; önce onu kaldırın.';
    end if;

    -- KASA: tahsilat/odeme baglanmissa silme cari bakiyeyi bozar.
    select count(*) into v_adet from public.kasa_islem ki where ki.belge_id = p_belge_id;
    if v_adet > 0 then
        return 'Belgeye bağlı kasa işlemi var; önce tahsilatı/ödemeyi kaldırın.';
    end if;

    return '';                                   -- bos = silinebilir
end $$;

comment on function public.fn_belge_silinebilir(integer) is
  'Belge silinebilir mi; bos metin = evet, dolu metin = kullaniciya gosterilecek sebep (181).';

-- --------------------------------------------------------------- silme -----
-- Satirlar, sevkiyat ve stok izleme CASCADE ile gider; mali hareket ve
--   e_belge kaydi ELLE temizlenir (FK'leri NO ACTION / SET NULL).
create or replace function public.fn_belge_sil(p_belge_id integer, p_kullanici integer)
returns text
language plpgsql as $$
declare
    v_sebep  text;
    v_no     text;
    v_satir  integer;
begin
    v_sebep := public.fn_belge_silinebilir(p_belge_id);
    if v_sebep <> '' then
        raise exception '%', v_sebep;
    end if;

    select coalesce(nullif(btrim(belge_no), ''), '#' || p_belge_id::text)
      into v_no from public.belge where id = p_belge_id;

    -- Stok bakiyesi: satirlarin dustugu/yukseldigi miktar geri alinir. Taslak
    --   belgede stok_durum_degis 0'dir, dolayisiyla dongu bos doner.
    perform public.fn_stok_durum_geri_al(p_belge_id)
      where exists (select 1 from pg_proc p join pg_namespace n on n.oid = p.pronamespace
                     where n.nspname = 'public' and p.proname = 'fn_stok_durum_geri_al');

    delete from public.mali_hareket where belge_id = p_belge_id;
    get diagnostics v_satir = row_count;

    delete from public.e_belge where belge_id = p_belge_id;
    delete from public.belge where id = p_belge_id;

    return format('"%s" silindi (%s cari hareketi kaldırıldı).', v_no, v_satir);
end $$;

comment on function public.fn_belge_sil(integer, integer) is
  'Belgeyi ve izlerini siler; on-kosul saglanmazsa hata (181). Kesin/izli belgede IPTAL kullanilir.';

do $$
begin
    raise notice '181 tamam: fn_belge_silinebilir + fn_belge_sil.';
end $$;
