import { useState } from 'react';

/**
 * AMELİYATHANE ve ACİL EKRAN MODALLARI - tek yerde toplanan durum.
 *
 * İKİ MODÜL, TEK KANCA. Ayrı iki dosya, dosya başına bir-iki `useState`
 * demek olurdu; ikisi de aynı `Liste` gövdesine bağlanıyor ve aynı anda en
 * çok biri açık oluyor. Radyolojide (sekiz modal) ayırmak yerindeydi, burada
 * ayırmak yalnız dosya sayısını artırırdı.
 *
 * Aksiyon modülleri (`ameliyathaneAksiyonlari` · `acilAksiyonlari`) bu
 * setter'ları bağlam olarak alır; çizimi `AmeliyatAcilModallari` yapar.
 */
export function useAmeliyatAcilModallari() {
  /** Bekleyen talepten ameliyat doğuran modal (715/719). */
  const [planlama, setPlanlama] = useState<
    { talepId: number; talepNo?: string; hastaAdi?: string; islem?: string;
      tahminiSure?: number; eksikler?: string } | null>(null);

  /** Güvenli cerrahi kontrol listesi (DSÖ) - kesinin kapısı. */
  const [kontrol, setKontrol] = useState<
    { ameliyatId: number; ameliyatNo?: string } | null>(null);

  /** Ameliyat → fatura ve sarf → stok (720): ne aktarıldı, ne bekliyor. */
  const [faturaStok, setFaturaStok] = useState<
    { ameliyatId: number; ameliyatNo?: string } | null>(null);

  /** Acil çıkış kararı: şekil + ICD tanısı + hedef bölüm + not. */
  const [acilCikis, setAcilCikis] = useState<
    { basvuruId: number; protokolNo?: string; hastaAdi?: string } | null>(null);

  return { planlama, setPlanlama, kontrol, setKontrol,
           faturaStok, setFaturaStok, acilCikis, setAcilCikis };
}

export type AmeliyatAcilModalDurumu = ReturnType<typeof useAmeliyatAcilModallari>;
