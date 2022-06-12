CREATE TABLE empresa(
   codigo INTEGER NOT NULL,
   nome VARCHAR NOT NULL,
   tipo int not null,
CONSTRAINT empresa_pk PRIMARY KEY (codigo)
);

CREATE TABLE acoes(
   empresa_dona INTEGER REFERENCES empresa(codigo),
   empresa_comprada INTEGER REFERENCES empresa(codigo),
    porcentagem INTEGER NOT NULL CHECK (porcentagem <= 100) ,
CONSTRAINT dona_fk FOREIGN KEY (empresa_dona) REFERENCES empresa (codigo) ON DELETE RESTRICT ON UPDATE CASCADE,
CONSTRAINT comprada_fk FOREIGN KEY (empresa_comprada) REFERENCES empresa (codigo) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE controla(
   empresa_controla INTEGER NOT NULL,
   empresa_controlada INTEGER NOT NULL,
CONSTRAINT controla_fk FOREIGN KEY (empresa_controla) REFERENCES empresa (codigo) ON DELETE RESTRICT ON UPDATE CASCADE,
CONSTRAINT controlada_fk FOREIGN KEY (empresa_controlada) REFERENCES empresa (codigo) ON DELETE RESTRICT ON UPDATE CASCADE
);

INSERT INTO public.empresa (codigo, nome, tipo) VALUES (4, 'E', 0);
INSERT INTO public.empresa (codigo, nome, tipo) VALUES (3, 'D', 1);
INSERT INTO public.empresa (codigo, nome, tipo) VALUES (2, 'C', 1);
INSERT INTO public.empresa (codigo, nome, tipo) VALUES (1, 'B', 0);
INSERT INTO public.empresa (codigo, nome, tipo) VALUES (0, 'A', 0);


INSERT INTO public.acoes (empresa_dona, empresa_comprada, porcentagem) VALUES (4, 1, 30);
INSERT INTO public.acoes (empresa_dona, empresa_comprada, porcentagem) VALUES (4, 2, 20);
INSERT INTO public.acoes (empresa_dona, empresa_comprada, porcentagem) VALUES (4, 3, 10);
INSERT INTO public.acoes (empresa_dona, empresa_comprada, porcentagem) VALUES (4, 0, 100);
INSERT INTO public.acoes (empresa_dona, empresa_comprada, porcentagem) VALUES (2, 3, 90);
INSERT INTO public.acoes (empresa_dona, empresa_comprada, porcentagem) VALUES (1, 2, 80);
INSERT INTO public.acoes (empresa_dona, empresa_comprada, porcentagem) VALUES (0, 1, 70);

select * from acoes

WITH RECURSIVE empresa_controladas AS (
	SELECT
		a.nome,
	    a.codigo
	FROM
		acoes ei
	JOIN empresa a ON ei.empresa_dona = a.codigo
	WHERE
		ei.empresa_dona = 3
	UNION
        SELECT
            a.nome,
            a.codigo
        FROM
            acoes ei
        JOIN empresa a ON ei.empresa_dona = a.codigo
) SELECT
	*
FROM
	empresa;

/*
    1 - iterar por cada empresa e descobrir quem controla a mesma
    2 - para escrever na tabela controla que empresa controla quem (maior que 50%)

    fazer o check da porcentagem para ser menor ou igual a 100%

*/

create or replace function before_update_insert_acao() returns trigger as $$
declare
	m record;
begin
    create temporary table total_acoes(empresa_dona, empresa_comprada, porcentagem) on commit drop as(
		select * from acoes union select * from new_tab
	);

    ;

    for m in select *  from empresa loop
        select * from acoes where acoes.empresa_comprada = m.codigo and

    end loop;
end
    $$ language 'plpgsql';

create trigger tg_before_update_insert_acoes
	after insert on acoes
    referencing new table as new_tab
    for each statement execute function before_update_insert_acao()

create trigger tg_before_update_update_acoes
	after insert on acoes
    referencing new table as new_tab
    for each statement execute function before_update_insert_acao()




