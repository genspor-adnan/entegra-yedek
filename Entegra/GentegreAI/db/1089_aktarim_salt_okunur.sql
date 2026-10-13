-- =============================================================================
--  1089  DELPHI AKTARIMI - ADIM 6a: SALT OKUNUR KİP   (dokuman/18 §10-11)
--
--  kurum_profil.veri_kaynagi = 'delphi' iken Delphi'den aktarılan veri web'de
--  DEĞİŞTİRİLEMEZ. Kural VERİTABANINDA (tetik): kart, özel uç (belge, kasa,
--  ödeme...), toplu işlem, zamanlı iş - hangi yoldan yazılırsa yazılsın aynı
--  karar. Hata 'GK422' -> API 422 IS_KURALI, mesaj kullanıcıya gösterilir.
--
--  Kullanıcı kararları (13.10.2026):
--   * Delphi kaydına web'e özgü EKLER (not, ek belge, görev, yorum) eklenebilir -
--     onlar ayrı tablolarda, bu tetik onlara dokunmaz.
--   * e-Belge gönderimi Delphi'de kalır.
--   * Aktarılan kaynaklarda web'de YENİ kayıt açılmaz. İstisna taraf: personel /
--     hasta / kişi kaydı web'in (IK, kullanıcı) - yalnız CARİ rolü (müşteri,
--     tedarikçi) kapalı. Adres yalnız Delphi carisine eklenemez.
--   * Hata kuyruğunda "Atla" yok (ekran adımı, 6c).
--
--  Aktarım (fn_aktar_paket) 'gentegre.aktarim' oturum ayarıyla geçer.
--  veri_kaynagi 'web' (varsayılan) iken tetik hiçbir şey yapmaz: Delphi'den bir
--  kez göç edip ayrılan kurumun satırları (aktarim_kaynak dolu) yine düzenlenir.
--  Kullanılmayan kalemi pasife alan zamanlı iş (552) Delphi satırını atlar.
-- =============================================================================

begin;

alter table public.kurum_profil add column if not exists veri_kaynagi varchar(10) not null default 'web';
do $$ begin
    alter table public.kurum_profil add constraint ck_kurum_profil_veri_kaynagi check (veri_kaynagi in ('web', 'delphi'));
exception when duplicate_object then null; end $$;
comment on column public.kurum_profil.veri_kaynagi is
    '1089: web = veri bu sistemde girilir; delphi = Delphi ERP aktarım ajanıyla gelir, aktarılan kaynaklar salt okunur. KURUM GENELİ: yalnız sube_id = 0 satırı okunur (1 Delphi veritabanı = 1 kurum).';

create or replace function public.fn_veri_kaynagi_delphi()
returns boolean language sql stable as $$
    select coalesce((select k.veri_kaynagi = 'delphi' from public.kurum_profil k where k.sube_id = 0), false)
$$;

-- Satır Delphi'nin mi (ve kurum Delphi kaynaklı mı)?
create or replace function public.fn_delphi_kaynakli(p_aktarim_kaynak smallint)
returns boolean language sql stable as $$
    select coalesce(p_aktarim_kaynak = 1, false) and public.fn_veri_kaynagi_delphi()
$$;

create or replace function public.fn_aktarim_salt_okunur()
returns trigger language plpgsql as $f$
begin
    if coalesce(current_setting('gentegre.aktarim', true), '') = '1' or not public.fn_veri_kaynagi_delphi() then
        return coalesce(new, old);
    end if;

    -- Stok bakiyesi Delphi STOKDURUM aynası: web'den hiç yazılmaz.
    if tg_table_name = 'stok_durum' then
        raise exception using errcode = 'GK422',
            message = 'Stok bakiyesi Delphi ERP''den gelir; stok hareketini Delphi''de yapın.';
    end if;

    if tg_op in ('UPDATE', 'DELETE') and old.aktarim_kaynak = 1 then
        raise exception using errcode = 'GK422',
            message = 'Bu kayıt Delphi ERP''den gelir; değişikliği Delphi''de yapın, birkaç saniye içinde burada görünür.';
    end if;

    if tg_op = 'INSERT' then
        if tg_table_name = 'taraf' then
            if coalesce(new.musteri, 0) = 1 or coalesce(new.tedarikci, 0) = 1 then
                raise exception using errcode = 'GK422',
                    message = 'Cariler Delphi ERP''den gelir; yeni cariyi Delphi''de açın.';
            end if;
        elsif tg_table_name = 'taraf_adres' then
            if exists (select 1 from public.taraf t where t.id = new.taraf_id and t.aktarim_kaynak = 1) then
                raise exception using errcode = 'GK422',
                    message = 'Bu cari Delphi ERP''den gelir; adresi Delphi''de ekleyin.';
            end if;
        else
            raise exception using errcode = 'GK422',
                message = 'Bu kayıtlar Delphi ERP''den gelir; yeni kaydı Delphi''de açın.';
        end if;
    end if;
    -- Web'in kendi satırı (personel taraf, web adresi) güncellenirken cari rolü verilemez.
    if tg_op = 'UPDATE' and tg_table_name = 'taraf'
       and (coalesce(new.musteri, 0) = 1 and coalesce(old.musteri, 0) = 0
            or coalesce(new.tedarikci, 0) = 1 and coalesce(old.tedarikci, 0) = 0) then
        raise exception using errcode = 'GK422',
            message = 'Cariler Delphi ERP''den gelir; müşteri / tedarikçi rolü Delphi''de verilir.';
    end if;
    return coalesce(new, old);
