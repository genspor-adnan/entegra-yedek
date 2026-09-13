-- =====================================================================
--  641_lab_istem_no_tetik.sql
--  İSTEM NUMARASI KAYDEDERKEN OTOMATİK (kullanici: "lab istem kartinda
--  Istem No editi kaldir, bu kaydedince otomatik olsun; duzenle diye
--  girince baslikta gorsun").
--
--  Numara tek yerden üretiliyordu: `LabServisi.IstemAcAsync`. Kart
--  üzerinden (Yeni > Kaydet) açılan istem o yoldan geçmiyor - `KartDeposu`
--  doğrudan tabloya yazıyor - ve numara BOŞ kalıyordu. Kullanıcı da boş
--  kutuyu kendi doldurmak zorunda kalıyordu; elle yazılan numara ise
--  sayaçla çakışabilirdi.
--
--  TETİK TABLONUN KENDİSİNDE: hangi yoldan yazılırsa yazılsın (uç, kart,
--  göç, elle SQL) numarasız istem oluşmaz. Uygulama katmanına koymak,
--  "bir yol daha eklenince yine unutulur" demekti - nitekim öyle oldu.
--
--  DOLU GELEN NUMARAYA DOKUNULMAZ: göç ve dış entegrasyon kendi
--  numarasıyla gelir. Sayaç da boşuna ilerlemez.
-- =====================================================================

create or replace function public.tg_lab_istem_no() returns trigger
language plpgsql as $tetik$
begin
    if coalesce(new.istem_no, '') = '' then
        -- Numaralandırma ayarı (633/634): tür 901 şablonu varsa ön ek ve
        --   hane oradan, yoksa LAB-YYYY/#####.
        new.istem_no := public.fn_lab_istem_no_uret(
                            coalesce(new.sube_id, 0),
                            coalesce(new.istem_tarihi::date, current_date));
    end if;
    return new;
end $tetik$;

drop trigger if exists tg_lab_istem_no on public.lab_istem;
create trigger tg_lab_istem_no
    before insert on public.lab_istem
    for each row execute function public.tg_lab_istem_no();

comment on function public.tg_lab_istem_no() is
  '641: istem numarasi bos gelirse sablondan uretilir - kart, uc ve goc '
  'ayni numarayi ayni yerden alsin.';

do $kontrol$
begin
    raise notice '641 tamam: numarasiz istem % (hepsi goc verisi)',
        (select count(*) from public.lab_istem where coalesce(istem_no, '') = '');
end $kontrol$;
