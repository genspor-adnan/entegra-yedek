-- 329: PRİM PLAN SATIRI SİLİNEMİYORSA ANLAŞILIR MESAJ.
--
-- Hakediş satırı, hangi kuralın uygulandığını göstermek için plan satırına
-- bağlıdır (denetim izi). Kullanılmış bir plan satırı silinmek istendiğinde
-- veritabanı ham yabancı anahtar hatası veriyordu ("violates foreign key
-- constraint hakedis_satir_plan_satir_id_fkey") ve ekranda "Beklenmeyen bir
-- hata oluştu" yazıyordu.
--
-- Bağ KOPARILMIYOR (on delete set null yapılmadı): prim tutarının hangi plan
-- satırından çıktığı kaydın kendisi kadar önemli - kural sonradan değişse
-- bile geçmiş hakediş açıklanabilir kalmalı. Bunun yerine silme, iş kuralı
-- hatasıyla (GK422) engellenir; kullanıcı satırı silmek yerine oranını
-- değiştirir ya da yeni bir plan açar.

create or replace function public.tg_prim_satir_silme()
returns trigger language plpgsql as $$
declare v_adet integer;
begin
    select count(*) into v_adet
      from public.hakedis_satir h where h.plan_satir_id = old.id;

    if v_adet > 0 then
        raise exception
            'Bu prim satırı % hakediş satırında kullanılmış, silinemez. Oranını değiştirebilir ya da planı kapatıp yeni plan açabilirsiniz.',
            v_adet using errcode = 'GK422';
    end if;
    return old;
end $$;

drop trigger if exists tr_prim_satir_silme on public.prim_plani_satir;
create trigger tr_prim_satir_silme
  before delete on public.prim_plani_satir
  for each row execute function public.tg_prim_satir_silme();

comment on function public.tg_prim_satir_silme is
  'Kullanilmis prim plan satirinin silinmesini anlasilir mesajla engeller (329).';

-- Ayni gerekce PLAN BASLIGI icin de gecerli: basligi silmek satirlarini da
--   silmeye calisir (cascade) ve ayni ham hatayla dusuyordu.
create or replace function public.tg_prim_plani_silme()
returns trigger language plpgsql as $$
declare v_adet integer;
begin
    select count(*) into v_adet
      from public.hakedis_satir h where h.plan_id = old.id;

    if v_adet > 0 then
        raise exception
            'Bu prim planından % hakediş satırı üretilmiş, plan silinemez. Planı pasife alabilirsiniz (Aktif kutusunu kaldırın).',
            v_adet using errcode = 'GK422';
    end if;
    return old;
end $$;

drop trigger if exists tr_prim_plani_silme on public.prim_plani;
create trigger tr_prim_plani_silme
  before delete on public.prim_plani
  for each row execute function public.tg_prim_plani_silme();

-- ------------------------------------------------- kalem turu normalizasyonu
-- Kapsamli satirda (Kategori/Urun) kalem turu BOS kalmamali: "farketmez"
-- birakilirsa kategori listesi ve urun aramasi suzulemez, kullanici da
-- kapsamin hangi taraftan (stok mu hizmet mi) secildigini goremez.
-- Varsayilan HIZMET: prim hizmet kaleminden dogar (stok primi istisnadir).
update public.prim_plani_satir
   set kalem_turu = 2
 where tip in (2, 3) and coalesce(kalem_turu, 0) = 0;

create or replace function public.tg_prim_kapsam()
returns trigger language plpgsql as $$
begin
    if new.tip in (2, 3) and coalesce(new.hedef_id, 0) = 0 then
        raise exception 'Kapsam seçilmeli: tip Kategori ya da Ürün ise kapsam boş bırakılamaz.'
            using errcode = 'GK422';
    end if;
    if new.tip = 1 then
        new.hedef_id := null;
    -- Kapsamli satirda kalem turu bos birakilamaz (bkz. yukaridaki gerekce).
    elsif coalesce(new.kalem_turu, 0) = 0 then
        new.kalem_turu := 2;
    end if;
    return new;
end $$;