end $f$;

comment on function public.fn_aktarim_salt_okunur() is
    '1089: veri_kaynagi = delphi iken aktarılan tablolara web yazımını reddeder (GK422); aktarım oturumu geçer.';

drop trigger if exists trg_aktarim_salt_okunur on public.taraf;
create trigger trg_aktarim_salt_okunur before insert or update or delete on public.taraf
    for each row execute function public.fn_aktarim_salt_okunur();
drop trigger if exists trg_aktarim_salt_okunur on public.taraf_adres;
create trigger trg_aktarim_salt_okunur before insert or update or delete on public.taraf_adres
    for each row execute function public.fn_aktarim_salt_okunur();
drop trigger if exists trg_aktarim_salt_okunur on public.stok;
create trigger trg_aktarim_salt_okunur before insert or update or delete on public.stok
    for each row execute function public.fn_aktarim_salt_okunur();
drop trigger if exists trg_aktarim_salt_okunur on public.stok_barkod;
create trigger trg_aktarim_salt_okunur before insert or update or delete on public.stok_barkod
    for each row execute function public.fn_aktarim_salt_okunur();
drop trigger if exists trg_aktarim_salt_okunur on public.stok_fiyat;
create trigger trg_aktarim_salt_okunur before insert or update or delete on public.stok_fiyat
    for each row execute function public.fn_aktarim_salt_okunur();
drop trigger if exists trg_aktarim_salt_okunur on public.stok_seri_lot;
create trigger trg_aktarim_salt_okunur before insert or update or delete on public.stok_seri_lot
    for each row execute function public.fn_aktarim_salt_okunur();
drop trigger if exists trg_aktarim_salt_okunur on public.stok_durum;
create trigger trg_aktarim_salt_okunur before insert or update or delete on public.stok_durum
    for each row execute function public.fn_aktarim_salt_okunur();
drop trigger if exists trg_aktarim_salt_okunur on public.hizmet;
create trigger trg_aktarim_salt_okunur before insert or update or delete on public.hizmet
    for each row execute function public.fn_aktarim_salt_okunur();
drop trigger if exists trg_aktarim_salt_okunur on public.hizmet_fiyat;
create trigger trg_aktarim_salt_okunur before insert or update or delete on public.hizmet_fiyat
    for each row execute function public.fn_aktarim_salt_okunur();
drop trigger if exists trg_aktarim_salt_okunur on public.masraf;
create trigger trg_aktarim_salt_okunur before insert or update or delete on public.masraf
    for each row execute function public.fn_aktarim_salt_okunur();
drop trigger if exists trg_aktarim_salt_okunur on public.masraf_fiyat;
create trigger trg_aktarim_salt_okunur before insert or update or delete on public.masraf_fiyat
    for each row execute function public.fn_aktarim_salt_okunur();
drop trigger if exists trg_aktarim_salt_okunur on public.depo;
create trigger trg_aktarim_salt_okunur before insert or update or delete on public.depo
    for each row execute function public.fn_aktarim_salt_okunur();
drop trigger if exists trg_aktarim_salt_okunur on public.doviz_kur;
create trigger trg_aktarim_salt_okunur before insert or update or delete on public.doviz_kur
    for each row execute function public.fn_aktarim_salt_okunur();
drop trigger if exists trg_aktarim_salt_okunur on public.masraf_merkezi;
create trigger trg_aktarim_salt_okunur before insert or update or delete on public.masraf_merkezi
    for each row execute function public.fn_aktarim_salt_okunur();
drop trigger if exists trg_aktarim_salt_okunur on public.proje;
create trigger trg_aktarim_salt_okunur before insert or update or delete on public.proje
    for each row execute function public.fn_aktarim_salt_okunur();
