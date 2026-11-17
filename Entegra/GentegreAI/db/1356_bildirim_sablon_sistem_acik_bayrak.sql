-- 1356 - Sistem şablonu bayrağı yalnız AÇIKÇA verilir (17.11.2026, 1354 düzeltmesi).
--   1354'teki tetik ekleyen = 0 ile eklenen HER şablonu sistem şablonu yapıyordu; ekleyeni boş gelen bir kayıt
--   (test fikstürü, aktarım) silinemez hale geldi (BildirimKuyruguTestleri "test.pasif"). Artık INSERT'te bayrağa
--   dokunulmaz: göçle gelen yeni sistem şablonları `sistem = 1`'i kendisi yazar. 1354'te işaretlenen mevcut satırlar
--   (kurulum anındaki göç şablonları) aynen kalır. Koruma (kod değişmez / silinmez) aynı.
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
    new.sistem := 1;
  end if;
  return case when tg_op = 'DELETE' then old else new end;
end $$;
comment on function public.tg_bildirim_sablon_sistem() is
  '1354/1356: sistem şablonunda kod değişmez, satır silinmez. Bayrak INSERT''te otomatik verilmez.';

-- Test fikstürü artığı (1354 tetiği yüzünden silinemeyen): yalnız bilinen test kodu.
update public.bildirim_sablon set sistem = 0 where kod = 'test.pasif' and sistem = 1;
