/*
INFO 430: Database Design and Management
Lab Assignment #2
Student Name : Gabriella Rivera 
Due Date: 4/20/2024
*/

USE UNIVERSITY

/*
Question 1: Write the SQL code to label every student into one of the following
based on their birthdate and return a count of how many are under each label
(HINT: this will be easiest if you use a CASE statement):
a) if they were born before January 1, 1925, label them as 'Greatest Generation'
b) if they were born between 1925 and 1945, label them as 'Silent Generation'
c) if they were born between 1946 and 1964, label them as 'Baby Boomers'
d) if they were born between 1965 and 1976, label them as 'Generation X'
e) if they were born between 1977 and 1995, label them as 'Millenials'
f) Else 'Generation ZZZZZZZ'
*/

-- SELECT TOP 5 * FROM tblSTUDENT

-- SELECT 
--   StudentID,
--   StudentFName,
--   StudentLName,
--   StudentBirth,
--   CASE
--     WHEN StudentBirth < '1925-01-01' THEN 'Greatest Generation'
--     WHEN StudentBirth BETWEEN '1925-01-01' AND '1945-12-31' THEN 'Silent Generation'
--     WHEN StudentBirth BETWEEN '1946-01-01' AND '1964-12-31' THEN 'Baby Boomers'
--     WHEN StudentBirth BETWEEN '1965-01-01' AND '1976-12-31' THEN 'Generation X'
--     WHEN StudentBirth BETWEEN '1977-01-01' AND '1995-12-31' THEN 'Millenials'
--     ELSE 'Generation ZZZZZZZ'
--   END AS GenerationLabel
-- FROM 
--   tblSTUDENT;

-- SELECT 
--   GenerationLabel,
--   COUNT(*) AS NumberOfStudents
-- FROM (
--   SELECT 
--     StudentBirth,
--     CASE
--       WHEN StudentBirth < '1925-01-01' THEN 'Greatest Generation'
--       WHEN StudentBirth BETWEEN '1925-01-01' AND '1945-12-31' THEN 'Silent Generation'
--       WHEN StudentBirth BETWEEN '1946-01-01' AND '1964-12-31' THEN 'Baby Boomers'
--       WHEN StudentBirth BETWEEN '1965-01-01' AND '1976-12-31' THEN 'Generation X'
--       WHEN StudentBirth BETWEEN '1977-01-01' AND '1995-12-31' THEN 'Millenials'
--       ELSE 'Generation ZZZZZZZ'
--     END AS GenerationLabel
--   FROM 
--     tblSTUDENT
-- ) AS SubQuery
-- GROUP BY GenerationLabel;


/*
Question 2: Write a stored procedure that will return department name and
total registration fees by department ordered by the most dollars received from
registration fees in descending order with the following conditions:
a). Users should be able to specify how many rows of result set using 'Top N'.
N should be passed to the procedure as a parameter.
b). Users should be able to specify that the class level is at least at a certain
level.
For example, classes are at least '300-level' (Hint: use courseNumber column).
This threshold should be passed to procedure as a parameter.
c) Users should be able to specify the student's permanent city (i.e.,
StudentPermCity).
This should be passed to the procedure as a parameter
d) Users should be able to specify registration date window (i.e., Begin date and
end date)
These should be passed to the function as parameters.
After you code the procedure, compile it and thereafter test it to ensure that it
is working correctly.
*/

-- RETURN -->  department name      total registration fees -- 
-- PARAMETERS --> N (number of rows of result)
--                class level >=                                
--                StudentPermCity
--                registration date window (Begin date and end date)
SELECT TOP 5 * FROM tblDEPARTMENT
SELECT TOP 5 * FROM tblCLASS_LIST
GO

/* STEP 2: DEFINE The Stored procedure */
CREATE OR ALTER Procedure depRegistrationFees
  (@C_city VARCHAR(50), @C_state VARCHAR(50))