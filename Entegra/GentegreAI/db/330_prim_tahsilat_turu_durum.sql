-- 330: TAHSİLAT TÜRÜNE GÖRE ORAN + PRİM SATIRI DURUM MAKİNESİ.
--
-- Kullanıcı:
--   1) "1000 TL işlem yapılmış; tahsilat NAKİT olursa %12, POS olursa %10."
--      Primin oranı, paranın hangi araçla tahsil edildiğine de bağlı (POS
--      komisyonu kurumda kalıyor, nakit tahsilat daha değerli).
--   2) "Prim satırında durum: TASLAK - henüz belge türü sipariş/başvuru ise;
--      KESİN - satış tahakkuku/fişi/faturasına dönüşmüşse; ONAYLI -
--      onaylanmışsa değişemez. Belge dönüşümlerinde prim satırlarını tekrar
--      gözden geçirmek gerekir."
--
-- DURUM ANLAMI (hakedis_satir.durum) - 324'teki üçlü yeniden tanımlandı:
--   1 Taslak  : gelir belgesi henüz kesilmemiş (sipariş/başvuru/teklif).
--               Tahsilat yapılmış olabilir; prim hesaplanır ama ödemeye
--               girmez, her değişiklikte yeniden üretilir.
--   2 Kesin   : kalem gelir belgesine dönüşmüş (tahakkuk/fiş/fatura/irsaliye).
--               Hâlâ yeniden hesaplanır - rol ya da oran düzeltilebilir.
--   3 Onaylı  : kilitlendi. Rol, oran, belge türü sonradan değişse bile
--               DOKUNULMAZ; fark sonraki döneme düzeltme olarak girer.
--               Dönem kapatma da satırı onaylı yapar.
--   4 Ödendi  : hakediş ödendi.
--
-- Eski kodlama (1 açık, 2 dönem kapandı, 3 ödendi) veriyle birlikte taşınır.

-- ================================================== tahsilat türü kriteri ==
alter table public.prim_plani_satir
  add column if not exists tahsilat_turu smallint not null default 0;

comment on column public.prim_plani_satir.tahsilat_turu is
  'Tahsilat türü kriteri (330): 0 farketmez, yoksa kasa_islem_turu kodu '
  '(21 nakit, 22 havale, 23 çek, 24 senet, 25 POS, 26 kupon).';

-- Kart alani icin secim listesi: yalniz TAHSILAT turleri (yon = 1, 21..26).
create or replace view public.v_tahsilat_turu_lookup as
select t.kod::integer as id, t.ad, 1 as aktif
  from public.kasa_islem_turu t
 where t.kod between 21 and 29;

comment on view public.v_tahsilat_turu_lookup is
  'Prim satirinda tahsilat turu secimi (330).';

-- ==================================================== belge türü zinciri ===
-- Dönüşüm iki adımlı olabilir (sipariş -> irsaliye -> fatura). Eski sürüm
-- yalnız BİR adım bakıyordu ve zincirin sonundaki faturayı göremiyordu;
-- oran yanlış belge türünden hesaplanabilirdi.
create or replace function public.fn_prim_belge_turu(p_satir_id integer)
returns smallint language sql stable as $$
    with recursive zincir(satir_id, tur, derinlik) as (
        select s.id, b.tur, 0
          from public.belge_satir s
          join public.belge b on b.id = s.belge_id
         where s.id = p_satir_id
        union all
        select h.id, b2.tur, z.derinlik + 1
          from zincir z
          join public.belge_satir h on h.kaynak_tur = 30 and h.kaynak_id = z.satir_id
          join public.belge b2 on b2.id = h.belge_id
         where z.derinlik < 5
    )
    select tur from zincir order by derinlik desc, satir_id desc limit 1;
$$;

comment on function public.fn_prim_belge_turu is
  'Kalemin GELIR belgesi turu (330): donusum zincirinin SONUNCU halkasi.';

-- Taslak mi? Siparis / teklif / basvuru turleri henuz gelir belgesi degildir.
create or replace function public.fn_prim_taslak_mi(p_belge_tur smallint)
returns boolean language sql immutable as $$
    select coalesce(p_belge_tur, 0) in (9, 18, 19, 30);
$$;

comment on function public.fn_prim_taslak_mi is
  'Belge turu henuz gelir belgesi degil mi (330): siparis/teklif/basvuru.';

