-- =====================================================================
--  533_ttb_fiyat_turetilmis.sql
--  TTB/HUV tarifesinde FİYAT TÜRETİLMİŞTİR: katsayı × çarpan.
--
--  Kullanıcı: "TTB/HUV'da da fiyat değişmez. Katsayı (elle girilir veya
--  listeden alınır), çarpan (elle girilir veya listeden alınır). Katsayı ve
--  çarpan değişince çarpımdan fiyat oluşur. Katkı yine elle girilir."
--
--  518'de çarpan değişince fiyat yeniden yazılıyordu (`fn_sls_carpan_manuel`)
--  ama iki delik vardı:
--    * KATSAYI (taban_fiyat) değişince fiyat OLDUĞU GİBİ kalıyordu - SKRS
--      puanı güncellenince liste eski fiyatı göstermeye devam ediyordu.
--    * FİYAT ELLE YAZILABİLİYORDU - girilen sayı bir sonraki çarpan
--      değişiminde sessizce kayboluyor, arada provizyona yanlış tutar
--      gidiyordu. "Değişmez" olan bir alanı yazılabilir bırakmak, kullanıcıya
--      tutmayacağı bir söz vermektir.
--
--  KURAL ARTIK TEK YERDE (bu tetik):
--    tarife 2 (TTB/HUV) -> fiyat = yuvarla(katsayı × çarpan). Kullanıcının
--      fiyat alanına yazdığı değer YOK SAYILIR (hata verilmez: aynı kaydetme
--      katsayı/çarpan değişimini de taşıyabilir).
--    tarife 3 (SUT)     -> fiyat SKRS'den; elle değişirse GK422 (518).
--    tarife 1 (Özel)    -> fiyat elle; dokunulmaz.
--  Katkı (`katki_tutar`) her tarifede ELLE - toplu üretim (fn_fiyat_katki_uret)
--  bir başlangıç doldurur, kilit koymaz.
-- =====================================================================

create or replace function public.tg_fiyat_satir_tarife() returns trigger
language plpgsql as $$
declare
    v_tip     smallint;
    v_yeni    numeric;
    v_yukleme boolean := coalesce(current_setting('gentegre.sut_yukleme', true), '') = '1';
begin
    select tarife_tipi into v_tip from public.fiyat_listesi where id = new.liste_id;
    v_tip := coalesce(v_tip, 0);

    -- TTB/HUV: FİYAT TÜRETİLMİŞ DEĞERDİR. Katsayı ya da çarpan hangi yoldan
    --   gelirse gelsin (elle giriş, toplu fn_fiyat_carpan, SKRS puan yükleme)
    --   fiyat aynı çarpımdan doğar - listede iki farklı gerçek olmaz.
    if v_tip = 2 then
        if coalesce(new.taban_fiyat, 0) > 0 and coalesce(new.carpan, 0) > 0 then
            select public.fn_fiyat_yuvarla(new.taban_fiyat * new.carpan,
                       coalesce(new.yuvarlama, fl.yuvarlama),
                       coalesce(new.yuvarlama_birim, fl.yuvarlama_birim))
              into v_yeni
              from public.fiyat_listesi fl
             where fl.id = new.liste_id;
            new.fiyat := coalesce(v_yeni, new.fiyat);
        elsif tg_op = 'UPDATE' and new.fiyat is distinct from old.fiyat then
            -- Katsayı/çarpan yoksa çarpım da yok: eski fiyat korunur ki
            --   elle yazılan sayı "kalıcı" sanılmasın.
            new.fiyat := old.fiyat;
        end if;
    end if;

    -- SUT: fiyat SKRS'den gelir; yükleyici dışında değiştirilemez.
    if v_tip = 3 and tg_op = 'UPDATE'
       and new.fiyat is distinct from old.fiyat
       and not v_yukleme then
        raise exception 'SUT fiyatı elle değiştirilemez - SKRS/SUT aktarımından gelir.'
              using errcode = 'GK422';
    end if;

    return new;
end $$;

-- Tetik KATSAYIYI da dinler: eskiden yalnız `fiyat, carpan, liste_id`
--   kolonlarında çalışıyordu, katsayı değişimi fiyatı tazelemiyordu.
drop trigger if exists zz_fiyat_satir_tarife on public.fiyat_listesi_satir;
create trigger zz_fiyat_satir_tarife
    before insert or update of fiyat, carpan, taban_fiyat, liste_id
    on public.fiyat_listesi_satir
    for each row execute function public.tg_fiyat_satir_tarife();

/**
 * KATSAYIYI LİSTEDEN AL: TTB/HUV katsayısı SKRS'nin tıbbi işlem puanıdır.
 * Elle girilebilir (satırdan) ya da bu fonksiyonla topluca tazelenir -
 * puanlar yılda bir güncelleniyor, 4 bin satırı tek tek yazmak işi değil.
 * Fiyat tetikle kendiliğinden yeniden doğar.
 *
 * p_kategori verilirse yalnız o dal (alt kategorileriyle).
 * Dönen: katsayısı değişen satır sayısı.
 */
create or replace function public.fn_fiyat_katsayi_yukle(
    p_liste integer, p_kategori integer default null)
returns integer language plpgsql as $$
declare v_sayi integer;
begin
    with recursive dal as (
        select p_kategori::integer id
        union all
        select k.id from public.kategori k join dal d on k.ust_id = d.id
    )
    update public.fiyat_listesi_satir s
       set taban_fiyat = p.puan,
           carpan = coalesce(nullif(s.carpan, 0), 1)
      from public.hizmet h
      join public.skrs_islem_puan p on p.kod = h.kod and p.aktif = 1
     where s.hizmet_id = h.id
       and s.liste_id = p_liste
       and coalesce(p.puan, 0) > 0
       and s.taban_fiyat is distinct from p.puan
       and (p_kategori is null or h.kategori in (select id from dal));
    get diagnostics v_sayi = row_count;
    return v_sayi;
end $$;

comment on function public.fn_fiyat_katsayi_yukle(integer, integer) is
    'TTB/HUV katsayısını SKRS tıbbi işlem puanından topluca tazeler; fiyat tetikle yeniden doğar (533).';

comment on function public.tg_fiyat_satir_tarife() is
    'Tarife kuralı: TTB/HUV fiyatı katsayı × çarpan (elle yazılamaz), SUT fiyatı SKRS''den kilitli, Özel elle (533).';
