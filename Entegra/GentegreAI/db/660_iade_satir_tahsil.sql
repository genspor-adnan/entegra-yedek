-- ============================================================================
--  Gentegre AI — İADE SATIR TAHSİLATINA YANSISIN
--  660_iade_satir_tahsil.sql
--
--  SORUN. Tahsilat sekmesine "↩ İade / İptal" eklendi: iade, aynı türde EKSİ
--  tutarlı bir kasa işlemidir (tür 21 nakit, 25 POS...). Kasa bakiyesi ve
--  belgenin tahsil toplamı bundan doğru çıkıyordu, ama SATIR bazında hiçbir
--  şey değişmiyordu:
--
--      · `fn_belge_satir_tahsil_tazele` satırın tahsil edilenini yalnızca
--        `kasa_islem_dagitim` satırlarından toplar,
--      · iade işleminin dağıtım satırı HİÇ YAZILAMIYOR, çünkü
--        `tg_kasa_dagitim_kontrol` "Dağıtılan tutar sıfırdan büyük olmalı"
--        diyerek eksi satırı reddediyor.
--
--  Sonuç: para kasadan çıkmış, hasta borcu geri doğmuş ama satır hâlâ "tahsil
--  edildi" görünüyor; belge kapanmış sayılıyor, prim de geri alınmıyordu.
--
--  ÇÖZÜM ÜÇ PARÇA:
--    1) Dağıtım EKSİ satır kabul eder - ama yalnız işlemin kendisi eksiyse ve
--       o satır/paydan daha önce tahsil edilenden fazlasını geri almadan.
--    2) Eksi işlemin dağıtımı KENDİLİĞİNDEN yazılır (`fn_kasa_dagitim_iade`):
--       istemcinin iadeyi elle dağıtması beklenmez - unutulursa satır yine
--       yanlış kalırdı.
--    3) `fn_belge_satir_tahsil_tazele` toplamı zaten netleşir; eksiye düşmesin
--       diye alt sınır 0'a bağlandı.
--
--  Prim, `tr_prim_dagitim` üzerinden dağıtım satırına bağlı olduğu için eksi
--  dağıtım satırı hakedişi de kendiliğinden düşürür - ayrıca bir şey yapılmaz.
-- ============================================================================
\set ON_ERROR_STOP on

-- ---------------------------------------------------------------------------
--  1) AŞIM KORUMASI - artık işaretli çalışır.
--
--  Eski kural "tutar > 0" idi ve üç şeyi aynı anda yapıyordu: sıfırı engellemek,
--  işaret tutarlılığı ve aşım kontrolü. Ayrıştırıldı:
--    · sıfır her zaman yasak (anlamsız satır),
--    · satır işlemle AYNI İŞARETTE olmalı (artı işleme eksi dağıtım, eksi
--      işleme artı dağıtım kasa ile satırı ters yönde ayırırdı),
--    · net dağıtılan 0 ile payın tutarı arasında kalmalı: payından fazlası
--      tahsil edilemez, tahsil edilenden fazlası da iade edilemez.
-- ---------------------------------------------------------------------------
create or replace function public.tg_kasa_dagitim_kontrol()
returns trigger language plpgsql as $$
declare
  v_pay_tutar numeric(19,4);
  v_dagitilan numeric(19,4);
  v_islem     numeric(19,4);
