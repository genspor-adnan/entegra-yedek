-- =====================================================================
--  946_randevu_mesai_yerel_saat.sql
--  943'ÜN DÜZELTMESİ: MESAİ DIŞI KONTROLÜ ŞUBE SAATİYLE.
--
--  randevu.baslangic timestamptz'dir (667): bir AN saklar, veritabanı
--  oturumu UTC'dir. 943 tetiği `new.baslangic::time` ile UTC saatini
--  çalışma planının DUVAR SAATİ bloklarıyla ('09:00'-'18:00')
--  karşılaştırıyordu: İstanbul'da 09:30'a verilen randevu "06:30 - 06:45:
--  çalışma planının dışında" diye REDDEDİLİYORDU (kart kaydında görüldü).
--
--  DÜZELTME: an, randevunun şubesinin saat dilimine (sube.zaman_dilimi,
--  boşsa Europe/Istanbul - Saat.Dilim ile aynı yedek) çevrilip gün ve saat
--  oradan alınır. Hata metni de yerel saati yazar.
--
--  Kuralın kendisi (kapsam, ayar randevu.mesai_disi) 943'teki gibi.
--  Idempotent.
-- =====================================================================
\set ON_ERROR_STOP on

create or replace function public.tg_randevu_mesai_kontrol()
returns trigger
language plpgsql
as $$
declare
    v_ayar  text;
    v_hekim text;
    v_dilim text;
    v_yerel timestamp;
    v_gun   date;
    v_bas   time;
    v_bit   time;
begin
    if coalesce(new.durum, 1) in (3, 4) then return new; end if;
    if new.hekim_id is null then return new; end if;
    -- Saat / sure / doktor degismediyse (durum guncellemesi) dokunma.
    if tg_op = 'UPDATE'
       and new.hekim_id is not distinct from old.hekim_id
       and new.baslangic = old.baslangic
       and new.sure_dk = old.sure_dk
       and coalesce(old.durum, 1) not in (3, 4) then
        return new;
    end if;
    if public.fn_hekim_planli(new.hekim_id) <> 1 then return new; end if;

    -- AN -> SUBENIN DUVAR SAATI (plan bloklari duvar saatidir).
    select coalesce(nullif(s.zaman_dilimi, ''), 'Europe/Istanbul') into v_dilim
      from public.sube s where s.id = new.sube_id;
    v_yerel := new.baslangic at time zone coalesce(v_dilim, 'Europe/Istanbul');
    v_gun   := v_yerel::date;

    -- Izin gunu: karar tg_randevu_izin_kontrol'un (kendi ayariyla).
    if exists (select 1 from public.fn_hekim_izinli(new.hekim_id, v_gun)) then
        return new;
    end if;

    v_bas := v_yerel::time;
    v_bit := v_bas + make_interval(mins => greatest(coalesce(new.sure_dk, 0), 1)::int);

    if exists (select 1
                 from public.fn_hekim_calisma_bloklari(new.sube_id, v_gun, v_gun, new.hekim_id) b
                where b.saat_bas is not null
                  and v_bas >= b.saat_bas and v_bit <= b.saat_bit
                  and v_bit > v_bas) then
        return new;
    end if;

    select coalesce(nullif(deger, ''), '0') into v_ayar
      from public.referans where anahtar = 'randevu.mesai_disi';

    if coalesce(v_ayar, '0') = '1' then
        raise warning 'Randevu % calisma plani disinda (hekim #%).',
            to_char(v_yerel, 'DD.MM.YYYY HH24:MI'), new.hekim_id;
        return new;
    end if;

    select coalesce(nullif(public.fn_taraf_ad(unvan, ad, soyad), ''), 'Doktor') into v_hekim
      from public.taraf where id = new.hekim_id;

    raise exception '% % saat % - %: çalışma planının dışında. Randevu doktorun çalışma '
                    'saatleri içinde verilmeli; gerekirse Çalışma Planı''ndan saat değişikliği '
                    'ya da ek mesai ekleyin.',
        v_hekim, to_char(v_gun, 'DD.MM.YYYY'),
        to_char(v_bas, 'HH24:MI'), to_char(v_bit, 'HH24:MI')
        using errcode = 'GK422';
end $$;

do $$
begin
    raise notice '946 tamam: mesai disi kontrolu sube saat diliminde.';
end $$;
