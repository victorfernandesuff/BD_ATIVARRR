CREATE TABLE bairro (
bairro_id integer NOT NULL,
nome character varying NOT NULL,
CONSTRAINT bairro_pk PRIMARY KEY
(bairro_id));

CREATE TABLE municipio (
municipio_id integer NOT NULL,
nome character varying NOT NULL,
CONSTRAINT municipio_pk PRIMARY KEY
(municipio_id));


CREATE TABLE antena (
antena_id integer NOT NULL,
bairro_id integer NOT NULL,
municipio_id integer NOT NULL,
CONSTRAINT antena_pk PRIMARY KEY
(antena_id),
CONSTRAINT bairro_fk FOREIGN KEY
(bairro_id) REFERENCES bairro
(bairro_id),
CONSTRAINT municipio_fk FOREIGN KEY
(municipio_id) REFERENCES municipio
                    (municipio_id));

CREATE TABLE ligacao (
ligacao_id bigint NOT NULL,
numero_orig integer NOT NULL,
numero_dest integer NOT NULL,
antena_orig integer NOT NULL,
antena_dest integer NOT NULL,
inicio timestamp NOT NULL,
fim timestamp NOT NULL,
CONSTRAINT ligacao_pk PRIMARY KEY
(ligacao_id),
CONSTRAINT antena_orig_fk FOREIGN KEY
(antena_orig) REFERENCES antena
(antena_id),
CONSTRAINT antena_dest_fk FOREIGN KEY
(antena_dest) REFERENCES antena
(antena_id));


INSERT INTO public.ligacao (ligacao_id, numero_orig, numero_dest, antena_orig, antena_dest, inicio, fim) VALUES (0, 111111111, 222222222, 0, 1, '2022-04-07 00:22:58.725187', '2022-04-07 00:32:58.725187');
INSERT INTO public.ligacao (ligacao_id, numero_orig, numero_dest, antena_orig, antena_dest, inicio, fim) VALUES (1, 111111111, 222222222, 2, 3, '2022-04-07 00:22:58.725187', '2022-04-07 00:32:58.725187');
INSERT INTO public.ligacao (ligacao_id, numero_orig, numero_dest, antena_orig, antena_dest, inicio, fim) VALUES (2, 111111111, 222222222, 1, 0, '2022-04-07 00:22:58.725187', '2022-04-07 00:32:58.725187');
INSERT INTO public.ligacao (ligacao_id, numero_orig, numero_dest, antena_orig, antena_dest, inicio, fim) VALUES (3, 111111111, 222222222, 0, 2, '2022-04-07 00:22:58.725187', '2022-04-07 00:32:58.725187');
INSERT INTO public.ligacao (ligacao_id, numero_orig, numero_dest, antena_orig, antena_dest, inicio, fim) VALUES (4, 111111111, 222222222, 3, 2, '2022-04-07 00:22:58.725187', '2022-04-07 00:32:58.725187');
INSERT INTO public.ligacao (ligacao_id, numero_orig, numero_dest, antena_orig, antena_dest, inicio, fim) VALUES (5, 111111111, 222222222, 1, 2, '2022-04-07 00:22:58.725187', '2022-04-07 00:32:58.725187');
INSERT INTO public.ligacao (ligacao_id, numero_orig, numero_dest, antena_orig, antena_dest, inicio, fim) VALUES (6, 111111111, 222222222, 0, 1, '2022-04-07 00:22:58.725187', '2022-04-07 00:32:58.725187');



insert into bairro values (0, 'Madureira');
insert into bairro values (1, 'Meier');
insert into bairro values (2, 'Jacarepagua');
insert into bairro values (3, 'Penha');

insert into municipio values (0, 'Rio de Janeiro');

insert into antena values (0, 0, 0);
insert into antena values (1, 1, 0);
insert into antena values (2, 2, 0);
insert into antena values (3, 3, 0);


select antena.bairro_id, antena.municipio_id from antena
group by antena.bairro_id, antena.municipio_id



with aux as (select avg(l.fim - l.inicio), l.antena_orig, l.antena_dest
from ligacao as l
         left join antena a on a.antena_id = l.antena_orig
         left join bairro b on a.bairro_id = b.bairro_id
         left join municipio m on m.municipio_id = a.municipio_id
         left join antena a2 on a2.antena_id = l.antena_dest
         left join bairro b2 on a2.bairro_id = b2.bairro_id
         left join municipio m2 on m2.municipio_id = a2.municipio_id
group by l.antena_orig, l.antena_dest)



with aux as (select
    (l.fim - l.inicio) as time_spent,
              case when l.antena_orig < l.antena_dest then
                    concat(l.antena_orig::text, '-', l.antena_dest::text)
                else concat(l.antena_dest::text, '-', l.antena_orig::text) END
                as regiao
from ligacao as l
         left join antena a on a.antena_id = l.antena_orig
         left join bairro b on a.bairro_id = b.bairro_id
         left join municipio m on m.municipio_id = a.municipio_id
         left join antena a2 on a2.antena_id = l.antena_dest
         left join bairro b2 on a2.bairro_id = b2.bairro_id
         left join municipio m2 on m2.municipio_id = a2.municipio_id
    ) select avg(time_spent) as average, regiao
from aux
group by regiao
order by average DESC


select concat(b.bairro_id::text, '-', m.municipio_id) as id_regiao
from ligacao as l
         left join antena a on a.antena_id = l.antena_orig
         left join bairro b on a.bairro_id = b.bairro_id
         left join municipio m on m.municipio_id = a.municipio_id
         left join antena a2 on a2.antena_id = l.antena_dest
         left join bairro b2 on a2.bairro_id = b2.bairro_id
         left join municipio m2 on m2.municipio_id = a2.municipio_id
group by id_regiao
--group by l.antena_orig, l.antena_dest


select l.antena_orig, l.antena_dest, a.antena_id, b.nome, b2.nome, m.nome,m2.nome
from ligacao as l
         left join antena a on a.antena_id = l.antena_orig
         left join bairro b on a.bairro_id = b.bairro_id
         left join municipio m on m.municipio_id = a.municipio_id
         left join antena a2 on a2.antena_id = l.antena_dest
         left join bairro b2 on a2.bairro_id = b2.bairro_id
         left join municipio m2 on m2.municipio_id = a2.municipio_id
group by b.nome, m.nome

--group by l.antena_dest, l.antena_orig

