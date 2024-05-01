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

SELECT TOP 5 * FROM tblSTUDENT

SELECT 
  StudentID,
  StudentFName,
  StudentLName,
  StudentBirth,
  CASE
    WHEN StudentBirth < '1925-01-01' THEN 'Greatest Generation'
    WHEN StudentBirth BETWEEN '1925-01-01' AND '1945-12-31' THEN 'Silent Generation'
    WHEN StudentBirth BETWEEN '1946-01-01' AND '1964-12-31' THEN 'Baby Boomers'
    WHEN StudentBirth BETWEEN '1965-01-01' AND '1976-12-31' THEN 'Generation X'
    WHEN StudentBirth BETWEEN '1977-01-01' AND '1995-12-31' THEN 'Millenials'
    ELSE 'Generation ZZZZZZZ'
  END AS GenerationLabel
FROM 
  tblSTUDENT;

SELECT 
  GenerationLabel,
  COUNT(*) AS NumberOfStudents
FROM (
  SELECT 
    StudentBirth,
    CASE
      WHEN StudentBirth < '1925-01-01' THEN 'Greatest Generation'
      WHEN StudentBirth BETWEEN '1925-01-01' AND '1945-12-31' THEN 'Silent Generation'
      WHEN StudentBirth BETWEEN '1946-01-01' AND '1964-12-31' THEN 'Baby Boomers'
      WHEN StudentBirth BETWEEN '1965-01-01' AND '1976-12-31' THEN 'Generation X'
      WHEN StudentBirth BETWEEN '1977-01-01' AND '1995-12-31' THEN 'Millenials'
      ELSE 'Generation ZZZZZZZ'
    END AS GenerationLabel
  FROM 
    tblSTUDENT
) AS SubQuery
GROUP BY GenerationLabel;


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

-- SELECT TOP 5 * FROM tblSTUDENT
-- SELECT TOP 5 * FROM tblCLASS_LIST
-- SELECT TOP 5 * FROM tblCLASS
-- SELECT TOP 5 * FROM tblCOURSE
-- SELECT TOP 5 * FROM tblDEPARTMENT
-- SELECT TOP 5 * FROM tblQUARTER
GO

/* STEP 2: DEFINE The Stored procedure */
CREATE OR ALTER Procedure GetDeptRegistrationFees
  @TopN INTEGER, 
  @CR_level NUMERIC(3,0), 
  @S_City VARCHAR(75), 
  @Begin_Reg_Date DATE,
  @End_Reg_Date DATE
  AS
  BEGIN
  --define select query
    SELECT TOP (@TopN) d.DeptName, SUM(cl.RegistrationFee) as TotalRegistrationFees
    FROM tblStudent s
      JOIN tblCLASS_LIST cl ON s.StudentID = cl.StudentID
      JOIN tblCLASS c on cl.ClassID = c.ClassID
      JOIN tblCOURSE cr on c.CourseID = cr.CourseID
      JOIN tblDEPARTMENT d on cr.DeptID = d.DeptID
      --where condition with parameter values
    WHERE cr.CourseNumber >= @CR_level 
      AND s.StudentPermCity = @S_City
      AND cl.RegistrationDate BETWEEN @Begin_Reg_Date and @End_Reg_Date
    GROUP BY d.DeptName
    ORDER BY TotalRegistrationFees DESC
      --value-returning
    RETURN
  END;
GO

EXEC GetDeptRegistrationFees 
  @TopN = 10, 
  @CR_level = 300, 
  @S_City = 'Seattle', 
  @Begin_Reg_Date = '2015-01-01', 
  @End_Reg_Date = '2022-12-31';
GO


