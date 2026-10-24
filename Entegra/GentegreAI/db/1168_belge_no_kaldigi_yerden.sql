-- ---------------------------------------------------------------------------
--  BELGE NUMARASI KALDIĞI YERDEN, KENDİ HANE SAYISIYLA DEVAM EDER.
--
--  Kullanıcı 24.10.2026 (UNIVERSE, Delphi'den aktarım sonrası): "bütün belgeler
--  kaldıkları numaradan ve hane sayısı kadar devam edecek". Sayaç (belge_no_sayac)
--  ilk kez kurulurken 0'dan başlıyordu: aktarılan satış irsaliyelerinin son
--  numarası 000156 iken yeni irsaliye 000001 alırdı (mükerrer numara); şablonsuz
--  türler (giriş / çıkış fişi, transfer) eski 6 haneli numaraların yerine 9 hane
--  basıyordu.
--
--  Yeni kural (yalnız fn_belge_no_uret):
--   * Sayaç ilk kez kurulurken o kapsamdaki (tür + şube [+ yıl] + şablon ön eki;
--     şablonsuzda seri) en büyük sayısal numara bulunur; sayaç oradan başlar.
--     Şablonun başlangıç numarası daha büyükse o geçerli (kullanıcı bilerek ileri
--     atlatmış olabilir).
--   * ŞABLONSUZ türde hane = kapsamdaki son numaranın hane sayısı (yoksa çağıranın
--     verdiği). Şablonlu türde hane şablondan gelir - ayar ekranında ne yazıyorsa.
--   * Sayaç zaten varsa hiçbir şey değişmez: kurulu ve çalışan diziler bozulmaz.
--
--  Yalnız fonksiyon tanımı değişir; tablo / veri dokunulmaz. Tekrar çalıştırılabilir.
-- ---------------------------------------------------------------------------
create or replace function public.fn_belge_no_uret(p_tur integer, p_seri text,
                                                   p_sube_id integer,
                                                   p_hane integer default 9,
                                                   p_tarih date default null::date)
returns text
language plpgsql
as $function$
declare
    v_sablon  public.numara_sablonu;
    v_anahtar text;
    v_kapsam  text;
    v_tarih   date := coalesce(p_tarih, current_date);
    v_yil     text := '';
    v_onek    text := '';
    v_hane    integer := p_hane;
    v_bas     bigint := 1;
    v_son     bigint;
    v_son_hane integer;
begin
    v_sablon := public.fn_numara_sablonu_bul(p_tur, p_sube_id, v_tarih);

    if v_sablon.id is not null then
        -- Sablonlu: sayac SABLONA baglidir - on ek/baslangic degisince yeni sayac.
        --   366: on ekte YYYY/YY varsa sayac YILA da baglidir (yil donunce 1'den).
        v_yil := case when public.fn_numara_onek_yilli(v_sablon.on_ek)
                      then '|Y' || to_char(v_tarih, 'YYYY') else '' end;
        v_anahtar := 'belge.belge_no|T' || p_tur::text ||
                     '|SUBE' || coalesce(p_sube_id, 0)::text ||
                     '|N' || v_sablon.id::text || v_yil;
        v_kapsam  := 'sablon ' || v_sablon.id::text || ' / tur ' || p_tur::text ||
                     ' / sube ' || coalesce(p_sube_id, 0)::text ||
                     case when v_yil = '' then '' else ' / yil ' || to_char(v_tarih, 'YYYY') end;
        v_onek := coalesce(public.fn_numara_onek_coz(v_sablon.on_ek, v_tarih), '');
        v_hane := v_sablon.hane;
        v_bas  := v_sablon.baslangic;
    else
        -- Sablonsuz: 025/087'deki eski davranis (seri bazli kapsam, on ek yok).
        v_anahtar := public.fn_belge_no_anahtar(p_tur, p_seri, p_sube_id);
        v_kapsam  := 'T' || p_tur::text || '|S' || coalesce(nullif(btrim(p_seri), ''), '-') ||
                     '|SUBE' || coalesce(p_sube_id, 0)::text;
    end if;

    -- KAPSAMDAKI SON NUMARA (1168): sayac ilk kez kuruluyorsa baslangic icin, sablonsuzda
    --   her seferinde hane icin. Kayit kendi satirini gormez (belge_no henuz bos).
    if v_sablon.id is null
       or not exists (select 1 from public.belge_no_sayac where anahtar = v_anahtar) then
        select max(substr(b.belge_no, length(v_onek) + 1)::bigint),
               (array_agg(length(b.belge_no) - length(v_onek) order by b.id desc))[1]
          into v_son, v_son_hane
          from public.belge b
         where b.tur = p_tur
           and coalesce(b.sube_id, 0) = coalesce(p_sube_id, 0)
           and left(b.belge_no, length(v_onek)) = v_onek
           and substr(b.belge_no, length(v_onek) + 1) ~ '^[0-9]{1,18}$'
           and (v_sablon.id is not null
                or coalesce(nullif(btrim(b.belge_seri), ''), '-') = coalesce(nullif(btrim(p_seri), ''), '-'))
           and (v_yil = '' or extract(year from b.belge_tarihi) = extract(year from v_tarih));

        if v_son is not null then v_bas := greatest(coalesce(v_bas, 1), v_son + 1); end if;
        if v_sablon.id is null and v_son_hane is not null then v_hane := v_son_hane; end if;
    end if;

    return v_onek || public.fn_numara_sirada(v_anahtar, 'belge', 'belge_no', v_kapsam, v_hane, v_bas);
end $function$;
