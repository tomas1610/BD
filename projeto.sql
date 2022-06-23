drop table if exists categoria;
drop table if exists categoria_simples;
drop table if exists super_categoria;
drop table if exists tem_outra;
drop table if exists produto;
drop table if exists tem_categoria;
drop table if exists ivm;
drop table if exists instalada_em;
drop table if exists instalada_em;
drop table if exists ponto_de_retalho;
drop table if exists instalada_em;
drop table if exists prateleira;
drop table if exists planograma;
drop table if exists retalhista;
drop table if exists responsavel_por;
drop table if exists evento_reposicao;


CREATE TABLE categoria(
    nome varchar(255) NOT NULL,
    PRIMARY KEY(nome)
);

CREATE TABLE categoria_simples(
    nome varchar(255) NOT NULL,
    PRIMARY KEY(nome),
    FOREIGN KEY(nome) REFERENCES categoria(nome)
);

CREATE TABLE super_categoria(
    nome varchar(255) NOT NULL,
    PRIMARY KEY(nome),
    FOREIGN KEY(nome) REFERENCES categoria(nome)
);

CREATE TABLE tem_outra(
    super_categoria varchar(255) NOT NULL,
    categoria varchar(255) NOT NULL,
    PRIMARY KEY(categoria),
    FOREIGN KEY(categoria) REFERENCES categoria(nome),
    FOREIGN KEY(super_categoria) REFERENCES super_categoria(nome),
    CHECK(categoria != super_categoria)
);

CREATE TABLE produto(
    ean numeric(13,0),
    cat varchar(255) NOT NULL,
    descr varchar(255) NOT NULL,
    PRIMARY KEY(ean),
    FOREIGN KEY(cat) REFERENCES categoria(nome)
);

CREATE TABLE tem_categoria(
    ean numeric(13,0),
    nome varchar(255) NOT NULL,
    FOREIGN KEY(ean) REFERENCES produto(ean),
    FOREIGN KEY(nome) REFERENCES categoria(nome)
);

CREATE TABLE ivm(
    num_serie int,
    manuf varchar(255) NOT NULL,
    PRIMARY KEY(num_serie,manuf)
);

CREATE TABLE ponto_de_retalho(
    nome varchar(255) NOT NULL,
    distrito varchar(255) NOT NULL,
    concelho varchar(255) NOT NULL, 
    PRIMARY KEY(nome)
);

CREATE TABLE instalada_em(
    num_serie int,
    manuf varchar(255) NOT NULL,
    place varchar(255) NOT NULL,
    PRIMARY KEY(num_serie,manuf),
    FOREIGN KEY(num_serie,manuf) REFERENCES ivm(num_serie,manuf),
    FOREIGN KEY(place) REFERENCES ponto_de_retalho(nome)
);

CREATE TABLE prateleira(
    nro int,
    num_serie int,
    manuf varchar(255) NOT NULL,
    heigh int,
    nome varchar(255) NOT NULL,
    PRIMARY KEY(nro,num_serie,manuf),
    FOREIGN KEY(num_serie,manuf) REFERENCES ivm(num_serie,manuf),
    FOREIGN KEY(nome) REFERENCES categoria(nome)
);

CREATE TABLE planograma(
    ean numeric(13,0),
    nro int,
    num_serie int,
    manuf varchar(255) NOT NULL,
    faces int,
    units int,
    PRIMARY KEY(ean,nro,num_serie,manuf),
    FOREIGN KEY(ean) REFERENCES produto(ean),
    FOREIGN KEY(nro,num_serie,manuf) REFERENCES prateleira(nro,num_serie,manuf)
);

CREATE TABLE retalhista(
    tin int,
    nome varchar(255) NOT NULL,
    UNIQUE(nome),
    PRIMARY KEY(tin)
);

CREATE TABLE responsavel_por(
    nome_cat varchar(255) NOT NULL,
    tin int,
    num_serie int,
    manuf varchar(255) NOT NULL,
    PRIMARY KEY(num_serie,manuf),
    FOREIGN KEY(num_serie,manuf) REFERENCES ivm(num_serie,manuf),
    FOREIGN KEY(tin) REFERENCES retalhista(tin),
    FOREIGN KEY(nome_cat) REFERENCES categoria(nome) 
);

CREATE TABLE evento_reposicao(
    ean numeric(13,0),
    nro int,
    num_serie int,
    manuf varchar(255) NOT NULL,
    instant varchar(10) NOT NULL,
    units int,
    tin int,
    PRIMARY KEY(ean,nro,num_serie,instant),
    FOREIGN KEY(ean,nro,num_serie,manuf) REFERENCES planograma(ean,nro,num_serie,manuf),
    FOREIGN KEY(tin) REFERENCES retalhista(tin)
);

 /*RESTRIÇÔES DE INTEGRIDADE */

DROP TRIGGER IF EXISTS verifica_categoria_dentro_mesma ON tem_outra;
DROP TRIGGER IF EXISTS verifica_numero_unidades ON evento_reposicao;
DROP TRIGGER IF EXISTS verifica_produto_reposto ON evento_reposicao;

CREATE OR REPLACE FUNCTION verifica_numero_unidades_trigger_proc() RETURNS TRIGGER
AS $$

BEGIN
    IF new.units > (SELECT units FROM planograma WHERE planograma.ean = new.ean) THEN
        RAISE EXCEPTION 'O número de unidades repostas num Evento de Reposição não pode exceder o número de unidades especIFicado no Planograma';

    END IF;

    RETURN new;
END;
$$ LANGUAGE plpgsql;
CREATE CONSTRAINT TRIGGER verifica_numero_unidades AFTER INSERT OR UPDATE ON evento_reposicao
FOR EACH ROW EXECUTE PROCEDURE verifica_numero_unidades_trigger_proc();

/*  SQL   */


SELECT nome
FROM responsavel_por
NATURAL JOIN retalhista
GROUP BY nome
HAVING COUNT(tin) >= ALL(
    SELECT COUNT(tin)
    FROM responsavel_por
    GROUP BY tin);

 
SELECT nome FROM retalhista
WHERE tin IN  (SELECT tin FROM responsavel_por WHERE nome_cat IN (SELECT nome FROM categoria_simples)); 

SELECT ean 
FROM produto
WHERE produto.ean NOT IN (SELECT ean from evento_reposicao);

SELECT ean FROM evento_reposicao GROUP BY ean HAVING COUNT(DISTINCT tin) = 1;

/* vistas */



/* indices */

DROP index if EXISTS index_7_1_1;
DROP INDEX IF EXISTS index_7_1_2;
CREATE INDEX index_7_1_1 ON retalhista(nome) USING btree;
CREATE INDEX index_7_1_2 ON responsavel_por USING HASH(tin);

SELECT DISTINCT R.nome
FROM retalhista R, responsavel_por P 
WHERE R.tin = P.tin and P. nome_cat = 'Frutos';


DROP index if exists index_7_2_1;
DROP index if exists index_7_2_2;
CREATE index index_7_2_1 ON tem_categoria USING HASH(nome);
CREATE index index_7_2_2 ON produto USING HASH(ean);

SELECT T.nome, count(T.ean) 
FROM produto P, tem_categoria T
WHERE p.cat = T.nome and P.descr like 'Pescada' 
GROUP BY T.nome;