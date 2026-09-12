-- =====================================================================
--  601_sgk_tarife_sut_listesi.sql
--  SAF SGK'DA TARİFE = SUT LİSTESİ + SGK SÖZLEŞMESİNDE SUT LİSTESİ ZORUNLU.
--
--  Kullanıcı raporu: "başvuru ekliyorum, kurum SGK seçtim, + ile ücret
--  ekleyeceğim ama SUT fiyatı değil özel fiyat geldi… altında katılım payı
--  da olması gerekir."
--
--  TEŞHİS (başvuru 85 · kurum 4968 SGK · sözleşme 433 "SGK-ES"):
--    Rota doğru çözülüyordu (fn_dagilim_rota -> 5 = SGK). Sorun sözleşmenin
--    KENDİSİNDEYDİ: `fiyat_listesi_id` ve `sgk_fiyat_listesi_id` ikisi de
--    boştu. Kurumun üç sözleşmesinden yalnız SGK-SSK (id 3) SUT listesine
--    bağlıydı; SGK-BAĞKUR (432) ve SGK-ES (433) bağlı değildi. Sonuç zinciri:
--
--      1. Sözleşmede tarife listesi yok  -> fn_belge_varsayilan_liste 3./4.
--         maddeye düşüyor -> hastanın/kurumun ÖZEL listesi geliyor.
--      2. sgk_fiyat_listesi_id yok       -> SutBedeliAsync null dönüyor,
--         SUT bedeli kutusu boş kalıyor.
--      3. SUT bedeli yok                 -> katılım payı SUT kodu eşleşmesi
--         üzerinden doğduğu için (595) 0 kalıyor.
--
--    Yani üç şikayet de tek kökten çıkıyor. Katılım payı altyapısı (kova 5,
--    emekli muafiyeti, `basvuru.sgk_katilim_payi` = 100 TL, kod listesi
--    520030/520031/520034) zaten kurulu ve çalışır durumda.
--
--  KARAR (kullanıcı): saf SGK'da (rota 5) satırın BİRİM FİYATI SUT olsun.
--    Hastane SGK'ya SUT üzerinden fatura kestiği için tarife = SUT'tur.
--    Kayıt tarafı bunu zaten yapıyordu (fn_belge_satir_dagit rota 5 dalı:
--    `tutar = SUT + ek katkı`, 599); eksik olan EKRANDA ilk gelen fiyattı -
--    kullanıcı özel fiyatı görüp kaydedince rakam altından değişiyordu.
--    Artık liste en baştan SUT olarak seçiliyor, ekran ile kayıt aynı sayıyı
--    gösteriyor.
--
--  Bu dosya üç şey yapar:
--    1) VERİ ONARIMI - SUT listesi boş kalmış SGK sözleşmelerini bağlar.
--    2) fn_belge_varsayilan_liste - saf SGK'da tarife listesi yazılmamışsa
--       SUT listesine düşer (sözleşmede AÇIKÇA yazılmış tarife hep kazanır).
--    3) tg_kurum_sozlesme_kontrol - SGK kurumunda SUT listesi zorunlu olur;
--       aynı boşluk bir daha sessizce oluşmasın.
--
--  Sıra önemli: önce veri onarımı, sonra tetik. Ters sırada mevcut boş
--  kayıtlar bir daha GÜNCELLENEMEZ hale gelirdi.
-- =====================================================================

-- ---------------------------------------------------------------------
--  1) VERİ ONARIMI
--
--  Yalnız PROVABLY YANLIŞ satır: kurum türü SGK (3) olduğu halde SUT
--  listesi boş olan sözleşme. SGK sözleşmesi SUT listesiz çalışamaz -
--  bu bir tercih değil, eksik kayıttır.
--
--  Hedef liste otomatik seçilir ve YALNIZ TEK ADAY varsa yazılır: yönü
--  satış (2), tarife tipi SUT (3), aktif. Birden fazla SUT listesi olan
--  kurulumda hangisinin geçerli olduğu bilinemez - orada dokunulmaz,
--  kullanıcı sözleşme kartından seçsin (2. adımdaki tetik zaten zorlar).
-- ---------------------------------------------------------------------
do $$
declare
    v_liste  integer;
    v_aday   integer;
    v_eksik  integer;
    v_yazan  integer := 0;
