-- =====================================================================
-- 469 - BAŞVURUDA SÖZLEŞME, ALT KURUM VE "SGK KATKISI KULLANILSIN"
--
-- Kullanıcı: "başvuruda kurum SGK ise alt kurum seçmem gerekiyor",
-- "birden fazla sözleşme varsa hasta (başvuru) seçer",
-- "karma tipte hasta SGK kullanılmasın talebinde bulunabilir; default SGK
--  katkı check'i gelsin, istenirse kalksın - sgk kolonu 0 olur, tüm provizyon
--  TTB üzerinden olur".
--
-- ÜÇ ALAN, ÜÇ AYRI SORU:
--   sozlesme_id : hangi anlaşma (fiyat listesi, karşılama, SGK carisi)
--   alt_kurum   : ÖSS'de sözleşmeden GELİR, SGK'da hastadan gelir/seçilir
--                 (devredilen kurum: SSK/Bağ-Kur/ES/Yeşil Kart)
--   sgk_kullan  : yalnız KARMA poliçede anlamlı; kapatılırsa rota ÖSS'ye döner
--
-- SEÇİM SUNUCUDA ZORUNLU: tetik, tek sözleşmeyi kendiliğinden atar; birden
-- fazla varsa seçilmeden kayıt kabul edilmez. İstemciye bırakmak, sözleşmesiz
-- başvuru üretir ve fiyat sessizce yanlış listeden gelirdi.
--
-- TETİK BACKFILL'DEN SONRA kurulur: mevcut satırları güncellerken kendi
-- kuralına takılmasın (eski kayıtlarda alt kurum bilgisi hiç yok).
-- =====================================================================

alter table public.belge_basvuru
  add column if not exists sozlesme_id integer references public.kurum_sozlesme(id),
  add column if not exists alt_kurum   smallint not null default 0,
  add column if not exists sgk_kullan  smallint not null default 1;

comment on column public.belge_basvuru.sozlesme_id is
  'Bu başvuruda geçerli kurum sözleşmesi (469). Tek sözleşme varsa tetik atar.';
comment on column public.belge_basvuru.alt_kurum is
  'Poliçe türü / devredilen kurum (469, kod_liste kurum.alt_kurum).';
comment on column public.belge_basvuru.sgk_kullan is
  'Karma poliçede SGK katkısı kullanılsın mı (469). 0 ise sgk payı 0, provizyon TTB üzerinden.';

create index if not exists ix_belge_basvuru_sozlesme
    on public.belge_basvuru (sozlesme_id) where sozlesme_id is not null;

-- Hastanın kurum kaydında da VARSAYILAN sözleşme/alt kurum tutulur: aynı
--   hasta her başvuruda aynı Bağ-Kur'lu, aynı poliçeli gelir.
alter table public.taraf_hasta_kurum
  add column if not exists sozlesme_id integer references public.kurum_sozlesme(id),
  add column if not exists alt_kurum   smallint not null default 0;

comment on column public.taraf_hasta_kurum.alt_kurum is
  'Hastanın devredilen kurumu / poliçe türü (469): başvuruya varsayılan olarak geçer.';

-- ------------------------------------------------------------- backfill --
-- Mevcut başvurulara kurumun tek sözleşmesi; SGK'da alt kurum hastadan,
--   yoksa 399 (Diğer). "Diğer" bilinçli: uydurulmuş bir Bağ-Kur, icmalde
--   yanlış kuruma fatura keserdi.
update public.belge_basvuru b
   set sozlesme_id = s.id
  from public.kurum_sozlesme s
 where b.sozlesme_id is null
   and b.odeyen_kurum_id is not null
   and s.kurum_id = b.odeyen_kurum_id
   and s.id = public.fn_kurum_sozlesme_sec(b.odeyen_kurum_id);

update public.belge_basvuru b
   set alt_kurum = s.alt_kurum
  from public.kurum_sozlesme s
 where b.alt_kurum = 0 and b.sozlesme_id = s.id and s.alt_kurum <> 0;

update public.belge_basvuru b
   set alt_kurum = coalesce(
         (select hk.alt_kurum from public.taraf_hasta_kurum hk
           where hk.hasta_id = (select bb.taraf_id from public.belge bb where bb.id = b.id)
             and hk.kurum_id = b.odeyen_kurum_id and hk.aktif = 1
             and hk.alt_kurum <> 0 limit 1), 399)
  from public.taraf_kurum k
 where b.alt_kurum = 0 and k.id = b.odeyen_kurum_id and k.tur = 3;

-- ------------------------------------------------------------- tetik --
create or replace function public.tg_belge_basvuru_sozlesme()
returns trigger language plpgsql as $$
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
end $$;

drop trigger if exists tg_belge_basvuru_sozlesme on public.belge_basvuru;
create trigger tg_belge_basvuru_sozlesme
    before insert or update of odeyen_kurum_id, sozlesme_id, alt_kurum, sgk_kullan
    on public.belge_basvuru
    for each row execute function public.tg_belge_basvuru_sozlesme();

do $$
begin
    raise notice '469 tamam: % basvurunun sozlesmesi atandi, % basvuru sozlesmesiz',
        (select count(*) from public.belge_basvuru where sozlesme_id is not null),
        (select count(*) from public.belge_basvuru
          where sozlesme_id is null and odeyen_kurum_id is not null);
end $$;
