-- ============================================================================
--  373 - belge.kdv_durum TEMIZLIGI ve KISITI
--
--  Kolon serbest metin (varchar(5)) oldugu icin zamanla dort ayri yazim
--  birikmisti:
--      Hariç  493   dogru
--      (bos)   34   eski kayitlar - kolon sonradan zorunlu hale geldi
--      Dahil    6   372 ile gelen yeni basvuru/tahakkuklar
--      Haric    3   KOD HATASI: IcmalUclari.cs "Haric" yaziyordu (c-sedilsiz)
--      Hari?    1   mojibake - bir aktarimda 'ç' kaybolmus
--      Muaf     1   ?
--
--  DAVRANIS ACISINDAN hepsi ayni: `fn_belge_diptoplam` yalniz 'Dahil' dalini
--  ayirir, geri kalan her deger "haric" gibi islenir. Yani bu kayitlar YANLIS
--  HESAPLANMIYOR - ama kolon guvenilmez oldugu icin ona bakan her yeni kural
--  (or. 372) once "hangi yazim" sorusunu cozmek zorunda kaliyor.
--
--  NE DUZELTILIYOR: yalnizca PROVABLY ayni degerin bozuk yazimlari
--  ('Haric', 'Hari?') ve BOS kayitlar. 'Muaf' DEGISTIRILMEDI - bir kullanicinin
--  bilerek yazmis olabilecegi, anlamini bilmedigimiz bir deger; uydurmak yerine
--  kisitta izinli birakildi.
--
--  KOK NEDEN AYRICA DUZELTILDI (kod): IcmalUclari.cs artik "Hariç" yaziyor -
--  yoksa temizlik bir sonraki icmalde yeniden bozulurdu.
-- ============================================================================

-- ================================================================= yedek ====
-- Dokunulan satirlar once yedeklenir: geri donmek gerekirse kaynak burada.
create table if not exists public._yedek_kdv_durum_373 (
    belge_id      integer primary key,
    eski_deger    varchar(5)  not null,
    yedek_tarihi  timestamp   not null default now()::timestamp
);

insert into public._yedek_kdv_durum_373 (belge_id, eski_deger)
select b.id, b.kdv_durum
  from public.belge b
 where b.kdv_durum in ('', 'Haric', 'Hari?')
   and not exists (select 1 from public._yedek_kdv_durum_373 y where y.belge_id = b.id);

-- ============================================================== onarim ======
-- Bozuk yazimlar: ayni degerin 'ç' kaybetmis halleri.
update public.belge set kdv_durum = 'Hariç'
 where kdv_durum in ('Haric', 'Hari?');

-- BOS kayitlar: kolon sonradan zorunlu oldu (BelgeDeposu bugun bos gelirse
-- 'Hariç' yaziyor). Eski bosluklar da ayni anlama geliyor - davranis
-- DEGISMIYOR, yalnizca kolon okunabilir hale geliyor.
update public.belge set kdv_durum = 'Hariç'
 where coalesce(btrim(kdv_durum), '') = '';

-- ================================================================ kisit =====
-- Serbest metin olmasi bu karmasayi dogurdu. Artik yalniz bilinen degerler
-- yazilabilir; yeni bir yazim hatasi KAYIT ANINDA patlar, aylar sonra veri
-- temizligiyle degil.
alter table public.belge alter column kdv_durum set default 'Hariç';

alter table public.belge drop constraint if exists ck_belge_kdv_durum;
alter table public.belge
  add constraint ck_belge_kdv_durum check (kdv_durum in ('Dahil', 'Hariç', 'Muaf'));

comment on column public.belge.kdv_durum is
  'Fiyatlarin KDV DURUMU (373): Dahil = birim_fiyat_kdvli/tutar_kdvli brut ve '
  'matrah ondan turetilir (basvuru, tahakkuk); Hariç = birim_fiyat matrahtir '
  've KDV uzerine eklenir (fatura, fis, ERP belgeleri); Muaf = tarihsel deger. '
  'Kisitli - yeni yazim eklemek icin kisit da guncellenmeli.';
