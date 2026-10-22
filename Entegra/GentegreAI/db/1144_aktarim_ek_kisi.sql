-- =============================================================================
--  1144  DELPHI AKTARIMI - EK: KULLANICI, PERSONEL, İLGİLİ KİŞİ, İZİN, PERSONEL HAREKETİ
--
--  Kullanıcı (22.10.2026): FETA Delphi'den web'e geçiyor, personel ve kullanıcılar da
--  taşınacak. Kaynak stg tabloları db/araclar/aktar_ek.ps1 doldurur (1143); bu
--  fonksiyon bir kez (Delphi kapanırken) çalışır, tekrar çalıştırmak güvenlidir.
--
--  KURALLAR
--   * Kullanıcı = taraf (Delphi KULLANICI.REHBERID'nin web kartı, fn_aktarim_kisi_id).
--     taraf_kullanici.id = o kart; eski_id = KULLANICI.ID (Delphi kökenli hesabın işareti).
--     Web'de açılmış hesaba (eski_id boş, ör. admin) DOKUNULMAZ.
--   * Kod: KULLANICI.KOD küçük harf, Türkçe harfler ASCII'ye, izin verilmeyen karakter
--     atılır (^[a-z0-9._@-]+$); boş kalırsa 'k<id>'; başka hesapla çakışırsa '-<id>' eki.
--   * Rol: Delphi yönetici (ROLID -1 / ROLLER.TY=1) -> 'yonetici', diğerleri 'atanmamis'.
--     Delphi YETKI satırları TAŞINMAZ - web yetki kataloğu ekran bazlı (998, 1126..);
--     yönetici rolleri GenProfil / Kullanıcılar ekranından verir.
--   * PAROLA TAŞINMAZ: Delphi şifresi geri çözülebilir XOR (hash değil), 95 hesabın 92'si
--     boş. Hesap parolasız (parola_degismeli = 1) açılır; yönetici parolayı atar.
--   * Kullanıcının kartı personel = 1 + taraf_personel (yoksa) + varsayılan şube. Personel
--     e-postası benzersiz: Delphi yer tutucusu ('-') silinir; gerçek adres başka personelde
--     varsa kart personel yapılmaz (hesap yine açılır).
--     Personel = 1 olan kartı çekirdek cari aktarımı (fn_aktar_cari) artık ezmez.
--   * Hesap açılışında web'in kendi "işe giriş" hareketi YAZILMAZ (gentegre.kadro_iz =
--     kapali): personel geçmişi Delphi PERS_HAREKET'ten gelir.
--   * REHBERPERSONEL = firmaların İLGİLİ KİŞİLERİ (çalışan değil): kişi kartı (kisi = 1,
--     bag_id = firma, unvan = ADSOYAD - kişi kartı tek alan kullanır). Firması taşınmamış
--     ya da adı boş satır atlanır.
--   * PERSONELIZIN -> personel_izin (onaylı, geçmiş). IZINTURU (GENINI -3501): 11 yıllık,
--     12-18 mazeret, 20 rapor, 19/21/23 ücretsiz, diğer 9. IZINTURU -1 izin değil HAK
--     kaydıdır -> personel_izin_hak (yıl = DONEM, hak_gun = HAK). Gün sayısını web tetiği
--     (tg_personel_izin_gun) tarihlerden hesaplar. BIRIM 2 (saatlik) Delphi'de saat
--     tutmaz (00:00, süre IZINLIGUNSAYISI'nda saat): gün boyu izin olur, süre açıklamaya.
--   * PERS_HAREKET -> personel_hareket (kaynak 1): TUR 1 işe giriş, 2 terfi/unvan (rol),
--     99 işten çıkış (9); diğerleri (Delphi 5) 99 'diğer'.
--  TAŞINMAYAN: Delphi şifre / TOKEN / gizli soru-cevap / SKINADI, YETKI / YETKIEK /
--  YETKIALANI satırları, KULLANICI_REHBER (son açılan kartlar).
-- =============================================================================

begin;

create or replace function public.fn_aktarim_kullanici_kod(p_kod text, p_id integer)
returns varchar language sql immutable as $f$
    select coalesce(nullif(regexp_replace(
               translate(lower(btrim(coalesce(p_kod, ''))), 'ıişğüöçâîû', 'iisguocaiu'),
               '[^a-z0-9._@-]', '', 'g'), ''), 'k' || p_id)::varchar(30)
$f$;

create or replace function public.fn_aktar_ek_kisi()
returns jsonb language plpgsql as $$
declare
    v_yonetici int := (select id from public.rol where kod = 'yonetici');
    v_atanmamis int := (select id from public.rol where kod = 'atanmamis');
    v_ke int := 0; v_kg int := 0; v_katla int := 0; v_kweb int := 0;
    v_per int := 0; v_tp int := 0; v_ks int := 0;
    v_ie int := 0; v_ig int := 0; v_iatla int := 0; v_hak int := 0;
    v_he int := 0; v_hg int := 0; v_hatla int := 0;
    v_te int := 0; v_tg int := 0; v_tatla int := 0; v_epc int := 0;
begin
    perform set_config('gentegre.aktarim', '1', true);
    perform set_config('gentegre.kadro_iz', 'kapali', true);

    -- ------------------------------------------------------------ kullanıcı ---
    drop table if exists _ek_k;
    create temp table _ek_k on commit drop as
    select k.id as delphi, public.fn_aktarim_kisi_id(k.rehberid) as taraf_id,
           public.fn_aktarim_kullanici_kod(k.kod, k.id) as kod,
           case when k.rolid = -1 or coalesce(r.ty, 0) = 1 then v_yonetici else v_atanmamis end as rol_id,
           coalesce(k.durum, 0)::smallint as aktif, public.fn_aktarim_sube(k.subeid) as sube_id,
           coalesce(public.fn_aktarim_zaman(k.eklemetarihi), now()) as ekleme
      from stg.kullanici k left join stg.roller r on r.id = k.rolid;
    delete from _ek_k where taraf_id is null;
    get diagnostics v_katla = row_count;
    -- web'de açılmış hesap (eski_id boş) Delphi'ye ezdirilmez
    delete from _ek_k e using public.taraf_kullanici u where u.id = e.taraf_id and u.eski_id is null;
    get diagnostics v_kweb = row_count;
    -- aynı kart iki Delphi hesabında: en küçük Delphi kimliği
    delete from _ek_k e where exists (select 1 from _ek_k o where o.taraf_id = e.taraf_id and o.delphi < e.delphi);
    -- kod çakışması: başka web hesabı ya da aynı koddan önceki Delphi hesabı
    update _ek_k e set kod = left(e.kod, 29 - length(e.delphi::text)) || '-' || e.delphi
     where exists (select 1 from public.taraf_kullanici u where u.kod = e.kod and u.id <> e.taraf_id)
        or exists (select 1 from _ek_k o where o.kod = e.kod and o.delphi < e.delphi);

    update public.taraf_kullanici u
       set kod = e.kod, rol_id = e.rol_id, aktif = e.aktif, eski_id = e.delphi
      from _ek_k e
     where u.id = e.taraf_id and u.eski_id is not null
       and (u.kod, u.rol_id, u.aktif, u.eski_id) is distinct from (e.kod, e.rol_id, e.aktif, e.delphi);
    get diagnostics v_kg = row_count;

    -- kart önce personel olur (taraf_personel, rol izi tetiklerinin aradığı satır)
    -- personel e-postası benzersizdir (ux_taraf_personel_eposta): Delphi'deki yer
    --   tutucu ('-', '@' içermeyen) silinir; gerçek adres başka personelde varsa kart
    --   personel yapılmaz (hesap yine açılır) - 'eposta_cakisma'.
    update public.taraf t set eposta = null
      from _ek_k e where t.id = e.taraf_id and coalesce(t.eposta, '') <> '' and position('@' in t.eposta) = 0;
    update public.taraf t set personel = 1
      from _ek_k e
     where t.id = e.taraf_id and t.personel = 0
       and not exists (select 1 from public.taraf o
                        where o.personel = 1 and o.id <> t.id and coalesce(t.eposta, '') <> ''
                          and lower(o.eposta) = lower(t.eposta))
       and not exists (select 1 from _ek_k e2 join public.taraf o on o.id = e2.taraf_id
                        where e2.delphi < e.delphi and coalesce(t.eposta, '') <> ''
                          and lower(o.eposta) = lower(t.eposta));
    get diagnostics v_per = row_count;
    v_epc := (select count(*) from _ek_k e join public.taraf t on t.id = e.taraf_id where t.personel = 0);
    insert into public.taraf_personel (id, sube_id, ekleme_tarihi)
    select e.taraf_id, coalesce(e.sube_id, t.sube_id), e.ekleme
      from _ek_k e join public.taraf t on t.id = e.taraf_id and t.personel = 1
    on conflict (id) do nothing;
    get diagnostics v_tp = row_count;

    insert into public.taraf_kullanici (id, kod, parola_hash, parola_degismeli, rol_id, aktif, eski_id, ekleme_tarihi)
    select e.taraf_id, e.kod, '', 1, e.rol_id, e.aktif, e.delphi, e.ekleme
      from _ek_k e
     where not exists (select 1 from public.taraf_kullanici u where u.id = e.taraf_id);
    get diagnostics v_ke = row_count;

    insert into public.kullanici_sube (taraf_id, sube_id, varsayilan, yazma)
    select e.taraf_id, coalesce(e.sube_id, t.sube_id), 1, 1
      from _ek_k e join public.taraf t on t.id = e.taraf_id
     where not exists (select 1 from public.kullanici_sube s where s.taraf_id = e.taraf_id)
    on conflict do nothing;
    get diagnostics v_ks = row_count;

    -- kullanici_rol EK roller içindir (ana rol taraf_kullanici.rol_id; tetik ana rolü reddeder).

    -- ----------------------------------------------------------- ilgili kişi ---
    drop table if exists _ek_t;
    create temp table _ek_t on commit drop as select t.* from public.taraf t with no data;
    insert into _ek_t (aktarim_id, unvan, bag_id, kisi, musteri, durum, notlar, sube_id, ekleme_tarihi)
    select p.id, left(btrim(p.adsoyad), 120), f.id, 1, 0, coalesce(p.aktif, 1),
           nullif(left(btrim(coalesce(p.notlar, '')), 1000), ''), coalesce(public.fn_aktarim_sube(p.subeid), f.sube_id),
           coalesce(public.fn_aktarim_zaman(p.eklemetarihi), f.ekleme_tarihi)   -- now() DEĞİL: her çalıştırmada değişirdi
      from stg.rehberpersonel p
      join public.taraf f on f.aktarim_kaynak = 1 and f.aktarim_tablo = 'REHBER' and f.aktarim_id = p.rehberid
     where btrim(coalesce(p.adsoyad, '')) <> '';
    v_tatla := (select count(*) from stg.rehberpersonel) - (select count(*) from _ek_t);
    select eklenen, guncellenen into v_te, v_tg from public.fn_aktarim_esitle('taraf', 'REHBERPERSONEL', '_ek_t',
        array['unvan', 'bag_id', 'kisi', 'musteri', 'durum', 'notlar', 'sube_id', 'ekleme_tarihi']);

    -- ----------------------------------------------------------------- izin ---
    drop table if exists _ek_i;
    create temp table _ek_i on commit drop as select i.* from public.personel_izin i with no data;
    insert into _ek_i (aktarim_id, taraf_id, tur, baslangic_tarihi, bitis_tarihi, aciklama, durum, sube_id,
                       talep_tarihi, yerine_id, ekleyen, ekleme_tarihi)
    select z.id, t.id,
           case when btrim(z.izinturu) = '11' then 1
                when btrim(z.izinturu) in ('12', '13', '14', '15', '16', '17', '18') then 2
                when btrim(z.izinturu) = '20' then 3
                when btrim(z.izinturu) in ('19', '21', '23') then 4 else 9 end,
           z.izinbaslangic::date, coalesce(z.izinbitis, z.izinbaslangic)::date,
           left(case when z.birim = 2 then '(Delphi: ' || coalesce(z.izinligunsayisi, 0)::numeric(10, 0) || ' saat) '
                     else '' end || coalesce(z.aciklama, ''), 300), 2,
           coalesce(public.fn_aktarim_sube(z.subeid), t.sube_id),
           z.eklemetarihi::date, public.fn_aktarim_kisi_id(z.vekil),
           coalesce(public.fn_aktarim_kisi_id(z.ekleyen), 0),
           coalesce(public.fn_aktarim_zaman(z.eklemetarihi), public.fn_aktarim_zaman(z.izinbaslangic))
      from stg.personelizin z
      join public.taraf t on t.id = public.fn_aktarim_kisi_id(z.rehberid)
     where btrim(coalesce(z.izinturu, '')) <> '-1' and z.izinbaslangic is not null;
    v_iatla := (select count(*) from stg.personelizin where btrim(coalesce(izinturu, '')) <> '-1')
               - (select count(*) from _ek_i);
    select eklenen, guncellenen into v_ie, v_ig from public.fn_aktarim_esitle('personel_izin', 'PERSONELIZIN', '_ek_i',
        array['taraf_id', 'tur', 'baslangic_tarihi', 'bitis_tarihi', 'aciklama', 'durum', 'sube_id',
              'talep_tarihi', 'yerine_id', 'ekleyen', 'ekleme_tarihi']);

    -- hak kaydı (IZINTURU -1): kişi + yıl başına bir satır; varsa dokunulmaz
    insert into public.personel_izin_hak (taraf_id, yil, hak_gun, aciklama, sube_id)
    select distinct on (t.id, z.donem) t.id, z.donem, coalesce(z.hak, 0), 'Delphi izin hakkı', t.sube_id
      from stg.personelizin z
      join public.taraf t on t.id = public.fn_aktarim_kisi_id(z.rehberid)
     where btrim(coalesce(z.izinturu, '')) = '-1' and coalesce(z.donem, 0) > 0
       and not exists (select 1 from public.personel_izin_hak h where h.taraf_id = t.id and h.yil = z.donem)
     order by t.id, z.donem, z.id;
    get diagnostics v_hak = row_count;

    -- -------------------------------------------------------- personel hareketi ---
    drop table if exists _ek_h;
    create temp table _ek_h on commit drop as select h.* from public.personel_hareket h with no data;
    insert into _ek_h (aktarim_id, taraf_id, tur, yururluk, sube_id, aciklama, kaynak, rol_id)
    select h.id, t.id,
           case h.tur when 1 then 1 when 2 then 2 when 99 then 9 else 99 end,
           h.tarih::date, coalesce(tp.sube_id, t.sube_id), left(coalesce(h.aciklama, ''), 500), 1,
           case when h.rolid = -1 then v_yonetici end
      from stg.pers_hareket h
      join public.taraf t on t.id = public.fn_aktarim_kisi_id(h.rehberid)
      left join public.taraf_personel tp on tp.id = t.id
     where h.tarih is not null;
    v_hatla := (select count(*) from stg.pers_hareket) - (select count(*) from _ek_h);
    select eklenen, guncellenen into v_he, v_hg from public.fn_aktarim_esitle('personel_hareket', 'PERS_HAREKET', '_ek_h',
        array['taraf_id', 'tur', 'yururluk', 'sube_id', 'aciklama', 'kaynak', 'rol_id']);

    return jsonb_build_object(
        'kullanici', jsonb_build_object('eklenen', v_ke, 'guncellenen', v_kg, 'karti_yok', v_katla,
                                        'web_hesabi_korundu', v_kweb, 'personel_yapilan', v_per,
                                        'personel_karti', v_tp, 'eposta_cakisma', v_epc, 'sube', v_ks),
        'ilgili_kisi', jsonb_build_object('eklenen', v_te, 'guncellenen', v_tg, 'atlanan', v_tatla),
        'izin', jsonb_build_object('eklenen', v_ie, 'guncellenen', v_ig, 'atlanan', v_iatla, 'hak', v_hak),
        'personel_hareket', jsonb_build_object('eklenen', v_he, 'guncellenen', v_hg, 'atlanan', v_hatla));
end $$;

comment on function public.fn_aktar_ek_kisi() is
    '1144: Delphi KULLANICI/ROLLER -> taraf_kullanici (+personel, şube, rol; parola yok), REHBERPERSONEL -> ilgili kişi kartı, PERSONELIZIN -> personel_izin (+hak), PERS_HAREKET -> personel_hareket. İdempotent.';

commit;
