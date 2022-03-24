-- INSERT
INSERT INTO barbershop VALUES ('21 BARBER', 'г. Йошкар-Ола, ул. Комсомольская, д.31', '1978-05-05');
INSERT INTO hairdresser VALUES ('Дмитрий Киселёв', 1, 200);
INSERT INTO barbershop (title, address, opening_date) VALUES ('MARI BARBER', 'г. Йошкар-Ола, ул. Димитрова, д. 78', '2012-09-09');
INSERT INTO client (full_name) SELECT full_name FROM hairdresser;

-- DELETE
DELETE FROM completed_work;
DELETE FROM client WHERE full_name = 'Дмитрий Киселёв';

-- UPDATE
UPDATE client SET full_name = 'Илья Шулепов';
UPDATE client SET full_name = 'Назиель Петров' WHERE full_name = 'Илья Шулепов';
UPDATE client SET full_name = 'Илья Шулепов', phone_number = '89648637651' WHERE full_name = 'Назиель Петров';

-- SELECT
SELECT full_name, phone_number FROM client;
SELECT * FROM client;
SELECT * FROM client WHERE full_name = 'Назиель Петров';

-- SELECT ORDER BY + TOP(LIMIT)
SELECT TOP(3) * FROM client ORDER BY full_name ASC;
SELECT * FROM client ORDER BY full_name DESC;
SELECT TOP(3) * FROM client ORDER BY full_name, phone_number;
SELECT * FROM client ORDER BY 1;

-- DATE
SELECT * FROM barbershop WHERE opening_date = '1978-05-05';
SELECT * FROM barbershop WHERE opening_date > '1978-05-05' AND opening_date <= '2020-12-12';
SELECT title, YEAR(opening_date) AS opening_year FROM barbershop WHERE opening_date = '1978-05-05';

-- Aggregation
SELECT COUNT(*) FROM barbershop;
SELECT COUNT(DISTINCT title) FROM barbershop;
SELECT DISTINCT title FROM barbershop;
SELECT MAX(opening_date) FROM barbershop;
SELECT MIN(opening_date) FROM barbershop;
SELECT title, COUNT(title) AS quantity FROM barbershop GROUP BY title;

-- До этого Захар уже проверил

-- SELECT GROUP BY + HAVING
-- Парикмахеры, попавшие под сокращение
SELECT id_hairdresser FROM completed_work GROUP BY id_hairdresser HAVING COUNT(id_service) < 5;

-- Лояльные клиенты
SELECT id_client FROM completed_work GROUP BY id_client HAVING COUNT(id_client) > 3;

-- Топ-3 парикмахеров месяца
SELECT TOP 3 id_hairdresser, SUM(CASE WHEN execution_time > '2022-11-02 00:00:00' THEN 1 ELSE 0 END) AS service_quantity 
  FROM completed_work GROUP BY id_hairdresser 
  HAVING SUM(CASE WHEN execution_time > '2022-11-02 00:00:00' THEN 1 ELSE 0 END) > 5;

-- SELECT JOIN
-- Получить номера телефонов или email клиентов, стрижка у которых была больше, чем месяц назад(для рассылки уведомления)
SELECT full_name, phone_number, email FROM completed_work
  LEFT JOIN client
  ON client.id_client = completed_work.id_client
  WHERE execution_time > '2022-11-01 00:00:00' AND execution_time < '2022-11-02 00:00:00';

-- Получить номера телефонов или email клиентов, стрижка у которых была больше, чем месяц назад(для рассылки уведомления)
SELECT full_name, phone_number, email FROM client
  RIGHT JOIN completed_work
  ON client.id_client = completed_work.id_client
  WHERE execution_time > '2022-11-01 00:00:00' AND execution_time < '2022-11-02 00:00:00';

SELECT client.full_name, hairdresser.full_name FROM client
  LEFT JOIN completed_work
  ON completed_work.id_client = client.id_client
  LEFT JOIN hairdresser
  ON completed_work.id_hairdresser = hairdresser.id_hairdresser
  WHERE (hairdresser.salary_per_hour > 1000) AND (NOT client.phone_number IS NULL) AND (completed_work.id_barbershop = 1);

SELECT full_name, phone_number FROM completed_work
  INNER JOIN client
  ON client.id_client = completed_work.id_client;

-- Подзапросы

-- Получить имя, телефон у клиентов, которые ходят в первый барбершоп
SELECT full_name, phone_number FROM client
  WHERE id_client IN 
  (SELECT id_client FROM completed_work WHERE id_barbershop = 1);

-- Получить id клиента, id парикмахера и имя клиента
SELECT id_client, id_hairdresser,
  (SELECT full_name FROM client WHERE client.id_client = completed_work.id_client) AS client_name
  FROM completed_work;

SELECT * FROM
  (SELECT id_client, id_hairdresser FROM completed_work) AS tbl;

SELECT * FROM
  client JOIN (SELECT id_client, id_hairdresser FROM completed_work) AS tbl
  ON tbl.id_client = client.id_client;
