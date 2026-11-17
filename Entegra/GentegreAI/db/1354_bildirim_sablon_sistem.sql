-- 1354 - Bildirim şablonu kartı (mockup Ekranlar/Ayarlar/bildirim_sablonu_karti.html, 17.11.2026).
--   SİSTEM ŞABLONU: kodu programda geçen şablon (basvuru.kvkk_sms, kimlik.parola_sifirlama, onam.istek …). Kodu
--   değişirse ilgili ekran şablonu bulamaz; silinirse gönderim düşer. Göçlerle kurulanlar (ekleyen = 0) sistem
--   şablonudur; kullanıcının açtığı şablon değildir. Sistem şablonunda KOD değiştirilemez ve SATIR silinemez
--   (metin, ad, durum, saat değişebilir - durum Pasif yapılabilir).
alter table public.bildirim_sablon add column if not exists sistem smallint not null default 0;
comment on column public.bildirim_sablon.sistem is
  '1354: 1 = kodu programda geçen sistem şablonu - kod değişmez, silinmez (tg_bildirim_sablon_sistem).';
update public.bildirim_sablon set sistem = 1 where ekleyen = 0 and sistem = 0;

create or replace function public.tg_bildirim_sablon_sistem()
returns trigger language plpgsql as $$
begin
  if tg_op = 'INSERT' then
    -- Göçle eklenen (ekleyen 0) sistem şablonudur.
    if coalesce(new.ekleyen, 0) = 0 then new.sistem := 1; end if;
    return new;
  end if;
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
comment on function public.tg_bildirim_sablon_sistem() is '1354: sistem şablonunda kod değişmez, satır silinmez.';

drop trigger if exists tr_bildirim_sablon_sistem on public.bildirim_sablon;
create trigger tr_bildirim_sablon_sistem
  before insert or update or delete on public.bildirim_sablon
  for each row execute function public.tg_bildirim_sablon_sistem();
