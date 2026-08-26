-- ============================================================================
--  Gentegre AI — e-BELGE menusunun diger adimlari: SIFIRLA ve SERI DEGISTIR
--  164_ebelge_sifirla_seri.sql
--
--  Kullanici: "menu diger adimlari da yap."
--
--  KAYNAK: Delphi `TEBelgeOlusturucu.MenuSifirla` (4123) ve `MenuSeriDegistir`
--  (4175). Menudeki oteki adimlar (Onizle, HTML/XML/PDF Kaydet, Gonder) UBL
--  XML'i ya da entegrator baglantisi istiyor - ikisi de henuz yok; bu dosyada
--  YALNIZ veriyle yapilabilenler var.
--
--  ORTAK KURAL - GONDERILMIS BELGEYE DOKUNULMAZ (Delphi `GonderilmisEngeli`):
--    durum 2 / 12 / 52 = gonderilmis. Numarasi GIB'e gitmistir; geri alinamaz,
--    serisi degistirilemez.
--
--  SIFIRLA: e_belge kaydini siler, belgeyi hazirlanmamis hale dondurur ve
--    belge numarasini "0" yapar (Delphi FATURANO='0'). Numara SAYACI GERI
--    ALINMAZ - o numara bosa duser; bosluksuzluk e-Belge tarafinda seri
--    numarasi icin gecerli, bizim ic sayacimizda degil.
--
--  SERI DEGISTIR: belgeyi ayni tur icin BASKA bir seriye tasir ve yeni numara
--    uretir. Hazirlanmamis belgede Delphi hazirlama akisina donuyor; burada da
--    oyle - once "e-Fatura Hazırla" kullanilir.
-- ============================================================================
\set ON_ERROR_STOP on

-- --------------------------------------------------------------- sifirla ---
create or replace function public.fn_ebelge_sifirla(p_belge_id integer, p_kullanici integer)
returns text
language plpgsql as $$
declare
    v_durum   smallint;
    v_silinen integer;
begin
    select efatura_durum into v_durum from public.belge where id = p_belge_id;
    if not found then
        raise exception 'Belge bulunamadı (%).', p_belge_id;
    end if;

    -- Gonderilmis belge geri alinamaz (Delphi: "Gonderilmis eBelge geri alinamaz!").
    if v_durum in (2, 12, 52) then
        raise exception 'Gönderilmiş e-Belge geri alınamaz.';
    end if;
    if coalesce(v_durum, 0) = 0 then
        raise exception 'Bu belge için e-Belge hazırlanmamış.';
    end if;
    if v_durum not in (1, 11, 51) then
        raise exception 'Bilinmeyen e-Belge durumu: %.', v_durum;
    end if;

    delete from public.e_belge where belge_id = p_belge_id;
    get diagnostics v_silinen = row_count;

    -- Belge numarasi "0"a doner: e-Belge bekleyen belge demektir (160 kurali).
    update public.belge
       set efatura_durum = 0, efatura_sonuc = 0, belge_no = '0',
           degistiren = p_kullanici, degistirme_tarihi = now()::timestamp
     where id = p_belge_id;

    return format('e-Belge geri alındı (%s kayıt silindi). Belge yeniden hazırlanabilir.',
                  v_silinen);
end $$;

comment on function public.fn_ebelge_sifirla(integer, integer) is
  'Hazirlanmis e-Belgeyi geri alir: e_belge satirini siler, belgeyi hazirlanmamis hale dondurur (164). Gonderilmis belgede calismaz.';

-- --------------------------------------------------- kullanilabilir seriler -
-- Ekranin "hangi serilere gecebilirim" sorusu. Kural secimiyle ayni sira:
--   once kullaniciya ozel, sonra senaryoya ozel, sonra genel.
create or replace function public.fn_ebelge_seri_listesi(
        p_belge_turu integer, p_senaryo integer, p_kullanici_id integer)
returns table (seri varchar, senaryo smallint, sira smallint)
language sql stable as $$
    select s.seri, s.senaryo, s.sira
      from public.ebelge_seri s
     where s.belge_turu = p_belge_turu
       and s.durum = 1
       and s.kullanici_id in (coalesce(p_kullanici_id, 0), 0)
       and s.senaryo in (coalesce(p_senaryo, 0), 0)
     order by (s.kullanici_id = coalesce(p_kullanici_id, 0)) desc,
              (s.senaryo = coalesce(p_senaryo, 0)) desc,
              s.sira, s.id
$$;

