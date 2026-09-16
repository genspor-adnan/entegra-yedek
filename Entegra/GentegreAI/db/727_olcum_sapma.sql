-- =====================================================================
--  727_olcum_sapma.sql
--  `fn_demirbas_olcum_sonuc` sapmayı da hesaplasın (723'ün eksiği).
--
--  NE OLUYORDU. Tetik yalnız `sonuc`u (sınır içi / sınır dışı) yazıyordu;
--    `sapma` ve `sapma_yuzde` kolonları dolmuyordu. Kart bu iki alanı SALT
--    OKUNUR gösterdiği için hiçbir yoldan da doldurulamıyordu - ölçüm
--    kaydedildi, "ne kadar saptı" sorusu yanıtsız kaldı.
--
--  NEDEN ELLE GİRİLMİYOR. Sapma, nominal ile ölçülenin farkıdır: kullanıcının
--    yazdığı bir sapma, kendi ölçümüyle çelişebilirdi. Sertifikada üç sayı
--    birden durur ve biri diğer ikisiyle tutmazsa hangisinin doğru olduğu
--    sonradan bilinemez.
--
--  YÜZDE NOMİNAL 0 İKEN YAZILMAZ (sıfıra bölme değil, anlamsızlık): sıfır
--    noktasında "% kaç saptı" sorusunun yanıtı yoktur - mutlak sapma vardır.
-- =====================================================================

create or replace function public.fn_demirbas_olcum_sonuc()
returns trigger language plpgsql as $tg$
begin
    -- SAPMA: ölçülen - nominal. İşaret KORUNUR - cihazın hep yukarı mı yoksa
    --   hep aşağı mı saptığı, ayar yönünü belirleyen bilgidir.
    if new.olculen is not null and new.nominal is not null then
        new.sapma := new.olculen - new.nominal;
        new.sapma_yuzde := case when new.nominal <> 0
                                then round((new.olculen - new.nominal) * 100 / new.nominal, 2)
                           end;
    else
        new.sapma := null;
        new.sapma_yuzde := null;
    end if;

    if new.olculen is null then
        new.sonuc := 0;
    elsif (new.alt_sinir is not null and new.olculen < new.alt_sinir)
       or (new.ust_sinir is not null and new.olculen > new.ust_sinir) then
        new.sonuc := 2;
    elsif new.alt_sinir is null and new.ust_sinir is null then
        new.sonuc := coalesce(new.sonuc, 0);   -- sinir metinle verilmis
    else
        new.sonuc := 1;
    end if;
    return new;
end;
$tg$;

-- TETİK NOMİNAL DEĞİŞİNCE DE ÇALIŞMALI: 723'te `of olculen, alt_sinir,
--   ust_sinir` yazıyordu - nominal düzeltilirse sapma eski değerde kalırdı.
drop trigger if exists tg_demirbas_olcum_sonuc on public.demirbas_kalibrasyon_olcum;
create trigger tg_demirbas_olcum_sonuc
  before insert or update of olculen, nominal, alt_sinir, ust_sinir
  on public.demirbas_kalibrasyon_olcum
  for each row execute function public.fn_demirbas_olcum_sonuc();

-- Mevcut satırları tazele (tetik yeniden çalışsın).
update public.demirbas_kalibrasyon_olcum set olculen = olculen;
