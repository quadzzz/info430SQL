/* 
    1. Write a SQL query to return the top 3 longest trips in hours from each starting station. 
    Your query should list starting station name, rent_id, trip duration (in hours), and rank. Note: trip duration is recorded in seconds, 
    so you need to convert that to hours in your query, rounded to 2 decimal places. 
    Also, station names are recorded with the original station IDs are starting characters in the name (e.g., 0230 Alexander & Railway). 
    Your query should return the station name with the leading numbers stripped (e.g., Alexander & Railway). 
    Hint: use string functions to strip leading numbers from the station name. 
    The sample output below shows how your query results should be formatted (note: this is not the complete set of rows in the result). 
*/

SELECT * FROM tblBikeRentals
GO 
WITH StationSubstring AS ( 
    SELECT 
        B.rent_id, 
        S.station_id, 
        SUBSTRING(S.station_name, 6, LEN(S.station_name) - 5) AS Station_Name, 
        B.duration
    FROM tblBikeRentals B 
    JOIN tblStation S ON B.depart_station_id = S.station_id
), 
Trips_R AS ( 
    SELECT 
        rent_id, 
        Station_Name, 
        ROUND(duration / 3600.0, 2) AS Duration, 
        RANK() OVER (PARTITION BY Station_Name ORDER BY duration DESC) AS [Rank]
    FROM StationSubstring
)
SELECT 
    Station_Name, 
    rent_id, 
    CAST(ROUND(Duration, 2) AS numeric(10, 2)) AS Duration,
    Rank
FROM Trips_R
WHERE Rank <= 3
ORDER BY Station_Name, Rank, Duration DESC;



/*
    Write a SQL query to return the day of the month and the change of the number of rides from the previous day where the following conditions are met:
    • The bike renter returned the bike to the same station where they rented the bike.
    • The change in the number of rides from the previous day is greater than 0.
    
    The excerpt below shows sample output (note: there should be 15 rows in the output).
*/
WITH daily_rides AS (
    SELECT
        CONVERT(date, depart_time) AS ride_date,
        COUNT(*) AS num_rides
    FROM tblBikeRentals
    WHERE depart_station_id = return_station_id
    GROUP BY CONVERT(date, depart_time)
),
ride_changes AS (
    SELECT
        ride_date,
        DAY(ride_date) AS day_of_month,
        num_rides,
        LAG(num_rides) OVER (ORDER BY ride_date) AS prev_day_rides
    FROM daily_rides
)
SELECT
    day_of_month,
    (num_rides - prev_day_rides) AS change_in_num_rides
FROM ride_changes
WHERE (num_rides - prev_day_rides) > 0
ORDER BY ride_date;



/*
    3.
    Write a query to return for each membership type, the top 2 departing stations (ranked by number of rentals), 
    a count of the number of rentals, bike type used, and rank. Please use dense rank approach to compute the rankings. 
    As in question 1, your query output should display station nation with leading numbers stripped. 
    Sample output is shown below (note: not a complete set of rows in the result). (Hint: You may also need to use ROW_NUMBER() 
    Window function to ensure that the results are presented with desired rank ordering. 
    To obtain the desired output, you will need to sort the final result in ascending order of membership type and row number). 
    Sample output is shown below (note: does not include all the rows in the result).
*/
WITH StationCounts AS (
    SELECT
        m.membership_type,
        s.station_name AS depart_station,
        COUNT(*) AS num_rides,
        bt.bike_type,
        DENSE_RANK() OVER (PARTITION BY m.membership_type ORDER BY COUNT(*) DESC) AS rank
    FROM tblBikeRentals br
    JOIN tblMembershipType m ON br.membership_type_id = m.membership_type_id
    JOIN tblStation s ON br.depart_station_id = s.station_id
    JOIN tblBikeType bt ON br.bike_id = bt.bike_type_id
    GROUP BY m.membership_type, s.station_name, bt.bike_type
),
TopStations AS (
    SELECT *
    FROM StationCounts
    WHERE rank <= 2
)
SELECT
    membership_type,
    depart_station,
    num_rides,
    bike_type,
    rank
FROM TopStations
ORDER BY membership_type, rank, depart_station;


/*
    4.
    Write a query to return the following columns: station name, date, and difference in the number of 
    rentals (i.e., [number of rentals where station served a return station] – 
    [number of rentals where the station served as a depart station]) where the following conditions are met:
    Limit output to dates where the difference in the number of rentals is the highest for each station and the difference is at least 25.
    This query helps to determine dates when a given station served more as a return station than as a departing station. 
    Hint: You need to Date functions and string functions to present the output in the desired format.
*/
WITH RentalCounts AS (
    SELECT
        SUBSTRING(S.station_name, 6, LEN(S.station_name) - 5) AS Station_Name,
        CONVERT(date, br.depart_time) AS ride_date,
        SUM(CASE WHEN br.depart_station_id = s.station_id THEN 1 ELSE 0 END) AS depart_count,
        SUM(CASE WHEN br.return_station_id = s.station_id THEN 1 ELSE 0 END) AS return_count
    FROM tblBikeRentals br
    JOIN tblStation s ON br.depart_station_id = s.station_id OR br.return_station_id = s.station_id
    GROUP BY s.station_name, CONVERT(date, br.depart_time)
),
Difference AS (
    SELECT
        Station_Name,
        ride_date,
        (return_count - depart_count) AS diff_count,
        ROW_NUMBER() OVER (PARTITION BY station_name ORDER BY (return_count - depart_count) DESC) AS rn
    FROM RentalCounts
    WHERE (return_count - depart_count) >= 25
)
SELECT
    Station_Name,
    FORMAT(ride_date, 'dddd, MMMM dd') AS [Date],
    diff_count AS [Number of rentals diff]
FROM Difference
WHERE rn = 1
ORDER BY Station_Name, ride_date;

