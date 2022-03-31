-- 1. �������� ������� �����

ALTER TABLE mark ADD FOREIGN KEY(id_lesson) REFERENCES lesson(id_lesson);
ALTER TABLE mark ADD FOREIGN KEY(id_student) REFERENCES student(id_student);
ALTER TABLE lesson ADD FOREIGN KEY(id_teacher) REFERENCES teacher(id_teacher);
ALTER TABLE lesson ADD FOREIGN KEY(id_subject) REFERENCES [subject](id_subject);
ALTER TABLE lesson ADD FOREIGN KEY(id_group) REFERENCES [group](id_group);
ALTER TABLE student ADD FOREIGN KEY(id_group) REFERENCES [group](id_group);

GO
-- 2. ������ ������ ��������� �� ����������� ���� ��� ��������� ������� ��������.
--    �������� ������ ������ � �������������� view

CREATE VIEW computer_science_result AS
  SELECT student.name, mark.mark FROM student
    LEFT JOIN mark ON student.id_student = mark.id_student
    LEFT JOIN lesson ON mark.id_lesson = lesson.id_lesson
    LEFT JOIN [subject] ON [subject].id_subject = lesson.id_subject
	WHERE [subject].name = '�����������'
GO

SELECT * FROM computer_science_result;
GO

-- 3. ���� ���������� � ��������� � ��������� ������� �������� � �������� ��������.
--    ���������� ��������� ��������, �� ������� ������ �� ��������, ������� ������� � ������.
--    �������� � ���� ���������, �� ����� ������������� ������

CREATE PROCEDURE debtor_procedure (@ID_GROUP INT)
AS
  SELECT student.name as student, [subject].name as subject FROM  student
    LEFT JOIN [group] ON student.id_group = [group].id_group
    LEFT JOIN lesson ON lesson.id_group = [group].id_group
	LEFT JOIN [subject] ON lesson.id_subject = [subject].id_subject
	LEFT JOIN mark ON mark.id_lesson = lesson.id_lesson
	WHERE mark.mark IS NULL AND [group].id_group = @ID_GROUP
GO

EXEC debtor_procedure @ID_GROUP = 1;

-- 4. ���� ������� ������ ��������� �� ������� �������� ��� ��� ���������, �� ������� ����������
-- �� ����� 35 ���������

CREATE TABLE #subject_student_quantity(id_subject int, subject_name nvarchar(50), student_quantity int, subject_average_mark smallint);
INSERT INTO #subject_student_quantity
  SELECT subject.id_subject, subject.name, COUNT(student.id_student), AVG(mark.mark) FROM subject
  LEFT JOIN lesson ON [subject].id_subject = lesson.id_subject
  LEFT JOIN [group] ON lesson.id_group = [group].id_group
  LEFT JOIN student ON [group].id_group = student.id_group
  LEFT JOIN mark ON lesson.id_lesson = mark.id_lesson
  WHERE student.id_student IS NOT NULL
  GROUP BY subject.id_subject, subject.name;

SELECT subject_name, subject_average_mark FROM #subject_student_quantity WHERE student_quantity >= 35;

-- 5. ���� ������ ��������� ������������� �� �� ���� ���������� ��������� � ��������� ������, �������, ��������, ����.
--    ��� ���������� ������ ��������� ���������� NULL ���� ������

SELECT [group].name, student.name, subject.name, lesson.date, mark.mark FROM student
  LEFT JOIN [group] ON student.id_group = [group].id_group
  LEFT JOIN lesson ON [group].id_group = lesson.id_group
  LEFT JOIN subject ON lesson.id_subject = subject.id_subject
  LEFT JOIN mark ON lesson.id_lesson = mark.id_lesson
  WHERE [group].name = '��';

-- 6. ���� ��������� ������������� ��, ���������� ������ ������� 5 �� �������� 
--    �� �� 12.05, �������� ��� ������ �� 1 ����

SELECT * FROM [group]
  LEFT JOIN lesson ON [group].id_group = lesson.id_group
  LEFT JOIN mark ON mark.id_lesson = lesson.id_lesson
  WHERE [group].name = '��' AND mark.mark < 5 AND lesson.date < '12.05.2019';

UPDATE mark SET mark.mark = mark.mark + 1 FROM [group]
  LEFT JOIN lesson ON [group].id_group = lesson.id_group
  LEFT JOIN mark ON mark.id_lesson = lesson.id_lesson
  WHERE [group].name = '��' AND mark.mark < 5 AND lesson.date < '12.05.2019';

-- 7. �������� ����������� �������

CREATE INDEX IX_subject_name ON subject (name);
CREATE INDEX IX_mark_mark ON mark (mark);
CREATE INDEX IX_group_id_group ON [group] (id_group);
CREATE INDEX IX_student_id_student ON student (id_student);
CREATE INDEX IX_group_name ON [group] (name);
CREATE INDEX IX_lesson_date ON lesson (date);