drop trigger if exists trg_aktarim_salt_okunur on public.hesap;
create trigger trg_aktarim_salt_okunur before insert or update or delete on public.hesap
    for each row execute function public.fn_aktarim_salt_okunur();
drop trigger if exists trg_aktarim_salt_okunur on public.kredi;
create trigger trg_aktarim_salt_okunur before insert or update or delete on public.kredi
    for each row execute function public.fn_aktarim_salt_okunur();
drop trigger if exists trg_aktarim_salt_okunur on public.is_merkezi;
create trigger trg_aktarim_salt_okunur before insert or update or delete on public.is_merkezi
    for each row execute function public.fn_aktarim_salt_okunur();
drop trigger if exists trg_aktarim_salt_okunur on public.urun_agaci;
create trigger trg_aktarim_salt_okunur before insert or update or delete on public.urun_agaci
    for each row execute function public.fn_aktarim_salt_okunur();
drop trigger if exists trg_aktarim_salt_okunur on public.urun_agaci_satir;
create trigger trg_aktarim_salt_okunur before insert or update or delete on public.urun_agaci_satir
    for each row execute function public.fn_aktarim_salt_okunur();
drop trigger if exists trg_aktarim_salt_okunur on public.urun_agaci_operasyon;
create trigger trg_aktarim_salt_okunur before insert or update or delete on public.urun_agaci_operasyon
    for each row execute function public.fn_aktarim_salt_okunur();
drop trigger if exists trg_aktarim_salt_okunur on public.belge;
create trigger trg_aktarim_salt_okunur before insert or update or delete on public.belge
    for each row execute function public.fn_aktarim_salt_okunur();
drop trigger if exists trg_aktarim_salt_okunur on public.belge_satir;
create trigger trg_aktarim_salt_okunur before insert or update or delete on public.belge_satir
    for each row execute function public.fn_aktarim_salt_okunur();
drop trigger if exists trg_aktarim_salt_okunur on public.stok_izleme;
create trigger trg_aktarim_salt_okunur before insert or update or delete on public.stok_izleme
    for each row execute function public.fn_aktarim_salt_okunur();
drop trigger if exists trg_aktarim_salt_okunur on public.mali_hareket;
create trigger trg_aktarim_salt_okunur before insert or update or delete on public.mali_hareket
    for each row execute function public.fn_aktarim_salt_okunur();
drop trigger if exists trg_aktarim_salt_okunur on public.kasa_islem;
create trigger trg_aktarim_salt_okunur before insert or update or delete on public.kasa_islem
    for each row execute function public.fn_aktarim_salt_okunur();

-- ------------------------------------------- paket: aktarım oturumu (1086) ---
create or replace function public.fn_aktar_paket(p_ajan integer, p jsonb)
returns jsonb language plpgsql as $$
declare
    v_no      varchar(64) := left(coalesce(nullif(btrim(p->>'paket'), ''), gen_random_uuid()::text), 64);
    v_bas     timestamptz := clock_timestamp();
    v_eski    record;
    v_bilinmeyen text;
    v_adim    record;
    v_parca   jsonb;
    v_sonuc   jsonb := '{}';
    v_tamam   text[] := '{}';
    v_hata    jsonb;
    v_mesaj   text;
    v_ayrinti text;
    v_paket_id bigint;
    v_tablolar text[];
