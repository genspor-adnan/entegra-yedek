-- 289: ÖDEME PAYLAŞIMI — SATIR TUTARININ KURUM/HASTA PAYINA BÖLÜNMESİ.
--
-- Kullanıcı: "ÖSS ise gelen provizyona göre ücret satırının bir kısmı sigorta
-- şirketi bir kısmı da hasta öder; ayrıca hastadan ek katkı da alınabilir…
-- SGK'da SUT ödemesi dönem sonu tek fatura ile kuruma faturalanır."
--
-- TASARIM: satır FİZİKSEL OLARAK BÖLÜNMEZ, tutarı iki paya ayrılır. Provizyon
-- sonradan revize olursa (sigorta %70 dedi, sonra %60) tek satırda tutar
-- güncellenir; satır ikiye bölünmüş olsaydı miktar ve dönüşüm zinciri kırılırdı.
--
-- KAPANMA: paylaşımlı satırda kapanma TUTAR üzerinden izlenir (iki sayaç),
-- paylaşımsız satırda eski MİKTAR mantığı aynen sürer - geriye dönük uyum.

-- ============================================================ satır payları ==
alter table public.belge_satir add column if not exists kurum_tutar numeric(19,4) not null default 0;
alter table public.belge_satir add column if not exists hasta_tutar numeric(19,4) not null default 0;
-- Karşılama oranı (%): provizyondan gelir. Tutarlar bundan hesaplanır ama
--   ELLE de düzenlenebilir - sigorta bazen orana değil sabit tutara onay verir.
alter table public.belge_satir add column if not exists karsilama numeric(9,4) not null default 0;
alter table public.belge_satir add column if not exists provizyon_no varchar(40) not null default '';
-- Kapanma sayaçları: hangi payın ne kadarı belgeye dönüştü.
alter table public.belge_satir add column if not exists kurum_kapatilan numeric(19,4) not null default 0;
alter table public.belge_satir add column if not exists hasta_kapatilan numeric(19,4) not null default 0;
-- HEDEF satırda: bu satır kaynağın hangi payını kapatıyor (0 tümü / 1 hasta / 2 kurum).
alter table public.belge_satir add column if not exists pay smallint not null default 0;

comment on column public.belge_satir.kurum_tutar is
  'Satır tutarının kurum (SGK/ÖSS) payı (289). kurum_tutar + hasta_tutar = tutar.';
comment on column public.belge_satir.hasta_tutar is
  'Satır tutarının hasta payı (289): katılım payı, fark ücreti, ek katkı.';
comment on column public.belge_satir.karsilama is
  'Kurumun karşılama oranı % (289). Provizyondan gelir; tutar elle de girilebilir.';
comment on column public.belge_satir.pay is
  'HEDEF satırda kaynağın hangi payını kapattığı (289): 0 tümü · 1 hasta · 2 kurum.';

create index if not exists ix_belge_satir_pay on public.belge_satir (pay) where pay > 0;

-- =================================================== kurumun faturalama modu ==
-- SGK dönem icmali ister, sigorta şirketleri çoğunlukla VAKA BAZLI fatura.
-- Aynı altyapı, farklı tetikleme: bayrak sözleşmede.
alter table public.taraf_kurum add column if not exists faturalama_modu smallint not null default 1;
alter table public.taraf_kurum add column if not exists varsayilan_karsilama numeric(9,4) not null default 0;

comment on column public.taraf_kurum.faturalama_modu is
  'Kurum payı nasıl faturalanır (289): 1 vaka bazlı (ÖSS) · 2 dönem icmali (SGK).';
comment on column public.taraf_kurum.varsayilan_karsilama is
  'Provizyon girilmediğinde uygulanacak karşılama oranı % (289).';

insert into public.kod_liste (kod, ad)
select 'kurum.faturalama_modu', 'Kurum Faturalama Modu'
 where not exists (select 1 from public.kod_liste where kod = 'kurum.faturalama_modu');

insert into public.kod_deger (liste_id, deger, ad, sira, aktif, ekleyen)
select l.id, v.deger, v.ad, v.deger * 10, 1, 0
  from public.kod_liste l
  cross join (values (1, 'Vaka Bazlı Fatura'), (2, 'Dönem İcmali')) as v(deger, ad)
 where l.kod = 'kurum.faturalama_modu'
   and not exists (select 1 from public.kod_deger d where d.liste_id = l.id and d.deger = v.deger);

-- ================================================================ paylaştırma ==
-- Satırın payını hesaplar. Oran verilmezse kurumun varsayılanı, o da yoksa
-- tamamı hastaya yazılır (kendi öder).
create or replace function public.fn_belge_satir_paylastir(
    p_tutar     numeric,
    p_karsilama numeric,
    p_kurum_id  integer default null)
returns table (kurum_tutar numeric, hasta_tutar numeric, karsilama numeric)
language sql stable as $$
    with o as (
        select coalesce(nullif(p_karsilama, 0),
                        (select tk.varsayilan_karsilama from public.taraf_kurum tk
                          where tk.id = p_kurum_id), 0) as oran
    )
    select round(coalesce(p_tutar, 0) * o.oran / 100.0, 2),
           coalesce(p_tutar, 0) - round(coalesce(p_tutar, 0) * o.oran / 100.0, 2),
           o.oran
      from o;
$$;

comment on function public.fn_belge_satir_paylastir(numeric, numeric, integer) is
  'Satır tutarını kurum/hasta payına böler (289). Oran yoksa kurumun varsayılanı.';

