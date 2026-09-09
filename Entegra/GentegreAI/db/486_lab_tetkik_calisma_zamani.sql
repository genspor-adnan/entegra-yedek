-- =====================================================================
-- 486 - TETKİK ÇALIŞMA ZAMANLARI
--
-- Kullanıcı: "tetkik kataloğuna tetkikler için Çalışma Zamanları ekle;
-- istem yapıldığında tüm sonuçlar ne zaman çıkacak belli olsun."
--
-- BUGÜNKÜ EKSİK: katalogta yalnız `hedef_tat_dk` var - "kaç dakikada biter".
-- Ama laboratuvarda her tetkik her an çalışmaz. Hormon paneli haftada üç gün
-- seri hâlinde, kültür günde bir kez, tam kan sayımı sürekli çalışır. Sonuç
-- saati bu yüzden "kabul + TAT" değil, "SIRADAKİ ÇALIŞMA + TAT"tır. Numune
-- kabul son saatini bir dakika geçen tüp bir sonraki seriye kalır ve hastaya
-- söylenen saat o an değişir.
--
-- Bu bilgi hiçbir yerde tutulmadığı için istem ekranı "yarın" diyor, tetkik
-- gerçekte üç gün sonra çıkıyordu.
--
--   calisma_duzeni : 0 sürekli (7/24) · 1 mesai içi · 2 belirli günlerde (seri)
--   calisma_gunleri: bit maskesi - 1 Pzt, 2 Sal, 4 Çar, 8 Per, 16 Cum,
--                    32 Cmt, 64 Paz (0 = düzen "sürekli" ise anlamsız)
--   calisma_saatleri: seri başlangıçları, "09:00,15:00"
--   kabul_son_dk   : çalışma saatinden KAÇ DAKİKA ÖNCE numune kabulü kapanır
--   en_az_seri     : bu sayı dolmadan çalışılmaz (0 = beklemez)
--   tatil_calisir  : resmî tatilde çalışılır mı
--   acil_beklemez  : acil istem düzeni beklemeden çalışılır mı
-- =====================================================================

alter table public.lab_tetkik
  add column if not exists calisma_duzeni   smallint      not null default 0,
  add column if not exists calisma_gunleri  smallint      not null default 0,
  add column if not exists calisma_saatleri varchar(100)  not null default '',
  add column if not exists kabul_son_dk     integer       not null default 30,
  add column if not exists en_az_seri       integer       not null default 0,
  add column if not exists tatil_calisir    smallint      not null default 0,
  add column if not exists acil_beklemez    smallint      not null default 1;

comment on column public.lab_tetkik.calisma_duzeni is
  'Çalışma düzeni (486): 0 sürekli · 1 mesai içi · 2 belirli günlerde (seri).';
comment on column public.lab_tetkik.calisma_gunleri is
  'Çalışma günleri bit maskesi (486): 1 Pzt · 2 Sal · 4 Çar · 8 Per · 16 Cum · 32 Cmt · 64 Paz.';
comment on column public.lab_tetkik.calisma_saatleri is
  'Seri başlangıç saatleri (486), virgüllü: "09:00,15:00".';
comment on column public.lab_tetkik.kabul_son_dk is
  'Çalışmadan kaç dakika önce numune kabulü kapanır (486). Sonrasındaki numune bir sonraki seriye kalır.';
comment on column public.lab_tetkik.en_az_seri is
  'Seri bu sayıya ulaşmadan çalışılmaz (486). 0 = beklemez.';
comment on column public.lab_tetkik.tatil_calisir is
  'Resmî tatilde çalışılır mı (486).';
comment on column public.lab_tetkik.acil_beklemez is
  'ACİL istem çalışma düzenini beklemez, hemen çalışılır (486).';

alter table public.lab_tetkik drop constraint if exists ck_lab_tetkik_calisma_duzeni;
alter table public.lab_tetkik
  add constraint ck_lab_tetkik_calisma_duzeni
  check (calisma_duzeni between 0 and 2) not valid;

-- Seri düzeninde GÜN ve SAAT verilmeden sonuç zamanı hesaplanamaz: bilgisi
--   olmayan bir söz vermektense kaydı reddetmek doğru.
alter table public.lab_tetkik drop constraint if exists ck_lab_tetkik_seri_tanimli;
alter table public.lab_tetkik
  add constraint ck_lab_tetkik_seri_tanimli
  check (calisma_duzeni <> 2
         or (calisma_gunleri > 0 and calisma_saatleri <> '')) not valid;

-- ------------------------------------------------------ sonuç zamanı ---
/*
 * BİR TETKİĞİN SONUCU NE ZAMAN ÇIKAR.
 *
 * Kural tek yerde: ekran da, istem ucu da, rapor da bunu çağırır. İstemcide
 * hesaplansaydı "hastaya söylenen saat" ile "laboratuvarın planı" ayrışırdı.
 *
 *   sürekli (0)      : kabul + TAT
 *   mesai içi (1)    : kabul mesai dışındaysa ertesi mesai başı + TAT
 *   seri (2)         : kabulden sonraki ilk uygun (gün, saat) + TAT
 *   acil + beklemez  : düzen atlanır, kabul + acil TAT
 *
 * Kabul son saati: çalışmaya `kabul_son_dk` kalmışsa o seri KAÇMIŞTIR.
 */
