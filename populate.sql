INSERT INTO categoria (nome) VALUES ('Hidratos'),('Proteína'),('Massa'),('Arroz'),('Carne'),('Peixe'),('Gelado'),('Doces');

INSERT INTO categoria_simples(nome) VALUES ('Massa'),('Arroz'),('Carne'),('Peixe'),('Gelado');

INSERT INTO super_categoria(nome) VALUES ('Hidratos'),('Proteína'),('Doces');

INSERT INTO tem_outra(super_categoria,categoria) VALUES ('Hidratos','Massa'),('Proteína','Peixe'),('Hidratos','Arroz'),('Doces','Gelado');

INSERT INTO produto(ean,cat,descr) VALUES ('175616578157','Massa','Esparguete'), ('1955193956522','Massa','Lacinhos'), ('5839678063314','Arroz','Arroz Bazmati'),
 ('8170646435651','Gelado','Perna de Pau'), ('8336565155354','Peixe','Salmão'), ('2661153333792','Carne','Frango'),
  ('2165008898193','Carne','Peru'), ('7242985114642','Peixe','Pescada');

INSERT INTO tem_categoria(ean,nome) VALUES ('175616578157','Massa'), ('1955193956522','Massa'), ('5839678063314','Arroz'),
 ('8170646435651','Gelado'), ('8336565155354','Peixe'), ('2661153333792','Carne'), ('2165008898193','Carne'), ('7242985114642','Peixe');

INSERT INTO ivm(num_serie,manuf) VALUES ('43','Tomás'),('1567','Filipe'),('294','Diogo'),('324','Matilde'),('7542','Marta'),('526','Mariana');

INSERT INTO ponto_de_retalho(nome,distrito,concelho) VALUES ('Galp','Aveiro','Aveiro'),('Continente','Aveiro','Ilhavo'),('Pingo Doce','Lisboa','Lisboa'),
('Mercadona','Porto','Porto'),('Jumbo','Lisboa','Almada');

INSERT INTO instalada_em(num_serie,manuf,place) VALUES ('43','Tomás','Galp'),('1567','Filipe','Jumbo'),('294','Diogo','Continente'),('324','Matilde','Galp'),
('7542','Marta','Pingo Doce'),('526','Mariana','Galp');

INSERT INTO prateleira(nro,num_serie,manuf,heigh,nome) VALUES ('1','43','Tomás','30','Massa'),('2','1567','Filipe','12','Arroz'),
('3','294','Diogo','8','Gelado'),('4','324','Matilde','2','Peixe'),('5','7542','Marta','42','Carne'),('6','526','Mariana','17','Carne');

INSERT INTO planograma(ean,nro,num_serie,manuf,faces,units) 
VALUES ('175616578157','1','43','Tomás','3','7'),
 ('1955193956522','2','1567','Filipe','1','10'),
  ('5839678063314','3','294','Diogo','5','9'),
   ('8170646435651','4','324','Matilde','1','10'),
    ('8336565155354','5','7542','Marta','2','6'),
     ('2661153333792','6','526','Mariana','3','9');

INSERT INTO retalhista(tin,nome) VALUES ('145','Tomás'),('13','Diogo'),('313','Filipe'),('1564','Matilde'),('193','Mariana'),('83','Adriana');

INSERT INTO responsavel_por(nome_cat,tin,num_serie,manuf) VALUES ('Massa','145','43','Tomás'),('Proteína','13','1567','Filipe'),
('Carne','313','294','Diogo'),('Doces','1564','324','Matilde'),('Arroz','193','7542','Marta'),('Hidratos','83','526','Mariana');

INSERT INTO evento_reposicao(ean,nro,num_serie,manuf,instant,units,tin) VALUES ('175616578157','1','43','Tomás','12/07/2020','2','145'), ('5839678063314','3','294','Diogo','16/10/2021','20','13');