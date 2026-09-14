-- ============================================================================
--  Gentegre AI — KALEM BAZLI İSKONTO ORANI
--  673_iskonto_kalem_orani.sql
--
--  Kullanıcı: "kalem bazlı oran da aç."
--
--  662'de talebin TEK oranı vardı ve karar bütün satırlara aynı yüzdeyi
--  yazıyordu. Gerçekte kalemler eşit değil: muayeneye %20 verilip tetkike
--  hiç verilmeyebilir, biri kurum anlaşmalı olduğu için dışarıda kalabilir.
--  Tek oran, görevliyi "ortalama bir oran" uydurmaya zorluyordu.
--
--  ÇÖZÜM: oran SATIRDA. Başlıktaki `oran` artık talebin EN YÜKSEK kalem
--  oranıdır - yetki tavanı kontrolü (hem istemcide hem uçta) onun üzerinden
--  yürür, çünkü sınırı zorlayan kalem odur.
--
--  KISMİ ONAYDA ORANLAR ORANTILI DÜŞER: %20 istenip %10 onaylandıysa çarpan
--  0,5'tir ve her kalem kendi oranının yarısını alır. Hepsine düz %10 yazmak,
--  görevlinin kurduğu kalem dengesini (birine 20, ötekine 5) bozardı.
-- ============================================================================
\set ON_ERROR_STOP on

alter table public.iskonto_talep_satir
    add column if not exists oran numeric(9,4) not null default 0;

comment on column public.iskonto_talep_satir.oran is
  'Kalemin ISTENEN iskonto orani (673). 0 ise baslik orani uygulanir (eski kayitlar).';

-- Eski taleplerde satir orani yok: baslik oranini satira tasi ki karar
--   fonksiyonu tek yoldan calissin.
update public.iskonto_talep_satir ts
   set oran = t.oran
  from public.iskonto_talep t
 where t.id = ts.talep_id and coalesce(ts.oran, 0) = 0;

comment on column public.iskonto_talep.oran is
  'Talebin EN YUKSEK kalem orani (673) - yetki tavani bunun uzerinden olculur.';

-- ---------------------------------------------------------------------------
--  KARAR: kalem oranları, kısmi onayda ORANTILI düşer.
-- ---------------------------------------------------------------------------
create or replace function public.fn_iskonto_talep_karar(
    p_talep_id integer,
    p_onay     smallint,          -- 1 onay · 2 ret
    p_oran     numeric,           -- onaylanan (en yüksek) oran; ret'te yok sayılır
    p_not      varchar,
    p_kullanici integer)
returns void language plpgsql as $$
declare
  v_durum  smallint;
  v_istek  numeric(9,4);
  v_oran   numeric(9,4);
  v_carpan numeric;
begin
    select durum, oran into v_durum, v_istek
      from public.iskonto_talep where id = p_talep_id;
    if v_durum is null then
        raise exception 'İskonto talebi bulunamadı: %', p_talep_id using errcode = 'GK404';
    end if;
    if v_durum <> 0 then
        raise exception 'Talep zaten sonuçlanmış (durum %).', v_durum using errcode = 'GK422';
    end if;

    if p_onay = 2 then
        update public.iskonto_talep
           set durum = 2, onay_id = p_kullanici, onay_ts = now()::timestamp,
               onaylanan_oran = 0, karar_notu = coalesce(p_not, ''),
               degistiren = p_kullanici, degistirme_tarihi = now()::timestamp
         where id = p_talep_id;
        return;
    end if;

    -- ONAYLANAN ORAN talepten büyük OLAMAZ: yetkili indirimi artırmak isterse
    --   kendi talebini açar - istenmeyen bir indirimi "onay" diye yazmak,
    --   talebi belge olmaktan çıkarırdı.
    v_oran := least(coalesce(p_oran, 0), v_istek);
    if not (v_oran > 0) then
        raise exception 'Onaylanan oran sıfırdan büyük olmalı.' using errcode = 'GK422';
    end if;
    -- Kalem dengesini koru: her kalem kendi oranının aynı oranda düşüğünü alır.
    v_carpan := case when v_istek > 0 then v_oran / v_istek else 1 end;

    -- Kilit ÖNCE kaldırılır: satır daha önce onaylıysa tetik yeni oranı
    --   reddederdi.
    update public.belge_satir s
       set iskonto_kilit = 0
      from public.iskonto_talep_satir ts
     where ts.talep_id = p_talep_id and s.id = ts.belge_satir_id;

    update public.belge_satir s
       set iskonto = round(
             case when coalesce(ts.oran, 0) > 0 then ts.oran else v_istek end
             * v_carpan, 4),
           iskonto2 = 0,
           iskonto_kilit = 1
      from public.iskonto_talep_satir ts
     where ts.talep_id = p_talep_id and s.id = ts.belge_satir_id;

    update public.iskonto_talep
       set durum = 1, onay_id = p_kullanici, onay_ts = now()::timestamp,
           onaylanan_oran = v_oran, karar_notu = coalesce(p_not, ''),
           degistiren = p_kullanici, degistirme_tarihi = now()::timestamp
     where id = p_talep_id;
end $$;

comment on function public.fn_iskonto_talep_karar is
  'Iskonto talebini onaylar (kalem oranlarini orantili yazip kilitler) ya da '
  'reddeder (662/673).';

do $$
begin
    raise notice '673 tamam: kalem orani kolonu + orantili karar.';
end $$;
