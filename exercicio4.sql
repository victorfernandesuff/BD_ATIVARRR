
/*DO $$ BEGIN
    PERFORM drop_functions();
    PERFORM drop_tables();
END $$;
*/

drop table if exists venda cascade;

CREATE TABLE venda
(
    ano_mes integer NOT NULL,
    unidade integer NOT NULL,
    vendedor text  NOT NULL,
    produto integer NOT NULL,
    valor real NOT NULL,
    CONSTRAINT venda_pkey PRIMARY KEY (produto, vendedor, ano_mes)
);



CREATE OR REPLACE FUNCTION projecao(p_produto int, p_ano_mes int) returns real AS $$
DECLARE
BEGIN
    CREATE TEMPORARY TABLE t1( ano_mes int , valor int );


    INSERT INTO t1
    SELECT ano_mes, SUM(valor) AS valor
    FROM venda
    WHERE produto=p_produto
    GROUP BY ano_mes
    ORDER BY ano_mes;
END;
$$ LANGUAGE plpgsql;