-- ======================================================== kapanma sayaçları ==
-- Paylaşımlı satırda kapanma TUTAR üzerinden: hedef satırlar `pay` taşır ve
-- tutarları ilgili sayaca toplanır. Paylaşımsız satırda eski miktar mantığı
-- aynen çalışır (pay = 0 hedefler).
create or replace function public.fn_belge_satir_kapatma_tazele(p_satir_id integer)
returns void
language plpgsql as $function$
declare
  v_belge   integer;
  v_miktar  numeric(19,6);
  v_hasta   numeric(19,4);
  v_kurum   numeric(19,4);
begin
    if p_satir_id is null or p_satir_id = 0 then return; end if;

    -- Pay TAŞIMAYAN hedefler miktarı kapatır (klasik sipariş → irsaliye/fatura).
    select coalesce(sum(h.miktar) filter (where coalesce(h.pay, 0) = 0), 0),
           coalesce(sum(h.tutar)  filter (where h.pay = 1), 0),
           coalesce(sum(h.tutar)  filter (where h.pay = 2), 0)
      into v_miktar, v_hasta, v_kurum
      from public.belge_satir h
     where h.kaynak_tur = 30 and h.kaynak_id = p_satir_id;

    update public.belge_satir k
       set kapatilan_miktar = case
             -- Paylaşımlı satır: iki pay da kapandıysa miktar da kapanmış sayılır.
             when (k.kurum_tutar + k.hasta_tutar) > 0
              and v_hasta >= k.hasta_tutar and v_kurum >= k.kurum_tutar then k.miktar
             when (k.kurum_tutar + k.hasta_tutar) > 0 then v_miktar
             else v_miktar end,
           hasta_kapatilan = v_hasta,
           kurum_kapatilan = v_kurum
     where k.id = p_satir_id
    returning k.belge_id into v_belge;

    if v_belge is null then
        select belge_id into v_belge from public.belge_satir where id = p_satir_id;
    end if;
    if v_belge is null then return; end if;

    perform public.fn_belge_kapanma_tazele(v_belge);
end $function$;

-- Belge kapanma durumu: paylaşımlı satırda "kalan" TUTARDAN, ötekinde miktardan.
create or replace function public.fn_belge_kapanma_tazele(p_belge_id integer)
returns void
language plpgsql as $function$
begin
    if coalesce(p_belge_id, 0) = 0 then return; end if;

    update public.belge b
       set kapanma_durum = x.durum
      from (
        select case
                 when count(*) = 0 then 0
                 when sum(case when kalan > 0 then 1 else 0 end) = 0 then 2
                 when sum(kapanan) > 0 then 1
                 else 0
               end as durum
          from (
            select case when (s.kurum_tutar + s.hasta_tutar) > 0
                        then greatest((s.hasta_tutar - s.hasta_kapatilan)
                                    + (s.kurum_tutar - s.kurum_kapatilan), 0)
                        else s.kalan_miktar end as kalan,
                   case when (s.kurum_tutar + s.hasta_tutar) > 0
                        then s.hasta_kapatilan + s.kurum_kapatilan
                        else s.kapatilan_miktar end as kapanan
              from public.belge_satir s where s.belge_id = p_belge_id
          ) y
      ) x
     where b.id = p_belge_id
       and b.kapanma_durum is distinct from x.durum;
end $function$;

-- =================================================================== İCMAL ==
-- SGK payı TEK TEK faturalanmaz: dönem sonunda tüm satırlar toplanıp kuruma
-- bir fatura kesilir. İcmal, hangi başvurunun hangi faturada olduğunu tutar.
create table if not exists public.kurum_icmal (
  id            integer generated by default as identity primary key,
  kurum_id      integer not null references public.taraf(id),
  donem_bas     date not null,
  donem_bit     date not null,
  durum         smallint not null default 1,        -- 1 Hazırlanıyor · 2 Faturalandı · 0 İptal
  belge_id      integer references public.belge(id),
  toplam        numeric(19,4) not null default 0,
  aciklama      varchar(300) not null default '',
  sube_id       integer not null default 0,
  ekleyen       integer not null default 0,
  ekleme_tarihi timestamp not null default now()::timestamp,
  degistiren    integer not null default 0,
  degistirme_tarihi timestamp
);
comment on table public.kurum_icmal is
  'Kurum dönem icmali (289): SGK payının toplu faturalanması.';
create index if not exists ix_kurum_icmal_kurum on public.kurum_icmal (kurum_id, durum);

create table if not exists public.kurum_icmal_satir (
  id             integer generated by default as identity primary key,
  icmal_id       integer not null references public.kurum_icmal(id) on delete cascade,
  belge_satir_id integer not null references public.belge_satir(id),
  tutar          numeric(19,4) not null default 0
);
-- Bir satırın kurum payı İKİ icmale birden giremez: aynı tutar iki kez
--   faturalanırdı.
create unique index if not exists ux_kurum_icmal_satir
  on public.kurum_icmal_satir (belge_satir_id);
create index if not exists ix_kurum_icmal_satir_icmal on public.kurum_icmal_satir (icmal_id);

insert into public.kod_liste (kod, ad)
select 'kurum.icmal_durum', 'İcmal Durumu'
 where not exists (select 1 from public.kod_liste where kod = 'kurum.icmal_durum');

insert into public.kod_deger (liste_id, deger, ad, sira, aktif, ekleyen)
select l.id, v.deger, v.ad, v.deger * 10, 1, 0
  from public.kod_liste l
  cross join (values (0, 'İptal'), (1, 'Hazırlanıyor'), (2, 'Faturalandı')) as v(deger, ad)
 where l.kod = 'kurum.icmal_durum'
   and not exists (select 1 from public.kod_deger d where d.liste_id = l.id and d.deger = v.deger);
