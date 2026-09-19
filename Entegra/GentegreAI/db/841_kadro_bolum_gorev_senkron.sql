-- ============================================================================
--  Gentegre AI — KADRO HAREKETİ: BÖLÜM / GÖREV / GİRİŞ-ÇIKIŞ SENKRONU
--  841_kadro_bolum_gorev_senkron.sql
--
--  Kullanıcı: *"hareketlere bölüm / görev eklesek.. personel kartından işe
--  giriş/çıkış, bölüm, görev bilgilerini çıkarsak mı"* → karar: alanlar
--  kartta KALIR ama **salt okunur** olur; değişikliği kadro hareketi yazar.
--
--  ============ 840'TA YARIM KALAN BAĞ ================================
--  `personel_hareket` tablosunda `departman_id` ve `gorev_id` vardı ama:
--    · `fn_personel_kadro_uygula` yalnız `taraf_personel` alanlarını (görev
--      metni, yönetici, şube, çalışma şekli, sözleşme) yazıyordu,
--    · kartta görünen Bölüm/Görev ise `taraf.departman` / `taraf.gorev_id`
--      kolonlarında - hareket onlara DOKUNMUYORDU. Hareket girilip bölüm
--      değiştirilince kart eski bölümde kalıyordu.
--    · İz tetiği `taraf_personel`i dinliyordu, `taraf`ı değil: karttan bölüm
--      değişince deftere satır düşmüyordu.
--
--  ============ İŞE GİRİŞ / ÇIKIŞ DE DEFTERDEN ========================
--  `ise_giris_tarihi` = tür 1 hareketin yürürlüğü, `isten_cikis_tarihi` =
--  tür 9. Kıdem ve izin hakkı (İş K. md. 53) bu tarihten hesaplandığı için
--  tarihsiz düzeltme izin bakiyesini de bozardı.
-- ============================================================================
\set ON_ERROR_STOP on

-- ------------------------------------------- hareketi karta uygula (v2) ----
create or replace function public.fn_personel_kadro_uygula(p_taraf_id integer)
returns integer language plpgsql as $$
declare
    h        public.personel_hareket;
    v_giris  date;
    v_cikis  date;
    v_sayi   integer := 0;
begin
    select * into h from public.fn_personel_kadro(p_taraf_id, current_date);

    -- Giriş/çıkış AYRI okunur: bugün geçerli hareket bir "terfi" olabilir,
    --   giriş tarihi yine ilk satırdadır.
    select min(yururluk) into v_giris from public.personel_hareket
     where taraf_id = p_taraf_id and tur = 1;
    select max(yururluk) into v_cikis from public.personel_hareket
     where taraf_id = p_taraf_id and tur = 9;

    if h.id is null and v_giris is null and v_cikis is null then return 0; end if;

    perform set_config('gentegre.kadro_iz', 'kapali', true);

    if h.id is not null then
        update public.taraf_personel p
           set gorev             = case when h.gorev <> '' then h.gorev else p.gorev end,
               yonetici_taraf_id = coalesce(h.yonetici_taraf_id, p.yonetici_taraf_id),
               sube_id           = case when h.sube_id > 0 then h.sube_id else p.sube_id end,
               calisma_sekli     = case when h.calisma_sekli > 0 then h.calisma_sekli
                                        else p.calisma_sekli end,
               sozlesme_turu     = case when h.sozlesme_turu > 0 then h.sozlesme_turu
                                        else p.sozlesme_turu end,
               degistirme_tarihi = now()
         where p.id = p_taraf_id;
        get diagnostics v_sayi = row_count;

        -- KARTTA GORUNEN BOLUM/GOREV `taraf` TABLOSUNDA (840 bunu atliyordu).
        update public.taraf t
           set departman = coalesce(h.departman_id, t.departman),
               gorev_id  = coalesce(h.gorev_id, t.gorev_id),
               degistirme_tarihi = now()
         where t.id = p_taraf_id
           and (h.departman_id is not null or h.gorev_id is not null);
    end if;

    -- GİRİŞ/ÇIKIŞ: defter neyi söylüyorsa o. Hareket yoksa karta dokunulmaz -
    --   dolgusu yapılmamış eski kayıt boşaltılmasın.
    update public.taraf_personel p
       set ise_giris_tarihi   = coalesce(v_giris, p.ise_giris_tarihi),
           isten_cikis_tarihi = case when v_cikis is not null then v_cikis
                                     else p.isten_cikis_tarihi end,
           degistirme_tarihi  = now()
     where p.id = p_taraf_id
       and (v_giris is not null or v_cikis is not null);

    perform set_config('gentegre.kadro_iz', '', true);
    return v_sayi;
end $$;

