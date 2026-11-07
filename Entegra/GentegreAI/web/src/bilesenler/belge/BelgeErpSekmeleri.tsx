import { TasiyiciSekmesi, EBelgeSekmesi, FaturalamaSekmesi }
  from './BelgeSekmeleri';
import type { useSevkiyatBilgisi } from '../../sayfalar/belgeKarti/useSevkiyatBilgisi';
import { c } from '../../dil/ceviri';

/**
 * ERP BELGESİNE ÖZGÜ SEKMELER: Taşıyıcı · e-Belge · Faturalama · İmza.
 *
 * Dördü de aynı kümeden besleniyor (sevkiyat, senaryo, dönüşümler) ve
 * başvuruda hiç çizilmiyor; kartın gövdesinde tek tek durdukça sekme
 * koşulları başvuru sekmeleriyle iç içe geçiyordu. Burada hangi sekmede ne
 * çizildiği bir bakışta okunur.
 */
export function BelgeErpSekmeleri({ aktifSekme, kilitli, sevkiyat, belge,
                                    irsaliyeMi, tur, basvuruMu, senaryo, setSenaryo, senaryoBaslikta,
                                    faturalama, belgeYenile }: {
  aktifSekme: string;
  kilitli: boolean;
  sevkiyat: ReturnType<typeof useSevkiyatBilgisi>;
  belge?: Record<string, unknown>;
  irsaliyeMi: boolean;
  tur: number;
  /** BAŞVURU (HBYS, tur 19 ile aynı!): Belgeye Dönüşüm sekmesi başvuruda hızlı düğmeleriyle AYNEN kalır
      (kullanıcı 07.11.2026 "sipariş kartında yapılanlar başvuru kartını etkilemesin"). */
  basvuruMu?: boolean;
  senaryo: number;
  setSenaryo(v: number): void;
  /** Faturada senaryo başlıkta seçilir - sekmede yok. */
  senaryoBaslikta?: boolean;
  /** Faturalama sekmesinin tüm girdisi - kart kurar, burada aynen geçer. */
  faturalama: React.ComponentProps<typeof FaturalamaSekmesi>;
  /** Belge başlığını sunucudan yeniden oku (e-Fatura menüsünden sonra). */
  belgeYenile?(): void;
}) {
  if (aktifSekme === 'tasiyici') {
    return <TasiyiciSekmesi kilitli={kilitli} sevkiyat={sevkiyat} belge={belge} />;
  }
  if (aktifSekme === 'ebelge') {
    return (
      <EBelgeSekmesi kilitli={kilitli} irsaliyeMi={irsaliyeMi} tur={tur}
                     senaryo={senaryo} setSenaryo={setSenaryo} senaryoGizli={senaryoBaslikta} belge={belge}
                     belgeYenile={belgeYenile} />
    );
  }
  // İRSALİYE + SİPARİŞ (kullanıcı 07.11.2026 "irsaliye deseni sipariş için de, başvuru aynen"): hızlı düğmeler yok,
  //   hedef menüsü sekmede, Tür'e tıklayınca belge sekmede. BAŞVURU DA tur 19 - `basvuruMu` ile ayrılır, sade DEĞİL.
  const siparisMi = (tur === 9 || tur === 19) && !basvuruMu;
  const sade = irsaliyeMi || siparisMi;
  if (aktifSekme === 'fatura') return (
    <FaturalamaSekmesi {...faturalama} hizliYok={sade}
                       kaynakTur={irsaliyeMi ? (tur === 10 || tur === 109 ? 10 : 14) : siparisMi ? tur : undefined} />);
  if (aktifSekme === 'imza') {
    return (
      <div className="kagrup">
        <h6>{c('İmza / Teslim Alan')}</h6>
        <div className="not">
          Teslim alan kişi, TC, görev, teslim zamanı, nüsha sayısı ve teslim notu
          alanları henüz şemada yok — e-İrsaliye teslim onayı akışıyla gelecek.
          İmzalı teslim belgesi şimdilik Resim / Doküman sekmesine eklenebilir.
        </div>
      </div>
    );
  }
  return null;
}
