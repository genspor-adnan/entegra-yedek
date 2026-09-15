-- 704: GÖRÜNTÜLEME ÖLÇÜMÜ AYNI ÇEKİMDE TEK SATIR.
--
-- 703'te ölçüm satırlarına mesaj kimliği eklenmiş ve mükerrer yazım refraksiyon
-- ile tonometride engellenmişti; GÖRÜNTÜLEME ÖLÇÜMÜ atlanmıştı. Sonuç: cihaz
-- mesajı ikinci kez işlendiğinde (sürücü düzeltildi, düğmeye iki kez basıldı)
-- aynı OCT çekiminde "RNFL 78,4" iki kez göründü — trend eğrisi aynı günü iki
-- nokta sayar ve "değişmedi" diyen bir grafik çizer.
--
-- KURAL: bir çekimde, bir gözde, bir ölçüm kodundan BİR satır. Aynı kod tekrar
-- gelirse (yeniden işleme) değer GÜNCELLENİR - ikinci satır açmak, hangisinin
-- geçerli olduğunu belirsiz bırakırdı.
--
-- ÖNCE MÜKERRERLERİ TEMİZLE: en son yazılan satır kalır (yeniden işleme,
-- düzeltilmiş sürücünün çıktısıdır).
delete from public.goz_goruntuleme_olcum o
 where exists (
     select 1 from public.goz_goruntuleme_olcum y
      where y.goruntuleme_id = o.goruntuleme_id
        and y.goz = o.goz
        and y.olcum = o.olcum
        and y.id > o.id);

create unique index if not exists ux_goz_goruntuleme_olcum
  on public.goz_goruntuleme_olcum (goruntuleme_id, goz, olcum);

comment on index public.ux_goz_goruntuleme_olcum is
  'Bir çekimde bir gözde bir ölçüm kodundan tek satır (704): mükerrer satır, '
  'trend eğrisinde aynı günü iki nokta sayardı.';
