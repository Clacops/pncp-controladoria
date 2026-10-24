-- ==============================================================================
-- PROJETO FINAL -| RESPOSTAS DE NEGÓCIO DA CONTROLADORIA
-- ==============================================================================

-- PERGUNTA 1: Qual é o percentual e o valor financeiro nominal economizado pelo governo?
-- Regra aplicada: O percentual é a SOMA(economia) / SOMA(estimado), apenas para itens comparáveis.
SELECT 
    SUM(valor_total_homologado) AS volume_homologado_total,
    SUM(CASE WHEN comparavel = 1 THEN valor_total_estimado ELSE 0 END) AS valor_estimado_comparavel,
    SUM(CASE WHEN comparavel = 1 THEN economia_valor ELSE 0 END) AS economia_nominal_total,
    ROUND((SUM(CASE WHEN comparavel = 1 THEN economia_valor ELSE 0 END) / 
           NULLIF(SUM(CASE WHEN comparavel = 1 THEN valor_total_estimado ELSE 0 END), 0)) * 100, 2) AS economia_percentual
FROM fato_item_contratado;


-- PERGUNTA 2: Quem são os maiores fornecedores em volume financeiro e qual percentual do orçamento público está concentrado neles?
-- Regra aplicada: Top 10 fornecedores e subconsulta para o denominador do percentual global.
WITH TotalVolume AS (
    SELECT SUM(valor_total_homologado) AS total_geral 
    FROM fato_item_contratado
)
SELECT 
    d.nome_fornecedor,
    SUM(f.valor_total_homologado) AS volume_financeiro,
    ROUND((SUM(f.valor_total_homologado) / MAX(tv.total_geral)) * 100, 2) AS percentual_orcamento
FROM fato_item_contratado f
JOIN dim_fornecedor d ON f.sk_fornecedor = d.sk_fornecedor
CROSS JOIN TotalVolume tv
GROUP BY d.nome_fornecedor
ORDER BY volume_financeiro DESC
LIMIT 10;


-- PERGUNTA 3: Quais modalidades licitatórias trazem maior deságio/economia e quais concentram o maior volume de recursos?
SELECT 
    m.nome_modalidade,
    SUM(f.valor_total_homologado) AS volume_recursos,
    SUM(CASE WHEN f.comparavel = 1 THEN f.economia_valor ELSE 0 END) AS economia_nominal,
    ROUND((SUM(CASE WHEN f.comparavel = 1 THEN f.economia_valor ELSE 0 END) / 
           NULLIF(SUM(CASE WHEN f.comparavel = 1 THEN f.valor_total_estimado ELSE 0 END), 0)) * 100, 2) AS desagio_percentual
FROM fato_item_contratado f
JOIN dim_modalidade m ON f.sk_modalidade = m.sk_modalidade
GROUP BY m.nome_modalidade
ORDER BY volume_recursos DESC;


-- PERGUNTA 4: Qual a duração média (em dias) entre o lançamento do edital e a sua homologação final, segmentada por órgão?
-- Regra aplicada: Apenas itens com ciclo, filtrando órgãos com 5 ou mais registos válidos.
SELECT 
    o.nome_orgao,
    ROUND(AVG(f.dias_ciclo), 1) AS duracao_media_dias,
    COUNT(f.dias_ciclo) AS qtd_itens_com_ciclo
FROM fato_item_contratado f
JOIN dim_orgao o ON f.sk_orgao = o.sk_orgao
WHERE f.dias_ciclo IS NOT NULL
GROUP BY o.nome_orgao
HAVING COUNT(f.dias_ciclo) >= 5
ORDER BY duracao_media_dias DESC;


-- PERGUNTA 5: Quais estados e regiões concentram as maiores despesas e quais apresentam os melhores indicadores de desconto?
SELECT 
    COALESCE(l.regiao, 'TOTAL GERAL') AS regiao,
    COALESCE(l.uf_sigla, 'SUBTOTAL REGIÃO') AS uf_sigla,
    SUM(f.valor_total_homologado) AS volume_despesas,
    ROUND((SUM(CASE WHEN f.comparavel = 1 THEN f.economia_valor ELSE 0 END) / 
           NULLIF(SUM(CASE WHEN f.comparavel = 1 THEN f.valor_total_estimado ELSE 0 END), 0)) * 100, 2) AS indicador_desconto_percentual
FROM fato_item_contratado f
JOIN dim_localidade l ON f.sk_localidade = l.sk_localidade
GROUP BY ROLLUP(l.regiao, l.uf_sigla)
ORDER BY 
    l.regiao NULLS LAST, 
    l.uf_sigla NULLS LAST,
    volume_despesas DESC;

-- PERGUNTA 6: Como os recursos se distribuem entre bens, serviços e obras e engenharia?
SELECT 
    perfil_gasto,
    SUM(valor_total_homologado) AS volume_recursos,
    COUNT(*) AS quantidade_itens
FROM fato_item_contratado
GROUP BY perfil_gasto
ORDER BY volume_recursos DESC;