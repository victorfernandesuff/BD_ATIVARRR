DROP TABLE IF EXISTS VENDA CASCADE;

CREATE TABLE VENDA (ANO_MES int NOT NULL, UNIDADE integer NOT NULL, VENDEDOR integer NOT NULL, PRODUTO integer NOT NULL, VALOR decimal NOT NULL);

INSERT INTO VENDA VALUES (202201, 4, 1, 1, 10.0);
INSERT INTO VENDA VALUES (202201, 4, 2, 1, 10.0);
INSERT INTO VENDA VALUES (202201, 4, 3, 1, 10.0);
INSERT INTO VENDA VALUES (202202, 4, 3, 1, 10.0);
INSERT INTO VENDA VALUES (202203, 4, 3, 1, 10.0);


SELECT ANO_MES, SUM(VALOR)
FROM VENDA
WHERE PRODUTO = 1
GROUP BY ANO_MES;


DROP FUNCTION IF EXISTS projecao;

CREATE OR REPLACE FUNCTION projecao(p_produto integer, p_ano_mes integer) 
-- RETURNS decimal AS $$
--acredito que o retorno seja um numero real
RETURNS TABLE(ano_mes integer, c2 bigint) AS $$
		
BEGIN

RETURN QUERY

((WITH T1 AS (SELECT VENDA.ANO_MES, SUM(VALOR)
FROM VENDA
WHERE PRODUTO = 1
GROUP BY VENDA.ANO_MES)
 
SELECT T1.ANO_MES,ROW_NUMBER() OVER (ORDER BY T1.ANO_MES ASC) as seq FROM T1 ORDER BY ANO_MES));
--não sei se é a tabela correta no numero 2, mas acredito que o retorno seja isso mesmo
-- matrix?
		
END;
$$ LANGUAGE plpgsql;

select projecao(1,1);
