-- ============================================================================
--  386 - PLAN KISI KURALININ MESAJI KULLANICIYA ULASSIN
--
--  383/384 tetigi `check_violation` (23514) firlatiyordu; API bu kodu
--  "Deger kurala uymuyor." diye cevirir ve TETIGIN YAZDIGI ACIKLAMA KAYBOLUR.
--  Kullanici "Dr. X 'Yapan' rolunde prim adayi degil, Prim Rolleri sekmesinden
--  isaretleyin" yerine anlamsiz bir cumle goruyordu - kural dogru calisip
--  yanlis konusuyordu.
--
--  Projede bunun icin AYRILMIS kod var: 'GK422' (bkz. VeriHatasi.Cevir) -
--  "DB tetikleyicilerinin bilerek firlattigi IS KURALI: mesaj kullaniciya
--  gosterilmek uzere yazilmistir".
-- ============================================================================

create or replace function public.tg_prim_plani_taraf_dogrula()
returns trigger
language plpgsql
as $function$
declare
    v_rol    smallint;
    v_unvan  varchar(200);
    v_durum  smallint;
    v_rol_ad text;
begin
    select p.rol into v_rol from public.prim_plani p where p.id = new.plan_id;
    select coalesce(t.unvan, ''), coalesce(t.durum, 1)
      into v_unvan, v_durum
      from public.taraf t where t.id = new.taraf_id;

    if coalesce(v_durum, 1) <> 1 then
        raise exception '% pasif; plana yalnizca aktif personel / dis hekim eklenebilir.',
            v_unvan using errcode = 'GK422';
    end if;

    if not exists (select 1 from public.v_prim_rol_aday a
                    where a.id = new.taraf_id
                      and a.rol = coalesce(v_rol, 0)
                      and coalesce(a.durum, 1) = 1) then
        select coalesce(kd.ad, 'rol ' || coalesce(v_rol, 0)::text) into v_rol_ad
          from public.kod_liste kl
          join public.kod_deger kd on kd.liste_id = kl.id and kd.deger = v_rol
         where kl.kod = 'prim.rol';

        raise exception
            '% kisisi "%" rolunde prim adayi degil. Personel kartindaki Prim '
            'Rolleri sekmesinden bu rolu isaretleyin; dis hekimlerde yalnizca '
            '"Gonderen" rolu vardir.', v_unvan, coalesce(v_rol_ad, '?')
            using errcode = 'GK422';
    end if;
    return new;
end $function$;