/*
Question 3: Write the SQL to create a stored procedure to INSERT a new row
into tblCLASS that calls four nested stored procedures (one for each FK).
You will need to write the SQL code to create the nested stored procedures as well.
Include an explicit transaction as well as error-handling if any variable ends-up
NULL (use either RAISERROR or THROW).
HINT: Use @C_Name to obtain CourseID, 
          @Q_Name to obtain QuarterID, 
          @C_RoomName to obtain ClassroomID, and
          @ScheduleName to retrieve ScheduleID. 
There will be 2 additional parameters that pass values straight through to the INSERT statement: @Year and @Section.
After you code the procecure perform the following:
a) Compile the procedure
b) Test the procedure to ensure that it is working correctly
USE the following arguments to test the procedure:
@C_Name: INFO432
@Q_Name: Spring
@C_RoomName: SAV399
@ScheduleName: MonWed5
@Year: 2024
@Section: T
To check that the value was inserted, run the following query:
SELECT * FROM tblCLASS WHERE [YEAR] = 2024
c) Clean-up: DO NOT delete the test row you inserted.
You will need it for questions 4 and 5.
*/

-- First stored procedure: Retrieve CourseID 
CREATE OR ALTER PROCEDURE spGetorCreateCourseID
    @C_Name VARCHAR(75),
    @CourseID INT OUTPUT
AS
BEGIN
    IF @C_Name IS NULL
        THROW 51000, 'The course name cannot be null.', 1;

    SELECT @CourseID = CourseID FROM tblCOURSE WHERE CourseName = @C_Name;

    IF @CourseID IS NULL
    BEGIN
        INSERT INTO tblCOURSE (CourseName) VALUES (@C_Name);
        SELECT @CourseID = SCOPE_IDENTITY();
    END
END;
GO

-- Stored procedure: Retrieve QuarterID 
CREATE OR ALTER PROCEDURE spGetorCreateQuarterID
    @Q_Name VARCHAR(30),
    @QuarterID INT OUTPUT
AS
BEGIN
    IF @Q_Name IS NULL
        THROW 51000, 'The quarter name cannot be null.', 1;

    SELECT @QuarterID = QuarterID FROM tblQUARTER WHERE QuarterName = @Q_Name;

    IF @QuarterID IS NULL
    BEGIN
        INSERT INTO tblQUARTER (QuarterName) VALUES (@Q_Name);
        SELECT @QuarterID = SCOPE_IDENTITY();
    END       
END;
GO

-- Stored procedure: Retrieve ClassroomID 
CREATE OR ALTER PROCEDURE spGetorCreateClassroomID
    @C_RoomName VARCHAR(30),
    @ClassroomID INT OUTPUT
AS
BEGIN
    IF @C_RoomName IS NULL
        THROW 51000, 'The classroom name cannot be null.', 1;

    SELECT @ClassroomID = ClassroomID FROM tblCLASSROOM WHERE CLassroomName = @C_RoomName;

    IF @ClassroomID IS NULL
    BEGIN
        INSERT INTO tblCLASSROOM (ClassroomName) 
        VALUES (@C_RoomName);
        SELECT @ClassroomID = SCOPE_IDENTITY();
    END         
END;
GO

-- Stored procedure: Retrieve ScheduleID 
CREATE OR ALTER PROCEDURE spGetorCreateScheduleID
    @ScheduleName VARCHAR(75),
    @ScheduleID INT OUTPUT
AS
BEGIN
    IF @ScheduleName IS NULL
        THROW 51000, 'The schedule name cannot be null.', 1;

        SELECT @ScheduleID = ScheduleID FROM tblSCHEDULE WHERE ScheduleName = @ScheduleName;

        IF @ScheduleID IS NULL
        BEGIN 
            INSERT INTO tblSCHEDULE (ScheduleName)
            VALUES (@ScheduleName);
            SELECT @ScheduleID = SCOPE_IDENTITY()
        END
END;
GO

-- Now the main stored procedure that inserts into tblCLASS.
CREATE OR ALTER PROCEDURE spInsertClass
    -- parameters
    @C_Name VARCHAR(75),
    @Q_Name VARCHAR(30),
    @C_RoomName VARCHAR(30),
    @ScheduleName VARCHAR(75),
    @Year INT,
    @Section VARCHAR(4)