begin
    perform pg_advisory_xact_lock(hashtext('gentegre.aktarim'));
    -- 1089: aktarım oturumu - salt okunur tetikleri (fn_aktarim_salt_okunur) geçer.
    perform set_config('gentegre.aktarim', '1', true);

    select id, durum, sonuc into v_eski from public.aktarim_paket where ajan_id = p_ajan and paket_no = v_no;
    if found and v_eski.durum = 1 then
        return v_eski.sonuc || jsonb_build_object('tekrar', true);
    end if;

    select string_agg(k, ', ' order by k) into v_bilinmeyen
      from (select jsonb_object_keys(coalesce(p->'U', '{}')) k
            union select jsonb_object_keys(coalesce(p->'D', '{}'))
            union select jsonb_object_keys(coalesce(p->'V', '{}'))) x
     where not exists (select 1 from public.fn_aktarim_adimlari() a where x.k = any (a.tablolar));
    if v_bilinmeyen is not null then
        raise exception 'AKTARIM_TABLO: bilinmeyen tablo %', v_bilinmeyen;
    end if;

    for v_adim in select * from public.fn_aktarim_adimlari() order by sira loop
        -- Adımın tabloları pakette yoksa çağrılmaz; yalnız versiyonu gelmişse de "tamam".
        if not (coalesce(p->'U', '{}') ?| v_adim.tablolar or coalesce(p->'D', '{}') ?| v_adim.tablolar) then
            v_tamam := v_tamam || v_adim.tablolar;
            continue;
        end if;
        begin
            execute format('select public.%I($1)', v_adim.fonksiyon) into v_parca using p;
            v_sonuc := v_sonuc || jsonb_build_object(v_adim.fonksiyon, v_parca);
            v_tamam := v_tamam || v_adim.tablolar;
            update public.aktarim_hata set cozulme = now() where adim = v_adim.fonksiyon and cozulme is null;
        exception when others then
            get stacked diagnostics v_mesaj = message_text, v_ayrinti = pg_exception_context;
            v_hata := jsonb_build_object('adim', v_adim.fonksiyon, 'tablolar', to_jsonb(v_adim.tablolar),
                                         'mesaj', v_mesaj);
            insert into public.aktarim_hata as h (ajan_id, adim, tablolar, paket_no, mesaj, ayrinti, ham)
            values (p_ajan, v_adim.fonksiyon, v_adim.tablolar, v_no, v_mesaj, v_ayrinti,
                    jsonb_build_object(
                        'U', (select coalesce(jsonb_object_agg(k, v), '{}') from jsonb_each(coalesce(p->'U', '{}')) e(k, v)
                               where k = any (v_adim.tablolar)),
                        'D', (select coalesce(jsonb_object_agg(k, v), '{}') from jsonb_each(coalesce(p->'D', '{}')) e(k, v)
                               where k = any (v_adim.tablolar))))
            on conflict (adim) where cozulme is null
            do update set deneme = h.deneme + 1, son_zaman = now(), paket_no = excluded.paket_no,
                          mesaj = excluded.mesaj, ayrinti = excluded.ayrinti, ham = excluded.ham,
                          ajan_id = excluded.ajan_id;
            exit;   -- sonraki adımlar buna bağlı
        end;
    end loop;

    v_sonuc := jsonb_build_object('paket', v_no, 'sonuc', v_sonuc, 'hata', v_hata,
                                  'ilerleyen', (select coalesce(jsonb_agg(k order by k), '[]')
                                                  from jsonb_object_keys(coalesce(p->'V', '{}')) k
                                                 where k = any (v_tamam)));

    insert into public.aktarim_paket as x (ajan_id, paket_no, sure_ms, durum, ozet, sonuc)
    values (p_ajan, v_no, (extract(epoch from clock_timestamp() - v_bas) * 1000)::int,
            case when v_hata is null then 1 else 2 end,
            (select jsonb_object_agg(t, jsonb_build_object(
                        'U', coalesce(jsonb_array_length(p->'U'->t), 0),
                        'D', coalesce(jsonb_array_length(p->'D'->t), 0)))
               from (select jsonb_object_keys(coalesce(p->'U', '{}')) t
                     union select jsonb_object_keys(coalesce(p->'D', '{}'))) y),
            v_sonuc)
    on conflict (ajan_id, paket_no)
    do update set alinma = now(), sure_ms = excluded.sure_ms, durum = excluded.durum,
                  ozet = excluded.ozet, sonuc = excluded.sonuc
    returning id into v_paket_id;

    -- Versiyon: yalnız uygulanan adımların tabloları, geri gitmez.
    insert into public.aktarim_durum as d (tablo, versiyon, son_paket, son_paket_id)
    select k, (v #>> '{}')::bigint, now(), v_paket_id
      from jsonb_each(coalesce(p->'V', '{}')) e(k, v)
     where k = any (v_tamam)
    on conflict (tablo) do update
       set versiyon = greatest(d.versiyon, excluded.versiyon), son_paket = now(), son_paket_id = v_paket_id;

    return v_sonuc;
end $$;

comment on function public.fn_aktar_paket(integer, jsonb) is
    '1086/1089: Delphi aktarım paketi - sıralı, adım başına savepoint, hata kuyruğu, CT versiyonu; aktarım oturumu (gentegre.aktarim).';

-- ------------------------------------------- zamanlı iş: Delphi kalemi (552) ---
create or replace function public.fn_hizmet_kullanilmayan_pasife(
    p_gun integer default null, p_deneme boolean default false)
returns table (pasife_alinan integer, aciklama text)
language plpgsql as $$
declare
    v_gun       integer;
    v_baslangic date;
    v_sayi      integer := 0;
begin
    select coalesce(nullif(deger, '')::integer, 365) into v_gun
      from public.referans where anahtar = 'hizmet.oto_pasif_gun';
    v_gun := coalesce(p_gun, v_gun, 365);
    if v_gun <= 0 then
        return query select 0, 'Otomatik pasife alma kapali (hizmet.oto_pasif_gun = 0).'::text;
        return;
    end if;

    select coalesce(nullif(deger, '')::date, current_date) into v_baslangic
      from public.referans where anahtar = 'hizmet.kullanim_izleme_baslangic';
    v_baslangic := coalesce(v_baslangic, current_date);
    if current_date - v_baslangic < v_gun then
        return query select 0,
            format('Izleme suresi dolmadi: %s gunun %s gunu gecti.',
                   v_gun, current_date - v_baslangic)::text;
        return;
    end if;

    create temporary table zz_pasif_aday on commit drop as
    select h.id
      from public.hizmet h
     where h.baslik_mi = 0 and h.durum = 1 and h.profil_pasif = 0
       and not public.fn_delphi_kaynakli(h.aktarim_kaynak)   -- 1089: Delphi'nin kaydı
       and not exists (
             select 1 from public.kalem_kullanim k
              where k.tur = 2 and k.kayit_id = h.id
                and k.son_tarih >= now()::timestamp - make_interval(days => v_gun))
       and not exists (
             select 1 from public.belge_satir bs
               join public.belge b on b.id = bs.belge_id
              where bs.hizmet_id = h.id
                and b.belge_tarihi >= now()::timestamp - make_interval(days => v_gun));

    select count(*) into v_sayi from zz_pasif_aday;
    if not p_deneme then
        update public.hizmet h set durum = 0, profil_pasif = 1
          from zz_pasif_aday a where a.id = h.id;
    end if;

    return query select v_sayi,
        format('%s gun kullanilmayan %s hizmet %s.', v_gun, v_sayi,
               case when p_deneme then 'bulundu (deneme)' else 'pasife alindi' end)::text;
end $$;

create or replace function public.fn_stok_kullanilmayan_pasife(
    p_gun integer default null, p_deneme boolean default false)
returns table (pasife_alinan integer, aciklama text)
language plpgsql as $$
declare
    v_gun       integer;
    v_baslangic date;
    v_sayi      integer := 0;
begin
    select coalesce(nullif(deger, '')::integer, 365) into v_gun
      from public.referans where anahtar = 'hizmet.oto_pasif_gun';
    v_gun := coalesce(p_gun, v_gun, 365);
    if v_gun <= 0 then
        return query select 0, 'Otomatik pasife alma kapali (hizmet.oto_pasif_gun = 0).'::text;
        return;
    end if;

    select coalesce(nullif(deger, '')::date, current_date) into v_baslangic
      from public.referans where anahtar = 'hizmet.kullanim_izleme_baslangic';
    v_baslangic := coalesce(v_baslangic, current_date);
    if current_date - v_baslangic < v_gun then
        return query select 0,
            format('Izleme suresi dolmadi: %s gunun %s gunu gecti.',
                   v_gun, current_date - v_baslangic)::text;
        return;
    end if;

    create temporary table zz_stok_pasif_aday on commit drop as
    select t.id
      from public.stok t
     where t.durum = 1 and t.profil_pasif = 0
       and not public.fn_delphi_kaynakli(t.aktarim_kaynak)   -- 1089: Delphi'nin kaydı
       and not exists (
             select 1 from public.kalem_kullanim k
              where k.tur = 1 and k.kayit_id = t.id
                and k.son_tarih >= now()::timestamp - make_interval(days => v_gun))
       -- BAKIYESI OLAN KART KAPANMAZ: depoda duran mal sayimda ve maliyette
       --   gorunmeye devam etmeli.
       and not exists (
             select 1 from public.stok_durum d
              where d.stok_id = t.id
                and (coalesce(d.kalan, 0) <> 0 or coalesce(d.rezerve, 0) <> 0))
       -- HIC BELGEDE GECMEMIS olmali (tarih siniri YOK): eski belgeyi acan
       --   ekran kapatilmis kalemi bos gosterirdi.
       and not exists (select 1 from public.belge_satir bs where bs.stok_id = t.id)
       -- Ilac icin uretilmis stok karti da dokunulmaz: katalog bagi kopmasin.
       and not exists (select 1 from public.ilac i where i.stok_id = t.id);

    select count(*) into v_sayi from zz_stok_pasif_aday;
    if not p_deneme then
        update public.stok t set durum = 0, profil_pasif = 1
          from zz_stok_pasif_aday a where a.id = t.id;
    end if;

    return query select v_sayi,
        format('%s gun kullanilmayan %s stok %s.', v_gun, v_sayi,
               case when p_deneme then 'bulundu (deneme)' else 'pasife alindi' end)::text;
end $$;

commit;
