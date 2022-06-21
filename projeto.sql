CREATE DATABASE projeto 

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
);

CREATE TABLE produto(
    ean numeric(13,0) NOT NULL,
    cat varchar(255) NOT NULL,
    descr varchar(255) NOT NULL,
    PRIMARY KEY(ean),
    FOREIGN KEY(cat) REFERENCES categoria(nome)
);

CREATE TABLE tem_categoria(
    ean numeric(13,0) NOT NULL,
    nome varchar(255) NOT NULL,
    FOREIGN KEY(ean) REFERENCES produto(ean),
    FOREIGN KEY(nome) REFERENCES categoria(nome)
);

CREATE TABLE ivm(
    num_serie int NOT NULL,
    manuf varchar(255) NOT NULL,
    PRIMARY KEY(num_serie),
    PRIMARY KEY(manuf)
);

CREATE TABLE ponto_de_retalho(
    nome varchar(255) NOT NULL,
    distrito varchar(255) NOT NULL,
    concelho varchar(255) NOT NULL, 
    PRIMARY KEY(nome)
);

CREATE TABLE instalada_em(
    num_serie int NOT NULL,
    manuf varchar(255) NOT NULL,
    place varchar(255) NOT NULL,
    PRIMARY KEY(num_serie),
    PRIMARY KEY(manuf),
    FOREIGN KEY(num_serie) REFERENCES ivm(num_serie),
    FOREIGN KEY(manuf) REFERENCES ivm(manuf),
    FOREIGN KEY(place) REFERENCES ponto_de_retalho(concelho)
);

CREATE TABLE prateleira(
    nro int NOT NULL,
    num_serie int NOT NULL,
    manuf varchar(255) NOT NULL,
    heigh int NOT NULL,
    nome varchar(255) NOT NULL,
    PRIMARY KEY(nro),
    PRIMARY KEY(num_serie),
    PRIMARY KEY(manuf),
    FOREIGN KEY(num_serie) REFERENCES ivm(num_serie),
    FOREIGN KEY(manuf) REFERENCES ivm(manuf),
    FOREIGN KEY(nome) REFERENCES categoria(nome)
);

CREATE TABLE planograma(
    ean numeric(13,0) NOT NULL,
    nro int NOT NULL,
    num_serie int NOT NULL,
    manuf varchar(255) NOT NULL,
    faces int NOT NULL,
    units int NOT NULL,
    PRIMARY KEY(ean),
    PRIMARY KEY(nro),
    PRIMARY KEY(num_serie),
    PRIMARY KEY(manuf),
    FOREIGN KEY(ean) REFERENCES produto(ean),
    FOREIGN KEY(nro) REFERENCES prateleira(nro),
    FOREIGN KEY(num_serie) REFERENCES prateleira(num_serie),
    FOREIGN KEY(manuf) REFERENCES prateleira(manuf)
);

CREATE TABLE retalhista(
    tin int NOT NULL,
    nome varchar(255) NOT NULL,
    UNIQUE(nome),
    PRIMARY KEY(tin)
);

CREATE TABLE responsavel_por(
    nome_cat varchar(255) NOT NULL,
    tin int NOT NULL,
    num_serie int NOT NULL,
    manuf varchar(255) NOT NULL,
    PRIMARY KEY(num_serie),
    PRIMARY KEY(manuf),
    FOREIGN KEY(num_serie) REFERENCES ivm(num_serie),
    FOREIGN KEY(manuf) REFERENCES ivm(manuf),
    FOREIGN KEY(tin) REFERENCES retalhista(tin),
    FOREIGN KEY(nome_cat) REFERENCES categoria(nome) 
);

CREATE TABLE evento_reposicao(
    ean numeric(13,0) NOT NULL,
    nro int NOT NULL,
    num_serie int NOT NULL,
    manuf varchar(255) NOT NULL,
    instant varchar(10) NOT NULL,
    units int NOT NULL,
    tin int NOT NULL,
    PRIMARY KEY(ean),
    PRIMARY KEY(nro),
    PRIMARY KEY(num_serie),
    PRIMARY KEY(manuf),
    PRIMARY KEY(instant),
    FOREIGN KEY(ean) REFERENCES planograma(ean),
    FOREIGN KEY(nro) REFERENCES planograma(nro),
    FOREIGN KEY(num_serie) REFERENCES planograma(num_serie),
    FOREIGN KEY(manuf) REFERENCES planograma(manuf),
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


SELECT MAX(count(nome)),
FROM responsavel_por
NATURAL JOIN retailer
GROUP BY nome_cat

 
SELECT nome
FROM responsavel_por NATURAL JOIN categoria_simples
GROUP BY nome
HAVING count(distinct (categoria_simples.nome)) = (SELECT count(*) FROM categoria_simples);

SELECT ean 
FROM produto
WHERE produto.ean NOT IN (SELECT ean from evento_reposicao)


SELECT  nome
FROM evento_reposicao
NATURAL JOIN produto,retailer
GROUP BY ean
WHERE (count(distinct nome) == 1);
 

SELECT customer_name
FROM depositor d NATURAL JOIN customer c
WHERE NOT EXISTS (
SELECT branch_name
FROM branch
WHERE branch_city = c.customer_city
EXCEPT
SELECT branch_name
FROM depositor d2 NATURAL JOIN account
WHERE d2.customer_name = d.custumer_name);


