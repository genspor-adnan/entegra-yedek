import { createContext } from 'react';

/**
 * EKRAN SEKMESİ GÖRÜNÜR MÜ (ana ekran v3, mockup Ekranlar/Ayarlar/ana_ekran_sekmeli_v3.html).
 *
 * Açık ekranlar sekmede CANLI tutulur (dönünce kaldığı yerde). Gizli sekmenin
 * penceresi (kart Modal'ı body'ye portal ile çizilir) aktif sekmenin üstünde
 * görünmemeli ve Esc'e tepki vermemeli - Modal ve useEscIleKapat bunu okur.
 * Sekmesiz çalışan her yerde varsayılan `true`: davranış değişmez.
 */
export const SekmeGorunurBaglami = createContext(true);

/**
 * İÇİNDE BULUNULAN EKRAN SEKMESİ: ekran kendi sekmesini kapatabilir (ör. "Yeni Hasta
 * Kartı" sekmesinde Kaydet -> sekme kapanır, listeye dönülür). Sekmeler kapalıyken null.
 */
export const EkranSekmesiBaglami = createContext<{ kapat(hedef?: string): void; baslik(ad: string, yol: string): void } | null>(null);

/** Bir listenin kayıtları değişti (başka sekmeden): liste tazelenir. detail = kaynak. */
export const LISTE_TAZELE_OLAYI = 'gentegre-liste-tazele';