-- ------------------------------------ karttan hareket izi: taraf tarafı ----
-- Personel kartında Bölüm/Görev değişince deftere satır düşsün. `taraf`
--   tablosu HASTA, CARİ, KİŞİ için de kullanılıyor - tetik yalnız PERSONEL
--   satırında çalışır, yoksa her hasta kaydı kadro hareketi üretirdi.
create or replace function public.tg_personel_kadro_iz_taraf()
returns trigger language plpgsql as $$
declare v_var integer;
begin
    if coalesce(current_setting('gentegre.kadro_iz', true), '') = 'kapali' then
        return null;
    end if;
    if not exists (select 1 from public.taraf_personel p where p.id = new.id) then
        return null;
    end if;
    if new.departman is not distinct from old.departman
       and new.gorev_id is not distinct from old.gorev_id then
        return null;
    end if;

    select id into v_var from public.personel_hareket
     where taraf_id = new.id and yururluk = current_date and kaynak = 2
     order by id desc limit 1;

    if v_var is not null then
        update public.personel_hareket
           set departman_id = new.departman, gorev_id = new.gorev_id,
               degistiren = new.degistiren, degistirme_tarihi = now()
         where id = v_var;
    else
        insert into public.personel_hareket
               (taraf_id, tur, yururluk, departman_id, gorev_id,
                gorev, yonetici_taraf_id, sube_id, calisma_sekli, sozlesme_turu,
                aciklama, kaynak, ekleyen)
        select new.id,
               case when new.departman is distinct from old.departman then 3 else 2 end,
               current_date, new.departman, new.gorev_id,
               coalesce(p.gorev, ''), p.yonetici_taraf_id, coalesce(p.sube_id, 0),
               coalesce(p.calisma_sekli, 0), coalesce(p.sozlesme_turu, 0),
               'Personel kartından türetildi.', 2, new.degistiren
          from public.taraf_personel p where p.id = new.id;
    end if;
    return null;
end $$;

drop trigger if exists tr_personel_kadro_iz_taraf on public.taraf;
create trigger tr_personel_kadro_iz_taraf
  after update of departman, gorev_id on public.taraf
  for each row execute function public.tg_personel_kadro_iz_taraf();

-- -------------------------------------- işe giriş/çıkış karttan deftere ----
-- Yeni personel kaydında giriş tarihi kartta girilir (840 kararı: alan ilk
--   kayıtta yazılabilir). O tarih deftere "işe giriş" satırı olarak düşer.
create or replace function public.tg_personel_giris_cikis_iz()
returns trigger language plpgsql as $$
begin
    if coalesce(current_setting('gentegre.kadro_iz', true), '') = 'kapali' then
        return null;
    end if;

    if new.ise_giris_tarihi is not null
       and new.ise_giris_tarihi is distinct from old.ise_giris_tarihi then
        if exists (select 1 from public.personel_hareket
                    where taraf_id = new.id and tur = 1) then
            update public.personel_hareket set yururluk = new.ise_giris_tarihi,
                   degistirme_tarihi = now()
             where taraf_id = new.id and tur = 1;
        else
            insert into public.personel_hareket
                   (taraf_id, tur, yururluk, gorev, sube_id, aciklama, kaynak, ekleyen)
            values (new.id, 1, new.ise_giris_tarihi, coalesce(new.gorev, ''),
                    coalesce(new.sube_id, 0), 'İşe giriş (karttan).', 2, new.degistiren);
        end if;
    end if;

    if new.isten_cikis_tarihi is not null
       and new.isten_cikis_tarihi is distinct from old.isten_cikis_tarihi then
        if exists (select 1 from public.personel_hareket
                    where taraf_id = new.id and tur = 9) then
            update public.personel_hareket set yururluk = new.isten_cikis_tarihi,
                   degistirme_tarihi = now()
             where taraf_id = new.id and tur = 9;
        else
            insert into public.personel_hareket
                   (taraf_id, tur, yururluk, gorev, sube_id, aciklama, kaynak, ekleyen)
            values (new.id, 9, new.isten_cikis_tarihi, coalesce(new.gorev, ''),
                    coalesce(new.sube_id, 0), 'İşten çıkış (karttan).', 2, new.degistiren);
        end if;
    end if;
    return null;
end $$;

drop trigger if exists tr_personel_giris_cikis_iz on public.taraf_personel;
create trigger tr_personel_giris_cikis_iz
  after insert or update of ise_giris_tarihi, isten_cikis_tarihi
  on public.taraf_personel
  for each row execute function public.tg_personel_giris_cikis_iz();

-- --------------------------------------------------------- geri dolgu ----
-- 840'ta yazılan "işe giriş" satırlarına bölüm/görev eklenir: o gün hangi
--   bölümdeydi bilinmiyor, bugünküyle doldurmak YANLIŞ olurdu - yalnız
--   hareketi OLMAYAN alanlar boş bırakılır. Burada yapılan tek şey, 840
--   sonrası girilmiş hareketleri karta bir kez uygulamak.
do $$
declare r record; v_sayi integer := 0;
begin
    for r in select distinct taraf_id from public.personel_hareket loop
        perform public.fn_personel_kadro_uygula(r.taraf_id);
        v_sayi := v_sayi + 1;
    end loop;
    raise notice '841 tamam: % personelin karti defterden tazelendi. '
                 'Bolum/gorev ve giris/cikis artik iki yonlu senkron.', v_sayi;
end $$;
