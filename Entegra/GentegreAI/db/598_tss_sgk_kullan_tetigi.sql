-- =====================================================================
--  598_tss_sgk_kullan_tetigi.sql
--  BAŞVURU TETİĞİ: `sgk_kullan` TSS'de de korunur.
--
--  597'de TSS'de "SGK kullanılmasın" hakkı açıldı (rota 3 -> 2), ama başvuru
--  tetiği işareti TSS'de zorla 1'e çekiyordu: kullanıcı kutuyu kaldırıyor,
--  kayıtta geri işaretleniyordu. Tetik artık TSS (202) ve KARMA (203) için
--  kullanıcının seçimini bırakır; ÖSS ve saf SGK'da (orada kutu çizilmez)
--  eskisi gibi 1'e çeker.
--
--  Gövde 494'ten alındı; değişen YALNIZ 3. kural.
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

    -- 3) SGK KULLANILSIN: TSS (202) ve KARMA'da (203) kapatılabilir (598,
    --    kullanıcı: "hasta SGK kullanılmasın deme hakkına sahip… TSS'de SGK
    --    kullanılmasın check'i ekle"). ÖSS'de SGK zaten yok; saf SGK
    --    hastasında karşılığı ödeyen kurumu Özel seçmektir - o durumlarda
    --    işaret zorla 1'e çekilir, yoksa ekranda görünmeyen bir seçim belgede
    --    kalır ve rotayı sessizce değiştirirdi.
    if coalesce(new.alt_kurum, 0) not in (202, 203) then
        new.sgk_kullan := 1;
    end if;
    return new;
end $function$;
