-- ============================================================================
--  Gentegre AI — e-BELGE HAZIRLAMA
--  163_ebelge_hazirla.sql
--
--  Kullanici: "fatura listesinde aksiyona e-Fatura Hazirla ekle, Delphi
--  kodundan yararlanarak yaz."
--
--  KAYNAK: Delphi `TEBelgeOlusturucu.MenuHazirla` (UEBelgeOlusturucu.pas:3892).
--  Oradaki akis, bizde karsiligi olan adimlarla:
--
--    1. Belge okunur; e-Belge zaten olusturulmussa DURUR ("EFATURADURUM > 0").
--    2. Yalniz e-Fatura / e-Irsaliye turleri hazirlanabilir.
--    3. DOGRULAMALAR EN BASTA - numara ve seri TUKETILMEDEN once. Delphi'deki
--       gerekce aynen gecerli: dogrulama patlarsa fatura numarasi bosa gider.
--    4. ALICI MUKELLEF MI: Delphi burada entegratorun alias servisine soruyor.
--       Bizde o servis YOK; karar cari kartindaki `efatura` bayragina gore:
--       mukellef ise e-Fatura, degilse e-ARSIV. (Ihracatta - senaryo 3 - Delphi
--       de alias sormuyor, belge her zaman e-Fatura.)
--    5. SERI: 156'daki kural tablosundan (`fn_ebelge_seri_bul`).
--    6. NUMARA: Delphi `BelgeNoUret` ile ayni bicim -> SERI + YIL + 9 hane
--       ("GEN2026000000001"). Sayac seri+yil basina, bosluksuz.
--    7. `e_belge` satiri acilir, `belge.efatura_durum` Delphi kodlariyla ayni
--       degere set edilir: 1 e-Fatura · 11 e-Arsiv · 51 e-Irsaliye.
--
--  BU ADIMDA UBL/XML URETILMEZ. Delphi'de `Olustur` cagrisi UBL'i de kurar;
--  o is (sablon + tevkifat/istisna/ihracat alanlari + entegrator API) ayri ve
--  buyuk. Burada belge KUYRUGA alinir: numara, seri, alici ve belge turu
--  kesinlesir; gonderim asamasi XML'i sonra uretir.
-- ============================================================================
\set ON_ERROR_STOP on

-- e-Belge numarasi: SERI + YIL + 9 hane (Delphi BelgeNoUret ile ayni).
create or replace function public.fn_ebelge_no_uret(p_seri text, p_yil integer)
returns text
language plpgsql as $$
declare
    v_anahtar text := 'e_belge.belge_no|S' || upper(btrim(p_seri)) || '|Y' || p_yil::text;
    v_sira    text;
begin
    -- Sayac ortak uretecte (152): satir kilidi altinda, bosluksuz.
    v_sira := public.fn_numara_sirada(v_anahtar, 'e_belge', 'belge_no',
                                      'seri ' || upper(btrim(p_seri)) || ' / ' || p_yil::text,
                                      9, 1);
    return upper(btrim(p_seri)) || p_yil::text || v_sira;
end $$;

comment on function public.fn_ebelge_no_uret(text, integer) is
  'e-Belge numarasi: SERI + YIL + 9 hane (Delphi BelgeNoUret esdegeri, 163).';

-- ---------------------------------------------------------------- hazirla --
-- Tek islemde: dogrula -> belge turunu belirle -> seri sec -> numara ver ->
--   e_belge satirini ac -> belgenin durumunu isaretle.
-- Cikis kolonlari degistigi icin once dusurulur: PostgreSQL `create or
--   replace` ile donus tipini degistirmez.
drop function if exists public.fn_ebelge_hazirla(integer, integer);

create function public.fn_ebelge_hazirla(p_belge_id integer, p_kullanici integer)
returns table (e_belge_id bigint, belge_turu smallint, belge_no varchar, seri varchar, uyari text)
language plpgsql as $$
declare
    b            record;
    v_mukellef   boolean;
    v_tur        smallint;
    v_seri       varchar;
    v_no         varchar;
    v_durum      smallint;
    v_uyari      text := '';
    v_id         bigint;
