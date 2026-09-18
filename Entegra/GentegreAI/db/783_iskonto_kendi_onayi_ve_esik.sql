-- ============================================================================
--  Gentegre AI — İSKONTODA İKİ KURAL: KENDİ ONAYI YOK · EŞİK ÜSTÜ ONAYSIZ GEÇMEZ
--  783_iskonto_kendi_onayi_ve_esik.sql
--
--  Kullanıcı (tasarım konuşması): *"iki kuralı yaz"*.
--
--  ============ 1) KENDİ TALEBİNİ ONAYLAYAMAZ =========================
--  İskonto talebi bir İMZADIR: "bu indirimi ben istedim, şu kişi uygun
--  buldu". İsteyenle onaylayan aynı kişi olunca imza kendi kendini onaylar
--  ve kayıt bir belge olmaktan çıkar. `iskonto_talep.isteyen_id` zaten
--  yazılıyordu; kural yalnızca kontrol edilmiyordu.
--
--  Yetki devri (`onay_vekalet`, 763) bu kuralı BOZMAZ: vekil BAŞKASININ
--  imzasını atar, kendi talebini değil.
--
--  ============ 2) EŞİK ÜSTÜ İSKONTO ONAYSIZ YAZILAMAZ ================
--  661'den beri `basvuru.iskonto` yetkisinin DEĞERİ bir tavandır: "bu rol en
--  çok %X iskonto yapabilir". Tavanı yeten kullanıcı talebi HİÇ AÇMADAN
--  indirimi uyguluyordu. Sonuç: tavanı %100 olan rol (ör. "İskonto
--  Onaylayanlar", 663) sınırsız indirimi tek başına, kayıtsız yapabiliyordu -
--  onay zinciri (754: birim · mali · üst) o kişi için hiç işlemiyordu.
--
--  Artık kurumun belirlediği **onay eşiği** üstündeki her iskonto, tavan ne
--  olursa olsun, ONAYLANMIŞ bir talepten gelmek zorunda. Onaylanan satırı
--  `iskonto_kilit = 1` ile `fn_iskonto_talep_karar` yazar (662) - kilit bu
--  kuralın da anahtarı: kilitli satır zincirden geçmiştir.
--
--  Eşik AYAR (`basvuru.iskonto_onay_esik`), koda gömülü değil: kurum %5 de
--  diyebilir %25 de. 0 yazılırsa kural kapanır (eski davranış).
--  Varsayılan **%10** - 754'teki "Mali İşler" basamağının eşiğiyle aynı:
--  mali işlerin bakması gereken oran, kimsenin tek başına geçemeyeceği
--  orandır.
--
--  KURAL YALNIZ BAŞVURUDA (tur 19 · tipi 30): ERP satış/alış belgesinde
--  iskonto ticari pazarlıktır, onay zinciri yoktur.
-- ============================================================================
\set ON_ERROR_STOP on

-- ------------------------------------------------------------- ayar -------
-- Ayarlar `referans` tablosunda (AyarDeposu): anahtar + deger + tip.
insert into public.referans (anahtar, deger, tip, kapsam, aciklama)
select 'basvuru.iskonto_onay_esik', '10', 'sayi', 'firma',
       'Bu oranin (%) USTUNDEKI iskonto, yetki tavani ne olursa olsun onayli '
       || 'talep ister (783). 0 = kural kapali.'
 where not exists (select 1 from public.referans where anahtar = 'basvuru.iskonto_onay_esik');

-- --------------------------------------------- 1) kendi talebini onaylama --
-- Fonksiyonun geri kalani 673'teki halidir; yalnizca basa iki kontrol
--   eklendi (govde kopyalanarak - migration'lar duzenlenmez, yenisi yazilir).
create or replace function public.fn_iskonto_talep_karar(
    p_talep_id integer, p_onay smallint, p_oran numeric,
    p_not character varying, p_kullanici integer)
returns void
language plpgsql
as $function$
declare
  v_durum   smallint;
  v_istek   numeric(9,4);
  v_isteyen integer;
  v_oran    numeric(9,4);
  v_carpan  numeric;
begin
    select durum, oran, isteyen_id into v_durum, v_istek, v_isteyen
      from public.iskonto_talep where id = p_talep_id;
    if v_durum is null then
        raise exception 'İskonto talebi bulunamadı: %', p_talep_id using errcode = 'GK404';
    end if;
    if v_durum <> 0 then
        raise exception 'Talep zaten sonuçlanmış (durum %).', v_durum using errcode = 'GK422';
    end if;
    -- KENDİ TALEBİNİ ONAYLAYAMAZ (783). Ret de onay da aynı kural: kendi
    --   talebini reddetmek zararsız görünür ama zinciri kendi üstünden
    --   kaldırmanın yolu olurdu.
    if v_isteyen = p_kullanici then
        raise exception 'Kendi iskonto talebinizi onaylayamaz ya da reddedemezsiniz.'
              using errcode = 'GK422';
    end if;

    if p_onay = 2 then
        update public.iskonto_talep
           set durum = 2, onay_id = p_kullanici, onay_ts = now()::timestamp,
               onaylanan_oran = 0, karar_notu = coalesce(p_not, ''),
               degistiren = p_kullanici, degistirme_tarihi = now()::timestamp
         where id = p_talep_id;
        return;
    end if;

    v_oran := least(coalesce(p_oran, 0), v_istek);
    if not (v_oran > 0) then
        raise exception 'Onaylanan oran sıfırdan büyük olmalı.' using errcode = 'GK422';
    end if;
    v_carpan := case when v_istek > 0 then v_oran / v_istek else 1 end;

    update public.belge_satir s
       set iskonto_kilit = 0
      from public.iskonto_talep_satir ts
     where ts.talep_id = p_talep_id and s.id = ts.belge_satir_id;

    update public.belge_satir s
       set iskonto = round(
             case when coalesce(ts.oran, 0) > 0 then ts.oran else v_istek end
             * v_carpan, 4),
           iskonto2 = 0,
           iskonto_kilit = 1
      from public.iskonto_talep_satir ts
     where ts.talep_id = p_talep_id and s.id = ts.belge_satir_id;

    update public.iskonto_talep
       set durum = 1, onay_id = p_kullanici, onay_ts = now()::timestamp,
           onaylanan_oran = v_oran, karar_notu = coalesce(p_not, ''),
           degistiren = p_kullanici, degistirme_tarihi = now()::timestamp
     where id = p_talep_id;
end $function$;

comment on function public.fn_iskonto_talep_karar is
  '662/673/783: iskonto talebinin karari - orani satirlara yazan TEK yer. '
  'Isteyen kendi talebini onaylayamaz (783).';

-- ------------------------------------------------ 2) esik ustu onay sarti --
create or replace function public.tg_belge_satir_iskonto_esik()
returns trigger
language plpgsql
as $$
declare
    v_esik  numeric;
    v_tur   smallint;
    v_tipi  smallint;
    v_yazi  text;
