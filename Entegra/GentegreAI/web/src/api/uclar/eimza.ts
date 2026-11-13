import { gonder, istek } from '../cekirdek';

/**
 * e-İMZA (1337, kullanıcı 13.11.2026): radyoloji raporu GenSigner (Sign-Server) ile XAdES enveloping imzalanır.
 * İki kip (Ayarlar › Entegrasyon Hesapları › EIMZA, ayarlar.kip):
 *   istemci → kart hekimin bilgisayarında; tarayıcı localhost GenSigner'a gider (bkz. bilesenler/eimza/genSigner.ts),
 *             imzalı XML API'ye gönderilir. PIN sunucuya gitmez.
 *   sunucu  → kart sunucuda; rapor HTML'i + PIN API'ye gider, API sunucudaki GenSigner'a imzalatır.
 */
export interface EImzaAyar { aktif: boolean; kip: 'istemci' | 'sunucu'; url: string; apiKey: string }

/** GenSigner sertifika satırı (CertificateObject). */
export interface EImzaSertifika {
  libraryAlias: string; slotId: number; serial: string; serialNumber?: string; cn?: string; subject?: string;
  issuer?: string; keyUsageSign?: boolean; dateValid?: boolean; notAfter?: unknown;
}

export interface EImzaKart { libraryAlias: string; slotId: number; serial: string; cn?: string }

export const eimzaUclari = {
  eimzaAyar: () => istek<EImzaAyar>('/api/eimza/ayar'),
  /** Sunucu kipi: sunucudaki GenSigner'ın gördüğü kartlar. */
  eimzaSertifikalar: () => istek<{ sertifikalar: EImzaSertifika[] }>('/api/eimza/sertifikalar'),
  /** İmza hazırlığı: kilit / sürüm / onaylanabilirlik denetimi + resmi rapor no; dönen sürümle çıktı çizilip imzalanır. */
  radyolojiRaporImzaHazirla: (raporId: number, surum: string) =>
    gonder<{ raporNo: string; surum: string; kip: 'istemci' | 'sunucu' }>(
      `/api/radyoloji/rapor/${raporId}/imza-hazirla?surum=${encodeURIComponent(surum)}`, {}),
  /** Rapor e-imza + onay (RadyolojiUclari.Imza): imzalı XML doküman deposuna, rapor onaylanıp kilitlenir. */
  radyolojiRaporImzala: (raporId: number, surum: string, govde: {
    html: string; mimeType: string; sertifika: EImzaKart; imzaBase64?: string; pin?: string;
  }) => gonder<{ tamam: boolean; dokumanId: number; imzaSertifika: string; paket?: unknown }>(
    `/api/radyoloji/rapor/${raporId}/imzala?surum=${encodeURIComponent(surum)}`, govde),
};
