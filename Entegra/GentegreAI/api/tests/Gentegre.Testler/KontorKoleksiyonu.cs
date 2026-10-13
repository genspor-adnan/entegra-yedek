namespace Gentegre.Testler;

/// <summary>
/// KONTÖR SATIRINA YAZAN TESTLER SIRAYLA KOŞAR.
///
/// `ai_kontor` kurumun TEK satırıdır (id = 1). AiKontorTestleri bakiyeyi
/// okuyup "+500" bekliyor, ModelTestleri aynı anda bakiyeyi 10'a sabitliyordu:
/// xUnit farklı sınıfları paralel koşturduğu için takım koşusunda ara sıra
/// kırmızı, tek başına hep yeşildi (flaky, 13.10.2026). Aynı koleksiyondaki
/// sınıflar paralel koşmaz. Bu satıra yazan yeni test de buraya girmeli.
/// </summary>
[CollectionDefinition(Ad)]
public sealed class KontorKoleksiyonu
{
    public const string Ad = "Kontör satırı";
}