begin
    if new.tutar = 0 then
        raise exception 'Dağıtılan tutar sıfır olamaz.' using errcode = 'GK422';
    end if;

    select coalesce(k.tutar, 0) into v_islem
      from public.kasa_islem k where k.id = new.kasa_islem_id;

    if (v_islem > 0 and new.tutar < 0) or (v_islem < 0 and new.tutar > 0) then
        raise exception 'Dağıtım satırı işlemle aynı işarette olmalı (işlem %, satır %).',
            v_islem, new.tutar using errcode = 'GK422';
    end if;
    if new.pay not in (1, 2, 3, 4, 5) then
        raise exception 'Bilinmeyen ödeme payı: %.', new.pay using errcode = 'GK422';
    end if;

    -- KDV DAHİL kova sınırı (323, 471'den aynen): tahsilat gerçek ödemedir,
    --   matrahla sınırlanamaz. KATILIM PAYI istisnadır - KDV'siz emanettir.
    select case new.pay
             when 5 then coalesce(dg.sgk_katilim_payi, 0)
             else round(case new.pay
                          when 1 then coalesce(dg.hasta_provizyon, 0)
                          when 2 then coalesce(dg.sgk, 0)
                          when 3 then coalesce(dg.oss, 0)
                          else coalesce(dg.hasta_ek_katki, 0) end
                        * (1 + coalesce(s.kdv, 0) / 100.0), 2)
           end
      into v_pay_tutar
      from public.belge_satir s
      left join public.belge_satir_dagilim dg on dg.belge_satir_id = s.id
     where s.id = new.belge_satir_id;

    -- Aynı satır/paya yazılmış DİĞER satırların neti (gerçekleşmiş, iptalsiz).
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

    -- İADE SINIRI: geri alınan, o satır/paydan tahsil edilenden fazla olamaz.
    --   Olsaydı satırın tahsil edileni eksiye düşer, kapanma ve prim hesabı
    --   anlamsızlaşırdı.
    if v_dagitilan + new.tutar < -0.005 then
        raise exception 'Satırdan tahsil edilenden fazlası iade edilemez (tahsil %, iade %).',
            v_dagitilan, -new.tutar using errcode = 'GK422';
    end if;

    -- İşlemden dağıtılan toplam, işlemin tutarını aşamaz (iki yönde de).
    select coalesce(sum(d.tutar), 0) into v_dagitilan
      from public.kasa_islem_dagitim d
     where d.kasa_islem_id = new.kasa_islem_id and d.id is distinct from new.id;

    if abs(v_dagitilan + new.tutar) > abs(v_islem) + 0.005 then
        raise exception 'Dağıtım toplamı işlem tutarını aşamaz (işlem %, dağıtılan %).',
            v_islem, v_dagitilan + new.tutar using errcode = 'GK422';
    end if;

    return new;
end $$;

-- ---------------------------------------------------------------------------
--  2) SATIR TAHSİLATI - eksi dağıtım satırlarıyla netleşir.
--
--  Toplam formülü değişmedi (dağıtım satırlarının toplamı); tek fark alt sınır:
--  artık eksi satır da toplama girdiği için, bozuk bir veri toplamı eksiye
--  düşürmesin diye 0'a bağlandı. Normal akışta zaten eksiye düşemez - koruma
--  (1) buna izin vermiyor.
-- ---------------------------------------------------------------------------
create or replace function public.fn_belge_satir_tahsil_tazele(p_satir_id integer)
returns void language plpgsql as $$
begin
    if coalesce(p_satir_id, 0) = 0 then return; end if;

    update public.belge_satir_dagilim dg
       set hasta_provizyon_tahsil = greatest(coalesce(x.p1, 0), 0),
           sgk_tahsil             = greatest(coalesce(x.p2, 0), 0),
           oss_tahsil             = greatest(coalesce(x.p3, 0), 0),
           hasta_ek_katki_tahsil  = greatest(coalesce(x.p4, 0), 0),
           sgk_katilim_tahsil     = greatest(coalesce(x.p5, 0), 0)
      from (
        select sum(d.tutar) filter (where d.pay = 1) as p1,
               sum(d.tutar) filter (where d.pay = 2) as p2,
               sum(d.tutar) filter (where d.pay = 3) as p3,
               sum(d.tutar) filter (where d.pay = 4) as p4,
               sum(d.tutar) filter (where d.pay = 5) as p5
          from public.kasa_islem_dagitim d
          join public.kasa_islem k on k.id = d.kasa_islem_id
         where d.belge_satir_id = p_satir_id
           and coalesce(k.durum, 0) = 2
           and k.iptal_islem_id is null
      ) x
     where dg.belge_satir_id = p_satir_id;
end $$;

comment on function public.fn_belge_satir_tahsil_tazele(integer) is
  'Satirin pay bazinda tahsil edilenini dagitim satirlarindan tazeler (660): '
  'iade satirlari EKSI tutarlidir ve toplami dusurur.';

-- ---------------------------------------------------------------------------
--  3) İADENİN DAĞITIMI OTOMATİK.
--
--  İadeyi hangi satırdan düşeceğini kullanıcıya sordurmuyoruz: iade "şu
--  tahsilatı geri ver" demektir, tahsilat hangi satırlara dağıldıysa geri alma
--  da oradan yapılır. Sıra tahsilatın tersi değil AYNISIDIR (önce hasta payı,
--  sonra kurum) - kullanıcı iki ekranda aynı sırayı görür.
--
--  Tahsil edilmemiş satır/paya dokunulmaz; iade artarsa (belgeye bağlı olandan
--  fazla iade) kalan dağıtılmadan bırakılır - kasada durur, satıra yazılmaz.
-- ---------------------------------------------------------------------------
create or replace function public.fn_kasa_dagitim_iade(p_kasa_islem_id integer)
returns numeric language plpgsql as $$
declare
  v_belge   integer;
  v_tutar   numeric(19,4);
  v_kalan   numeric(19,4);
  v_al      numeric(19,4);
  r         record;
