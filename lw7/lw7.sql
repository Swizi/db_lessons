-- 1. Добавить внешние ключи

ALTER TABLE mark ADD FOREIGN KEY(id_lesson) REFERENCES lesson(id_lesson);
ALTER TABLE mark ADD FOREIGN KEY(id_student) REFERENCES student(id_student);
ALTER TABLE lesson ADD FOREIGN KEY(id_teacher) REFERENCES teacher(id_teacher);
ALTER TABLE lesson ADD FOREIGN KEY(id_subject) REFERENCES [subject](id_subject);
ALTER TABLE lesson ADD FOREIGN KEY(id_group) REFERENCES [group](id_group);
ALTER TABLE student ADD FOREIGN KEY(id_group) REFERENCES [group](id_group);

GO
-- 2. Выдать оценки студентов по информатике если они обучаются данному предмету.
--    Оформить выдачу данных с использованием view
 --

DROP VIEW computer_science_students_lessons;
DROP VIEW computer_science_result;
GO

CREATE VIEW computer_science_students_lessons AS
  SELECT student.name, lesson.id_lesson FROM student
	LEFT JOIN [group] ON student.id_group = [group].id_group
    LEFT JOIN lesson ON [group].id_group = lesson.id_group
    LEFT JOIN [subject] ON [subject].id_subject = lesson.id_subject
	WHERE [subject].name = 'Информатика'
GO

CREATE VIEW computer_science_result AS
  SELECT computer_science_students_lessons.name, mark.mark FROM computer_science_students_lessons
	LEFT JOIN mark ON computer_science_students_lessons.id_lesson = mark.id_lesson;
GO

SELECT * FROM computer_science_result;
GO

-- 3. Дать информацию о должниках с указанием фамилии студента и названия предмета.
--    Должниками считаются студенты, не имеющие оценки по предмету, который ведется в группе.
--    Оформить в виде процедуры, на входе идентификатор группы

DROP PROCEDURE get_debtors;
GO

CREATE PROCEDURE get_debtors (@ID_GROUP INT)
AS
  SELECT student.name, subject.name, COUNT(mark.mark) FROM student
    LEFT JOIN [group] ON student.id_group = [group].id_group
    LEFT JOIN lesson ON lesson.id_group = [group].id_group
	LEFT JOIN [subject] ON lesson.id_subject = [subject].id_subject
	LEFT JOIN mark ON mark.id_lesson = lesson.id_lesson AND student.id_student = mark.id_student
	WHERE [group].id_group = @ID_GROUP
	GROUP BY student.name, subject.name
	HAVING COUNT(mark.mark) = 0
GO

EXEC get_debtors @ID_GROUP = 4;

SELECT * FROM mark m
join lesson l on l.id_lesson = m.id_lesson 
where m.id_student = 18 and l.id_subject = 10 and l.id_group = 1
-- 4. Дать среднюю оценку студентов по каждому предмету для тех предметов, по которым занимается
-- не менее 35 студентов

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

-- 5. Дать оценки студентов специальности ВМ по всем проводимым предметам с указанием группы, фамилии, предмета, даты.
--    При отсутствии оценки заполнить значениями NULL поля оценки

SELECT [group].name, student.name, subject.name, lesson.date, mark.mark FROM student
  LEFT JOIN [group] ON student.id_group = [group].id_group
  LEFT JOIN lesson ON [group].id_group = lesson.id_group
  LEFT JOIN subject ON lesson.id_subject = subject.id_subject
  LEFT JOIN mark ON lesson.id_lesson = mark.id_lesson
  WHERE [group].name = 'ВМ';

-- 6. Всем студентам специальности ПС, получившим оценки меньшие 5 по предмету 
--    БД до 12.05, повысить эти оценки на 1 балл

SELECT * FROM [group]
  LEFT JOIN lesson ON [group].id_group = lesson.id_group
  LEFT JOIN mark ON mark.id_lesson = lesson.id_lesson
  WHERE [group].name = 'ПС' AND mark.mark < 5 AND lesson.date < '12.05.2019';

UPDATE mark SET mark.mark = mark.mark + 1 FROM [group]
  LEFT JOIN lesson ON [group].id_group = lesson.id_group
  LEFT JOIN mark ON mark.id_lesson = lesson.id_lesson
  WHERE [group].name = 'ПС' AND mark.mark < 5 AND lesson.date < '12.05.2019';

-- 7. Добавить необходимые индексы

CREATE INDEX IX_subject_name ON subject (name);
CREATE INDEX IX_mark_mark ON mark (mark);
CREATE INDEX IX_group_id_group ON [group] (id_group);
CREATE INDEX IX_student_id_student ON student (id_student);
CREATE INDEX IX_group_name ON [group] (name);
CREATE INDEX IX_lesson_date ON lesson (date);