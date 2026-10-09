-- =============================================================================
--  1007 - SABİT VARLIKLAR: ZİMMET / HAREKETLER EKRANI, DÖKÜMLER, AYARLAR
--
--  Kullanıcı (10.10.2026): "file:///.../Ekranlar/Demirbas/
--  demirbas_zimmet_hareketleri.html yap", "sabit varlıklar altına bir de
--  dökümler ekle", "gerekiyorsa ayarlar da ekle".
--
--  EKRAN KODLARI (menü kodu = yetki matrisi kodu, 1003 ilkesi):
--    demirbas.zimmet          Sabit Varlıklar › Zimmet / Hareketler  ← demirbas
--    demirbas.ayar            Sabit Varlıklar › Ayarlar › Demirbaş   ← ayar
--    dokum.sabit_varliklar    Sabit Varlıklar › Dökümler             ← dokum
--  Rolde eski kod varsa yeni kod AYNI haklarla eklenir (1003 dağıtımı) -
--  kimse yetki kazanmaz ya da kaybetmez. İdempotent: var olan rol_yetki
--  satırına dokunmaz.
--
--  HAREKET LİSTESİ: v_demirbas_hareket_liste - 1006 tetiğinin yazdığı
--  demirbas_hareket satırı + demirbaş, kişi ve lokasyon adları. Ekranın
--  "Hareketler" sekmesi bu görünümden (KaynakKatalogu demirbasHareket).
--
--  AYARLAR (referans):
--    demirbas.iade_lokasyon      İade alınan demirbaşın döndüğü lokasyon
--                                (boşsa lokasyon değişmez).
--    demirbas.tutanak_metni      Zimmet tutanağının taahhüt paragrafı.
--    demirbas.amortisman_yontem  Yeni demirbaşın amortisman yöntemi (1/2).
--    demirbas.amortisman_omur    Yeni demirbaşın faydalı ömrü (0 = boş).
--  Yeni kayıt varsayılanları TETİKLE uygulanır: kart, Excel içeri alma ve
--  satınalma mal kabulü aynı kurala uyar.
-- =============================================================================

begin;

-- ------------------------------------------------------------ ekran kodları --
create temp table _bolme (yeni varchar(60), eski varchar(60), ad varchar(120),
                          grup varchar(40), sira smallint)
  on commit drop;

insert into _bolme values
  ('demirbas.zimmet',       'demirbas', 'Zimmet / Hareketler (Sabit Varlıklar)', 'Sabit Varlıklar', 0),
  ('demirbas.ayar',         'ayar',     'Demirbaş Ayarları (Sabit Varlıklar)',   'Sabit Varlıklar', 0),
  ('dokum.sabit_varliklar', 'dokum',    'Dökümler — Sabit Varlıklar',            'Sabit Varlıklar', 0);

do $$
declare n int;
begin
  select count(*) into n from _bolme b where not exists (select 1 from public.yetki y where y.kod = b.eski);
  if n > 0 then raise exception '1007: % satırın eski kodu yetki tablosunda yok', n; end if;
end $$;

insert into public.yetki (kod, ad, grup, tur, sira, urun_modu, modul)
select b.yeni, b.ad, b.grup, 0, ye.sira, 0, ye.modul
  from _bolme b
  join public.yetki ye on ye.kod = b.eski
on conflict (kod) do update
   set ad = excluded.ad, grup = excluded.grup, tur = 0, aktif = 1;

insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, deger, kapsam, ekleyen)
select ry.rol_id, yn.id, ry.gor, ry.ekle, ry.degistir, ry.sil, ry.deger, ry.kapsam, 0
  from _bolme b
  join public.yetki ye     on ye.kod = b.eski
  join public.yetki yn     on yn.kod = b.yeni
  join public.rol_yetki ry on ry.yetki_id = ye.id
on conflict (rol_id, yetki_id) do nothing;

update public.rol r set yetki_surumu = yetki_surumu + 1
 where exists (select 1 from public.rol_yetki ry
                 join public.yetki y on y.id = ry.yetki_id
                 join _bolme b on b.yeni = y.kod
                where ry.rol_id = r.id);

