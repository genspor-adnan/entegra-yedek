-- ============================================================================
--  Gentegre AI — TOPLU e-BELGE HAZIRLAMA
--  183_ebelge_toplu.sql
--
--  Kullanici: "toplu islem yap."
--
--  NEDEN FONKSIYON: hazirlama numara sayacini kilitler; N belgeyi N ayri
--  istekle hazirlamak hem N tur ag gidis-gelisi hem de sayac uzerinde N ayri
--  kilit demekti. Burada tek cagri, tek islem.
--
--  HATA TEK BELGEYI DUSURUR, TOPLU ISI DEGIL: bir belgenin carisinde VKN yoksa
--  yalniz o satir "hata" doner, digerleri hazirlanir. Tek transaction olsaydi
--  tek hatali belge yuzunden 49 dogru belge de geri alinirdi.
-- ============================================================================
\set ON_ERROR_STOP on

create or replace function public.fn_ebelge_toplu_hazirla(
        p_belge_idler integer[], p_kullanici integer)
returns table (belge_id integer, basarili boolean, belge_no text, mesaj text)
language plpgsql as $$
declare
    v_id  integer;
    r     record;
begin
    foreach v_id in array coalesce(p_belge_idler, '{}')
    loop
        begin
            select * into r from public.fn_ebelge_hazirla(v_id, p_kullanici);
            belge_id  := v_id;
            basarili  := true;
            belge_no  := r.belge_no;
            mesaj     := coalesce(nullif(r.uyari, ''),
                                  public.fn_ebelge_tur_adi(r.belge_turu) || ' hazırlandı.');
            return next;
        exception when others then
            -- Belge bazinda yakala: digerleri devam etsin.
            belge_id  := v_id;
            basarili  := false;
            belge_no  := '';
            mesaj     := SQLERRM;
            return next;
        end;
    end loop;
end $$;

comment on function public.fn_ebelge_toplu_hazirla(integer[], integer) is
  'Secili belgeleri sirayla hazirlar; hata TEK belgeyi duserir, digerleri devam eder (183).';

do $$
begin
    raise notice '183 tamam: fn_ebelge_toplu_hazirla.';
end $$;
