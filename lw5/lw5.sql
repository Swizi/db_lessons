-- 1. �������� ������� �����.
ALTER TABLE room ADD FOREIGN KEY(id_room_category) REFERENCES room_category(id_room_category);
ALTER TABLE room ADD FOREIGN KEY(id_hotel) REFERENCES hotel(id_hotel);
ALTER TABLE room_in_booking ADD FOREIGN KEY(id_room) REFERENCES room(id_room);
ALTER TABLE room_in_booking ADD FOREIGN KEY(id_booking) REFERENCES booking(id_booking);
ALTER TABLE booking ADD FOREIGN KEY(id_client) REFERENCES client(id_client);

-- 2. ������ ���������� � �������� ��������� �������, ����������� � ������� ��������� ����� �� 1 ������ 2019 �
SELECT client.id_client, client.name, client.phone FROM client 
  LEFT JOIN booking ON client.id_client = booking.id_client
  LEFT JOIN room_in_booking ON booking.id_booking = room_in_booking.id_booking
  LEFT JOIN room ON room_in_booking.id_room = room.id_room
  LEFT JOIN hotel ON room.id_hotel = hotel.id_hotel
  LEFT JOIN room_category ON room.id_room_category = room_category.id_room_category
  WHERE hotel.name = '������' AND room_category.name = '����' AND room_in_booking.checkin_date <= '2019-04-01' AND room_in_booking.checkout_date >= '2019-04-01';

-- 3. ���� ������ ��������� ������� ���� �������� �� 22 ������
SELECT room.id_room FROM room
  LEFT JOIN room_in_booking ON room.id_room = room_in_booking.id_room
  WHERE room_in_booking.id_room IS NULL OR NOT (room_in_booking.checkin_date <= '2019-04-22' AND room_in_booking.checkout_date >= '2019-04-22');

-- 4. ���� ���������� ����������� � ��������� ������� �� 23 ����� �� ������ ��������� �������
SELECT room_category.name, COUNT(*) AS clients_quantity FROM room_category 
  LEFT JOIN room ON room.id_room_category = room_category.id_room_category
  LEFT JOIN room_in_booking ON room_in_booking.id_room = room.id_room
  LEFT JOIN hotel ON hotel.id_hotel = room.id_hotel
  WHERE hotel.name = '������' AND (room_in_booking.checkin_date <= '2019-03-23' AND room_in_booking.checkout_date >= '2019-03-23')
  GROUP BY room_category.name;

-- 5. ���� ������ ��������� ����������� �������� �� ���� �������� ��������� �������, ��������� � ������ � ��������� ���� ������
SELECT DISTINCT client.name, room_in_booking.id_room FROM client
  LEFT JOIN booking ON client.id_client = booking.id_client
  LEFT JOIN room_in_booking ON booking.id_booking = room_in_booking.id_booking
  INNER JOIN( 
	  SELECT tbl.id_room, MAX(tbl.checkout_date) AS checkout_date FROM (SELECT room.id_room, room_in_booking.checkout_date FROM booking
	  LEFT JOIN room_in_booking ON room_in_booking.id_booking = booking.id_booking
	  LEFT JOIN room ON room.id_room = room_in_booking.id_room
	  LEFT JOIN hotel ON room.id_hotel = hotel.id_hotel
	  WHERE hotel.name = '������' AND room_in_booking.checkout_date >= '2019-04-01' AND room_in_booking.checkout_date <= '2019-04-30') AS tbl
	  GROUP BY tbl.id_room
  ) AS last_room_date ON last_room_date.checkout_date = room_in_booking.checkout_date AND last_room_date.id_room = room_in_booking.id_room;

-- 6.�������� �� 2 ��� ���� ���������� � ��������� ������� ���� �������� ������ ��������� �������, ������� ���������� 10 ���.
UPDATE room_in_booking SET room_in_booking.checkout_date = DATEADD(DAY, 2, room_in_booking.checkout_date) FROM room_in_booking
  LEFT JOIN room ON room.id_room = room_in_booking.id_room
  LEFT JOIN hotel ON hotel.id_hotel = room.id_hotel
  LEFT JOIN room_category ON room_category.id_room_category = room.id_room_category
  WHERE hotel.name = '������' AND room_category.name = '������' AND room_in_booking.checkin_date = '2019-05-10';

-- ��������
SELECT room_in_booking.checkout_date FROM room_in_booking
  LEFT JOIN room ON room.id_room = room_in_booking.id_room
  LEFT JOIN hotel ON hotel.id_hotel = room.id_hotel
  LEFT JOIN room_category ON room_category.id_room_category = room.id_room_category
  WHERE hotel.name = '������' AND room_category.name = '������' AND room_in_booking.checkin_date = '2019-05-10';

-- 7. ����� ��� "��������������" �������� ����������.
SELECT * FROM room_in_booking AS tbl1
  INNER JOIN room_in_booking AS tbl2 ON ((tbl2.checkin_date >= tbl1.checkin_date AND tbl2.checkin_date <= tbl1.checkout_date) OR
  (tbl2.checkout_date >= tbl1.checkin_date AND tbl2.checkout_date <= tbl1.checkout_date) OR
  (tbl1.checkin_date >= tbl2.checkin_date AND tbl1.checkout_date < tbl2.checkout_date)) AND
  (tbl1.id_room = tbl2.id_room and tbl1.id_room_in_booking != tbl2.id_room_in_booking);
--  ������ ����� ����������� ��������, ��� ������� ������������ ���, ��� ������� tbl2 ����� ���� ������ tbl1
--  ������� ��������, ��� tbl1 ����� ���� ������ tbl2

SELECT * FROM room_in_booking AS tbl1
  INNER JOIN room_in_booking AS tbl2 ON (tbl1.id_room = tbl2.id_room and tbl1.id_room_in_booking != tbl2.id_room_in_booking)
 where (tbl2.checkin_date <= tbl1.checkin_date AND tbl2.checkout_date >= tbl1.checkin_date) OR
  (tbl2.checkin_date >= tbl1.checkin_date AND tbl2.checkin_date <= tbl1.checkout_date);

-- 8. ������� ������������ � ����������
-- scope_identity
BEGIN TRANSACTION
  INSERT INTO client (name, phone) VALUES ('������� �������', '7(92)653-47-80');
  INSERT INTO booking (id_client, booking_date) (SELECT id_client, '2021-03-17' FROM client WHERE name = '������� �������' AND phone = '7(92)653-47-80');
  INSERT INTO room_in_booking (id_booking, id_room, checkin_date, checkout_date)
    (SELECT id_booking, 10, '2021-03-18', '2021-03-20' FROM booking WHERE id_booking =
    (SELECT id_booking FROM booking WHERE id_client =
    (SELECT id_client FROM client WHERE name = '������� �������' AND phone = '7(92)653-47-80')));
COMMIT TRANSACTION;

-- 9. �������� ����������� ������� ��� ���� ������
CREATE INDEX idx_room_category ON room_category (name);
CREATE INDEX idx_hotel ON hotel (name);
CREATE INDEX idx_checkin_date ON room_in_booking (checkin_date);
CREATE INDEX idx_checkout_date ON room_in_booking (checkout_date);
CREATE INDEX idx_client ON client (name, phone);