-- 1387: çek / senet GİRİŞ HAREKETİ (Delphi TCekWizardDlg.TabCeklerAfterPost: çek kaydedilince "Yeni Çek" satırı).
--
-- Web'de giriş hareketi (130) yalnız kasa tahsilatı / ödemesiyle gelen kıymete yazılıyordu (KasaDeposu
-- CekSenetBaglaAsync). Çek / senet KARTINDAN eklenen kıymetin hiç hareketi olmuyordu: kartın Hareketler sekmesi boş
-- kalıyor, "Son Hareketi Geri Al" (1386) ilk işlemi giriş sanıp geri almayı reddediyordu.
--
-- * Tetik: cek_senet eklenince giriş satırı (130, eski durum 0) - aktarım kayıtları hariç (1147 kendi hareketini
--   yazar). Kasa yolu artık bu satırı GÜNCELLER (kasa işlemi bağlanır), ikinci satır yazmaz.
-- * Onarım: hareketi HİÇ olmayan, aktarımla gelmemiş kıymetlere giriş satırı (kanıtlanabilir eksik - başka satır
--   yok). Eklenen satırlar _yedek_cek_giris_1387'de listelenir (geri dönüş: o id'leri silin).

create or replace function public.fn_cek_senet_giris_hareketi() returns trigger
language plpgsql as $$
begin
    if new.aktarim_kaynak is not null then return new; end if;
    insert into public.cek_senet_hareket
        (cek_senet_id, islem, tarih, eski_durum, yeni_durum, taraf_id, aciklama, belge_no, ekleyen)
    values (new.id, 130, coalesce(new.tarih::date, current_date), 0, new.durum, new.taraf_id,
            case when new.tur = 2 then 'Yeni senet' else 'Yeni çek' end,
            left(coalesce(new.makbuz_no, ''), 30), coalesce(new.ekleyen, 0));
    return new;
end $$;

drop trigger if exists trg_cek_senet_giris_hareketi on public.cek_senet;
create trigger trg_cek_senet_giris_hareketi
    after insert on public.cek_senet
    for each row execute function public.fn_cek_senet_giris_hareketi();

create table if not exists public._yedek_cek_giris_1387 (hareket_id integer primary key, cek_senet_id integer,
                                                         zaman timestamptz default now());

with eklenen as (
    insert into public.cek_senet_hareket
        (cek_senet_id, islem, tarih, eski_durum, yeni_durum, taraf_id, aciklama, belge_no, ekleyen)
    select c.id, 130, coalesce(c.tarih::date, current_date), 0, 10, c.taraf_id,
           case when c.tur = 2 then 'Yeni senet' else 'Yeni çek' end, left(coalesce(c.makbuz_no, ''), 30),
           coalesce(c.ekleyen, 0)
      from public.cek_senet c
     where c.aktarim_kaynak is null
       and not exists (select 1 from public.cek_senet_hareket h where h.cek_senet_id = c.id)
    returning id, cek_senet_id
)
insert into public._yedek_cek_giris_1387 (hareket_id, cek_senet_id) select id, cek_senet_id from eklenen;