begin
    select bl.*, t.efatura as taraf_efatura, t.vkno as taraf_vkno, t.unvan as taraf_ad
      into b
      from public.belge bl
      left join public.taraf t on t.id = bl.taraf_id
     where bl.id = p_belge_id;

    if not found then
        raise exception 'Belge bulunamadı (%).', p_belge_id;
    end if;

    -- 1) Zaten hazirlanmis mi (Delphi: "eBelge zaten olusturulmus").
    if coalesce(b.efatura_durum, 0) <> 0 then
        raise exception 'Bu belge için e-Belge zaten hazırlanmış (durum %).', b.efatura_durum;
    end if;

    -- 2) Tur kontrolu: yalniz GIDEN fatura ve irsaliye.
    if b.tur not in (15, 14) then
        raise exception 'e-Belge yalnızca satış faturası ve satış irsaliyesi için hazırlanır.';
    end if;

    -- 3) ANA SALTER firma geneli; tur bayragi artik SUBENIN MUKELLEFIYETI (172).
    --    Eski `eirsaliye.aktif` ayari kaldirildi: "aktif" ile "mukellefiyet"
    --    ayni seydi ve iki yerde durunca tutarsizlasabiliyordu.
    if coalesce((select deger from public.referans where anahtar = 'ebelge.aktif'), '0') <> '1' then
        raise exception 'e-Belge kullanımda değil. Ayarlar › Satış Belgeleri › e-Belge''den açın.';
    end if;
    if b.tur = 14 and not public.fn_ebelge_mukellef_mi(b.sube_id, 7) then
        raise exception 'Bu şube e-İrsaliye mükellefi değil. Yönetim › Firma Bilgileri › e-Belge''den işaretleyin.';
    end if;

    -- 4) DOGRULAMALAR - numara/seri TUKETILMEDEN (Delphi ile ayni gerekce).
    if coalesce(b.taraf_id, 0) = 0 then
        raise exception 'Belgede cari seçilmemiş.';
    end if;
    if coalesce(btrim(b.taraf_vkno), '') = '' then
        raise exception '% için vergi/kimlik numarası girilmemiş; e-Belge gönderilemez.', b.taraf_ad;
    end if;
    if not exists (select 1 from public.belge_satir s where s.belge_id = b.id) then
        raise exception 'Belgede kalem yok.';
    end if;
    if coalesce(b.genel_toplam, 0) <= 0 then
        raise exception 'Belge tutarı sıfır; e-Belge hazırlanamaz.';
    end if;
    -- e-Irsaliyede sevk bilgisi zorunlu (Delphi: SevkBilgisiDogrula).
    if b.tur = 14 and coalesce(btrim(b.arac_plaka), '') = ''
       and coalesce(b.tasiyici_id, 0) = 0 then
        raise exception 'e-İrsaliyede taşıyıcı ya da araç plakası girilmeli (Taşıyıcı / Sevkiyat sekmesi).';
    end if;

    -- 5) BELGE TURU: alici GIB mukellefi mi? Delphi entegratore sorar; bizde
    --    cari kartindaki bayrak. Ihracatta (senaryo 3) alias sorulmaz - her
    --    zaman e-Fatura.
    v_mukellef := coalesce(b.taraf_efatura, 0) = 1;
    if b.tur = 14 then
        v_tur := 7;                                  -- e-Irsaliye
        v_durum := 51;
    elsif coalesce(b.senaryo, 0) = 3 or v_mukellef then
        v_tur := 1;                                  -- e-Fatura
        v_durum := 1;
        if coalesce(b.senaryo, 0) = 3 and not v_mukellef then
            v_uyari := 'İhracat faturası: alıcı GİB mükellefi değil, belge e-Fatura olarak hazırlandı.';
        end if;
    else
        v_tur := 2;                                  -- e-Arsiv
        v_durum := 11;
        v_uyari := 'Alıcı e-Fatura mükellefi değil; belge e-Arşiv olarak hazırlandı.';
    end if;

    -- Secilen turde mukellef degilsek belge entegratorden geri doner; numara
    --   harcanmadan burada durur (172).
    if not public.fn_ebelge_mukellef_mi(b.sube_id, v_tur) then
        raise exception 'Bu şube % mükellefi değil. Yönetim › Firma Bilgileri › e-Belge''den işaretleyin.',
              public.fn_ebelge_tur_adi(v_tur);
    end if;

    -- 6) SERI (156 kurallari) - yoksa hazirlama durur, numara harcanmaz.
    v_seri := public.fn_ebelge_seri_bul(v_tur, coalesce(b.senaryo, 0), p_kullanici);
    if coalesce(btrim(v_seri), '') = '' then
        raise exception 'Bu belge türü için seri tanımı yok. Ayarlar › Satış Belgeleri › e-Belge › Seri Bilgileri''nden ekleyin.';
    end if;

    -- 7) NUMARA (Delphi BelgeNoUret bicimi).
    v_no := public.fn_ebelge_no_uret(v_seri, extract(year from b.belge_tarihi)::integer);

    -- 8) e_belge satiri + belgenin durumu.
    insert into public.e_belge (belge_id, taraf_id, belge_turu, yon, belge_no,
                                alici_alias, durum, ekleyen)
    values (b.id, b.taraf_id, v_tur, 1, v_no, '', 1, p_kullanici)
    returning id into v_id;

    -- ALIAS ZORUNLU: ciplak `belge_no` PL/pgSQL'de fonksiyonun cikis kolonuyla
    --   karisiyor ("ambiguous"); tablo kolonu her zaman alias'la yazilir.
    update public.belge bl
       set efatura_durum = v_durum,
           efatura_sonuc = 0,
           -- Belgenin kendi numarasi bos ya da "0" ise (e-Belge bekleyen belge,
           --   160) e-Belge numarasi belgeye de yazilir - liste ve ekstrede
           --   ayni numara gorunsun.
           belge_no = case when coalesce(btrim(bl.belge_no), '') in ('', '0')
                           then v_no else bl.belge_no end,
           degistiren = p_kullanici,
           degistirme_tarihi = now()::timestamp
     where bl.id = b.id;

    return query select v_id, v_tur, v_no::varchar, v_seri::varchar, v_uyari;
end $$;

comment on function public.fn_ebelge_hazirla(integer, integer) is
  'Belgeyi e-Belge kuyruguna alir: dogrular, belge turunu (e-Fatura/e-Arsiv/e-Irsaliye) belirler, seri ve numara verir, e_belge satirini acar (163). UBL uretimi gonderim asamasinda.';

do $$
begin
    raise notice '163 tamam: fn_ebelge_hazirla + fn_ebelge_no_uret hazir.';
end $$;
