CREATE DATABASE projeto 

CREATE TABLE category(
    nome varchar(255),
    PRIMARY KEY(nome),
    nome IN ((SELECT nome FROM simple_category) UNION (SELECT nome FROM super_category))
);

CREATE TABLE simple_category(
    nome varchar(255),
    FOREIGN KEY(nome) REFERENCES category(nome)
);

CREATE TABLE super_category(
    nome varchar(255)
    FOREIGN KEY(nome) REFERENCES category(nome)
);

CREATE TABLE tem_outra(
    super_category,
    category,
    PRIMARY KEY(category),
    FOREIGN KEY(category) REFERENCES category(nome),
    FOREIGN KEY(super_category) REFERENCES super_category(nome),
    super_category != category
);

CREATE TABLE product(
    ean numeric(13,0),
    cat varchar(255),
    descr varchar(255),
    PRIMARY KEY(ean),
    FOREIGN KEY(cat) REFERENCES category(nome)
);

CREATE TABLE tem_categoria(
    ean numeric(13,0),
    nome varchar(255),
    FOREIGN KEY(ean) REFERENCES product(ean),
    FOREIGN KEY(nome) REFERENCES category(nome)
);

CREATE TABLE ivm(
    num_serie int,
    manuf varchar(255),
    PRIMARY KEY(num_serie,manuf),
);

CREATE TABLE ponto_de_retalho(
    nome varchar(255),
    distrito varchar(255),
    concelho varchar(255),
    PRIMARY KEY(nome)
);

CREATE TABLE installed_at(
    num_serie int,
    manuf varchar(255),
    place varchar(255),
    PRIMARY KEY(num_serie),
    PRIMARY KEY(manuf),
    FOREIGN KEY(num_serie) REFERENCES ivm(num_serie),
    FOREIGN KEY(manuf) REFERENCES ivm(manuf),
    FOREIGN KEY(place) REFERENCES ponto_de_retalho(concelho)
);

CREATE TABLE shelve(
    nro int,
    num_serie int,
    manuf varchar(255),
    heigh int,
    nome varchar(255),
    PRIMARY KEY(nro),
    PRIMARY KEY(num_serie),
    PRIMARY KEY(manuf),
    FOREIGN KEY(num_serie) REFERENCES ivm(num_serie),
    FOREIGN KEY(manuf) REFERENCES ivm(manuf),
    FOREIGN KEY(nome) REFERENCES category(nome)
);

CREATE TABLE planograma(
    ean numeric(13,0),
    nro int,
    num_serie int,
    manuf varchar(255),
    faces int,
    units int,
    loc varchar(255)
);

CREATE TABLE retailer(
    tin int,
    nome varchar(255),
    UNIQUE(nome),
    PRIMARY KEY(tin)
);

CREATE TABLE responsible_for(
    nome_cat varchar(255),
    tin int,
    num_serie int,
    manuf varchar(255),
    PRIMARY KEY(num_serie,manuf),
    FOREIGN KEY(num_serie) REFERENCES ivm(num_serie),
    FOREIGN KEY(manuf) REFERENCES ivm(manuf),
    FOREIGN KEY(tin) REFERENCES retailer(tin),
    FOREIGN KEY(nome_cat) REFERENCES category(nome) 
);

CREATE TABLE replanishment_event(
    ean numeric(13,0),
    nro int,
    num_serie int,
    manuf varchar(255),
    instant varchar(10),
    units int,
    tin int,
    PRIMARY KEY(ean,nro,num_serie,manuf,instant),
    FOREIGN KEY(ean) REFERENCES planograma(ean),
    FOREIGN KEY(nro) REFERENCES planograma(nro),
    FOREIGN KEY(num_serie) REFERENCES planograma(num_serie),
    FOREIGN KEY(manuf) REFERENCES planograma(manuf),
    FOREIGN KEY(tin) REFERENCES retailer(tin)
);

/* RESTRIÇÔES DE INTEGRIDADE */

DROP TRIGGER IF EXISTS verifica_categoria_dentro_mesma ON tem_outra;
DROP TRIGGER IF EXISTS verifica_numero_unidades ON replanishment_event;
DROP TRIGGER IF EXISTS verifica_produto_reposto ON replanishment_event;

CREATE OR REPLACE FUNCTION verifica_numero_unidades_trigger_proc() RETURNS TRIGGER AS $$
BEGIN
    SELECT (replanishment_event.units, planograma.units) INTO (rep_units, plan_units)
    FROM replanishment_event, planograma
    WHERE replanishment_event.num_serie == planograma.num_serie;
    
    IF rep_units > place THEN
        RAISE EXCEPTION 'O número de unidades repostas no evento de reposição excedeu o número
        especificado no planograma';
    END IF;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION  verifica_categoria_dentro_mesma_trigger_proc() RETURNS TRIGGER AS $$
DECLARE  in_category VARCHAR(255) := '' ;
DECLARE  super VARCHAR(255) := '' ;
BEGIN
    select (super,category) into (super,in_category) from tem_outra;
    WHILE in_category IS NOT NULL THEN
        IF in_category.nome == super.nome THEN
            RAISE EXCEPTION 'Uma Categoria não pode estar contida em si própria';
        END IF;
        select (super,category) into (super,in_category) from tem_outra WHERE super.nome == in_category.nome;
    END LOOP;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION  verifica_produto_reposto_trigger_proc() RETURNS TRIGGER AS $$
DECLARE  cat_produto VARCHAR(255) := '' ;
DECLARE  cat_prateleira VARCHAR(255) := '' ;
DECLARE  flag INTEGER := 0;
BEGIN  
    select ean.cat,num_serie.nome INTO cat_produto,cat_prateleira 
    from replanishment_event
    
    WHILE cat_produto IS NOT NULL THEN
        select num_serie.nome INTO cat_prateleira 
        from replanishment_event
        WHILE cat_prateleira IS NOT NULL THEN
            IF cat_produto == cat_prateleira THEN
                SET flag = flag + 1 ;
            END IF; 
            select category into cat_prateleira from tem_outra where tem_outra.super.nome == cat_prateleira
        select category into cat_produto from tem_outra where tem_outra.super.nome == cat_produto.nome /* no tem_outra.super é a coluna dos pais das super categorias ainda por definir o nome*/
        END LOOP;
    END LOOP;
    IF flag == 0 THEN
         RAISE EXCEPTION 'Um Produto só pode ser reposto numa Prateleira que apresente (pelo menos) uma das
Categorias desse produto';
    END IF;
END;

/*  SQL   */


SELECT MAX(count(nome)),
FROM responsible_for
NATURAL JOIN retailer
GROUP BY nome_cat

 
SELECT nome
FROM responsible_for NATURAL JOIN simple_category
GROUP BY nome
HAVING count(distinct (simple_category.nome)) = (SELECT count(*) FROM simple_category);

SELECT ean 
FROM product
WHERE product.ean NOT IN (SELECT ean from replanishment_event)


SELECT  nome
FROM replanishment_event
NATURAL JOIN product,retailer
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


