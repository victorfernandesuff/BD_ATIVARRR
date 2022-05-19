/*
DO $$ BEGIN
    PERFORM drop_functions();
    PERFORM drop_tables();
END $$;
*/

create table cliente(
	id int primary key,
	nome varchar not null
);

insert into cliente (id, nome) values 
(1, 'Gabriel'),
(2, 'Nicole'),
(3, 'Flávio'),
(4, 'Bruna'),
(5, 'Victor');

create table conta_corrente (
	id int primary key,
	abertura timestamp not null,
	encerramento timestamp
);

insert into conta_corrente (id, abertura, encerramento) values 
(1, now(), null),
(2, now(), null),
(3, now(), null),
(4, now(), null),
(5, now(), null);

create table correntista(
	cliente int references cliente(id),
	conta_corrente int references conta_corrente(id),
	primary key(cliente, conta_corrente)
);

insert into correntista (cliente, conta_corrente) values 
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5);


create table limite_credito(
	conta_corrente int references conta_corrente(id),
	valor float not null,
	inicio timestamp not null,
	fim timestamp
);

insert into limite_credito values 
(1, 1000, now(), now() + interval '2 days'),
(2, 1000, now(), now() + interval '4 days'),
(3, 1000, now(), now() + interval '6 days'),
(4, 1000, now(), now() + interval '8 days'),
(5, 1000, now(), now() + interval '10 days');

create table movimento(
	conta_corrente int references conta_corrente(id),
	"data" timestamp,
	valor float not null,
	primary key (conta_corrente,"data")
);

/*
 * Regras do jogo:
 * - Cliente x Conta corrente ---> NxN ---> Um cliente tem várias contas corrente e uma conta corrente pode pertencer a vários clientes -> Correntista
 * - Uma conta corrente pode fazer um movimento em uma data com valor positivo ou negativo.
 * - O atributo valor em limite_credito é o máximo que um cliente pode gastar em um dia
 * - Os clientes não podem gastar mais que isso em um dia
 * - Transações que aumentam o saldo devedor além desse limite são rejeitadas -> transação = movimento 
 * - Contas correntes que não tem limite_credito possuem limite de crédito 0
 * - A data de fim no limite de crédito diz qual é a data máxima que vale aquele crédito diário 
 * 		Ex.: Se tiver inicio hoje e fim daqui a 10 dias, durante esses 10 dias o cliente terá limite máximo DIARIO igual a esse valor
 * - Se não tem data de fim, esse limite serve para todos os dias até o fim da conta corrente
 * 
 * Fazer:
 * - Implementar triggers para garantir a regra de limite de saldo devedor. Ou seja, em nenhum momento a soma de movimentações deve ser abaixo do limite de crédito
 * 
 * O que o professor quer: # DELETAR ESSE COMENTÁRIO DPS
 * - A cada update ou insert na tabela de movimentação, seja em bulk ou não, a gente tem que verificar se algum momento o somatório até a data corrente vai dar ruim
 * - O que pensei em fazer: trigger before insert que pega todas as linhas que estão no banco + o que ta sendo inserido, ordena por "data" e, pra cada linha verificar se a soma até então deu >= o valor
 * - Fazer um trigger before update que faz a mesma coisa, kkkk
 * 
 */
--
--CREATE TRIGGER test_trigger AFTER INSERT ON test_table
--FOR EACH ROW EXECUTE PROCEDURE test();


create or replace function before_insert_movimento() returns trigger as $$
declare 
	m record;
	limite_e_saldo record;
begin 
	create temporary table total_movimentos (conta_corrente, "data", valor) on commit drop as (
		select * from movimento union select * from new_tab
	);
	
	create temporary table resultado_parcial (conta_corrente, limite, saldo_atual) on commit drop as (
		select conta_corrente, -valor as limite, 0.0 
		from limite_credito 
		where conta_corrente in (
			select conta_corrente from total_movimentos
		) 
	);

	for m in select * from total_movimentos order by "data" asc loop
		update resultado_parcial set saldo_atual = saldo_atual + m.valor where resultado_parcial.conta_corrente = m.conta_corrente;
		select conta_corrente, limite, saldo_atual into limite_e_saldo from resultado_parcial where resultado_parcial.conta_corrente = m.conta_corrente;
		raise notice '% % % %', limite_e_saldo.conta_corrente, limite_e_saldo.saldo_atual, limite_e_saldo.limite, m."data";
		if limite_e_saldo.saldo_atual < limite_e_saldo.limite then
			raise notice 'Transação inválida encontrada.';
			rollback;	
			raise notice 'Depois do rollback.';
			return null;
		end if;
	end loop;	
	return new;
end;
$$ language 'plpgsql';


create trigger tg_before_insert_movimento 
	after insert on movimento 
	referencing 
		new table as new_tab
	for each statement execute function before_insert_movimento();


select * from movimento;

truncate table movimento;

insert into movimento (conta_corrente, "data", valor) values
(1, now(), -1000);




--CREATE TRIGGER emp_audit_ins
--    AFTER INSERT ON emp
--    REFERENCING NEW TABLE AS new_tab
--    FOR EACH STATEMENT EXECUTE FUNCTION process_emp_audit();
--CREATE TRIGGER emp_audit_upd
--    AFTER UPDATE ON emp
--    REFERENCING OLD TABLE AS old_table NEW TABLE AS new_table
--    FOR EACH STATEMENT EXECUTE FUNCTION process_emp_audit();
--CREATE TRIGGER emp_audit_del
--    AFTER DELETE ON emp
--    REFERENCING OLD TABLE AS old_table
--    FOR EACH STATEMENT EXECUTE FUNCTION process_emp_audit();


create table test1(a int);

CREATE PROCEDURE transaction_test1()
LANGUAGE plpgsql
AS $$
BEGIN
    FOR i IN 0..9 LOOP
        INSERT INTO test1 (a) VALUES (i);
        IF i % 2 = 0 THEN
            COMMIT;
        ELSE
            ROLLBACK;
        END IF;
    END LOOP;
END;
$$;

CALL transaction_test1();

select * from test1;



