
DO $$ BEGIN
    PERFORM drop_tables();
END $$;



drop table if exists campeonato cascade;
CREATE TABLE campeonato (
codigo text NOT NULL,
nome TEXT NOT NULL,
ano integer not null,
CONSTRAINT campeonato_pk PRIMARY KEY
(codigo));

drop table if exists time_ cascade;
CREATE TABLE time_ (
sigla text NOT NULL,
nome TEXT NOT NULL,
CONSTRAINT time_pk PRIMARY KEY
(sigla));

drop table if exists jogo cascade;
CREATE TABLE jogo (
campeonato text not null,
numero integer NOT NULL,
time1 text NOT NULL,
time2 text NOT NULL,
gols1 integer not null,
gols2 integer not null,
data_ date not null,
CONSTRAINT jogo_pk PRIMARY KEY
(campeonato,numero),
CONSTRAINT jogo_campeonato_fk FOREIGN KEY
(campeonato) REFERENCES campeonato
(codigo),
CONSTRAINT jogo_time_fk1 FOREIGN KEY
(time1) REFERENCES time_ (sigla),
CONSTRAINT jogo_time_fk2 FOREIGN KEY
(time2) REFERENCES time_ (sigla));


INSERT INTO public.time_ (sigla, nome) VALUES ('FLA', 'Flamengo');
INSERT INTO public.time_ (sigla, nome) VALUES ('VAS', 'Vasco');
INSERT INTO public.time_ (sigla, nome) VALUES ('BOT', 'Botafogo');
INSERT INTO public.time_ (sigla, nome) VALUES ('FLU', 'Fluminense');


INSERT INTO public.campeonato (codigo, nome, ano) VALUES ('1', 'Campeonato Carioca', 2022);

INSERT INTO public.jogo (campeonato, numero, time1, time2, gols1, gols2, data_) VALUES ('1', 1, 'FLA', 'FLU', 2, 0, '2022-04-12');
INSERT INTO public.jogo (campeonato, numero, time1, time2, gols1, gols2, data_) VALUES ('1', 2, 'VAS', 'BOT', 2, 1, '2022-04-11');
INSERT INTO public.jogo (campeonato, numero, time1, time2, gols1, gols2, data_) VALUES ('1', 3, 'VAS', 'FLU', 3, 1, '2022-04-10');
INSERT INTO public.jogo (campeonato, numero, time1, time2, gols1, gols2, data_) VALUES ('1', 4, 'BOT', 'FLU', 2, 1, '2022-04-09');


create or replace function classificacao(campeonato_ text, pos_inicial int, pos_final int)
RETURNS TABLE(cod_campeonato text,time_sigla text,pontos int, vitorias int) AS $$
DECLARE
    jogo_campeonato jogo%ROWTYPE;
    time_campeonato1 record;
    time_campeonato2 record;
    time1_exists bool;
    time2_exists bool;
BEGIN
    create temp table if not exists time_classificacao (cod_campeonato text,time_sigla text,pontos int, vitorias int);

    FOR jogo_campeonato IN
       (select * from jogo where jogo.campeonato = campeonato_)
    LOOP
--         time1_exists = exists(SELECT * FROM time_classificacao where time_classificacao.time_sigla = jogo_campeonato.time1);
--         time2_exists = exists(SELECT * FROM time_classificacao where time_classificacao.time_sigla = jogo_campeonato.time2);

        SELECT * into time_campeonato1 FROM time_classificacao where time_classificacao.time_sigla = jogo_campeonato.time1;
        SELECT * into time_campeonato2 FROM time_classificacao where time_classificacao.time_sigla = jogo_campeonato.time2;


        if jogo_campeonato.gols2 > jogo_campeonato.gols1 then
            INSERT into time_classificacao VALUES (jogo_campeonato.campeonato, jogo_campeonato.time2, 3, 1 )
                on conflict (time_sigla) do update SET pontos = (time_campeonato2.pontos + 3), vitorias = (time_campeonato2.vitorias + 1);
        else
            INSERT into time_classificacao VALUES (jogo_campeonato.campeonato, jogo_campeonato.time2, 0, 0 )
            on conflict (time_sigla) do nothing;
        end if;





        if jogo_campeonato.gols1 > jogo_campeonato.gols2 then
            INSERT into time_classificacao VALUES (jogo_campeonato.campeonato, jogo_campeonato.time1, 3, 1 )
                on conflict (time_sigla) do update SET pontos = (time_campeonato1.pontos + 3), vitorias = (time_campeonato1.vitorias + 1);
        else
            INSERT into time_classificacao VALUES (jogo_campeonato.campeonato, jogo_campeonato.time1, 0, 0 )
            on conflict (time_sigla) do nothing;
        end if;
        --------------------------

--         if time1_exists then
--             raise notice 'time 1 adicionou 3 pontos';
--             if jogo_campeonato.gols1 > jogo_campeonato.gols2 then
--                 UPDATE time_classificacao SET pontos = (time_campeonato1.pontos + 3),
--                                               vitorias = (time_campeonato1.vitorias + 1)
--                 where time_classificacao.time_sigla = time_campeonato1.time_sigla;
--             end if;
--         end if;
--
--         if time2_exists then
--             raise notice 'time 3 adicionou 3 pontos';
--             if jogo_campeonato.gols2 > jogo_campeonato.gols1 then
--                 UPDATE time_classificacao SET pontos = (time_campeonato2.pontos + 3),
--                                               vitorias = (time_campeonato2.vitorias + 1)
--                 where time_classificacao.time_sigla = time_campeonato2.time_sigla;
--             end if;
--         end if;
--
--         if time_campeonato1 is null then
--             if jogo_campeonato.gols1 > jogo_campeonato.gols2 then
--                 INSERT into time_classificacao(cod_campeonato, time_sigla, pontos, vitorias) VALUES (jogo_campeonato.campeonato, jogo_campeonato.time1, 3, 1 );
--             else
--                 INSERT into time_classificacao(cod_campeonato, time_sigla, pontos, vitorias)  VALUES (jogo_campeonato.campeonato, jogo_campeonato.time1, 0, 0 );
--             end if;
--         end if;
--
--         if time_campeonato2 is null then
--             if jogo_campeonato.gols2 > jogo_campeonato.gols1 then
--                 INSERT into time_classificacao(cod_campeonato, time_sigla, pontos, vitorias)  VALUES (jogo_campeonato.campeonato, jogo_campeonato.time2, 3, 1 );
--             else
--                 INSERT into time_classificacao(cod_campeonato, time_sigla, pontos, vitorias)  VALUES (jogo_campeonato.campeonato, jogo_campeonato.time2, 0, 0 );
--             end if;
--         end if;

    end loop;

    RETURN QUERY SELECT * FROM time_classificacao order by time_classificacao.pontos desc, time_classificacao.vitorias desc LIMIT (pos_final - pos_inicial) + 1 OFFSET (pos_inicial);
    drop table time_classificacao;
END
$$ LANGUAGE plpgsql;

select classificacao('1', 0, 3);

