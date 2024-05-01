USE MovieDB 

-- NAME : GABRIELLA RIVERA

-- Using the preceding database, write the SQL queries to answer the following questions:

-- What is the shortest movie?
-- What is the movie with the most number of votes?
-- Which movie made the most net profit?
-- Which movie lost the most money?
-- How many movies were made in the 80’s?
-- What is the most popular movie released in the year 1980?
-- How long was the longest movie made before 1900?
-- Which language has the shortest movie?
-- Which collection has the highest total popularity?
-- Which language has the most movies in production or post-production?
-- What was the most expensive movie that ended up getting canceled?
-- How many collections have movies that are in production for the language French (FR)
-- List the top ten rated movies that have received more than 5000 votes
-- Which collection has the most movies associated with it?
-- What is the collection with the longest total duration?
-- Which collection has made the most net profit?
-- List the top 100 movies by their duration from longest to shortest
-- Which languages have more than 25,000 movies associated with them?
-- Which collections had all their movies made in the 80’s?
-- In the language that has the most number of movies in the database, how many movies start with “The”? (You may not hard-code a language)


-- What is the shortest movie?
SELECT TOP 1 movieTitle, movieRuntime 
FROM tblMovie
WHERE movieRuntime = (SELECT MIN(movieRuntime) FROM tblMovie);
-- this query returns multiple movies with a "shortest" runtime of 1 minute


-- What is the movie with the most number of votes?
SELECT movieTitle AS Most_Number_of_Votes
FROM tblMovie
WHERE movieVoteCount = (SELECT MAX(movieVoteCount) FROM tblMovie);


-- Which movie made the most net profit?
SELECT movieTitle AS Highest_Revenue
FROM tblMovie
WHERE movieRevenue = (SELECT MAX(movieRevenue) FROM tblMovie);


-- Which movie lost the most money?
SELECT TOP 1 movieTitle, (movieBudget - movieRevenue) AS Loss
FROM tblMovie
ORDER BY Loss DESC;


-- How many movies were made in the 80’s?
SELECT COUNT(*) AS NumberofMovies
FROM tblMovie
WHERE movieReleaseDate BETWEEN '1980-01-01' AND '1989-12-31';


-- What is the most popular movie released in the year 1980?
SELECT TOP 1 movieTitle AS Most_Popular_80s
FROM tblMovie
WHERE movieReleaseDate BETWEEN '1980-01-01' AND '1980-12-31'
ORDER BY moviePopularity DESC;


-- How long was the longest movie made before 1900?

-- SELECT TOP 1 movieTitle AS Longest_B4_1900
-- FROM tblMovie
-- WHERE movieReleaseDate < '1900-01-01'
-- ORDER BY movieRuntime;


-- -- Which language has the shortest movie?
-- SELECT TOP 1 movieRuntime, languageName
-- FROM tblMovie m 
--     JOIN tblMovieLanguage ml ON m.movieID = ml.movieID
--     JOIN tblLanguage l ON ml.languageID = l.languageID
-- ORDER BY movieRuntime ASC;


-- the above code does produce one answer, but does not account for multiple movies with the same shortest runtime in different languages
WITH LanguageRuntime AS (
    SELECT
        l.languageName,
        MIN(m.movieRuntime) AS ShortestMovieRuntime
    FROM tblMovie m
    JOIN tblMovieLanguage ml ON m.movieID = ml.movieID
    JOIN tblLanguage l ON ml.languageID = l.languageID
    GROUP BY l.languageName
)
SELECT languageName
FROM LanguageRuntime
WHERE ShortestMovieRuntime = (SELECT MIN(ShortestMovieRuntime) FROM LanguageRuntime);




--Which collection has the highest total popularity?

-- solution 1
WITH MostPopularCollection AS (
    SELECT 
        c.collectionName,
        SUM(m.moviePopularity) AS SumPopular
    FROM tblMovie m
    JOIN tblCollection c on m.collectionID = c.collectionID
    GROUP BY c.collectionName
)
SELECT collectionName
FROM MostPopularCollection
WHERE SumPopular = (SELECT MAX(SumPopular) FROM MostPopularCollection);

-- solution 2
SELECT TOP 1 c.collectionName, SUM(m.moviePopularity) AS TotalPopularity
FROM tblMovie m
JOIN tblCollection c ON m.collectionID = c.collectionID
GROUP BY c.collectionName
ORDER BY TotalPopularity DESC;


-- Which language has the most movies in production or post-production?
SELECT TOP 1 l.languageName, COUNT(*) AS NumberOfMovies
FROM tblMovie m
JOIN tblMovieLanguage ml ON m.movieID = ml.movieID
JOIN tblLanguage l ON ml.languageID = l.languageID
JOIN tblStatus st ON m.statusID = st.statusID
WHERE st.statusName IN ('In Production', 'Post Production')
GROUP BY l.languageName
ORDER BY NumberOfMovies DESC;


