INSERT INTO categoria (nome) VALUES ('Hidratos'),('Proteína'),
    ('Massa'),('Arroz'),('Carne'),('Peixe'),('Gelado'),('Doces');

INSERT INTO categoria_simples(nome) VALUES ('Massa'),('Arroz'),('Carne'),('Peixe'),('Gelado');

INSERT INTO super_categoria(nome) VALUES ('Hidratos'),('Proteína'),('Doces');

INSERT INTO produto(ean) VALUES ('175616578157'), ('1955193956522'), ('5839678063314'), ('8170646435651'), ('8336565155354'), ('2661153333792'), ('2165008898193'), ('7242985114642');
INSERT INTO produto(cat) VALUES  ('Massa'),('Massa'),
    ('Arroz'),('Gelado'),('Peixe'),('Carne'),('Carne'),('Peixe');
INSERT INTO produto(descr) VALUES ('Esparguete'),('Lacinhos'),('Arroz Bazmati'),
    ('Perna de Pau'),('Salmão'),('Peru'),('Frango'),('Pescada');

INSERT INTO tem_categoria(ean) VALUES ('175616578157'), ('1955193956522'), ('5839678063314'), ('8170646435651'), ('8336565155354'), ('2661153333792'), ('2165008898193'), ('7242985114642');
INSERT INTO tem_categoria(cat) VALUES ('Massa'),('Massa'),
    ('Arroz'),('Gelado'),('Peixe'),('Carne'),('Carne'),('Peixe');

INSERT INTO ivm(num_serie) VALUES ('43'),('1567'),('294'),('324'),('7542'),('526');
INSERT INTO ivm(manuf) VALUES ('Tomás'),('Filipe'),('Diogo'),('Matilde'),('Francisco'),('Mariana');

INSERT INTO ponto_de_retalho(nome) VALUES ('Galp'),('Continente'),('Pingo Doce'),('Mercadona'),('Galp');
INSERT INTO ponto_de_retalho(distrito) VALUES ('Aveiro'),('Aveiro'),('Lisboa'),('Porto'),('Lisboa');
INSERT INTO ponto_de_retalho(concelho) VALUES ('Aveiro'),('Ilhavo'),('Lisboa'),('Porto'),('Almada');

INSERT INTO instalada_em(num_serie) VALUES ('43'),('1567'),('294'),('324'),('7542'),('526');
INSERT INTO instalada_em(manuf) VALUES ('Tomás'),('Filipe'),('Diogo'),('Matilde'),('Francisco'),('Mariana');
INSERT INTO instalada_em(place) VALUES ('Aveiro'),('Ilhavo'),('Lisboa'),('Porto'),('Almada');~

INSERT INTO prateleira(nro) VALUES ('1'),('2'),('3'),('4'),('5'),('6');
INSERT INTO prateleira(num_serie) VALUES ('43'),('1567'),('294'),('324'),('7542'),('526');
INSERT INTO prateleira(manuf) VALUES ('Tomás'),('Filipe'),('Diogo'),('Matilde'),('Francisco'),('Mariana');
INSERT INTO prateleira(heigh) VALUES ('30'),('12'),('8'),('2'),('42'),('17');
INSERT INTO prateleira(nome) VALUES ('Massa'),('Arroz'),('Gelado'),('Peixe'),('Carne'),('Carne');

INSERT INTO planograma(ean) VALUES ('175616578157'), ('1955193956522'), ('5839678063314'), ('8170646435651'), ('8336565155354'), ('2661153333792'), ('2165008898193'), ('7242985114642');
INSERT INTO planograma(nro) VALUES ('1'),('1'),('4'),('6'),('2'),('2');
INSERT INTO planograma(num_serie) VALUES ('43'),('1567'),('294'),('324'),('7542'),('526');
INSERT INTO planograma(manuf) VALUES ('Tomás'),('Filipe'),('Diogo'),('Matilde'),('Francisco'),('Mariana');
INSERT INTO planograma(faces) VALUES ('3'),('1'),('5'),('1'),('2'),('3');
INSERT INTO planograma(units) VALUES ('7'),('10'),('9'),('10'),('6'),('9');

INSERT INTO retalhista(tin) VALUES ('145'),('13'),('313'),('1564'),('193'),('83');
INSERT INTO retalhista(nome) VALUES ('Tomás'),('Diogo'),('Filipe'),('Matilde'),('Mariana'),('Adriana');

INSERT INTO responsavel_por(nome_cat) VALUE ('Massa'),('Proteína'),('Carne'),('Doces'),('Arroz'),('Hidratos');
INSERT INTO responsavel_por(tin) VALUES ('145'),('13'),('313'),('1564'),('193'),('83');
INSERT INTO responsavel_por(num_serie) VALUES ('43'),('1567'),('294'),('324'),('7542'),('526');
INSERT INTO responsavel_por(manuf) VALUES ('Tomás'),('Filipe'),('Diogo'),('Matilde'),('Francisco'),('Mariana');

INSERT INTO evento_reposicao(ean) VALUES ('175616578157'), ('1955193956522'), ('5839678063314'), ('8170646435651'), ('8336565155354'), ('2661153333792'), ('2165008898193'), ('7242985114642');
INSERT INTO evento_reposicao(nro) VALUES ('1'),('1'),('4'),('6'),('2'),('2');
INSERT INTO evento_reposicao(num_serie) VALUES ('43'),('1567'),('294'),('324'),('7542'),('526');
INSERT INTO evento_reposicao(manuf) VALUES ('Tomás'),('Filipe'),('Diogo'),('Matilde'),('Francisco'),('Mariana');
INSERT INTO evento_reposicao(instant) VALUES ('12/07/2020'),('27/03/2021'),('16/10/2021'),('01/09/2020'),('23/04/2022'),('12/03/2021');
INSERT INTO evento_reposicao(units) VALUES ('2'),('44'),('21'),('32'),('10'),('15');
INSERT INTO evento_reposicao(tin) VALUES ('145'),('13'),('313'),('1564'),('193'),('83');