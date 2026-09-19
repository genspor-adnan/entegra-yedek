-- ============================================================================
--  Gentegre AI — YENİ PERSONELİN ANA ROLÜ DE DEFTERE
--  845_yeni_personel_ana_rol.sql
--
--  Kullanıcı: *"yeni pers kart açtım ana rol yoktu ekleyemedim.. oysa zorunlu
--  alan olmalı.. kaydedince o da harekete geçmeli"*.
--
--  ============ 843'TE AÇIK KALAN DELİK ===============================
--  `tr_personel_rol_iz` yalnız **UPDATE of rol_id** üzerindeydi. Yeni
--  personelin hesabı henüz yokken açılır: `taraf_kullanici` satırı INSERT
--  edilir - update olmadığı için deftere hiçbir şey düşmüyordu. Kartın
--  yazdığı "İşe giriş" hareketi de rolsüz doğuyordu (hesap kart yazıldıktan
--  SONRA açılıyor, o sırada okunacak rol yok).
--
--  Çözüm: tetik INSERT'te de çalışır. Hesap açılınca
--    · o güne ait bir hareket varsa (tipik olarak "İşe giriş") rol ONA işlenir
--      - yeni satır açmak aynı günü iki kez anlatırdı,
--    · hiç hareket yoksa "İşe giriş" satırı burada açılır (giriş tarihi
--      girilmemiş personel).
-- ============================================================================
\set ON_ERROR_STOP on

create or replace function public.tg_personel_rol_iz()
returns trigger language plpgsql as $$
declare v_var integer; v_giris date; v_yertutucu integer; v_ilk boolean;
begin
    if coalesce(current_setting('gentegre.kadro_iz', true), '') = 'kapali' then
        return null;
    end if;
    -- YALNIZ PERSONEL: portal hesabinin ve sistem kullanicisinin kadrosu yok.
    if not exists (select 1 from public.taraf_personel p where p.id = new.id) then
        return null;
    end if;

    -- ILK ATAMA (hesap yeni acildi ya da rol hala YER TUTUCU): rol VAR OLAN
    --   satira islenir. Kartin yazdigi "Ise giris" hareketi rolsuz/yer
    --   tutuculu dogmustu - ayni gune ikinci satir acmak defteri tekrara
    --   dusururdu. Yeni personel kaydi hesabi "Rol Atanmamis" ile aciyor,
    --   gercek rol hemen ardindan UPDATE ile geliyor: o da ilk atamadir.
    select id into v_yertutucu from public.rol where kod = 'atanmamis';
    v_ilk := tg_op = 'INSERT'
             or (v_yertutucu is not null and old.rol_id = v_yertutucu);

    if v_ilk then
        select id into v_var from public.personel_hareket
         where taraf_id = new.id
         order by yururluk desc, id desc limit 1;

        if v_var is not null then
            -- Yer tutucu rol gercek bir gorev degil: uzerine yazilir.
            update public.personel_hareket
               set rol_id = case when rol_id is null or rol_id = v_yertutucu
                                 then new.rol_id else rol_id end,
                   degistirme_tarihi = now()
             where id = v_var;
        else
            -- Hic hareket yok: giris tarihi girilmemis personel. Defter yine
            --   de "ise giris" ile baslasin ki rol tarihsiz kalmasin.
            select p.ise_giris_tarihi into v_giris
              from public.taraf_personel p where p.id = new.id;
            insert into public.personel_hareket
                   (taraf_id, tur, yururluk, rol_id, departman_id, gorev_id,
                    gorev, sube_id, aciklama, kaynak, ekleyen)
            select new.id, 1, coalesce(v_giris, current_date), new.rol_id,
                   t.departman, t.gorev_id, coalesce(p.gorev, ''),
                   coalesce(p.sube_id, 0), 'İşe giriş (hesap açılışı).', 2,
                   new.ekleyen
              from public.taraf_personel p
              join public.taraf t on t.id = p.id
             where p.id = new.id;
        end if;
        return null;
    end if;

    -- Ayni gun ikinci kez degisirse yeni satir acma, mevcudu duzelt.
    select id into v_var from public.personel_hareket
     where taraf_id = new.id and yururluk = current_date and kaynak = 2
     order by id desc limit 1;

    if v_var is not null then
        update public.personel_hareket
           set rol_id = new.rol_id, degistirme_tarihi = now()
         where id = v_var;
    else
        insert into public.personel_hareket
               (taraf_id, tur, yururluk, rol_id, departman_id, gorev_id,
                gorev, yonetici_taraf_id, sube_id, calisma_sekli, sozlesme_turu,
                aciklama, kaynak, ekleyen)
        select new.id, 2, current_date, new.rol_id, t.departman, t.gorev_id,
               coalesce(p.gorev, ''), p.yonetici_taraf_id, coalesce(p.sube_id, 0),
               coalesce(p.calisma_sekli, 0), coalesce(p.sozlesme_turu, 0),
               'Ana rol degisikligi.', 2, new.degistiren
          from public.taraf_personel p
          join public.taraf t on t.id = p.id
         where p.id = new.id;
    end if;
    return null;
end $$;

-- IKI TETIK: `when` kosulunda `tg_op` kullanilamaz (yalniz OLD/NEW gorunur),
--   insert ve update ayri tanimlanir. Fonksiyon ikisini `tg_op` ile ayirir.
drop trigger if exists tr_personel_rol_iz on public.taraf_kullanici;
create trigger tr_personel_rol_iz
  after update of rol_id on public.taraf_kullanici
  for each row when (old.rol_id is distinct from new.rol_id)
  execute function public.tg_personel_rol_iz();

drop trigger if exists tr_personel_rol_iz_yeni on public.taraf_kullanici;
create trigger tr_personel_rol_iz_yeni
  after insert on public.taraf_kullanici
  for each row execute function public.tg_personel_rol_iz();