begin
    select count(*) into v_eksik
      from public.kurum_sozlesme s
      join public.taraf_kurum k on k.id = s.kurum_id
     where k.tur = 3 and s.sgk_fiyat_listesi_id is null;

    if v_eksik = 0 then
        raise notice '601/1: SUT listesi eksik SGK sozlesmesi yok - onarim gerekmedi.';
        return;
    end if;

    select count(*), min(l.id) into v_aday, v_liste
      from public.fiyat_listesi l
     where l.yon = 2 and coalesce(l.tarife_tipi, 0) = 3 and l.durum = 1;

    if v_aday <> 1 then
        raise notice '601/1: % SGK sozlesmesinde SUT listesi bos ama % aday SUT '
                     'listesi var - otomatik secim yapilmadi, sozlesme kartindan '
                     'secilmeli.', v_eksik, v_aday;
        return;
    end if;

    -- Yedek: onarımdan ÖNCEKİ hali saklanır (geri alınabilsin).
    create table if not exists public.yedek_601_sozlesme_sut (
        id                   integer primary key,
        kurum_id             integer,
        ad                   varchar(120),
        sgk_fiyat_listesi_id integer,
        yedek_tarihi         timestamp not null default now());

    insert into public.yedek_601_sozlesme_sut (id, kurum_id, ad, sgk_fiyat_listesi_id)
    select s.id, s.kurum_id, s.ad, s.sgk_fiyat_listesi_id
      from public.kurum_sozlesme s
      join public.taraf_kurum k on k.id = s.kurum_id
     where k.tur = 3 and s.sgk_fiyat_listesi_id is null
    on conflict (id) do nothing;

    update public.kurum_sozlesme s
       set sgk_fiyat_listesi_id = v_liste
      from public.taraf_kurum k
     where k.id = s.kurum_id
       and k.tur = 3
       and s.sgk_fiyat_listesi_id is null;
    get diagnostics v_yazan = row_count;

    raise notice '601/1: % SGK sozlesmesine SUT listesi % baglandi (yedek: '
                 'yedek_601_sozlesme_sut).', v_yazan, v_liste;
end $$;


-- ---------------------------------------------------------------------
--  2) VARSAYILAN LİSTE: SAF SGK'DA TARİFE = SUT
--
--  Gövde 468'den alındı; EKLENEN yalnız 2b maddesi. Sıralama kasıtlı:
--
--    1  Kampanya listesi          (anlaşma her şeyi tayin eder)
--    2  Sözleşme tarife listesi   (AÇIKÇA yazılmışsa o kazanır - hastane
--                                  SGK işini kendi tarifesiyle görmek
--                                  istiyorsa bunu yazarak söyler)
--    2b SAF SGK ise SUT listesi   <-- 601, yeni
--    3  Ödeyen kurumun listesi
--    4  Cari / yön varsayılanı
--
--  2b yalnız kurum türü SGK (3) iken devreye girer. TSS/Karma'da (tür 2)
--  tarife ile SUT AYRI kalmalıdır: orada SUT SGK'nın payını, tarife de
--  sigortanın üstlendiği farkı belirler - ikisini eşitlemek sigortanın
--  payını sıfırlardı.
-- ---------------------------------------------------------------------
create or replace function public.fn_belge_varsayilan_liste(
    p_tur integer,
    p_taraf_id integer,
    p_tarih date default current_date,
    p_odeyen_kurum_id integer default null,
    p_sozlesme_id integer default null)
returns integer
language sql stable as $function$
    select coalesce(
        -- 1) KAMPANYA LİSTESİ: anlaşma hem baz listeyi hem indirimi tayin eder.
        (select fl.id
           from public.kampanya k
           join public.fiyat_listesi fl on fl.id = k.fiyat_listesi_id
          where k.id = public.fn_taraf_kampanya(
                           case when coalesce(p_odeyen_kurum_id, 0) > 0
                                then p_odeyen_kurum_id else p_taraf_id end,
                           p_tarih, p_sozlesme_id)
            and fl.durum = 1
            and fl.yon = public.fn_belge_yon(p_tur)),

        -- 2) SÖZLEŞME TARİFE LİSTESİ (468): anlaşmada yazan liste.
        (select fl.id
           from public.kurum_sozlesme s
           join public.fiyat_listesi fl on fl.id = s.fiyat_listesi_id
          where s.id = coalesce(p_sozlesme_id,
                                public.fn_kurum_sozlesme_sec(p_odeyen_kurum_id, p_tarih))
            and s.durum = 1
            and (s.baslangic is null or s.baslangic <= p_tarih)
            and (s.bitis is null or s.bitis >= p_tarih)
            and fl.durum = 1
            and fl.yon = public.fn_belge_yon(p_tur)),

        -- 2b) SAF SGK'DA TARİFE = SUT (601): sözleşmede ayrı bir tarife
        --     listesi yazılmamışsa SGK hastasının fiyatı SUT'tur. Yoksa
        --     zincir aşağıdaki maddelere düşüyor ve ekranda hastanenin ÖZEL
        --     fiyatı çıkıyordu; kayıtta tutar SUT'a döndüğü için (599) ekran
        --     ile kayıt farklı rakam gösteriyordu.
        (select fl.id
           from public.kurum_sozlesme s
           join public.taraf_kurum k on k.id = s.kurum_id
           join public.fiyat_listesi fl on fl.id = s.sgk_fiyat_listesi_id
          where s.id = coalesce(p_sozlesme_id,
                                public.fn_kurum_sozlesme_sec(p_odeyen_kurum_id, p_tarih))
            and k.tur = 3
            and s.durum = 1
            and (s.baslangic is null or s.baslangic <= p_tarih)
            and (s.bitis is null or s.bitis >= p_tarih)
            and fl.durum = 1
            and fl.yon = public.fn_belge_yon(p_tur)),

        -- 3) Ödeyen kurum bir caridir: listesi cari kuralından.
        case when coalesce(p_odeyen_kurum_id, 0) > 0
             then public.fn_cari_fiyat_listesi(p_odeyen_kurum_id,
                                               public.fn_belge_yon(p_tur), p_tarih)
        end,

        -- 4) Carinin kendi listesi / yönün varsayılanı.
        public.fn_cari_fiyat_listesi(p_taraf_id, public.fn_belge_yon(p_tur), p_tarih));
