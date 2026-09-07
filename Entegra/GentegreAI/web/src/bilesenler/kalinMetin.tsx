/**
 * `**kalın**` yazımını GÜVENLE çizer: metin parçalara ayrılıp React
 * düğümü olarak basılır - `dangerouslySetInnerHTML` yok, dolayısıyla
 * cevaba HTML enjekte edilemez.
 *
 * Rehber cevabı iki yerde görünüyor (sağ alt panel ve Yapay Zeka ekranı);
 * biri kalın yazımı çizip öteki `**yıldızları**` ham gösterince aynı cevap
 * iki farklı üründen gelmiş gibi duruyordu.
 */
export function Kalinla({ metin }: { metin: string }) {
  const parcalar = metin.split(/\*\*(.+?)\*\*/g);
  return <>{parcalar.map((p, i) => (i % 2 === 1 ? <b key={i}>{p}</b> : p))}</>;
}
