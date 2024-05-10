-- NAME: Gabriella Rivera

/* USE Subquery for this Question */
--================================
/*
1) Which students with the special need of 'Anxiety' have completed
more than 13 credits of 300-level
Information School classes with a grade less than 3.1 in the last 3 years?
Your query should return student's last name and first name as
one column. Separate last name and first with a comma; e.g., Doe, John
*/
    -- "INFORMATICS" --> tblDEPARTMENT
    -- credits --> tblCOURSE
    -- course level --> tblCOURSE
    -- grades --> tblCLASS_LIST
SELECT
    StudentName
FROM (
    SELECT
        s.StudentID,
        CONCAT(s.StudentLname, ', ', s.StudentFname) AS StudentName,
        SUM(Credits) AS TotalCreds
    FROM
        tblSTUDENT s
        JOIN tblSTUDENT_SPECIAL_NEED ssn ON s.StudentID = ssn.StudentID
        JOIN tblSPECIAL_NEED sn ON ssn.SpecialNeedID = sn.SpecialNeedID
        JOIN tblCLASS_LIST cl ON s.StudentID = cl.StudentID
        JOIN tblCLASS c ON cl.ClassID = c.ClassID
        JOIN tblCOURSE cr ON c.CourseID = cr.CourseID
        JOIN tblDEPARTMENT d ON cr.DeptID = d.DeptID
    WHERE
        sn.SpecialNeedName = 'Anxiety'
        AND d.DeptName = 'Informatics'
        AND cr.CourseNumber BETWEEN 300 AND 399
        AND cl.Grade < 3.1
        AND DATEDIFF(YEAR, c.YEAR, GETDATE()) <= 3
    GROUP BY
        s.StudentFname, s.StudentLname, s.StudentID
) AS SubQuery
WHERE
    TotalCreds > 13;


/* USE CTEs for this Question */
--===============================
/*
2) Write the SQL to determine the top 10 states by number of students
who have completed both 15 credits of Arts and Science courses
as well as between 5 and 18 credits of Medicine since 2003.
Your result should list state name and number of students.
Sort the results in descending order of the number of students.
*/
    -- sum credits of Arts and Science courses
    -- sum credits of Medicine since 2003 DATEDIFF(YEAR, c.YEAR, GETDATE()) <= 11
    -- count number of students
WITH AS_Students AS (
    SELECT 
        s.StudentID,
        s.StudentPermState,
        SUM(cr.Credits) AS Sum_AS_Credits
    FROM
        tblSTUDENT s
        JOIN tblCLASS_LIST cl ON s.StudentID = cl.StudentID
        JOIN tblCLASS c ON cl.ClassID = c.ClassID
        JOIN tblCOURSE cr ON c.CourseID = cr.CourseID
        JOIN tblDEPARTMENT d ON cr.DeptID = d.DeptID
        JOIN tblCOLLEGE cg on d.CollegeID = cg.CollegeID
    WHERE
        cg.CollegeName = 'Arts and Sciences' 
    AND cl.RegistrationDate >= '2003-01-01'
    GROUP BY
        s.StudentID, 
        s.StudentPermState 
    HAVING
        SUM(cr.Credits) = 15 
),
MedStudents AS (
    SELECT
        s.StudentID,
        StudentPermState,
        SUM(cr.Credits) AS Sum_Med_Credits
    FROM
        tblSTUDENT s
        JOIN tblCLASS_LIST cl ON s.StudentID = cl.StudentID
        JOIN tblCLASS c ON cl.ClassID = c.ClassID
        JOIN tblCOURSE cr ON c.CourseID = cr.CourseID
        JOIN tblDEPARTMENT d ON cr.DeptID = d.DeptID
        JOIN tblCOLLEGE cg on d.CollegeID = cg.CollegeID
    WHERE
        cg.CollegeName = 'Arts and Sciences' 
    AND cl.RegistrationDate >= '2003-01-01'
    GROUP BY
        s.StudentID, 
        s.StudentPermState 
    HAVING
        SUM(cr.Credits) BETWEEN 5 AND 18
),
QualifiedStudents AS (
    SELECT
        a.StudentPermState,
        a.StudentID
    FROM
        AS_Students a
    JOIN
        MedStudents m ON a.StudentID = m.StudentID
)
SELECT TOP 10 
    StudentPermState,
    COUNT(StudentID) AS StudentCount
FROM
    QualifiedStudents
GROUP BY
    StudentPermState
ORDER BY
    StudentCount DESC


/* USE temp table for this Question */
--===================================
/*
3) Write the SQL to determine which location on campus has held the classes that
generated the most combined money in registration fees for
the colleges of 'Engineering', 'Nursing', 'Pharmacy', and 'Public Affairs (Evans School)'.
Your query should return location name.
*/

-- Drop the temp table if it already exists
IF OBJECT_ID('tempdb..#LocationFees') IS NOT NULL
    DROP TABLE #LocationFees;

-- Create the temporary table
CREATE TABLE #LocationFees (
    LocationName NVARCHAR(100),
    TotalFees MONEY
);

-- Populate the temp table with combined registration fees
INSERT INTO #LocationFees (LocationName, TotalFees)
SELECT
    l.LocationName,
    SUM(cl.RegistrationFee) AS TotalFees