comment on function public.fn_ebelge_seri_listesi(integer, integer, integer) is
  'Belge turu/senaryo/kullanici icin secilebilecek seriler, oncelik sirasiyla (164).';

-- ---------------------------------------------------------- seri degistir ---
-- p_seri bos ise SIRADAKI seri secilir (Delphi'de "taslak seri degistir"
--   davranisi: birden fazla seri varsa ikincisine gecer).
create or replace function public.fn_ebelge_seri_degistir(
        p_belge_id integer, p_kullanici integer, p_seri text default null)
returns table (yeni_no varchar, yeni_seri varchar)
language plpgsql as $$
declare
    b          record;
    v_tur      smallint;
    v_mevcut   varchar;
    v_seri     varchar;
    v_no       varchar;
    v_seriler  varchar[];
begin
    select bl.efatura_durum, bl.senaryo, bl.belge_tarihi, bl.belge_no, bl.tur
      into b
      from public.belge bl where bl.id = p_belge_id;
    if not found then
        raise exception 'Belge bulunamadı (%).', p_belge_id;
    end if;

    if b.efatura_durum in (2, 12, 52) then
        raise exception 'Gönderilmiş belgenin serisi değiştirilemez.';
    end if;
    if coalesce(b.efatura_durum, 0) = 0 then
        raise exception 'Önce "e-Fatura Hazırla" ile belge hazırlanmalı.';
    end if;

    -- Hazirlamada verilen durum belge turunu soyluyor (Delphi ile ayni esleme).
    v_tur := case b.efatura_durum when 11 then 2 when 51 then 7 else 1 end;

    -- MEVCUT SERI e_belge'den okunur, belgeden DEGIL: belgenin kendi numarasi
    --   doluysa hazirlama onu degistirmiyor (160), dolayisiyla orada eski i-
    --   numara duruyor ve ilk 3 karakter "000" gibi cikip seri bulunamiyordu.
    select upper(left(coalesce(btrim(e.belge_no), ''), 3)) into v_mevcut
      from public.e_belge e where e.belge_id = p_belge_id
     order by e.id desc limit 1;
    v_mevcut := coalesce(v_mevcut, '');

    if coalesce(btrim(p_seri), '') <> '' then
        v_seri := upper(btrim(p_seri));
        -- Elle verilen seri de kural listesinde olmali - rastgele seri GIB'de
        --   tanimsizdir, belge reddedilir.
        if not exists (select 1 from public.fn_ebelge_seri_listesi(v_tur, coalesce(b.senaryo, 0), p_kullanici) l
                        where l.seri = v_seri) then
            raise exception '"%" bu belge türü için tanımlı bir seri değil.', v_seri;
        end if;
    else
        select array_agg(l.seri order by l.sira, l.seri)
          into v_seriler
          from public.fn_ebelge_seri_listesi(v_tur, coalesce(b.senaryo, 0), p_kullanici) l;

        if v_seriler is null or array_length(v_seriler, 1) < 2 then
            raise exception 'Geçilebilecek başka seri yok; Seri Bilgileri''nden ikinci bir seri tanımlayın.';
        end if;
        -- Mevcut serinin BIR SONRAKISI; sondaysa basa doner.
        select coalesce(
                 (select v_seriler[i + 1] from generate_subscripts(v_seriler, 1) i
                   where v_seriler[i] = v_mevcut and i < array_length(v_seriler, 1)),
                 case when v_seriler[1] = v_mevcut then v_seriler[2] else v_seriler[1] end)
          into v_seri;
    end if;

    if v_seri = v_mevcut then
        raise exception 'Belge zaten "%" serisinde.', v_seri;
    end if;

    v_no := public.fn_ebelge_no_uret(v_seri, extract(year from b.belge_tarihi)::integer);

    update public.e_belge
       set belge_no = v_no, degistiren = p_kullanici, degistirme_tarihi = now()::timestamp
     where belge_id = p_belge_id;

    update public.belge bl
       set belge_no = v_no, degistiren = p_kullanici, degistirme_tarihi = now()::timestamp
     where bl.id = p_belge_id;

    return query select v_no::varchar, v_seri::varchar;
end $$;

comment on function public.fn_ebelge_seri_degistir(integer, integer, text) is
  'Hazirlanmis e-Belgeyi baska seriye tasir ve yeni numara uretir (164). Seri verilmezse siradaki kurala gecer.';

do $$
begin
    raise notice '164 tamam: fn_ebelge_sifirla, fn_ebelge_seri_listesi, fn_ebelge_seri_degistir.';
end $$;