-- --------------------------------------------------------- hareket listesi --
create or replace view public.v_demirbas_hareket_liste as
select h.id,
       h.zaman,
       h.hareket                                   as tip,
       h.demirbas_id,
       d.kod                                       as demirbas_kod,
       d.ad                                        as demirbas_ad,
       coalesce(kt.ad, '')                         as kategori,
       h.eski_zimmet_id,
       h.yeni_zimmet_id,
       coalesce(ek.ad, '')                         as eski_kisi,
       coalesce(yk.ad, '')                         as yeni_kisi,
       coalesce(el.ad, '')                         as eski_lokasyon,
       coalesce(yl.ad, '')                         as yeni_lokasyon,
       h.tutanak_no,
       coalesce(iy.ad, '')                         as islem_yapan,
       h.aciklama,
       d.sube_id
  from public.demirbas_hareket h
  join public.demirbas d on d.id = h.demirbas_id
  left join public.v_personel_lookup ek on ek.id = h.eski_zimmet_id
  left join public.v_personel_lookup yk on yk.id = h.yeni_zimmet_id
  left join public.v_personel_lookup iy on iy.id = h.ekleyen
  left join public.kod_liste ll on ll.kod = 'demirbas.lokasyon'
  left join public.kod_deger el on el.liste_id = ll.id and el.deger = h.eski_lokasyon and el.dil = 0
  left join public.kod_deger yl on yl.liste_id = ll.id and yl.deger = h.yeni_lokasyon and yl.dil = 0
  left join public.kod_liste kl on kl.kod = 'demirbas.kategori'
  left join public.kod_deger kt on kt.liste_id = kl.id and kt.deger = d.kategori and kt.dil = 0;

-- ------------------------------------------------------------------ ayarlar --
insert into public.referans (anahtar, deger, tip, aciklama)
select v.anahtar, v.deger, v.tip, v.aciklama
  from (values
    ('demirbas.iade_lokasyon', '', 'metin',
     'İade alınan demirbaşın döndüğü lokasyon (boşsa değişmez)'),
    ('demirbas.tutanak_metni',
     'Yukarıda bilgileri yazılı demirbaşları sağlam ve çalışır durumda teslim aldım. '
     || 'Demirbaşları özenle kullanacağımı, kurum dışına çıkarmayacağımı ve görevimden '
     || 'ayrılırken eksiksiz iade edeceğimi kabul ederim.', 'uzunMetin',
     'Zimmet tutanağının taahhüt paragrafı'),
    ('demirbas.amortisman_yontem', '1', 'sayi',
     'Yeni demirbaşın amortisman yöntemi (1 normal, 2 azalan bakiyeler)'),
    ('demirbas.amortisman_omur', '0', 'sayi',
     'Yeni demirbaşın faydalı ömrü - yıl (0 = boş bırak)')
  ) as v(anahtar, deger, tip, aciklama)
 where not exists (select 1 from public.referans r where r.anahtar = v.anahtar);

create or replace function public.fn_demirbas_amortisman_varsayilan()
returns trigger language plpgsql as $tg$
declare
    v_yontem smallint;
    v_omur   smallint;
begin
    -- Kart yöntemi değiştirmediyse (tablo varsayılanı 1) ayar uygulanır.
    select nullif(trim(deger), '')::smallint into v_yontem
      from public.referans where anahtar = 'demirbas.amortisman_yontem';
    if new.amortisman_yontem = 1 and v_yontem in (1, 2) then
        new.amortisman_yontem := v_yontem;
    end if;
    if new.amortisman_omur_yil is null then
        select nullif(trim(deger), '')::smallint into v_omur
          from public.referans where anahtar = 'demirbas.amortisman_omur';
        if v_omur between 1 and 50 then new.amortisman_omur_yil := v_omur; end if;
    end if;
    return new;
exception when invalid_text_representation then
    -- Bozuk ayar kaydı demirbaş eklemeyi durdurmasın.
    return new;
end;
$tg$;

drop trigger if exists tg_demirbas_amortisman_varsayilan on public.demirbas;
create trigger tg_demirbas_amortisman_varsayilan
  before insert on public.demirbas
  for each row execute function public.fn_demirbas_amortisman_varsayilan();

do $$
declare n int;
begin
  select count(*) into n from public.rol_yetki ry join public.yetki y on y.id = ry.yetki_id
   join _bolme b on b.yeni = y.kod;
  raise notice '1007: 3 ekran kodu, % rol satırı', n;
end $$;

commit;