FROM
    tblCLASS_LIST cl
    JOIN tblCLASS c ON cl.ClassID = c.ClassID
    JOIN tblCOURSE cr ON c.CourseID = cr.CourseID
    JOIN tblDEPARTMENT d ON cr.DeptID = d.DeptID
    JOIN tblCOLLEGE cg ON d.CollegeID = cg.CollegeID
    JOIN tblCLASSROOM crs ON c.ClassroomID = crs.ClassroomID
    JOIN tblBUILDING b ON crs.BuildingID = b.BuildingID
    JOIN tblLOCATION l ON b.LocationID = l.LocationID
WHERE
    cg.CollegeName IN ('Engineering', 'Nursing', 'Pharmacy', 'Public Affairs (Evans School)')
GROUP BY
    l.LocationName;

-- Retrieve the location with the highest combined registration fees
SELECT TOP 1
    LocationName
FROM
    #LocationFees
ORDER BY
    TotalFees DESC
 -- Returns the location with the most combined registration fees

-- Clean up by dropping the temp table
DROP TABLE #LocationFees;


/* USE either subquery, CTE, or temp table for this Question
You choose whichever approach you prefer.
*/--===========================================
/*
4) Write the SQL to determine the buildings that have held more than 10 classes
from the Mathematics department since 1997 that have also
held fewer than 20 classes from the Anthropology department since 2016.
You query should return building name. List the results in alphabetical order.
*/

WITH Math_Buildings AS (
    SELECT b.BuildingName,
        COUNT(c.ClassID) AS MathClasses
    FROM tblBUILDING b
    JOIN tblCLASSROOM cr on b.BuildingID = cr.BuildingID
    JOIN tblCLASS c on cr.ClassroomID = c.ClassroomID
    JOIN tblCOURSE cs on c.CourseID = cs.CourseID
    JOIN tblDEPARTMENT d on cs.DeptID = d.DeptID
    WHERE 
        d.DeptName = 'Mathematics'
    AND
        c.YEAR > '01-01-1997'
    GROUP BY b.BuildingName
    HAVING
        COUNT(c.ClassID) > 10
),
Anthropology_Buildings AS (
    SELECT b.BuildingName,
        COUNT(c.ClassID) AS AnthroClasses
    FROM tblBUILDING b
    JOIN tblCLASSROOM cr on b.BuildingID = cr.BuildingID
    JOIN tblCLASS c on cr.ClassroomID = c.ClassroomID
    JOIN tblCOURSE cs on c.CourseID = cs.CourseID
    JOIN tblDEPARTMENT d on cs.DeptID = d.DeptID
    WHERE d.DeptName = 'Anthropology'
    AND c.YEAR > '01-01-2016'
    GROUP BY b.BuildingName
    HAVING COUNT(c.ClassID) < 20    
), 
Buildings AS (
    SELECT
        mb.BuildingName          
    FROM
        Math_Buildings mb
    JOIN
        Anthropology_Buildings ab ON mb.BuildingName = ab.BuildingName
)
SELECT BuildingName 
FROM Buildings

go

/* USE either subquery, CTE, or temp table for this Question
You choose whichever approach you prefer.
*/--=============================================
/*
5) Write the SQL to determine which students have completed at least 15 credits of
classes each from the colleges of Medicine,
Information School, and Arts and Sciences since 2009 that also completed more than
3 classes held in buildings on Stevens Way
in classrooms of type 'large lecture hall'.
Your output should show student's last name and first name in separate columns.
*/
WITH Group_1 AS (
    SELECT 
        s.StudentID,
        s.StudentFname,
        s.StudentLname,
        SUM(cr.Credits) AS Sum_Credits
    FROM tblSTUDENT s
        JOIN tblCLASS_LIST cl ON s.StudentID = cl.StudentID
        JOIN tblCLASS c ON cl.ClassID = c.ClassID
        JOIN tblCOURSE cr ON c.CourseID = cr.CourseID
        JOIN tblDEPARTMENT d ON cr.DeptID = d.DeptID
        JOIN tblCOLLEGE cg on d.CollegeID = cg.CollegeID
    WHERE cg.CollegeName IN ('Medicine', 'Information School', 'Arts and Sciences')
    AND cl.RegistrationDate > '01-01-2009'
    GROUP BY 
        s.StudentID,
        s.StudentFname,
        s.StudentLname
    HAVING SUM(cr.Credits) >= 15
),
Group_2 AS (
    SELECT 
        s.StudentID,
        s.StudentFname,
        s.StudentLname,
        COUNT(c.ClassID) as NumClasses
    FROM tblSTUDENT s 
        JOIN tblCLASS_LIST cl ON s.StudentID = cl.StudentID
        JOIN tblCLASS c ON cl.ClassID = c.ClassID
        JOIN tblCLASSROOM cr ON c.ClassroomID = cr.ClassroomID
        JOIN tblCLASSROOM_TYPE ct on cr.ClassroomTypeID = ct.ClassroomTypeID
        JOIN tblBUILDING b ON cr.BuildingID = b.BuildingID
        JOIN tblLOCATION l on b.LocationID = l.LocationID
    WHERE l.LocationName = 'Stevens Way'
    AND ct.ClassroomTypeName = 'large lecture hall'
    GROUP BY 
        s.StudentID,
        s.StudentFname,
        s.StudentLname
    HAVING COUNT(c.ClassID) > 3
), 
CombinedGroups AS (
    SELECT
        g1.StudentFname,
        g1.StudentLname
    FROM
        Group_1 g1
    JOIN
        Group_2 g2 ON g1.StudentID = g2.StudentID
)
SELECT StudentFName, StudentLName
FROM CombinedGroups
    