begin
    if coalesce(new.iskonto, 0) <= 0 then return new; end if;
    -- ONAYDAN GELEN SATIR: `fn_iskonto_talep_karar` kilitle yazar; zincirden
    --   gectigi icin esik kontrolu ona uygulanmaz.
    if coalesce(new.iskonto_kilit, 0) = 1 then return new; end if;

    select coalesce(nullif(deger, '')::numeric, 0) into v_esik
      from public.referans where anahtar = 'basvuru.iskonto_onay_esik';
    if coalesce(v_esik, 0) <= 0 then return new; end if;      -- kural kapali

    select b.tur, b.tipi into v_tur, v_tipi
      from public.belge b where b.id = new.belge_id;
    -- YALNIZ BASVURU (19/30): ERP belgesinde iskonto ticari pazarliktir.
    if coalesce(v_tur, 0) <> 19 or coalesce(v_tipi, 0) <> 30 then return new; end if;

    if new.iskonto > v_esik then
        -- Metin ONCEDEN kurulur: plpgsql'de "%" bicim belirtecidir, yuzde
        --   isaretini mesaja gommek kacis kalabaligi yaratiyor ve bir kez
        --   "%10s" gibi bozuk cikti verdi.
        v_yazi := '%' || trim(to_char(v_esik, 'FM999990.##'));
        raise exception '% üstü iskonto onay ister (en çok % doğrudan '
                        'uygulanabilir); satırı seçip "İskonto Onayı İste" ile '
                        'gönderin.', v_yazi, v_yazi using errcode = 'GK422';
    end if;
    return new;
end $$;

comment on function public.tg_belge_satir_iskonto_esik() is
  'Esik ustu iskontoyu onaysiz yazdirmaz (783): yetki tavani zinciri '
  'atlatamaz. Onayli satir iskonto_kilit=1 ile gelir ve muaftir.';

drop trigger if exists tg_belge_satir_iskonto_esik on public.belge_satir;

create trigger tg_belge_satir_iskonto_esik
    before insert or update of iskonto on public.belge_satir
    for each row execute function public.tg_belge_satir_iskonto_esik();

do $$
declare v_esik text; v_asan int;
begin
    select deger into v_esik from public.referans where anahtar = 'basvuru.iskonto_onay_esik';
    select count(*) into v_asan
      from public.belge_satir s join public.belge b on b.id = s.belge_id
     where b.tur = 19 and b.tipi = 30 and coalesce(s.iskonto_kilit, 0) <> 1
       and s.iskonto > coalesce(nullif(v_esik, '')::numeric, 0);
    -- GECMISE DOKUNULMUYOR: var olan satirlar oldugu gibi kalir (tetik yalniz
    --   YENI yazimda calisir). Sayi yalnizca haberdir.
    raise notice '783 tamam: esik yuzde %. Gecmiste esigi asan onaysiz satir: % '
                 '(dokunulmadi).', v_esik, v_asan;
end $$;
