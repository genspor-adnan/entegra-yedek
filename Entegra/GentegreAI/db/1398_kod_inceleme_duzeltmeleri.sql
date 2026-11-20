-- 1398: kod inceleme düzeltmeleri (20.11.2026) - rapor gönderim kuyruğu ve çek / senet giriş hareketi tarihi.
--
-- 1) GÖNDERİM KUYRUĞU: işçi her turda "zamanı gelen en eski N satırı" alıyordu; BORÇ BEKLEYEN satır eski plan
--    zamanıyla hep başta kalıyor, borçlu rapor sayısı N'yi geçince yeni raporlara sıra gelmiyordu. Yeni kolon
--    sonraki_deneme: borç bekleyen satır birkaç dakika sonraya ertelenir, kuyruk buna göre sıralanır. planlanan
--    DEĞİŞMEZ (listede "şu saatte gidecekti" olarak görünür).
--
-- 2) ÇEK / SENET GİRİŞ HAREKETİ (1387): giriş satırı kıymetin tarihini (kullanıcının yazdığı tarih) alıyordu. İşlem
--    kuralı "bugünden ileri olamaz, son hareketten önce olamaz" olduğu için İLERİ tarihli girilen kıymette hiçbir
--    işlem yapılamıyordu. Giriş hareketinin tarihi bugünü geçemez.
--    Onarım yalnız KANITLANABİLİR hatalı satır: tetiğin yazdığı giriş (130) satırı, tarihi bugünden ileri. Eski değer
--    _yedek_cek_giris_tarih_1398'de (geri dönüş: tarihi oradan geri yazın).
\set ON_ERROR_STOP on

begin;

alter table public.radyoloji_rapor_gonderim add column if not exists sonraki_deneme timestamptz;
comment on column public.radyoloji_rapor_gonderim.sonraki_deneme is
    'İşçinin bu satırı yeniden deneyeceği en erken an (borç bekleyende ertelenir). Boşsa planlanan geçerli.';
drop index if exists public.ix_rrg_bekleyen;
create index if not exists ix_rrg_bekleyen on public.radyoloji_rapor_gonderim ((coalesce(sonraki_deneme, planlanan)))
    where durum in (1, 2);

create or replace function public.fn_cek_senet_giris_hareketi() returns trigger
language plpgsql as $$
begin
    if new.aktarim_kaynak is not null then return new; end if;
    insert into public.cek_senet_hareket
        (cek_senet_id, islem, tarih, eski_durum, yeni_durum, taraf_id, aciklama, belge_no, ekleyen)
    values (new.id, 130, least(coalesce(new.tarih::date, current_date), current_date), 0, new.durum, new.taraf_id,
            case when new.tur = 2 then 'Yeni senet' else 'Yeni çek' end,
            left(coalesce(new.makbuz_no, ''), 30), coalesce(new.ekleyen, 0));
    return new;
end $$;

create table if not exists public._yedek_cek_giris_tarih_1398 (hareket_id integer primary key, eski_tarih timestamp,
                                                               zaman timestamptz default now());
with hatali as (
    select h.id, h.tarih from public.cek_senet_hareket h
     where h.islem = 130 and h.tarih::date > current_date
), yedek as (
    insert into public._yedek_cek_giris_tarih_1398 (hareket_id, eski_tarih)
    select id, tarih from hatali on conflict (hareket_id) do nothing
)
update public.cek_senet_hareket h set tarih = current_date from hatali x where h.id = x.id;

commit;