-- ======================================================== durum gecisi =====
do $$
begin
    -- Eski 3 (odendi) -> 4, eski 2 (donem kapandi) -> 3 (onayli).
    --   Sirasi onemli: once 3->4, sonra 2->3.
    if exists (select 1 from public.hakedis_satir where durum = 3) then
        update public.hakedis_satir set durum = 4 where durum = 3;
    end if;
    update public.hakedis_satir set durum = 3 where durum = 2;

    -- Eski 1 (acik) -> gelir belgesi kesilmisse 2 (kesin), degilse 1 (taslak).
    update public.hakedis_satir h
       set durum = case when public.fn_prim_taslak_mi(
                              public.fn_prim_belge_turu(h.belge_satir_id))
                        then 1 else 2 end
     where h.durum = 1;
end $$;

-- Hakedis BASLIGI durumu da ayni sozlugu kullanir: 2 kesinlesmis -> onayli.
comment on column public.hakedis_satir.durum is
  'Prim satiri durumu (330): 1 taslak, 2 kesin, 3 onayli (kilitli), 4 odendi.';

-- ================================================ eslestirme fonksiyonu ====
drop function if exists public.fn_prim_plan_satiri(
    smallint, integer, integer, integer, smallint, smallint, integer, integer, date);

create or replace function public.fn_prim_plan_satiri(
    p_rol           smallint,
    p_taraf_id      integer,
    p_hizmet_id     integer,
    p_stok_id       integer,
    p_belge_tur     smallint,
    p_pay           smallint,
    p_kurum_id      integer,
    p_sube_id       integer,
    p_tarih         date,
    p_tahsilat_turu smallint default 0)
returns table (plan_id integer, satir_id integer, oran_tipi smallint,
               deger numeric, alt_sinir numeric, ust_sinir numeric, baz smallint)
language sql stable as $$
    select p.id, s.id, s.oran_tipi, s.deger, s.alt_sinir, s.ust_sinir, p.baz
      from public.prim_plani p
      join public.prim_plani_satir s on s.plan_id = p.id
     where coalesce(p.durum, 1) = 1
       and p.baslangic <= p_tarih
       and (p.bitis is null or p.bitis >= p_tarih)
       and s.rol = p_rol
       -- kapsam (plan basligi)
       and (p.hekim_id is null or p.hekim_id = p_taraf_id)
       and (coalesce(p.odeyen_kurum_id, 0) = 0 or p.odeyen_kurum_id = p_kurum_id)
       and (coalesce(p.sube_id, 0) = 0 or p.sube_id = p_sube_id)
       -- kapsam (satir): Liste = tumu · Kategori · Urun
       and (s.tip = 1
            or (s.tip = 2 and (
                   (coalesce(s.kalem_turu, 0) in (0, 2)
                    and s.hedef_id = (select h.kategori from public.hizmet h
                                       where h.id = p_hizmet_id))
                or (coalesce(s.kalem_turu, 0) in (0, 1)
                    and s.hedef_id = (select st.kategori from public.stok st
                                       where st.id = p_stok_id))))
            or (s.tip = 3 and (
                   (coalesce(s.kalem_turu, 0) in (0, 2) and s.hedef_id = p_hizmet_id)
                or (coalesce(s.kalem_turu, 0) in (0, 1) and s.hedef_id = p_stok_id))))
       -- belge türü kriteri (bos = tumu)
       and (s.belge_turleri = ''
            or p_belge_tur is null
            or p_belge_tur::text = any(string_to_array(s.belge_turleri, ',')))
       -- TAHSILAT TURU kriteri (330): nakit %12, POS %10 gibi
       and (coalesce(s.tahsilat_turu, 0) = 0
            or s.tahsilat_turu = p_tahsilat_turu)
       -- pay kriteri
       and (s.pay = 0 or s.pay = p_pay)
     order by
       -- ozgulluk: dar kapsam once
       (case s.tip when 3 then 3 when 2 then 1 else 0 end)
       + (case when coalesce(s.kalem_turu, 0) <> 0 then 1 else 0 end)
       + (case when s.belge_turleri <> '' then 1 else 0 end)
       + (case when coalesce(s.tahsilat_turu, 0) <> 0 then 1 else 0 end)
       + (case when s.pay <> 0 then 1 else 0 end)
       + (case when p.hekim_id is not null then 1 else 0 end)
       + (case when coalesce(p.odeyen_kurum_id, 0) <> 0 then 1 else 0 end) desc,
       p.oncelik desc, s.sira, s.id
     limit 1;
$$;

comment on function public.fn_prim_plan_satiri is
  'Kalem+rol icin EN DAR eslesen prim plan satiri (324; kapsam 328, tahsilat turu 330).';

