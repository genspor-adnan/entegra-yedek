-- =====================================================================
-- 799 - TELERADYOLOJI DURUM ZAMAN DAMGALARI
--
-- 798 kartinda `okuma_bas`, `teslim_zamani` ve `teslim_durum` SALT OKUNUR
-- ("tetik yaziyor") isaretlendi - ama 797'deki tetik yalniz `onay_zamani`yi
-- damgaliyordu. Yani bu uc alani YAZAN KIMSE YOKTU: ekran gosteremiyordu,
-- kullanici da giremiyordu. Damgayi ekrana actirmak yerine tetige eklemek
-- dogrusu: ayni sayi iki yerden hesaplanmasin.
--
-- OKUMA BASLANGICI SLA'NIN IKI PARCASINI AYIRIR: "sirada bekledi" ile
-- "radyolog okudu" suresi ancak bu damga varsa ayrilabilir - teleradyolojide
-- gecikmenin kimden kaynaklandigi sorusunun cevabi budur.
--
-- TESLIM DURUMU HL7/FHIR TESLIMINDEN ONCE DE ANLAMLI (faz 2): kanal
-- otomatiklesene kadar "durum 7'ye alindi = teslim edildi" gecerlidir; kanal
-- geldiginde damgayi o yazacak ve burasi yalniz elle teslimi damgalayacak.
-- =====================================================================

create or replace function public.tg_telerad_istek()
returns trigger
language plpgsql
as $function$
declare
    v_sla integer;
begin
    if tg_op = 'INSERT' then
        if coalesce(new.istek_no, '') = '' then
            new.istek_no := public.fn_telerad_istek_no(coalesce(new.cekim_zamani::date, current_date));
        end if;
        -- SOZLESME: verilmediyse kurumun O TARIHTE aktif sozlesmesi.
        if new.sozlesme_id is null then
            select s.id into new.sozlesme_id
              from public.telerad_sozlesme s
             where s.kurum_id = new.kurum_id and s.durum = 1
               and s.baslangic <= coalesce(new.cekim_zamani::date, current_date)
               and (s.bitis is null or s.bitis >= coalesce(new.cekim_zamani::date, current_date))
             order by s.baslangic desc limit 1;
        end if;
    end if;

    -- SLA SOZLESMEDEN KOPYALANIR (tetkik anindaki soz gecerlidir) ve
    --   GORUNTU GELDIGI AN baslar - istek acildigi an degil.
    if new.sla_dk = 0 and new.sozlesme_id is not null then
        select case new.oncelik when 3 then s.sla_acil_dk
                                when 2 then s.sla_oncelikli_dk
                                else s.sla_rutin_dk end
          into v_sla
          from public.telerad_sozlesme s where s.id = new.sozlesme_id;
        new.sla_dk := coalesce(v_sla, 0);
    end if;

    if new.gelis_zamani is not null and new.sla_dk > 0 then
        new.sla_bitis := new.gelis_zamani + make_interval(mins => new.sla_dk);
    end if;

    -- GORUNTU GELDI -> SIRADA. Durumu elle geriye almak serbest (ek goruntu
    --   istendi gibi); burada yalniz "bekliyordu, geldi" gecisi yazilir.
    if new.goruntu_durum = 1 and new.durum = 1 then new.durum := 2; end if;

    -- ATAMA -> durum en az "atandi"; atama kalkinca sıraya döner.
    if new.atanan_radyolog_id is not null and new.durum = 2 then new.durum := 3; end if;
    if new.atanan_radyolog_id is null and new.durum = 3 then new.durum := 2; end if;

    -- OKUMA BASLADI (799): durum 4'e gecen istegin okuma damgasi. ILK KEZ
    --   yazilir - istek okumaya birkac kez donebilir (ek goruntu istendi,
    --   taslaga geri alindi); baslangic o ilk andir, sonuncusu degil.
    if new.durum >= 4 and new.durum <> 8 and new.okuma_bas is null then
        new.okuma_bas := now()::timestamp;
    end if;

    -- ONAY: zaman damgasi + SLA asimi KARARI burada verilir (tek yer).
    if new.durum >= 6 and new.onay_zamani is null then
        new.onay_zamani := now()::timestamp;
    end if;
    if new.onay_zamani is not null and new.sla_bitis is not null then
        new.sla_asildi := case when new.onay_zamani > new.sla_bitis then 1 else 0 end;
    end if;

    -- TESLIM (799): durum 7 = is karsi tarafa gecti. Damga ve teslim durumu
    --   BURADA dogar; "teslim edildi" yazip zamani bos birakmak, hangi isin
    --   ne zaman cikti sorusunu cevapsiz birakiyordu.
    if new.durum = 7 then
        if new.teslim_zamani is null then new.teslim_zamani := now()::timestamp; end if;
        -- Teslim kanali hata yazdiysa (faz 2) ona dokunma.
        if new.teslim_durum = 0 then new.teslim_durum := 1; end if;
    end if;

    if tg_op = 'UPDATE' then new.degistirme_tarihi := now(); end if;
    return new;
end $function$;

comment on function public.tg_telerad_istek() is
  '797/799: istek numarasi, sozlesme cozumu, SLA kopyasi ve durum gecisleri '
  'TEK yerde - ekran, API ve ice aktarim ayni kurala carpsin. Zaman damgalari '
  '(okuma_bas, onay_zamani, teslim_zamani) ve teslim_durum burada yazilir; '
  'ekranda salt okunurdur.';

-- GECMIS SATIRLAR: onaylanmis/teslim edilmis ama damgasiz kalanlar yalniz
--   provably eksik olanlardir (damga null, durum ilerlemis). Teslim zamani
--   icin en iyi bilinen alt sinir onay zamanidir - uydurma "simdi" yazmak
--   gecmisi bugune tasirdi.
update public.telerad_istek
   set teslim_durum = 1
 where durum = 7 and teslim_durum = 0;

update public.telerad_istek
   set teslim_zamani = onay_zamani
 where durum = 7 and teslim_zamani is null and onay_zamani is not null;
