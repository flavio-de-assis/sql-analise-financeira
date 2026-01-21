SELECT 
  d.cddocumento AS conta,
  d.dtemissao AS data_emissao,
  d.dtvencimento AS data_vencimento,
  CASE 
    WHEN d.tipopagamento = 0 THEN 'CLIENTE'
    WHEN d.tipopagamento = 1 THEN 'COLABORADOR'
    WHEN d.tipopagamento = 2 THEN 'FORNECEDOR'
    WHEN d.tipopagamento = 3 THEN 'OUTROS'
    ELSE d.tipopagamento::text
  END AS pagamento_a,
  p.nome AS destinatario,
  COALESCE(p.cnpj, p.cpf) AS cpf_cnpj,
  dt.nome AS tipo_documento,
  d.numero AS documento,
  cg.nome AS conta_gerencial,
  c.nome AS centro_de_custo,
  pj.nome AS projeto,
  ri.valor / 100 AS valor
FROM documento d
LEFT JOIN rateio r ON d.cdrateio = r.cdrateio 
LEFT JOIN rateioitem ri ON r.cdrateio = ri.cdrateio 
LEFT JOIN centrocusto c ON ri.cdcentrocusto = c.cdcentrocusto
LEFT JOIN contagerencial cg ON ri.cdcontagerencial = cg.cdcontagerencial  
JOIN pessoa p ON d.cdpessoa = p.cdpessoa
LEFT JOIN documentotipo dt ON d.cddocumentotipo = dt.cddocumentotipo 
LEFT JOIN projeto pj ON ri.cdprojeto = pj.cdprojeto
WHERE 1 = 1
  AND d.dtemissao >= #DATA_INICIO_EMISSAO.DATA
  AND d.dtemissao <= #DATA_FIM_EMISSAO.DATA
  AND d.dtvencimento >= #DATA_INICIO_VENCIMENTO.DATA
  AND d.dtvencimento <= #DATA_FIM_VENCIMENTO.DATA
  AND d.cddocumentotipo = #TIPO_DOCUMENTO.AUTOCOMPLETE(
    'SELECT dt1.cddocumentotipo, dt1.nome FROM documentotipo dt1'
  )
  AND d.cdpessoa = #DESTINATARIO.AUTOCOMPLETE(
    'SELECT p1.cdpessoa, p1.nome FROM pessoa p1 ORDER BY p1.nome'
  )
  AND d.cddocumentoacao = #SITUACAO.LIST_QUERY(
    'SELECT da.cddocumentoacao, da.nome 
     FROM documentoacao da 
     WHERE da.cddocumentoacao IN (0,1,2,3,4,5,6,107)'
  )
ORDER BY data_emissao;
