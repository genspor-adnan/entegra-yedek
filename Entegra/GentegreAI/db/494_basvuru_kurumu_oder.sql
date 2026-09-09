-- =====================================================================
--  494_basvuru_kurumu_oder.sql
--  Başvuru tetiği "Kurumu Öder" türünü tanır (493).
--
--  Hata: tetik türleri 1 Özel / 2 ÖSS / geri kalan SGK diye üçe ayırıyordu;
--  yeni tür 4 SGK dalına düşüp "devredilen kurum seçilmeli" diyordu -
--  Kurumu Öder başvurusu kaydedilemiyor, dolayısıyla tahakkuka da
--  dönüştürülemiyordu.
-- =====================================================================

CREATE OR REPLACE FUNCTION public.tg_belge_basvuru_sozlesme()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
declare
    v_tur      smallint;
    v_tarih    date;
    v_alt      smallint;
    v_sozlesme public.kurum_sozlesme%rowtype;
    v_aktif    integer;
begin
    if new.odeyen_kurum_id is null then
        new.sozlesme_id := null;
        new.alt_kurum   := 0;
        new.sgk_kullan  := 1;
        return new;
    end if;

    select tur into v_tur from public.taraf_kurum where id = new.odeyen_kurum_id;
    if v_tur is null then
        raise exception 'Ödeyen taraf bir KURUM değil (taraf_kurum kaydı yok).';
    end if;

    select coalesce(b.belge_tarihi::date, current_date) into v_tarih
      from public.belge b where b.id = new.id;
    v_tarih := coalesce(v_tarih, current_date);

    -- 1) SÖZLEŞME: verilmediyse tek olanı al; birden fazlaysa SEÇTİR.
    if new.sozlesme_id is null then
        new.sozlesme_id := public.fn_kurum_sozlesme_sec(new.odeyen_kurum_id, v_tarih);
    end if;

    -- ÖZEL (ÜCRETLİ) KURUM: sözleşmesiz de olur (485). Fiyat kurumun satış
    --   fiyat listesinden gelir; paylaşılacak bir pay yoktur, tutarın tamamı
    --   hastanındır (rota 1).
    if new.sozlesme_id is null and v_tur = 1 then
        new.alt_kurum  := 0;
        new.sgk_kullan := 1;
        return new;
    end if;

    if new.sozlesme_id is null then
        select count(*) into v_aktif
          from public.kurum_sozlesme s
         where s.kurum_id = new.odeyen_kurum_id and s.durum = 1
           and (s.baslangic is null or s.baslangic <= v_tarih)
           and (s.bitis     is null or s.bitis     >= v_tarih);
        if v_aktif = 0 then
            raise exception 'Bu kurumun yürürlükte sözleşmesi yok - önce kurum kartından sözleşme tanımlayın.';
        end if;
        raise exception 'Kurumun % sözleşmesi var - hangisinin geçerli olduğunu seçin.', v_aktif;
    end if;

    select * into v_sozlesme from public.kurum_sozlesme where id = new.sozlesme_id;
    if v_sozlesme.kurum_id <> new.odeyen_kurum_id then
        raise exception 'Seçilen sözleşme bu ödeyen kuruma ait değil.';
    end if;

    -- 2) ALT KURUM: ÖSS'de sözleşme SABİTLER (poliçe türü anlaşmanın kendisi),
    --    SGK'da hastadan gelir ve seçilebilir.
    if v_tur = 1 then
        new.alt_kurum := 0;
    elsif v_tur = 4 then
        -- KURUMU ÖDER (493): poliçe/devredilen kurum kavramı yok; tamamını
        --   kurum karşılar, hastadan tahsilat yapılmaz.
        new.alt_kurum := 0;
    elsif v_tur = 2 then
        new.alt_kurum := v_sozlesme.alt_kurum;
    else
        if coalesce(new.alt_kurum, 0) = 0 then
            select hk.alt_kurum into v_alt
              from public.taraf_hasta_kurum hk
              join public.belge b on b.id = new.id
             where hk.hasta_id = b.taraf_id and hk.kurum_id = new.odeyen_kurum_id
               and hk.aktif = 1 and hk.alt_kurum <> 0
             limit 1;
            new.alt_kurum := coalesce(v_alt, 0);
        end if;
        if coalesce(new.alt_kurum, 0) = 0 then
            raise exception 'SGK başvurusunda devredilen kurum (SSK/Bağ-Kur/ES/Yeşil Kart) seçilmeli.';
        end if;
        if (new.alt_kurum / 100) <> 3 then
            raise exception 'Devredilen kurum (%) SGK kod uzayında değil.', new.alt_kurum;
        end if;
    end if;

    -- 3) SGK KULLANILSIN yalnız KARMA'da kapatılabilir: ÖSS'de SGK zaten yok,
    --    TSS ve saf SGK'da SGK payı anlaşmanın kendisidir.
    if coalesce(new.alt_kurum, 0) <> 203 then
        new.sgk_kullan := 1;
    end if;
    return new;
end $function$;
