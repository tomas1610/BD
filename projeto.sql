drop table if exists categoria cascade;
drop table if exists categoria_simples cascade;
drop table if exists super_categoria cascade;
drop table if exists tem_outra cascade;
drop table if exists produto cascade;
drop table if exists tem_categoria cascade;
drop table if exists ivm cascade;
drop table if exists instalada_em cascade;
drop table if exists instalada_em cascade;
drop table if exists ponto_de_retalho cascade;
drop table if exists instalada_em cascade;
drop table if exists prateleira cascade;
drop table if exists planograma cascade;
drop table if exists retalhista cascade;
drop table if exists responsavel_por cascade;
drop table if exists evento_reposicao cascade;


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
    FOREIGN KEY(super_categoria) REFERENCES super_categoria(nome)
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

/*teste git*/

/* RESTRIÇÔES DE INTEGRIDADE */

DROP TRIGGER IF EXISTS verifica_categoria_dentro_mesma ON tem_outra;
DROP TRIGGER IF EXISTS verifica_numero_unidades ON evento_reposicao;
DROP TRIGGER IF EXISTS verifica_produto_reposto ON evento_reposicao;

CREATE OR REPLACE FUNCTION verifica_numero_unidades_trigger_proc() RETURNS TRIGGER AS $$
BEGIN
    SELECT (evento_reposicao.units, planograma.units) INTO (rep_units, plan_units)
    FROM evento_reposicao, planograma
    WHERE evento_reposicao.num_serie == planograma.num_serie;
    
    IF rep_units > place THEN
        RAISE EXCEPTION 'O número de unidades repostas no evento de reposição excedeu o número
        especificado no planograma';
    END IF;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION  verifica_categoria_dentro_mesma_trigger_proc() RETURNS TRIGGER AS $$
DECLARE  in_categoria VARCHAR(255) := '' ;
DECLARE  super VARCHAR(255) := '' ;
BEGIN
    select (super,categoria) into (super,in_categoria) from tem_outra;
    WHILE in_categoria IS NOT NULL THEN
        IF in_categoria.nome == super.nome THEN
            RAISE EXCEPTION 'Uma Categoria não pode estar contida em si própria';
        END IF;
        select (super,categoria) into (super,in_categoria) from tem_outra WHERE super.nome == in_categoria.nome;
    END LOOP;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION  verifica_produto_reposto_trigger_proc() RETURNS TRIGGER AS $$
DECLARE  cat_produto VARCHAR(255) := '' ;
DECLARE  cat_prateleira VARCHAR(255) := '' ;
DECLARE  flag INTEGER := 0;
BEGIN  
    select ean.cat,num_serie.nome INTO cat_produto,cat_prateleira 
    from evento_reposicao
    
    WHILE cat_produto IS NOT NULL THEN
        select num_serie.nome INTO cat_prateleira 
        from evento_reposicao
        WHILE cat_prateleira IS NOT NULL THEN
            IF cat_produto == cat_prateleira THEN
                SET flag = flag + 1 ;
            END IF; 
            select categoria into cat_prateleira from tem_outra where tem_outra.super.nome == cat_prateleira
        select categoria into cat_produto from tem_outra where tem_outra.super.nome == cat_produto.nome /* no tem_outra.super é a coluna dos pais das super categorias ainda por definir o nome*/
        END LOOP;
    END LOOP;
    IF flag == 0 THEN
         RAISE EXCEPTION 'Um Produto só pode ser reposto numa Prateleira que apresente (pelo menos) uma das
Categorias desse produto';
    END IF;
END;

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
WHERE produto.ean NOT IN (SELECT ean from evento_reposicao)


SELECT  nome
FROM evento_reposicao
NATURAL JOIN produto,retailer
GROUP BY ean
WHERE (COUNT(distinct nome) == 1);