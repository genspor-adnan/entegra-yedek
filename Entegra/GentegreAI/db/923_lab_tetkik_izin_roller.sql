-- =====================================================================
--  923_lab_tetkik_izin_roller.sql
--  TEST SEVİYESİ YETKİSİ — ROL KÜMESİYLE KARAR (denetim 28.09.2026 #7)
--
--  SORUN: 889'daki `fn_lab_tetkik_izin(tetkik, ROL, işlem)` tek rol alıyor
--  ve API bu rolü JWT'deki `rolId` talebinden veriyordu:
--    * ana rol değişince eski rolün tetkik izni token yenilenene kadar
--      (30 dk) sürüyordu,
--    * EK ROLLER (665) hiç sorulmuyordu - kısıtlı tetkik için ek rolüyle
--      izinli kullanıcı sonucu göremiyordu.
--
--  ÇÖZÜM: aynı kuralı ROL KÜMESİYLE soran fonksiyon. Küme API'de her istekte
--  `fn_kullanici_rolleri`den (ana + ek, yalnız aktif hesap) okunur ve dizi
--  olarak verilir; kümedeki herhangi bir rol izinliyse izin vardır (genel
--  yetki çözümüyle aynı birleşim kuralı, 665).
--
--  KURAL DEĞİŞMEDİ: kısıtsız tetkik herkese açık, tanınmayan işlem KAPALI,
--  boş rol kümesi kısıtlı tetkikte KAPALI. 889'daki tek-rol fonksiyonu
--  geriye uyum için yerinde kalır; karar tek yerde kalsın diye iki fonksiyon
--  aynı gövdeyi paylaşır (tek rol = tek elemanlı küme).
--
--  Tekrar çalıştırılabilir: yalnız `create or replace`.
-- =====================================================================

create or replace function public.fn_lab_tetkik_izin_roller(p_tetkik_id integer,
                                                            p_rol_idleri integer[],
                                                            p_islem varchar)
returns boolean language sql stable as $$
    select case
             when p_islem not in ('iste', 'gor', 'onayla') then false
             -- Kısıtlanmamış tetkik: herkese açık.
             when not exists (select 1 from public.lab_tetkik_kisit k
                               where k.tetkik_id = p_tetkik_id and k.aktif = 1)
                  then true
             else exists (
                    select 1 from public.lab_tetkik_kisit k
                     where k.tetkik_id = p_tetkik_id and k.aktif = 1
                       and k.rol_id = any(coalesce(p_rol_idleri, '{}'::integer[]))
                       and case p_islem
                             when 'iste'   then k.iste
                             when 'gor'    then k.gor
                             else               k.onayla
                           end = 1)
           end;
$$;

comment on function public.fn_lab_tetkik_izin_roller(integer, integer[], varchar) is
  '923: rol KUMESI (ana + ek) bu tetkikte bu islemi yapabilir mi. Kumedeki '
  'herhangi bir rol yeterli; kisitsiz tetkik acik, taninmayan islem KAPALI.';

-- Tek-rol sürümü aynı kararı verir: gövde tek yerde kalsın.
create or replace function public.fn_lab_tetkik_izin(p_tetkik_id integer,
                                                     p_rol_id    integer,
                                                     p_islem     varchar)
returns boolean language sql stable as $$
    select public.fn_lab_tetkik_izin_roller(p_tetkik_id, array[p_rol_id], p_islem);
$$;

do $$
begin
    -- Sınama: kısıtsız tetkik açık, bilinmeyen işlem kapalı.
    if public.fn_lab_tetkik_izin_roller(-1, '{}'::integer[], 'gor') is not true then
        raise exception '923: kisitsiz tetkik acik olmali';
    end if;
    if public.fn_lab_tetkik_izin_roller(-1, '{}'::integer[], 'sil') is not false then
        raise exception '923: taninmayan islem kapali olmali';
    end if;
    raise notice '923 tamam: fn_lab_tetkik_izin_roller';
end $$;