-- ========================================================== fn_prim_uret ===
create or replace function public.fn_prim_uret(p_dagitim_id integer)
returns integer language plpgsql as $$
declare
  d          record;
  r          record;
  kural      record;
  v_matrah   numeric(19,4);
  v_tutar    numeric(19,4);
  v_belgetur smallint;
  v_durum    smallint;
  v_kurum    integer;
  v_sube     integer;
  v_tarih    date;
  v_sayac    integer := 0;
begin
    select d2.id, d2.belge_satir_id, d2.pay, d2.tutar,
           k.islem_tarihi::date as tarih, k.durum, k.iptal_islem_id,
           k.tur as tahsilat_turu,
           s.hizmet_id, s.stok_id, s.kdv, b.sube_id, bb.odeyen_kurum_id
      into d
      from public.kasa_islem_dagitim d2
      join public.kasa_islem k on k.id = d2.kasa_islem_id
      join public.belge_satir s on s.id = d2.belge_satir_id
      join public.belge b on b.id = s.belge_id
      left join public.belge_basvuru bb on bb.id = b.id
     where d2.id = p_dagitim_id;

    if not found then return 0; end if;

    -- Yeniden uretilebilir satirlari temizle. ONAYLI (3) ve ODENMIS (4)
    --   satira dokunulmaz: kilitli prim geriye donuk degismez.
    delete from public.hakedis_satir
     where dagitim_id = p_dagitim_id and durum in (1, 2);

    -- Iptal edilmis ya da gerceklesmemis tahsilat prim uretmez.
    if coalesce(d.durum, 0) <> 2 or d.iptal_islem_id is not null then
        return 0;
    end if;

    -- PRIM TABANI: dagitilan tutarin KDV'siz karsiligi (323 karari).
    v_matrah := round(d.tutar / (1 + coalesce(d.kdv, 0) / 100.0), 4);
    v_belgetur := public.fn_prim_belge_turu(d.belge_satir_id);
    -- Gelir belgesi kesilmemisse satir TASLAK'tir (330).
    v_durum := case when public.fn_prim_taslak_mi(v_belgetur) then 1 else 2 end;
    v_kurum := d.odeyen_kurum_id;
    v_sube := d.sube_id;
    v_tarih := d.tarih;

    for r in select br.rol, br.taraf_id, br.pay_yuzde
               from public.belge_satir_rol br
              where br.belge_satir_id = d.belge_satir_id
    loop
        select * into kural
          from public.fn_prim_plan_satiri(r.rol, r.taraf_id, d.hizmet_id, d.stok_id,
                                          v_belgetur, d.pay, v_kurum, v_sube, v_tarih,
                                          d.tahsilat_turu);
        if not found then continue; end if;

        v_tutar := case when kural.oran_tipi = 2
                        then kural.deger
                        else round(v_matrah * kural.deger / 100.0, 2) end;
        v_tutar := round(v_tutar * coalesce(r.pay_yuzde, 100) / 100.0, 2);

        if kural.alt_sinir is not null and v_tutar < kural.alt_sinir then
            v_tutar := kural.alt_sinir;
        end if;
        if kural.ust_sinir is not null and v_tutar > kural.ust_sinir then
            v_tutar := kural.ust_sinir;
        end if;
        if v_tutar <= 0 then continue; end if;

        insert into public.hakedis_satir
               (taraf_id, rol, dagitim_id, belge_satir_id, plan_id, plan_satir_id,
                tarih, belge_tur, pay, taban, oran_tipi, deger, pay_yuzde, tutar, durum)
        values (r.taraf_id, r.rol, p_dagitim_id, d.belge_satir_id,
                kural.plan_id, kural.satir_id, v_tarih, v_belgetur, d.pay,
                v_matrah, kural.oran_tipi, kural.deger,
                coalesce(r.pay_yuzde, 100), v_tutar, v_durum)
        on conflict (dagitim_id, taraf_id, rol) where dagitim_id is not null
        do update set tutar = excluded.tutar, taban = excluded.taban,
                      deger = excluded.deger, belge_tur = excluded.belge_tur,
                      plan_id = excluded.plan_id, plan_satir_id = excluded.plan_satir_id,
                      durum = excluded.durum
        -- KILITLI satira dokunma (326/330).
        where hakedis_satir.durum in (1, 2);

        v_sayac := v_sayac + 1;
    end loop;

    return v_sayac;
end $$;

-- ===================================================== onay / onay kaldir ==
-- Onaylanan satir KILITLENIR: rol, oran, belge turu sonradan degisse bile
-- yeniden hesaplanmaz. Donemi kapanmis satirin onayi kaldirilamaz.
create or replace function public.fn_prim_onayla(
    p_id integer, p_geri smallint default 0)