-- What was the most expensive movie that ended up getting canceled?
SELECT TOP 1 m.movieTitle, s.statusName, MAX(m.movieBudget) as budget
FROM tblMovie m 
JOIN tblStatus s ON m.statusID = s.statusID
WHERE s.statusName = 'canceled' 
GROUP BY m.movieTitle, s.statusName
ORDER BY budget DESC


-- How many collections have movies that are in production for the language French (FR)
SELECT COUNT(DISTINCT m.collectionID) AS NumberOfCollections
FROM tblMovie m
JOIN tblMovieLanguage ml ON m.movieID = ml.movieID
JOIN tblLanguage l ON ml.languageID = l.languageID
JOIN tblStatus s ON m.statusID = s.statusID
WHERE l.languageName = 'Français' AND s.statusName = 'In Production'


-- List the top ten rated movies that have received more than 5000 votes
SELECT TOP 10 m.movieTitle, m.movieVoteCount
FROM tblMovie m 
WHERE m.movieVoteCount > 5000
ORDER BY m.movieVoteCount DESC;


-- Which collection has the most movies associated with it?
SELECT TOP 1 c.collectionName, COUNT(*) as MovieCount
FROM tblMovie m 
JOIN tblCollection c on m.collectionID = c.collectionID
GROUP BY c.collectionName
ORDER BY MovieCount DESC


-- What is the collection with the longest total duration?
SELECT TOP 1 collectionName, SUM(movieRuntime) AS TotalDuration
FROM tblMovie 
JOIN tblCollection on tblMovie.collectionID = tblCollection.collectionID
GROUP BY collectionName
ORDER BY TotalDuration DESC


-- Which collection has made the most net profit?
SELECT TOP 1 collectionName, ABS(SUM(movieBudget) - SUM(movieRevenue)) AS NetProfit
FROM tblMovie
JOIN tblCollection on tblMovie.collectionID = tblCollection.collectionID
GROUP BY collectionName
ORDER BY NetProfit DESC


-- List the top 100 movies by their duration from longest to shortest
SELECT TOP 100 movieTitle, movieRuntime AS movieDuration
FROM tblMovie
ORDER BY movieDuration DESC


-- Which languages have more than 25,000 movies associated with them?
SELECT l.languageName, COUNT(*) AS MovieCount
FROM tblMovie m
JOIN tblMovieLanguage ml ON m.movieID = ml.movieID
JOIN tblLanguage l ON ml.languageID = l.languageID
GROUP BY l.languageName
HAVING COUNT(*) > 25000


-- Which collections had all their movies made in the 80’s?
SELECT c.collectionName 
FROM tblMovie m 
JOIN tblCollection c on m.collectionID = c.collectionID
GROUP BY c.collectionName
HAVING MIN(YEAR(movieReleaseDate)) >= 1980 AND MAX(YEAR(movieReleaseDate)) <= 1989;



-- In the language that has the most number of movies in the database, how many movies start with “The”? (You may not hard-code a language)

-- Solution 1
WITH LanguageMovieCount AS (
    SELECT TOP 1 ml.languageID, l.languageName, COUNT(*) AS MovieCount
    FROM tblMovieLanguage ml
    JOIN tblLanguage l on ml.languageID = l.languageID
    GROUP BY ml.languageID, l.languageName
    ORDER BY MovieCount DESC
),
MostMoviesLanguage AS (
    SELECT languageID, languageName
    FROM LanguageMovieCount
),
MoviesStartWithThe AS (
    SELECT m.movieID, m.movieTitle, mml.languageName
    FROM tblMovie m
    JOIN MostMoviesLanguage mml ON m.languageID = mml.languageID
    WHERE m.movieTitle LIKE 'The %'
    GROUP BY m.movieID, m.movieTitle, mml.languageName
)

SELECT mst.languageName, COUNT(*) AS MoviesStartingWithThe
FROM MoviesStartWithThe mst
GROUP BY mst.languageName;

-- Solution 2
WITH LanguageMovieCount AS (
    SELECT TOP 1 ml.languageID, l.languageName, COUNT(*) AS MovieCount
    FROM tblMovieLanguage ml
    JOIN tblLanguage l on ml.languageID = l.languageID
    GROUP BY ml.languageID, l.languageName
    ORDER BY MovieCount DESC
),
MoviesStartWithThe AS (
    SELECT m.movieID, m.movieTitle, lmc.languageName
    FROM tblMovie m
    JOIN LanguageMovieCount lmc ON m.languageID = lmc.languageID
    WHERE m.movieTitle LIKE 'The %'
    GROUP BY m.movieID, m.movieTitle, lmc.languageName
)

SELECT mst.languageName, COUNT(*) AS MoviesStartingWithThe
FROM MoviesStartWithThe mst
GROUP BY mst.languageName



