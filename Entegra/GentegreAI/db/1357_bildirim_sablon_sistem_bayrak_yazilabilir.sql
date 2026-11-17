-- 1357 - Sistem şablonu bayrağı göçle kaldırılabilsin (17.11.2026, 1356 düzeltmesi).
--   1354/1356 tetiği UPDATE'te `new.sistem := 1` yazıyordu: bayrak bir kez verilince hiçbir yoldan kaldırılamıyordu
--   (1356'nın test artığı temizliği bu yüzden etkisiz kaldı). Bayrak zaten API'den yazılamaz (kart alanı salt okunur);
--   tetik yalnız KOD değişikliğini ve SİLMEYİ engeller.
create or replace function public.tg_bildirim_sablon_sistem()
returns trigger language plpgsql as $$
begin
  if tg_op = 'INSERT' then return new; end if;
  if old.sistem = 1 then
    if tg_op = 'DELETE' then
      raise exception using errcode = 'GK422',
        message = 'Sistem şablonu silinemez (kodu programda geçer) - kullanılmasın isteniyorsa Durum''u Pasif yapın.';
    end if;
    if new.kod is distinct from old.kod then
      raise exception using errcode = 'GK422',
        message = 'Sistem şablonunun kodu değiştirilemez - ilgili ekran şablonu bu kodla bulur.';
    end if;
  end if;
  return case when tg_op = 'DELETE' then old else new end;
end $$;
comment on function public.tg_bildirim_sablon_sistem() is
  '1354/1357: sistem şablonunda kod değişmez, satır silinmez. Bayrak yalnız göçle verilir / kaldırılır.';

update public.bildirim_sablon set sistem = 0 where kod = 'test.pasif' and sistem = 1;
