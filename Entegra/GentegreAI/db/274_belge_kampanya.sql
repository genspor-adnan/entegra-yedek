-- 274: BELGE ↔ KAMPANYA BAĞI (kullanıcı: "müşteri belgede ne bulunacak, fiyat
-- listesi mi kampanya adı mı? ... ikisi de").
--
-- Fiyatlama HİBRİT: fiyat listesi BAZ FİYATI, kampanya İNDİRİMİ belirler.
--   Belgede ikisinin de kimliği durur:
--     belge.fiyat_listesi_id  (205) -> baz fiyat nereden geldi
--     belge.kampanya_id       (bu)  -> hangi kampanya işledi
--     belge_satir.kampanya_satir_id -> o kalemi HANGİ KURAL vurdu
--   Satır kimliği asıl denetim izidir: kampanya satırı sonradan düzenlenir ya
--   da silinirse belgede kanıt kalır, iade/iptalde aynı fiyat üretilebilir.
--   Fiyatın kendisi zaten belge_satir.birim_fiyat'ta donmuş durumda; buradaki
--   kimlikler yalnız izlenebilirlik ve yeniden hesap içindir.
--
-- Kampanya artık YALNIZ kuruma bağlı değil: her cari kendi kampanyasını
--   taşıyabilir (taraf.kampanya_id) ve kimseye bağlı olmayan dönemsel
--   kampanya `genel` bayrağıyla herkese uygulanır. Böylece hasta başvurusu,
--   normal fatura ve fiş tek hattan fiyatlanır.

-- ------------------------------------------------------- genel kampanya ----
alter table public.kampanya add column if not exists genel smallint not null default 0;

comment on column public.kampanya.genel is
  'Herkese açık dönemsel kampanya (274). Cariye/kuruma bağlı kampanya varsa O kazanır.';

create index if not exists ix_kampanya_genel on public.kampanya (genel)
  where genel = 1;

-- --------------------------------------------------- cariye bağlı kampanya --
alter table public.taraf add column if not exists kampanya_id integer;

do $$
begin
  if not exists (select 1 from information_schema.table_constraints
                  where constraint_name = 'fk_taraf_kampanya') then
    alter table public.taraf
      add constraint fk_taraf_kampanya
          foreign key (kampanya_id) references public.kampanya (id);
  end if;
end $$;

comment on column public.taraf.kampanya_id is
  'Cariye özel kampanya (274). Kurum sözleşmesindeki kampanya bunu ezer.';

create index if not exists ix_taraf_kampanya on public.taraf (kampanya_id)
  where kampanya_id is not null;

-- ------------------------------------------------------------ belge bağı ----
alter table public.belge add column if not exists kampanya_id integer;

do $$
begin
  if not exists (select 1 from information_schema.table_constraints
                  where constraint_name = 'fk_belge_kampanya') then
    alter table public.belge
      add constraint fk_belge_kampanya
          foreign key (kampanya_id) references public.kampanya (id);
  end if;
end $$;

comment on column public.belge.kampanya_id is
  'Belgeye işleyen kampanya (274). Belgeye YAZILIR: kurum sonradan kampanya değiştirse eski belge sabit kalır.';

create index if not exists ix_belge_kampanya on public.belge (kampanya_id)
  where kampanya_id is not null;

alter table public.belge_satir add column if not exists kampanya_satir_id integer;

do $$
begin
  if not exists (select 1 from information_schema.table_constraints
                  where constraint_name = 'fk_belge_satir_kampanya_satir') then
    alter table public.belge_satir
      add constraint fk_belge_satir_kampanya_satir
          foreign key (kampanya_satir_id) references public.kampanya_satir (id);
  end if;
end $$;

comment on column public.belge_satir.kampanya_satir_id is
  'Kalemin fiyatını belirleyen kampanya satırı (274) - denetim izi.';

create index if not exists ix_belge_satir_kampanya_satir
  on public.belge_satir (kampanya_satir_id) where kampanya_satir_id is not null;

-- ------------------------------------------------- geçerli kampanya çözümü --
-- Öncelik: ÖDEYEN KURUM sözleşmesi > carinin kendi kampanyası > genel kampanya.
-- Kurum da bir taraf olduğundan tek fonksiyon her iki durumu karşılar; ödeyen
-- kurum varsa çağıran onun id'sini geçer.
create or replace function public.fn_taraf_kampanya(
    p_taraf_id integer,
    p_tarih    date default current_date)
returns integer
language sql stable as $$
    with aday as (
        -- 1) Kurum sözleşmesi (sözleşme de kampanya da yürürlükte olmalı).
        select k.id, 1 as oncelik
          from public.taraf_kurum tk
          join public.kampanya k on k.id = tk.kampanya_id
         where tk.id = p_taraf_id
           and tk.durum = 1
           and (tk.baslangic is null or tk.baslangic <= p_tarih)
           and (tk.bitis     is null or tk.bitis     >= p_tarih)
           and k.durum = 1
           and (k.baslangic is null or k.baslangic <= p_tarih)
           and (k.bitis     is null or k.bitis     >= p_tarih)
        union all
        -- 2) Cariye özel kampanya.
        select k.id, 2
          from public.taraf t
          join public.kampanya k on k.id = t.kampanya_id
         where t.id = p_taraf_id
           and k.durum = 1
           and (k.baslangic is null or k.baslangic <= p_tarih)
           and (k.bitis     is null or k.bitis     >= p_tarih)
        union all
        -- 3) Genel kampanya - cari verilmese de geçerli.
        select k.id, 3
          from public.kampanya k
         where k.genel = 1
           and k.durum = 1
           and (k.baslangic is null or k.baslangic <= p_tarih)
           and (k.bitis     is null or k.bitis     >= p_tarih)
    )
    select id from aday order by oncelik, id limit 1;
$$;

comment on function public.fn_taraf_kampanya(integer, date) is
  'Tarafın (cari ya da ödeyen kurum) verilen tarihte geçerli kampanyası (274): kurum sözleşmesi > cari > genel.';

-- Eski ad korunur: 272'de yazılan uç ve olası çağrılar kırılmasın.
create or replace function public.fn_kurum_kampanya(
    p_kurum_id integer,
    p_tarih    date default current_date)
returns integer
language sql stable as $$
    select public.fn_taraf_kampanya(p_kurum_id, p_tarih);
$$;

comment on function public.fn_kurum_kampanya(integer, date) is
  'fn_taraf_kampanya için eski ad (274). Yeni kod fn_taraf_kampanya çağırmalı.';
