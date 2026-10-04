-- ============================================================================
--  Gentegre AI — ARIZA AKIŞI: DEVRAL TEK SATIR
--  956_ariza_hareket_devral.sql
--
--  954'teki akış tetiği "Devral"da iki satır yazıyordu (atandı + işleme
--  alındı). Kişi işi kendine aldığında yalnız "işleme alındı" yazılır;
--  başkasına atama yine "atandı" olarak düşer. Yalnız dev docker.
-- ============================================================================

create or replace function public.tg_ariza_talep_hareket()
returns trigger language plpgsql as $fn$
declare
    v_kim integer := coalesce(new.degistiren, 0);
    v_ad  varchar;
begin
    if tg_op = 'INSERT' then
        insert into public.ariza_talep_hareket (talep_id, tur, metin, yazan, tarih)
        values (new.id, 1, '', new.talep_eden, new.ekleme_tarihi);
        select d.ad into v_ad from public.kod_deger d join public.kod_liste l on l.id = d.liste_id
         where l.kod = 'ariza.ekip' and d.deger = new.ekip and d.dil = 0;
        insert into public.ariza_talep_hareket (talep_id, tur, metin, yazan, tarih)
        values (new.id, 2, coalesce(v_ad, ''), 0, new.ekleme_tarihi);
        return new;
    end if;

    -- DEVRAL: kişi işi kendine aldıysa "atandı" yazılmaz - aynı anda düşen
    --   "işleme alındı" satırı yeter (956).
    if new.sorumlu_id is distinct from old.sorumlu_id and new.sorumlu_id is not null
       and not (new.sorumlu_id = v_kim and new.durum = 3 and old.durum in (1, 2)) then
        insert into public.ariza_talep_hareket (talep_id, tur, metin, yazan)
        values (new.id, 3, coalesce((select public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120)
                                       from public.taraf t where t.id = new.sorumlu_id), ''), v_kim);
    end if;

    if new.durum is distinct from old.durum then
        insert into public.ariza_talep_hareket (talep_id, tur, metin, yazan)
        values (new.id,
                case when new.durum = 3 and old.durum in (1, 2) then 4
                     when new.durum = 4 then 5
                     when new.durum = 5 and v_kim = 0 then 11
                     when new.durum = 5 then 6
                     when new.durum = 0 then 8
                     when old.durum in (4, 5) then 7
                     else 4 end,
                case when new.durum = 4 then coalesce(new.cozum_notu, '') else '' end,
                v_kim);
    end if;
    return new;
end $fn$;