begin
    select k.belge_id, coalesce(k.tutar, 0) into v_belge, v_tutar
      from public.kasa_islem k where k.id = p_kasa_islem_id;

    -- Yalnız belgeye bağlı EKSİ işlem dağıtılır.
    if coalesce(v_belge, 0) = 0 or v_tutar >= 0 then return 0; end if;

    v_kalan := abs(v_tutar);

    for r in
      -- Bu belgenin satır/paylarında NET tahsil edilen tutarlar. Sıra:
      --   satır sırası, sonra pay (1 hasta provizyon · 4 ek katkı ·
      --   5 SGK katılım · 2 SGK · 3 ÖSS) - hasta payları önce.
      select d.belge_satir_id, d.pay, sum(d.tutar) as net
        from public.kasa_islem_dagitim d
        join public.kasa_islem k on k.id = d.kasa_islem_id
        join public.belge_satir s on s.id = d.belge_satir_id
       where s.belge_id = v_belge
         and coalesce(k.durum, 0) = 2
         and k.iptal_islem_id is null
       group by d.belge_satir_id, d.pay, s.sira
      having sum(d.tutar) > 0.004
       order by s.sira,
                case d.pay when 1 then 1 when 4 then 2 when 5 then 3
                           when 2 then 4 else 5 end,
                d.belge_satir_id
    loop
        exit when v_kalan <= 0.004;
        v_al := least(v_kalan, r.net);

        insert into public.kasa_islem_dagitim (kasa_islem_id, belge_satir_id, pay, tutar)
        values (p_kasa_islem_id, r.belge_satir_id, r.pay, round(-v_al, 4))
        on conflict (kasa_islem_id, belge_satir_id, pay)
          do update set tutar = public.kasa_islem_dagitim.tutar + excluded.tutar;

        v_kalan := v_kalan - v_al;
    end loop;

    return round(abs(v_tutar) - v_kalan, 4);
end $$;

comment on function public.fn_kasa_dagitim_iade(integer) is
  'Eksi (iade) kasa islemini belgenin tahsil edilmis satir/paylarina dagitir; '
  'dagitilan toplami doner (660).';

-- İade gerçekleştiği anda dağıt: istemcinin ayrıca dağıtım ucu çağırması
-- beklenmez. Yalnız EKSİ ve belgeye bağlı işlemde çalışır; iptal ters kaydı
-- (artı tutarlı, `iptal_islem_id` ile işaretli) buradan geçmez.
create or replace function public.tg_kasa_islem_iade_dagit()
returns trigger language plpgsql as $$
begin
    if coalesce(new.tutar, 0) < 0
       and coalesce(new.belge_id, 0) <> 0
       and coalesce(new.durum, 0) = 2
       and new.iptal_islem_id is null
    then
        -- TUTAR DEGISTIYSE ESKI DAGITIM BAYAT: iade kartindan 197 -> 150'ye
        --   cekilirse satirdan hala 197 dusulmus gorunurdu. Eski satirlar
        --   silinip yeniden dagitilir (silme de tazelemeyi tetikler).
        if tg_op = 'UPDATE' and coalesce(old.tutar, 0) is distinct from new.tutar then
            delete from public.kasa_islem_dagitim where kasa_islem_id = new.id;
        end if;

        if not exists (select 1 from public.kasa_islem_dagitim
                        where kasa_islem_id = new.id) then
            perform public.fn_kasa_dagitim_iade(new.id);
        end if;
    end if;
    return null;
end $$;

drop trigger if exists tr_kasa_islem_iade_dagit on public.kasa_islem;
create trigger tr_kasa_islem_iade_dagit
  after insert or update of durum, tutar, belge_id on public.kasa_islem
  for each row execute function public.tg_kasa_islem_iade_dagit();

-- ---------------------------------------------------------------------------
--  GEÇMİŞ VERİ. Bu sürümden önce girilmiş eksi işlem yok (iade ekranı yeni),
--  ama varsa dağıtılsın: dağıtımı hiç olmayan, belgeye bağlı, gerçekleşmiş
--  eksi işlemler bir kez işlenir. Idempotent - dağıtımı olan atlanır.
-- ---------------------------------------------------------------------------
do $$
declare r record; v_sayi integer := 0;
begin
    for r in select k.id from public.kasa_islem k
              where coalesce(k.tutar, 0) < 0
                and coalesce(k.belge_id, 0) <> 0
                and coalesce(k.durum, 0) = 2
                and k.iptal_islem_id is null
                and not exists (select 1 from public.kasa_islem_dagitim d
                                 where d.kasa_islem_id = k.id)
    loop
        perform public.fn_kasa_dagitim_iade(r.id);
        v_sayi := v_sayi + 1;
    end loop;
    raise notice 'Geriye dönük dağıtılan iade işlemi: %', v_sayi;
end $$;
