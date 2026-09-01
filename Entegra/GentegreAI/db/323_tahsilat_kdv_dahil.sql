-- 323: Tahsilat dağıtımının tabanı KDV DAHİL, prim tabanı KDV HARİÇ.
--
-- 321'de dağıtım, satırın pay tutarları (belge_satir.hasta_tutar /
-- kurum_tutar) üzerinden yapılıyordu. Bu tutarlar KDV HARİÇ matrahtır:
--
--     satır payları 4,61 + 7,23 = 11,84   (matrah)
--     belge genel toplamı            13,02   (KDV 1,18 dahil)
--
-- Hasta kasaya 13,02 öder; dağıtılabilir taban 11,84 olduğu için aradaki
-- 1,18 hiçbir satıra bağlanamaz ve sonsuza kadar "dağıtılmamış avans"
-- görünürdü. Tahsilat gerçek ödemedir - tabanı da ödenen tutar olmalı.
--
-- Bu göç iki tabanı ayırır:
--   * DAĞITIM tabanı  = KDV DAHİL pay (hastanın fiilen ödediği tutar)
--   * PRİM tabanı     = KDV HARİÇ matrah (kullanıcı kararı: KDV kurumun
--     geliri değil, devlete aittir)
-- Matrah karşılığı dağıtılan tutardan geri hesaplanır: tutar / (1 + kdv/100).

-- Kolon adları/sırası değiştiği için görünüm ÖNCE düşürülür: PostgreSQL
-- "create or replace view" ile kolon adı değiştirmeye izin vermez.
drop view if exists public.v_belge_satir_tahsilat;

-- ------------------------------------------ tahsil edilebilir satır (v2) --
create or replace view public.v_belge_satir_tahsilat as
select s.id                                   as satir_id,
       s.belge_id,
       s.sira,
       coalesce(nullif(hz.ad, ''), nullif(st.ad, ''), nullif(s.aciklama, ''), '')
                                              as kalem,
       coalesce(nullif(hz.kod, ''), nullif(st.kod, ''), '')
                                              as kalem_kod,
       s.miktar,
       s.tutar,
       coalesce(s.kdv, 0)                     as kdv,
       -- MATRAH (KDV hariç) - prim tabanı bu.
       s.hasta_tutar                          as hasta_matrah,
       s.kurum_tutar                          as kurum_matrah,
       -- ÖDENECEK (KDV dahil) - tahsilat ve dağıtım tabanı bu.
       round(s.hasta_tutar * (1 + coalesce(s.kdv, 0) / 100.0), 2) as hasta_tutar,
       round(s.kurum_tutar * (1 + coalesce(s.kdv, 0) / 100.0), 2) as kurum_tutar,
       s.hasta_tahsil,
       s.kurum_tahsil,
       greatest(round(s.hasta_tutar * (1 + coalesce(s.kdv, 0) / 100.0), 2)
                - s.hasta_tahsil, 0)          as hasta_kalan,
       greatest(round(s.kurum_tutar * (1 + coalesce(s.kdv, 0) / 100.0), 2)
                - s.kurum_tahsil, 0)          as kurum_kalan,
       -- PRİM TABANI: tahsil edilenin KDV'siz karşılığı.
       round(s.hasta_tahsil / (1 + coalesce(s.kdv, 0) / 100.0), 4) as hasta_tahsil_matrah,
       round(s.kurum_tahsil / (1 + coalesce(s.kdv, 0) / 100.0), 4) as kurum_tahsil_matrah,
       s.hizmet_id,
       s.stok_id
  from public.belge_satir s
  left join public.hizmet hz on hz.id = s.hizmet_id
  left join public.stok st on st.id = s.stok_id
 order by s.sira, s.id;

comment on view public.v_belge_satir_tahsilat is
  'Tahsilat dağıtımı (321/323): dağıtım tabanı KDV DAHİL pay, prim tabanı '
  'KDV HARİÇ matrah (hasta_tahsil_matrah / kurum_tahsil_matrah).';

-- --------------------------------------------------- aşım koruması (v2) --
-- Kural değişmedi, yalnız üst sınır KDV dahil paya bakıyor: hasta 13,02
-- ödediyse satıra 13,02 dağıtılabilmeli, 11,84 değil.
create or replace function public.tg_kasa_dagitim_kontrol()
returns trigger language plpgsql as $$
declare
  v_pay_tutar numeric(19,4);
  v_dagitilan numeric(19,4);
  v_islem     numeric(19,4);
begin
    if new.tutar <= 0 then
        raise exception 'Dağıtılan tutar sıfırdan büyük olmalı.' using errcode = 'GK422';
    end if;

    -- KDV DAHİL pay (323): tahsilat gerçek ödemedir, matrahla sınırlanamaz.
    select round(case when new.pay = 2 then s.kurum_tutar else s.hasta_tutar end
                 * (1 + coalesce(s.kdv, 0) / 100.0), 2)
      into v_pay_tutar
      from public.belge_satir s where s.id = new.belge_satir_id;

    select coalesce(sum(d.tutar), 0) into v_dagitilan
      from public.kasa_islem_dagitim d
      join public.kasa_islem k on k.id = d.kasa_islem_id
     where d.belge_satir_id = new.belge_satir_id and d.pay = new.pay
       and d.id is distinct from new.id
       and coalesce(k.durum, 0) = 2 and k.iptal_islem_id is null;

    if coalesce(v_pay_tutar, 0) > 0 and v_dagitilan + new.tutar > v_pay_tutar + 0.005 then
        raise exception 'Satıra payından fazla tahsilat dağıtılamaz (pay %, dağıtılan %, eklenen %).',
            v_pay_tutar, v_dagitilan, new.tutar using errcode = 'GK422';
    end if;

    select coalesce(k.tutar, 0) into v_islem
      from public.kasa_islem k where k.id = new.kasa_islem_id;

    select coalesce(sum(d.tutar), 0) into v_dagitilan
      from public.kasa_islem_dagitim d
     where d.kasa_islem_id = new.kasa_islem_id and d.id is distinct from new.id;

    if v_dagitilan + new.tutar > v_islem + 0.005 then
        raise exception 'Dağıtım toplamı işlem tutarını aşamaz (işlem %, dağıtılan %).',
            v_islem, v_dagitilan + new.tutar using errcode = 'GK422';
    end if;

    return new;
end $$;

comment on column public.belge_satir.hasta_tahsil is
  'Satırın hasta payından TAHSİL EDİLEN tutar - KDV DAHİL (323). Prim tabanı '
  'için KDV''siz karşılığı v_belge_satir_tahsilat.hasta_tahsil_matrah.';
