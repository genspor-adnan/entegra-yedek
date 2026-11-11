-- 1299 - Planı Üret: seçili hedeflerle sınırlı üretim ("Haftaya dağıt"; mockup temsilci_paneli_plan_v2.html)
--
-- "Sırası gelenler" çekmecesinde işaretlenen hekim / müşteriler haftaya ilçe-gün kuralıyla dağıtılır:
-- fn_dis_hekim_plan_uret'e p_hekimler (integer[]) eklendi. Verilince YALNIZ o hedefler alınır ve sıra / sıklık
-- şartı aranmaz (kullanıcı zaten seçti; planlı ziyareti olan yine atlanır). Verilmezse eski davranış.
-- Eski 6 parametreli imza DÜŞÜRÜLÜR (iki imza birlikte "function is not unique" yapar).
--
-- Tekrar çalıştırılabilir.
begin;

drop function if exists public.fn_dis_hekim_plan_uret(integer, integer, date, integer, boolean, integer);

create or replace function public.fn_dis_hekim_plan_uret(
    p_temsilci_id integer, p_sube_id integer, p_hafta_bas date,
    p_gun_basi integer default 6, p_grupla boolean default true, p_kullanici integer default 0,
    p_hekimler integer[] default null)
returns integer language plpgsql as $$
declare
    r          record;
    v_gun      integer;
    v_say      integer := 0;
    v_yuk      integer[] := array[0, 0, 0, 0, 0];     -- Pzt..Cum mevcut + eklenen
    v_ilce     text[]    := array['', '', '', '', ''];  -- günün baskın ilçesi
    v_hafta_son date := p_hafta_bas + 6;
    i          integer;
    v_secim    integer;
    v_tarih    timestamptz;
    v_sayac    integer;
    v_metin    text;
begin
    if p_temsilci_id is null or p_sube_id is null or p_hafta_bas is null then return 0; end if;
    -- Mevcut planlı yük (gün başına) ve günün baskın ilçesi.
    for i in 1..5 loop
        select count(*) into v_sayac from public.dis_hekim_ziyaret v
         where v.temsilci_id = p_temsilci_id and v.durum = 0 and v.tarih::date = p_hafta_bas + (i - 1);
        v_yuk[i] := coalesce(v_sayac, 0);
        select coalesce(vv.hekim_ilce, '') into v_metin
          from public.dis_hekim_ziyaret v
          join public.v_dis_hekim_ziyaret_vade vv on vv.hekim_id = v.hekim_id and vv.temsilci_id = v.temsilci_id
         where v.temsilci_id = p_temsilci_id and v.durum = 0 and v.tarih::date = p_hafta_bas + (i - 1)
         group by vv.hekim_ilce order by count(*) desc limit 1;
        v_ilce[i] := coalesce(v_metin, '');
    end loop;

    for r in
        select distinct on (vd.hekim_id)
               vd.hekim_id, vd.hekim_ilce, vd.gecikme_gun, vd.acik_talep, vd.gonderim_dusen, vd.vade_tarihi
          from public.v_dis_hekim_ziyaret_vade vd
         where vd.temsilci_id = p_temsilci_id and vd.sube_id = p_sube_id
           and vd.planli_ziyaret_id is null
           and (p_hekimler is not null and vd.hekim_id = any(p_hekimler)
                or p_hekimler is null and vd.siklik_hafta > 0 and vd.vade_tarihi <= v_hafta_son)
         order by vd.hekim_id, (vd.acik_talep > 0 or vd.gonderim_dusen = 1) desc, vd.gecikme_gun desc
    loop
        v_secim := 0;
        -- Aynı ilçe aynı güne (kapasite varsa).
        if p_grupla and coalesce(r.hekim_ilce, '') <> '' then
            for i in 1..5 loop
                if v_ilce[i] = r.hekim_ilce and v_yuk[i] < p_gun_basi then v_secim := i; exit; end if;
            end loop;
        end if;
        -- Yoksa en boş gün.
        if v_secim = 0 then
            v_gun := 1;
            for i in 2..5 loop if v_yuk[i] < v_yuk[v_gun] then v_gun := i; end if; end loop;
            if v_yuk[v_gun] >= p_gun_basi then exit; end if;   -- hafta doldu
            v_secim := v_gun;
            if v_ilce[v_secim] = '' then v_ilce[v_secim] := coalesce(r.hekim_ilce, ''); end if;
        end if;
        v_tarih := (p_hafta_bas + (v_secim - 1) + time '09:00' + (v_yuk[v_secim] * interval '45 minutes'))::timestamptz;
        insert into public.dis_hekim_ziyaret (hekim_id, temsilci_id, sube_id, tarih, tur, amac, sonuc, durum, oneri, hatirlat,
                                              notu, ekleyen)
        values (r.hekim_id, p_temsilci_id, p_sube_id, v_tarih, 1,
                case when r.gonderim_dusen = 1 then 4 when r.acik_talep > 0 then 3 else 1 end, 0, 0, 1, 0,
                case when r.gonderim_dusen = 1 then 'Öneri: gönderim / satış düştü'
                     when r.acik_talep > 0 then 'Öneri: açık talebi var'
                     when p_hekimler is not null then 'Öneri: seçilerek dağıtıldı'
                     else 'Öneri: ziyaret sıklığı doldu' end
                || case when r.gecikme_gun > 0 then ' (' || r.gecikme_gun || ' gün gecikti)' else '' end,
                coalesce(p_kullanici, 0));
        v_yuk[v_secim] := v_yuk[v_secim] + 1;
        v_say := v_say + 1;
    end loop;
    return v_say;
end $$;
comment on function public.fn_dis_hekim_plan_uret(integer, integer, date, integer, boolean, integer, integer[]) is
  '1290/1299: haftaya ÖNERİ ziyaret açar (durum 0, oneri 1). p_hekimler null: sırası gelen, planı olmayan hedefler; dolu: yalnız o hedefler (sıra şartı aranmaz). Açık talep / gönderim düşüşü öne; aynı ilçe aynı güne; gün başı sınırı.';

commit;
