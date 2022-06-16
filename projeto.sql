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

CREATE TABLE product(
    ean numeric(13,0),
    cat varchar(255),
    descr varchar(255),
    PRIMARY KEY(ean),
    FOREIGN KEY(cat) REFERENCES category(nome)
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

CREATE TABLE shelve(
    nro int,
    num_serie int,
    manuf varchar(255),
    heigh int,
    nome varchar(255),
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
