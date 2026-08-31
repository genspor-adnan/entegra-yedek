-- 302: Kurum SOZLESMESINE fiyat listesi (kullanici: "kurumda sozlesmeye
-- kampanya soluna fiyat listesi ekle").
--
-- Bugune kadar kurumun fiyati iki dolayli yoldan cozuluyordu: sozlesmedeki
-- KAMPANYANIN listesi ya da kurumun CARI fiyat listesi eslesmesi
-- (fn_cari_fiyat_listesi). Ikisi de "anlasmada su liste gecerli" cumlesini
-- dogrudan yazmiyordu; kullanici sozlesmede aciktan gorsun istiyor.
--
-- SIRA (fn_belge_varsayilan_liste):
--   1) Kampanya listesi   - kampanya hem baz listeyi hem indirimi tayin eder
--   2) SOZLESME listesi   - YENI: kurumla imzalanan anlasmanin listesi
--   3) Odeyen kurumun cari listesi
--   4) Carinin (hastanin) kendi listesi / yonun varsayilani

alter table public.taraf_kurum
  add column if not exists fiyat_listesi_id integer
      references public.fiyat_listesi(id);

comment on column public.taraf_kurum.fiyat_listesi_id is
  'Sozlesmede gecerli fiyat listesi (302) - kampanyadan sonra, cari listesinden once.';

create index if not exists ix_taraf_kurum_fiyat_listesi
    on public.taraf_kurum (fiyat_listesi_id) where fiyat_listesi_id is not null;

-- ------------------------------------------------- varsayilan liste secimi --
create or replace function public.fn_belge_varsayilan_liste(
    p_tur integer,
    p_taraf_id integer,
    p_tarih date default current_date,
    p_odeyen_kurum_id integer default null)
returns integer
language sql
stable
as $function$
    select coalesce(
        -- 1) KAMPANYA LISTESI (274): anlaşma hem baz listeyi hem indirimi
        --    tayin eder. Kampanya kurum > cari sırasıyla fn_taraf_kampanya'da
        --    çözülür; ödeyen kurum varsa fiyatı ÖDEYEN taraf belirler.
        (select fl.id
           from public.kampanya k
           join public.fiyat_listesi fl on fl.id = k.fiyat_listesi_id
          where k.id = public.fn_taraf_kampanya(
                           case when coalesce(p_odeyen_kurum_id, 0) > 0
                                then p_odeyen_kurum_id else p_taraf_id end,
                           p_tarih)
            and fl.durum = 1
            and fl.yon = public.fn_belge_yon(p_tur)),

        -- 2) SOZLESME LISTESI (302): kurumla imzalanan anlaşmada yazan liste.
        --    Sözleşme SÜRESİ ve durumu da bakılır - biten anlaşmanın fiyatı
        --    yeni başvuruya uygulanmamalı.
        (select fl.id
           from public.taraf_kurum tk
           join public.fiyat_listesi fl on fl.id = tk.fiyat_listesi_id
          where tk.id = p_odeyen_kurum_id
            and tk.durum = 1
            and (tk.baslangic is null or tk.baslangic <= p_tarih)
            and (tk.bitis is null or tk.bitis >= p_tarih)
            and fl.durum = 1
            and fl.yon = public.fn_belge_yon(p_tur)),

        -- 3) Ödeyen kurum bir caridir: listesi de cari kuralından okunur.
        case when coalesce(p_odeyen_kurum_id, 0) > 0
             then public.fn_cari_fiyat_listesi(p_odeyen_kurum_id,
                                               public.fn_belge_yon(p_tur), p_tarih)
        end,

        -- 4) Carinin kendi listesi / yönün varsayılanı.
        public.fn_cari_fiyat_listesi(p_taraf_id, public.fn_belge_yon(p_tur), p_tarih));
$function$;