returns smallint language plpgsql as $$
declare v_durum smallint; v_hakedis integer;
begin
    select durum, hakedis_id into v_durum, v_hakedis
      from public.hakedis_satir where id = p_id;

    if not found then
        raise exception 'Prim satırı bulunamadı.' using errcode = 'GK422';
    end if;

    if p_geri = 1 then
        if v_hakedis is not null then
            raise exception 'Dönemi kapanmış prim satırının onayı kaldırılamaz.'
                using errcode = 'GK422';
        end if;
        if v_durum <> 3 then
            raise exception 'Yalnız onaylı satırın onayı kaldırılabilir.'
                using errcode = 'GK422';
        end if;
        update public.hakedis_satir set durum = 2 where id = p_id;
        return 2;
    end if;

    if v_durum = 1 then
        raise exception 'Taslak prim onaylanamaz: önce kalem gelir belgesine (tahakkuk/fiş/fatura) dönüşmeli.'
            using errcode = 'GK422';
    end if;
    if v_durum <> 2 then
        return v_durum;                       -- zaten onayli ya da odenmis
    end if;

    update public.hakedis_satir set durum = 3 where id = p_id;
    return 3;
end $$;

comment on function public.fn_prim_onayla is
  'Prim satirini onaylar/onayi kaldirir (330). Onayli satir yeniden hesaplanmaz.';

-- ======================================================== dönem kapatma ====
-- Kapatma yalniz KESIN ve ONAYLI satirlari baglar; taslak satir gelir
-- belgesi kesilene kadar hakedise girmez.
create or replace function public.fn_hakedis_kapat(
    p_taraf_id integer, p_bas date, p_bit date,
    p_kullanici integer default 0, p_sube integer default null)
returns integer language plpgsql as $$
declare
  v_id     integer;
  v_toplam numeric(19,4);
  v_taslak integer;
begin
    select coalesce(sum(tutar), 0) into v_toplam
      from public.hakedis_satir
     where taraf_id = p_taraf_id and hakedis_id is null
       and durum in (2, 3) and tarih between p_bas and p_bit;

    if v_toplam = 0 then
        select count(*) into v_taslak
          from public.hakedis_satir
         where taraf_id = p_taraf_id and hakedis_id is null
           and durum = 1 and tarih between p_bas and p_bit;

        if v_taslak > 0 then
            raise exception
                'Bu dönemde yalnız TASLAK prim var (% satır): kalemler gelir belgesine dönüşmeden hakediş kapatılamaz.',
                v_taslak using errcode = 'GK422';
        end if;
        raise exception 'Bu dönemde bağlanacak prim satırı yok.'
            using errcode = 'GK422';
    end if;

    insert into public.hakedis (taraf_id, donem_baslangic, donem_bitis, durum,
                                toplam, sube_id, ekleyen)
    values (p_taraf_id, p_bas, p_bit, 2, v_toplam, p_sube, p_kullanici)
    returning id into v_id;

    update public.hakedis_satir
       set hakedis_id = v_id, durum = 3            -- kapanan satir ONAYLI
     where taraf_id = p_taraf_id and hakedis_id is null
       and durum in (2, 3) and tarih between p_bas and p_bit;

    return v_id;
end $$;

-- ============================================================== görünümler =
drop view if exists public.v_hakedis_satir;
create view public.v_hakedis_satir as
select hs.id,
       hs.hakedis_id,
       hs.taraf_id,
       coalesce(t.unvan, '')                  as kisi,
       hs.rol,
       coalesce(kr.ad, '')                    as rol_adi,
       hs.tarih,
       hs.belge_tur,
       coalesce(bt.ad, '')                    as belge_tur_adi,
       -- Tahsilatin turu (330): "nakitte %12, POS'ta %10" satirda okunur.
       k.tur                                  as tahsilat_turu,
       coalesce(tt.ad, '')                    as tahsilat_turu_adi,
       hs.pay,
       case hs.pay when 2 then 'Kurum payı' else 'Hasta payı' end as pay_adi,
       hs.taban,
       hs.oran_tipi,
       hs.deger,
       hs.pay_yuzde,
       hs.tutar,
       hs.durum,
       case hs.durum when 1 then 'Taslak' when 2 then 'Kesin'
                     when 3 then 'Onaylı'  when 4 then 'Ödendi'
                     else '' end              as durum_adi,
       hs.belge_satir_id,
       s.belge_id,
       coalesce(hz.ad, st.ad, s.aciklama, '') as kalem,
       coalesce(h2.unvan, '')                 as hasta,
       b.sube_id
  from public.hakedis_satir hs
  left join public.taraf t on t.id = hs.taraf_id
  join public.belge_satir s on s.id = hs.belge_satir_id
  join public.belge b on b.id = s.belge_id
  left join public.kasa_islem_dagitim d on d.id = hs.dagitim_id
  left join public.kasa_islem k on k.id = d.kasa_islem_id
  left join public.kasa_islem_turu tt on tt.kod = k.tur
  left join public.kasa_islem_turu bt on bt.kod = hs.belge_tur
  left join public.taraf h2 on h2.id = b.taraf_id
  left join public.hizmet hz on hz.id = s.hizmet_id
  left join public.stok st on st.id = s.stok_id
  left join public.kod_liste kl on kl.kod = 'prim.rol'
  left join public.kod_deger kr on kr.liste_id = kl.id and kr.deger = hs.rol
 where hs.durum <> 0;

