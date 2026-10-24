-- ---------------------------------------------------------------------------
--  STOK GİRİŞ / ÇIKIŞ FİŞİ (3 / 4) OTOMATİK FİŞLENMEZ.
--
--  Kullanıcı 24.10.2026 (UNIVERSE, giriş fişi kaydı): fiş carisizdir; muhasebe
--  karşılığı cari değil gider / gelir hesabıdır (fire, sayım farkı - fişin TİPİ)
--  ve o eşleme henüz yok (liste tanımı: "F7'de bağlanacak"). fn_belge_fis_turu_uygun
--  bu türleri fişlenebilir saydığı için kayıt "Cari için muhasebe hesabı
--  çözülemedi" ile bütün transaction'ı (stok girişi dahil) geri alıyordu - üretim
--  belgelerindeki (429) aynı hata, aynı çözüm: eşleme gelene kadar fiş üretilmez.
--
--  Yalnız fonksiyon tanımı değişir; tablo / veri dokunulmaz. Tekrar çalıştırılabilir.
-- ---------------------------------------------------------------------------
create or replace function public.fn_belge_fis_turu_uygun(p_tur integer)
returns boolean language sql immutable as $$
    -- Fişlenmeyen (mali sonuç faturada doğan) belgeler:
    --   9/19 sipariş · 18 teklif · 105 talep · 10/14 irsaliye ·
    --   109/119 konsinye · 20 transfer · 13/17 tahakkuk · 30 eski başvuru ·
    --   121/122/123 üretim sarf / mamul girişi / fire (429) ·
    --   3/4 stok giriş / çıkış fişi (1167 - gider/gelir eşlemesi gelene kadar).
    select coalesce(p_tur, 0)
           not in (3, 4, 9, 10, 13, 14, 17, 18, 19, 20, 30, 105, 109, 119,
                   121, 122, 123);
$$;
