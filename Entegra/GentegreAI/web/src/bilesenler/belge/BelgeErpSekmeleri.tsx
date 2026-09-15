import { TasiyiciSekmesi, EBelgeSekmesi, FaturalamaSekmesi }
  from './BelgeSekmeleri';
import type { useSevkiyatBilgisi } from '../../sayfalar/belgeKarti/useSevkiyatBilgisi';

/**
 * ERP BELGESİNE ÖZGÜ SEKMELER: Taşıyıcı · e-Belge · Faturalama · İmza.
 *
 * Dördü de aynı kümeden besleniyor (sevkiyat, senaryo, dönüşümler) ve
 * başvuruda hiç çizilmiyor; kartın gövdesinde tek tek durdukça sekme
 * koşulları başvuru sekmeleriyle iç içe geçiyordu. Burada hangi sekmede ne
 * çizildiği bir bakışta okunur.
 */
export function BelgeErpSekmeleri({ aktifSekme, kilitli, sevkiyat, belge,
                                    irsaliyeMi, tur, senaryo, setSenaryo,
                                    faturalama }: {
  aktifSekme: string;
  kilitli: boolean;
  sevkiyat: ReturnType<typeof useSevkiyatBilgisi>;
  belge?: Record<string, unknown>;
  irsaliyeMi: boolean;
  tur: number;
  senaryo: number;
  setSenaryo(v: number): void;
  /** Faturalama sekmesinin tüm girdisi - kart kurar, burada aynen geçer. */
  faturalama: React.ComponentProps<typeof FaturalamaSekmesi>;
}) {
  if (aktifSekme === 'tasiyici') {
    return <TasiyiciSekmesi kilitli={kilitli} sevkiyat={sevkiyat} belge={belge} />;
  }
  if (aktifSekme === 'ebelge') {
    return (
      <EBelgeSekmesi kilitli={kilitli} irsaliyeMi={irsaliyeMi} tur={tur}
                     senaryo={senaryo} setSenaryo={setSenaryo} belge={belge} />
    );
  }
  if (aktifSekme === 'fatura') return <FaturalamaSekmesi {...faturalama} />;
  if (aktifSekme === 'imza') {
    return (
      <div className="kagrup">
        <h6>İmza / Teslim Alan</h6>
        <div className="not">
          Teslim alan kişi, TC, görev, teslim zamanı, nüsha sayısı ve teslim notu
          alanları henüz şemada yok — e-İrsaliye teslim onayı akışıyla gelecek.
          İmzalı teslim belgesi şimdilik Yorum / Medya sekmesine eklenebilir.
        </div>
      </div>
    );
  }
  return null;
}