comment on view public.v_hakedis_satir is
  'Hakediş satırı raporu (324/330): kişi, rol, kalem, tahsilat türü, durum.';

drop view if exists public.v_hakedis_ozet;
create view public.v_hakedis_ozet as
select hs.taraf_id,
       coalesce(t.unvan, '')                                    as kisi,
       -- Kapatilabilir: gelir belgesi kesilmis (kesin/onayli) ve donemi
       --   kapanmamis satirlar. Taslak AYRI gosterilir - kullanici neyin
       --   neden kapanmadigini gorsun.
       count(*) filter (where hs.hakedis_id is null and hs.durum in (2, 3))     as acik_satir,
       coalesce(sum(hs.tutar) filter
                (where hs.hakedis_id is null and hs.durum in (2, 3)), 0)        as acik_tutar,
       count(*) filter (where hs.durum = 1)                                     as taslak_satir,
       coalesce(sum(hs.tutar) filter (where hs.durum = 1), 0)                   as taslak_tutar,
       coalesce(sum(hs.tutar) filter (where hs.hakedis_id is not null), 0)      as kapanan_tutar,
       coalesce(sum(hs.tutar), 0)                                              as toplam,
       min(hs.tarih)                                                            as ilk_tarih,
       max(hs.tarih)                                                            as son_tarih
  from public.hakedis_satir hs
  left join public.taraf t on t.id = hs.taraf_id
 where hs.durum <> 0
 group by hs.taraf_id, t.unvan;

comment on view public.v_hakedis_ozet is
  'Kişi bazında hakediş özeti (324/330): kapatılabilir, taslak ve kapanmış tutar.';

-- ================================== belge türü değişince yeniden gözden geçir
-- Dönüşüm tetiği (324) kaynak satırın primlerini tazeliyor. Belgenin TÜRÜ
-- doğrudan değiştirilirse (fiş -> fatura) de aynı gözden geçirme gerekir:
-- oran belge türüne bağlı ve satır taslaktan kesine geçebilir.
create or replace function public.tg_prim_belge_tur()
returns trigger language plpgsql as $$
declare r record;
begin
    if new.tur is not distinct from old.tur then return null; end if;

    for r in select d.id
               from public.kasa_islem_dagitim d
               join public.belge_satir s on s.id = d.belge_satir_id
              where s.belge_id = new.id
    loop
        perform public.fn_prim_uret(r.id);
    end loop;

    -- Bu belgenin KAYNAK satirlari da etkilenir: prim kaynak kalemde durur,
    --   gelir belgesi turu bu belgeden okunur.
    for r in select d.id
               from public.kasa_islem_dagitim d
              where d.belge_satir_id in (
                    select h.kaynak_id from public.belge_satir h
                     where h.belge_id = new.id and h.kaynak_tur = 30
                       and h.kaynak_id is not null)
    loop
        perform public.fn_prim_uret(r.id);
    end loop;
    return null;
end $$;

drop trigger if exists tr_prim_belge_tur on public.belge;
create trigger tr_prim_belge_tur
  after update of tur on public.belge
  for each row execute function public.tg_prim_belge_tur();

-- --------------------------------------------------------------- yetki ----
insert into public.yetki (kod, ad, grup, tur, sira) values
    ('prim.onayla', 'Prim satirini onayla', 'kart', 1, 142)
on conflict (kod) do nothing;

insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil)
select r.id, y.id, 1, 1, 1, 1
  from public.rol r cross join public.yetki y
 where r.kod = 'yonetici' and y.kod = 'prim.onayla'
on conflict (rol_id, yetki_id) do update
   set gor = 1, ekle = 1, degistir = 1, sil = 1;