create or replace function public.fn_lab_tetkik_sonuc_zamani(
    p_tetkik_id integer,
    p_kabul     timestamp default now()::timestamp,
    p_acil      smallint  default 0)
returns timestamp
language plpgsql stable as $$
declare
    t        record;
    v_tat    integer;
    v_gun    date;
    v_saat   time;
    v_bit    integer;
    v_aday   timestamp;
    i        integer;
    s        text;
begin
    select calisma_duzeni, calisma_gunleri, calisma_saatleri, kabul_son_dk,
           coalesce(hedef_tat_dk, 0) as hedef, coalesce(acil_tat_dk, 0) as acil,
           acil_beklemez, tatil_calisir
      into t from public.lab_tetkik where id = p_tetkik_id;
    if not found then return null; end if;

    v_tat := case when p_acil = 1 and t.acil > 0 then t.acil else t.hedef end;

    -- ACİL düzeni atlar: numune gelir gelmez çalışılır.
    if p_acil = 1 and t.acil_beklemez = 1 then
        return p_kabul + make_interval(mins => v_tat);
    end if;

    if t.calisma_duzeni = 0 then                      -- sürekli
        return p_kabul + make_interval(mins => v_tat);
    end if;

    if t.calisma_duzeni = 1 then                      -- mesai içi (08:00-17:00)
        v_aday := p_kabul;
        if v_aday::time > time '17:00' then
            v_aday := (v_aday::date + 1) + time '08:00';
        elsif v_aday::time < time '08:00' then
            v_aday := v_aday::date + time '08:00';
        end if;
        return v_aday + make_interval(mins => v_tat);
    end if;

    -- SERİ: kabulden sonraki ilk (çalışma günü, çalışma saati). En çok 14 gün
    --   ileri bakılır - bulunamıyorsa tanım eksiktir, null dönmek "bilmiyorum"
    --   demenin dürüst yoludur.
    for i in 0..13 loop
        v_gun := (p_kabul::date) + i;
        -- Pazartesi 1 ... Pazar 7  ->  bit 1,2,4,...,64
        v_bit := (1 << (extract(isodow from v_gun)::int - 1));
        if (t.calisma_gunleri & v_bit) = 0 then continue; end if;

        foreach s in array string_to_array(t.calisma_saatleri, ',') loop
            if btrim(s) = '' then continue; end if;
            v_saat := btrim(s)::time;
            v_aday := v_gun + v_saat;
            -- Kabul son saati: çalışmaya kabul_son_dk kalmışsa bu seri kaçtı.
            if v_aday - make_interval(mins => coalesce(t.kabul_son_dk, 0)) >= p_kabul then
                return v_aday + make_interval(mins => v_tat);
            end if;
        end loop;
    end loop;

    return null;
end $$;

comment on function public.fn_lab_tetkik_sonuc_zamani(integer, timestamp, smallint) is
  'Tetkiğin sonucu ne zaman çıkar (486): kabul zamanından sonraki ilk çalışma + TAT.';

-- --------------------------------------------- istemin bitiş zamanı ---
/*
 * BİR İSTEMİN TÜM SONUÇLARI NE ZAMAN HAZIR.
 *
 * Kullanıcı: "istem yapıldığında tüm sonuçlar ne zaman çıkacak belli olsun."
 * Cevap EN GEÇ biten tetkiktir - ortalama değil, en büyüğü. Bir tetkiği
 * bilinmiyorsa (tanımı eksik) null döner: eksik bilgiyle saat vermek,
 * hastaya yanlış söz vermektir.
 */
create or replace function public.fn_lab_istem_sonuc_zamani(p_istem_id integer)
returns timestamp
language sql stable as $$
    select case when count(*) filter (where z.zaman is null) > 0 then null
                else max(z.zaman) end
      from public.lab_istem_satir s
      join public.lab_istem i on i.id = s.istem_id
      cross join lateral (
          select public.fn_lab_tetkik_sonuc_zamani(
                     s.tetkik_id,
                     coalesce(i.istem_tarihi, now()::timestamp),
                     case when coalesce(i.oncelik, 0) >= 2 then 1 else 0 end::smallint)
                 as zaman) z
     where s.istem_id = p_istem_id and s.tetkik_id is not null;
$$;

comment on function public.fn_lab_istem_sonuc_zamani(integer) is
  'İstemin TÜM sonuçlarının hazır olacağı an (486): en geç biten tetkik belirler.';

do $$
begin
    raise notice '486 tamam: tetkik calisma zamanlari + sonuc zamani hesabi';
end $$;