AS
BEGIN
    DECLARE @CourseID INT, @QuarterID INT, @ClassroomID INT, @ScheduleID INT;

        -- Obtain foreign key values by calling nested stored procedures
        EXEC spGetorCreateCourseID @C_Name, @CourseID OUTPUT;
        EXEC spGetorCreateQuarterID @Q_Name, @QuarterID OUTPUT;
        EXEC spGetorCreateClassroomID @C_RoomName, @ClassroomID OUTPUT;
        EXEC spGetorCreateScheduleID @ScheduleName, @ScheduleID OUTPUT;

        -- Check for NULL values after nested procedures
        IF @CourseID IS NULL OR @QuarterID IS NULL OR @ClassroomID IS NULL OR @ScheduleID IS NULL
            THROW 51000, 'A foreign key value is NULL.', 1;

        -- Insert the new class with obtained FK values
        INSERT INTO tblCLASS (CourseID, QuarterID, YEAR, ClassroomID, ScheduleID, Section) 
        VALUES (@CourseID, @QuarterID, @Year, @ClassroomID, @ScheduleID, @Section);

END; 
GO

EXEC spInsertClass
    @C_Name = 'INFO432',
    @Q_Name = 'Spring',
    @C_RoomName = 'SAV399',
    @ScheduleName = 'MonWed5',
    @Year = 2024,
    @Section = 'T'
GO

SELECT * FROM tblCLASS WHERE [YEAR] = 2024

GO
/*====================================================================
Qquestion 4: Write the SQL to create a stored procedure to UPDATE the
Section for a given class. This procedure should use parameters to lookup classID.
You will need to define @C_ID variable that is going to hold the classID of the row
to upate.
Use RAISERROR method of error-handling if variable is NULL.
Include an explicit transaction as well as error-handling if any variable ends-up
NULL (use either RAISERROR or THROW).
HINT: To lookup ClassID, use @C_Name to obtain CourseID, @Q_Name to obtain
QuarterID, @C_RoomName to obtain ClassroomID, and
@ScheduleName to retrieve ScheduleID. There will be 2 additional parameters that
pass values straight through
to the lookup query: @Year and @Section.
After you code the procecure perform the following:
a) Compile the procedure
b) Test the procedure to ensure that it is working correctly
Use the row of data you inserted into tblCLASS in Q3 above.
In other words, use the following arguments to test the procedure:
@C_Name: INFO432
@Q_Name: Spring
@C_RoomName: SAV399
@ScheduleName: MonWed5
@Year: 2024
@Section: T
The arguments above are just for looking up the value to store in @C_ID.
In the actual update statement, SET Section to 'A'.
Check that everything worked fine by running the following query:
SELECT * FROM tblCLASS WHERE [YEAR] = 2024
=======================================================================*/

CREATE OR ALTER PROCEDURE spUpdateSection 
	--parameters
	@C_Name VARCHAR(75),
    @Q_Name VARCHAR(30),
    @C_RoomName VARCHAR(30),
    @ScheduleName VARCHAR(75),
    @Year INT,
    @NewSection VARCHAR(4)
	AS
	BEGIN
		DECLARE @CourseID INT, @QuarterID INT, @ClassroomID INT, @ScheduleID INT, @C_ID INT;

        -- Retrieve the CourseID, QuarterID, ClassroomID, and ScheduleID based on the given names
        SELECT @CourseID = CourseID FROM tblCOURSE WHERE CourseName = @C_Name;
        SELECT @QuarterID = QuarterID FROM tblQUARTER WHERE QuarterName = @Q_Name;
        SELECT @ClassroomID = ClassroomID FROM tblCLASSROOM WHERE ClassroomName = @C_RoomName;
        SELECT @ScheduleID = ScheduleID FROM tblSCHEDULE WHERE ScheduleName = @ScheduleName;

        -- Check for NULL values after nested procedures
        IF @CourseID IS NULL OR @QuarterID IS NULL OR @ClassroomID IS NULL OR @ScheduleID IS NULL
            RAISERROR('One of the lookup values is NULL.', 16, 1);

        -- Look up the ClassID using the obtained FK values
        SELECT @C_ID = ClassID
        FROM tblCLASS
        WHERE CourseID = @CourseID AND QuarterID = @QuarterID AND ClassroomID = @ClassroomID
            AND ScheduleID = @ScheduleID AND YEAR = @Year;

        IF @C_ID IS NULL
            RAISERROR('No class found with the specified criteria.', 16, 1);

        -- Update the Section for the found ClassID
        UPDATE tblCLASS
        SET Section = @NewSection
        WHERE ClassID = @C_ID
    END;
    GO



