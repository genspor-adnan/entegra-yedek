-- 242: Şubesiz kalan kullanıcılara ÇALIŞTIĞI şube yetkisi (kullanıcı: "alt
-- oturumda Merkez diye gelmedi").
--
-- 239'da açılan hesaplara kullanici_sube kaydı yazılmamıştı: kişi şubesiz
-- giriş yapıyor, şube seçici ve oturum bilgisi boş kalıyordu. Otomatik hesap
-- açma artık çalıştığı şubeyi de yetkilendiriyor; bu betik mevcut boşlukları
-- kapatır (varsayılan + yazma).

insert into public.kullanici_sube (taraf_id, sube_id, varsayilan, yazma, ekleyen)
select k.id, t.sube_id, 1, 1, 0
  from public.taraf_kullanici k
  join public.taraf t on t.id = k.id
  join public.sube s on s.id = t.sube_id and s.aktif = 1
 where not exists (select 1 from public.kullanici_sube ks where ks.taraf_id = k.id);
