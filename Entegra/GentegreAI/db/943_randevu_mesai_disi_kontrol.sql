-- =====================================================================
--  943_randevu_mesai_disi_kontrol.sql
--  RANDEVU ÇALIŞMA PLANININ DIŞINA YAZILAMAZ (kullanıcı: "çalışma planları
--  varken randevu ayarlarına gerek kaldı mı" -> plan tek kaynak, adım 2).
--
--  Önceden randevu yalnız ÇAKIŞMA (tg_randevu_cakisma) ve İZİN
--  (tg_randevu_izin_kontrol) için denetleniyordu; doktorun çalışma saatleri
--  hiç kontrol edilmiyordu - mesai dışına, çalışmadığı güne ya da plandaki
--  "Kapalı" istisnasına randevu yazılabiliyordu.
--
--  KURAL: doktorun çalışma planı varsa (fn_hekim_planli = 1) randevunun
--  BAŞI ve SONU o günkü bir çalışma bloğunun içinde olmalı
--  (fn_hekim_calisma_bloklari: şablon + saat değişikliği / ek mesai,
--  kapalı / kongre / izin günleri blok üretmez).
--
--  KONTROL EDİLMEYENLER:
--    * planı olmayan doktor (plan henüz girilmemiş kurulum - eski davranış),
--    * hekimsiz randevu (cihaz randevusu - radyoloji kendi kapatmalarıyla),
--    * iptal / gelmedi randevusu,
--    * saati, süresi ve doktoru DEĞİŞMEYEN güncelleme ("Geldi" işaretlemek
--      eski bir mesai dışı randevuyu kilitlemesin),
--    * onaylı izin günü: o kararı tg_randevu_izin_kontrol verir (kendi
--      ayarıyla) - aynı randevuya iki ayrı mesaj çıkmasın.
--
--  AYAR randevu.mesai_disi: 0 engelle (varsayılan) · 1 yalnız uyar.
--  (randevu.izinli_hekim ile aynı gerekçe: sert kural seçeneksiz kalırsa
--  kurum randevuyu kâğıda yazar.)
--
--  Idempotent.
-- =====================================================================
\set ON_ERROR_STOP on

insert into public.referans (anahtar, deger, aciklama)
select 'randevu.mesai_disi', '0',
       'Calisma plani disina randevu: 0 engelle (varsayilan) - 1 yalniz uyar.'
 where not exists (select 1 from public.referans where anahtar = 'randevu.mesai_disi');

create or replace function public.tg_randevu_mesai_kontrol()
returns trigger
language plpgsql
as $$
declare
    v_ayar  text;
    v_hekim text;
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
    -- Izin gunu: karar tg_randevu_izin_kontrol'un (kendi ayariyla).
    if exists (select 1 from public.fn_hekim_izinli(new.hekim_id, new.baslangic::date)) then
        return new;
    end if;

    v_bas := new.baslangic::time;
    v_bit := v_bas + make_interval(mins => greatest(coalesce(new.sure_dk, 0), 1)::int);

    if exists (select 1
                 from public.fn_hekim_calisma_bloklari(new.sube_id, new.baslangic::date,
                                                       new.baslangic::date, new.hekim_id) b
                where b.saat_bas is not null
                  and v_bas >= b.saat_bas and v_bit <= b.saat_bit
                  and v_bit > v_bas) then
        return new;
    end if;

    select coalesce(nullif(deger, ''), '0') into v_ayar
      from public.referans where anahtar = 'randevu.mesai_disi';

    if coalesce(v_ayar, '0') = '1' then
        raise warning 'Randevu % calisma plani disinda (hekim #%).',
            to_char(new.baslangic, 'DD.MM.YYYY HH24:MI'), new.hekim_id;
        return new;
    end if;

    select coalesce(nullif(public.fn_taraf_ad(unvan, ad, soyad), ''), 'Doktor') into v_hekim
      from public.taraf where id = new.hekim_id;

    raise exception '% % saat % - %: çalışma planının dışında. Randevu doktorun çalışma '
                    'saatleri içinde verilmeli; gerekirse Çalışma Planı''ndan saat değişikliği '
                    'ya da ek mesai ekleyin.',
        v_hekim, to_char(new.baslangic, 'DD.MM.YYYY'),
        to_char(v_bas, 'HH24:MI'), to_char(v_bit, 'HH24:MI')
        using errcode = 'GK422';
end $$;

drop trigger if exists tr_randevu_mesai on public.randevu;
create trigger tr_randevu_mesai
    before insert or update of hekim_id, baslangic, sure_dk, durum on public.randevu
    for each row execute function public.tg_randevu_mesai_kontrol();

do $$
begin
    raise notice '943 tamam: randevu calisma plani disi kontrolu (ayar randevu.mesai_disi).';
end $$;