EXEC spUpdateSection
    @C_Name = 'INFO432',
    @Q_Name = 'Spring',
    @C_RoomName = 'SAV399',
    @ScheduleName = 'MonWed5',
    @Year = 2024,
    @NewSection = 'A'
GO

/*============================================================================
Question 5: Write the SQL to create a stored procedure to DELETE a row in the CLASS
table.
Sometimes classes are canceled if there isn't enough enrollment.
Like you did in question 4, this procedure should use parameters to lookup classID.
You will need to define @C_ID variable that is going to hold the classID of the row
to DELETE.
Use RAISERROR method of error-handling if variable is NULL.
Include an explicit transaction as well as error-handling if any variable ends-up
NULL (use either RAISERROR or THROW).
HINT: To lookup ClassID, use @C_Name to obtain CourseID, @Q_Name to obtain
QuarterID, @C_RoomName to obtain ClassroomID, and
@ScheduleName to retrieve ScheduleID. There will be 2 additional parameters that
pass values straight through
to the lookup query: @Year and @Section.
After you code the procecure perform the following:
a) Compile the procedure
b) Test the procedure to ensure that it is working correctly
Use the row of data you inserted into tblCLASS in Q3 above.
In other words, use the following arguments to test the procedure:
@C_Name: INFO432
@Q_Name: Spring
@C_RoomName: SAV399
@ScheduleName: MonWed5
@Year: 2024
@Section: T
Check that everything worked fine by running the following query (The result should
be null):
SELECT * FROM tblCLASS WHERE [YEAR] = 2024
=============================================================================*/
CREATE OR ALTER PROCEDURE spDeleteClass 
	--parameters
	@C_Name VARCHAR(75),
    @Q_Name VARCHAR(30),
    @C_RoomName VARCHAR(30),
    @ScheduleName VARCHAR(75),
    @Year INT,
    @Section VARCHAR(4)
	AS
	BEGIN
		DECLARE @CourseID INT, @QuarterID INT, @ClassroomID INT, @ScheduleID INT, @C_ID INT;

        -- Retrieve the CourseID, QuarterID, ClassroomID, and ScheduleID based on the given names
        SELECT @CourseID = CourseID FROM tblCOURSE WHERE CourseName = @C_Name;
        SELECT @QuarterID = QuarterID FROM tblQUARTER WHERE QuarterName = @Q_Name;
        SELECT @ClassroomID = ClassroomID FROM tblCLASSROOM WHERE ClassroomName = @C_RoomName;
        SELECT @ScheduleID = ScheduleID FROM tblSCHEDULE WHERE ScheduleName = @ScheduleName;

        -- Check for NULL values after nested procedures
        IF @CourseID IS NULL OR @QuarterID IS NULL OR @ClassroomID IS NULL OR @ScheduleID IS NULL
            RAISERROR('One of the lookup values is NULL.', 16, 1);

        -- Look up the ClassID using the obtained FK values
        SELECT @C_ID = ClassID
        FROM tblCLASS
        WHERE CourseID = @CourseID AND QuarterID = @QuarterID AND ClassroomID = @ClassroomID
            AND ScheduleID = @ScheduleID AND YEAR = @Year;

        IF @C_ID IS NULL
            RAISERROR('No class found with the specified criteria.', 16, 1);

        -- Update the Section for the found ClassID
        DELETE tblCLASS
        WHERE ClassID = @C_ID
    END;
    GO


EXEC spDeleteClass
    @C_Name = 'INFO432',
    @Q_Name = 'Spring',
    @C_RoomName = 'SAV399',
    @ScheduleName = 'MonWed5',
    @Year = 2024,
    @Section = 'A'
GO