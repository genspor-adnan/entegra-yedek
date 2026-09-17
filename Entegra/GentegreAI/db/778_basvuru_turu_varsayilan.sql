-- ============================================================================
--  Gentegre AI — BAŞVURU TÜRÜ: VARSAYILAN POLİKLİNİK, BOŞ KALMAZ
--  778_basvuru_turu_varsayilan.sql
--
--  Kullanıcı: *"başvuru türü varsayılan poliklinik olacak boş geçilemeyecek
--  (muayene modülü kullanılıyorsa)"*.
--
--  ============ NEDEN SUNUCUDA DA BİR KURAL VAR ========================
--  Ekran türü zorunlu alan olarak sorar (kayıt kabul memuru boş bırakamaz),
--  ama başvuru satırı ekrandan başka yollarla da doğuyor: dış kurum numune
--  başvurusu, diş/FTR akışları, toplu API çağrıları. Kural yalnız ekranda
--  dursaydı o yollardan türsüz başvuru girmeye devam ederdi ve "poliklinik
--  başvurusu sayısı" hiçbir zaman güvenilir olmazdı.
--
--  ============ REDDETMEK DEĞİL, VARSAYILAN DOLDURMAK ==================
--  Tetik boş türü REDDETMİYOR, POLİKLİNİK (1) yazıyor. Gerekçe: reddetmek
--  ekranda zaten yakalanan bir durumu ikinci kez, ama bu sefer anlaşılmaz bir
--  yerde (kaydın ortasında) patlatırdı - üstelik türü hiç sorulmayan eski
--  kayıtların güncellenmesini de kilitlerdi. "Boş geçilemez" uyarısını
--  KULLANICIYA ekran verir; buradaki tetik son çare olarak kaydın anlamsız
--  (türsüz) doğmasını engeller.
--
--  ============ YALNIZ MUAYENE MODÜLÜ AÇIKKEN =========================
--  Poliklinik varsayımı ancak poliklinik yapan kurumda doğrudur. Muayene
--  modülü kapalı bir kurulumda (ör. yalnız laboratuvar / görüntüleme veren
--  kurum) başvuru türü "Laboratuvar / Görüntüleme"dir ve o değeri ekran
--  kendisi yazar - oraya "Poliklinik" damgalamak veriyi bozardı. Modül
--  şubeye göre çözülüyor (`fn_kurum_modul_acik`): çok şubeli kurulumda bir
--  şube poliklinik, ötekisi yalnız görüntüleme olabilir.
--
--  ============ GEÇMİŞ KAYITLARA DOKUNULMUYOR =========================
--  Var olan türsüz başvurulara toplu "Poliklinik" yazmak, o gün ne olduğunu
--  bilmediğimiz kayıtlara veri uydurmak olurdu (kimi acil, kimi günübirlik
--  olabilir). Eski satırlar boş kalır; biri düzenlenip kaydedilirse tetik o
--  an devreye girer.
-- ============================================================================
\set ON_ERROR_STOP on

create or replace function public.tg_belge_basvuru_tur()
returns trigger
language plpgsql
as $$
declare
    v_sube integer;
begin
    if new.basvuru_turu is not null then
        return new;
    end if;

    -- Modül şubeye göre açık: başvurunun şubesi belgenin şubesidir.
    select b.sube_id into v_sube from public.belge b where b.id = new.id;

    if public.fn_kurum_modul_acik('muayene', coalesce(v_sube, 0)) then
        new.basvuru_turu := 1;          -- basvuru.tur 1 = Poliklinik (298)
    end if;

    return new;
end $$;

comment on function public.tg_belge_basvuru_tur() is
  'Turu bos basvuruya varsayilan Poliklinik (1) yazar - yalniz muayene modulu acik subede (778).';

drop trigger if exists tg_belge_basvuru_tur on public.belge_basvuru;

-- INSERT'te her satir, UPDATE'te yalniz tur kolonuna dokunan istek: turu
--   degistirmeyen bir guncelleme (or. provizyon alanlari) eski bos degeri
--   oldugu gibi birakir - gecmise donuk damga vurulmaz.
create trigger tg_belge_basvuru_tur
    before insert or update of basvuru_turu on public.belge_basvuru
    for each row execute function public.tg_belge_basvuru_tur();

do $$
declare v_turusuz int;
begin
    select count(*) into v_turusuz from public.belge_basvuru
     where basvuru_turu is null;
    raise notice '778 tamam: tur tetigi kuruldu. Mevcut turu bos basvuru: % '
                 '(bilerek dokunulmadi).', v_turusuz;
end $$;