$function$;

comment on function public.fn_belge_varsayilan_liste(integer, integer, date, integer, integer) is
  'Belgenin varsayilan fiyat listesi: kampanya > sozlesme tarifesi > SAF SGK ise '
  'SUT listesi (601) > odeyen kurumun listesi > carinin listesi.';


-- ---------------------------------------------------------------------
--  3) SGK SÖZLEŞMESİNDE SUT LİSTESİ ZORUNLU
--
--  Gövde 468'den alındı; EKLENEN yalnız son kontrol. SGK sözleşmesi SUT
--  listesiz kaydedilebildiği için başvuru 85 sessizce özel fiyatla açıldı -
--  hiçbir yerde uyarı çıkmamıştı. Kural artık kaydın kendisinde.
--
--  Mesaj P0001 ile döner; VeriHatasi.Cevir bunu is kuralina cevirip
--  kullaniciya oldugu gibi gosterir (api/src/Gentegre.Veri/VeriHatasi.cs).
-- ---------------------------------------------------------------------
create or replace function public.tg_kurum_sozlesme_kontrol()
returns trigger language plpgsql as $$
declare v_tur smallint;
begin
    select tur into v_tur from public.taraf_kurum where id = new.kurum_id;
    if v_tur is null then
        raise exception 'Sözleşme açılan taraf bir KURUM değil (taraf_kurum kaydı yok).';
    end if;

    if new.alt_kurum <> 0 and (new.alt_kurum / 100) <> v_tur then
        raise exception 'Alt kurum (%) bu kurumun türüne (%) uymuyor.',
              new.alt_kurum, v_tur;
    end if;

    -- ÖSS sözleşmesi alt kurumsuz olamaz: rota (ÖSS/TSS/Karma) buradan çıkar.
    if v_tur = 2 and new.alt_kurum = 0 then
        raise exception 'ÖSS sözleşmesinde poliçe türü (ÖSS/TSS/Karma) seçilmeli.';
    end if;

    -- SGK payı olan sözleşmede SGK carisi zorunlu; SGK kurumunda kendisidir.
    if new.sgk_kurum_id is null then
        if v_tur = 3 then new.sgk_kurum_id := new.kurum_id;
        elsif new.alt_kurum in (202, 203) then
            raise exception 'TSS/Karma sözleşmesinde SGK carisi seçilmeli.';
        end if;
    end if;

    if new.bitis is not null and new.baslangic is not null
       and new.bitis < new.baslangic then
        raise exception 'Sözleşme bitişi başlangıcından önce olamaz.';
    end if;

    -- SUT LİSTESİ ZORUNLU (601): SGK sözleşmesinde hem SGK'nın ödediği bedel
    --   hem hastanın katılım payı SUT listesinden çıkar. Liste seçilmezse
    --   başvuru sessizce hastanenin özel fiyatıyla açılır ve katılım payı
    --   hiç doğmaz - kullanıcı bunu ancak faturada fark eder.
    if v_tur = 3 and new.sgk_fiyat_listesi_id is null then
        raise exception 'SGK sözleşmesinde SUT listesi seçilmeli: SGK''nın ödediği '
                        'bedel ve hastanın katılım payı bu listeden hesaplanır.';
    end if;

    return new;
end $$;

do $$
begin
    raise notice '601 tamam: SUT listesiz SGK sozlesmesi kaldi mi -> %',
        (select count(*) from public.kurum_sozlesme s
           join public.taraf_kurum k on k.id = s.kurum_id
          where k.tur = 3 and s.sgk_fiyat_listesi_id is null);
end $$;
