-- Im using SQL in vs code, so u need to setup SQL in vs code to run this file
select distinct(type), count(type) as number from netflix
group by type;

select type, title, release_year from netflix
where release_year=2021 and country = "United States"
group by type,title, release_year;

-- 1.	Find movies released in 2021:
select  * from netflix
where type = "movie" and release_year = "2021";

-- 2.	List all unique content ratings:
select distinct(rating) from netflix;

-- 3.	Find the top 5 countries with the most content:
select country, count(show_id) as no_of_entries from netflix
group by country
order by no_of_entries desc limit 5;

-- 4.	Calculate the avg duration of movies:
select distinct type, round(avg (duration),2) as duration_movie from netflix
group by type;

-- 6.	Find shows or movies added in the last month:
-- Identify entries where the "date_added" is within the last 30 days.

-- 5.	List all directors with more than 5 show/movies.
select director,count(show_id) as entries from netflix
group by director
having count(*) > 5;

-- 6.	Retrieve the oldest content added:
select * from netflix
order by release_year asc
limit 1;

-- 7. latest content added:
select * from netflix
order by release_year desc
limit 1;

-- More Complex SQL Problems:
-- 1. Group the data by release_year and calculate the total number of movies & TV shows released each year. Identify the year with the highest total content release.
select type, release_year , count(show_id) as content_release
from netflix
group by type ,release_year
order by content_release desc;

-- 2.	Director with Diverse Genres:
-- Identify directors who have worked across more than 3 different genres.
select director,listed_in, count(listed_in) as genres from netflix
group by director,listed_in
having count(listed_in) >=3 order by genres desc;

-- 3.	Longest and Shortest Movies:
-- longest movie
select title, country, max(duration) as longest_movie 
from netflix where type = "movie"
group by title, country
order by longest_movie desc limit 1;
 -- shortest_movie
select title, country, min(duration) as shortest_movie
from netflix where type = "movie"
group by title, country
order by shortest_movie LIMIT 1;

--                 changing type of date col text to date.
ALTER TABLE netflix ADD COLUMN date_added_clean DATE;
UPDATE netflix
SET date_added_clean = STR_TO_DATE(date_added, '%m/%d/%Y');
ALTER TABLE netflix DROP COLUMN date_added;
ALTER TABLE netflix CHANGE date_added_clean date_added DATE;

-- 4.	Content Added Over Time:
-- Create cumulative count of content added over time, grouped by month & year
select
 extract(year from date_added) as year,
 extract(month from date_added) as month,
 count(*) as content_added,
 SUM(COUNT(*)) OVER (ORDER BY EXTRACT(YEAR FROM date_added), EXTRACT(MONTH FROM date_added)) AS cumulative_count
from netflix
group by extract(year from date_added), extract(month from date_added)
order by year, month;

-- 5.	Multi-Country Content:
select * from netflix where country in ("canada","united states");
 
-- 6.	Content by Region & Rating:
-- show how many "TV-MA" or "PG-13" entries are available per country.
select country, rating, count(show_id) as rate_count
from netflix
where rating in ("TV-MA","TV-14")
group by country, rating
order by rate_count desc;

-- 7.	Average Release Gap Between Movies by Director:
-- Calculate the average gap (in years) between movies released by the same director
select director, avg(release_year) as avg_gap
from netflix
where type = "movie"
group by director;

-- 8.	TV Shows with Multiple Seasons:
select type, director, country, count(show_id) as tv_show from netflix
where type = "TV Show" and duration > ("1 season")
group by type, director, country order by tv_show desc;

-- 9.	Top 10 Most Frequent Directors:
select director, count(*) as frequent_director from netflix
group by director order by frequent_director desc limit 10;

-- 10. Content Rating Impact on Duration: 
SELECT rating, ROUND(AVG(duration), 2) AS duration_of_movie FROM netflix
where type = "movie" AND rating IN ("TV-MA", "PG-13")
group BY rating order BY duration_of_movie;


-- 11.	Content with Missing Information:
SELECT * FROM netflix
WHERE director = 'Not Given' OR country = 'Not Given' OR date_added IS NULL;

-- 12.	Country with the Oldest and Newest avg Releases:
-- oldest year
select country, avg(release_year) as oldest_year from netflix
group by country order by oldest_year limit 1;
-- newest year
select country, avg(release_year) as latest_year from netflix
group by country order by latest_year desc limit 1;
-- 2nd method of 12.
SELECT 
  (SELECT country FROM netflix GROUP BY country ORDER BY AVG(release_year) ASC LIMIT 1) AS oldest_country,
  (SELECT AVG(release_year) FROM netflix GROUP BY country ORDER BY AVG(release_year) ASC LIMIT 1) AS oldest_year,
  (SELECT country FROM netflix GROUP BY country ORDER BY AVG(release_year) DESC LIMIT 1) AS latest_country,
  (SELECT AVG(release_year) FROM netflix GROUP BY country ORDER BY AVG(release_year) DESC LIMIT 1) AS latest_year;
