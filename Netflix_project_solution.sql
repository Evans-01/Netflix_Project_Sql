-- Project Netflix

DROP TABLE IF EXISTS netflix;
create table netflix(
	show_id	varchar(10),
	type varchar(10),
	title varchar(105),
	director varchar(208),
	casts varchar(800),
	country varchar(130),
	date_added varchar(50),
	release_year int,
	rating varchar(10),
	duration varchar(10),
	listed_in varchar(100),
	description varchar(250)
);


SELECT * FROM netflix;

SELECT count(*) No_Of_Records FROM netflix;

SELECT DISTINCT type Different_Types FROM netflix;

-- Business Problems & Solutions

-- 1. Count the number of Movies vs TV Shows

select type as Number_of_Types,
	count(type) no from netflix
group by type; 

-- 2. Find the most common rating for movies and TV shows

select type, 
	rating from
(
	select type,
	rating, 
	count(*), 
	rank() over(partition by type order by count(*) desc) Ranking  from netflix
	group by 1,2
)
where ranking = 1;

-- 3. List all movies released in a specific year (e.g., 2021)

select * from netflix
where release_year=2021 and type='Movie';

-- 4. Find the top 5 countries with the most content on Netflix

select new_country from
(
	select unnest(string_to_array(country, ',')) new_country, 
		count(*), 
		rank() over(order by count(*) desc) Top from netflix
	group by 1
) as Top
where Top < 6;

-- 5. Identify the longest movie

select max(new_duration) from
(
	select regexp_substr(duration, '[0-9]+')::int new_duration from netflix
	where type = 'Movie'
) as x;

-- 6. Find content added in the last 5 years

select *,
	to_date(date_added,'Month DD,YYYY') from netflix
	where to_date(date_added,'Month DD,YYYY') >= (
												select max(
												to_date(date_added,'Month DD,YYYY') - interval '5 years')
												from netflix
	);

-- 7. Find all the movies/TV shows by director 'James Mangold'!

select type,title,director,release_year from netflix
where director like '%James Mangold%';

-- 8. List all TV shows with more than 5 seasons

select title,release_year, duration from
(
	select title,
		release_year,duration,split_part(duration, ' ',1)::int seasons from netflix
		where type = 'TV Show'
)
where seasons >=5
order by release_year;

-- 9. Count the number of content items in each genre

select unnest(string_to_array(listed_in, ',')) genre, count(*) from netflix
group by genre
order by Count(*) desc;

-- 10.Find each year and the average numbers of content release in India on netflix. 
-- return top 5 year with highest avg content release!

select extract(Year from to_date(date_added,'Month DD,YYYY'))as years,
	count(*),
	round(count(*)::numeric/(select count(*) from netflix where country like '%India%')::numeric * 100,2) as Avg_content
from netflix
where country like '%India%'
group by 1;

-- 11. List all movies that are documentaries

select show_id, title,director, listed_in from netflix
where type = 'Movie' and listed_in ilike '%Documentaries%';

-- 12. Find all content without a director

select distinct director, count(*) from netflix
group by director
having director isnull;

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

select extract(year from to_date(date_added, 'Month DD,YYYY')) as years, count(*) from netflix
where casts like '%Salman Khan%' and to_date(date_added, 'Month DD,YYYY') >= current_date - interval '10 years'
group by years;

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

select unnest(string_to_array(casts,',')) actors,count(*) num from netflix
where country ilike '%india%'
group by 1
order by num desc
limit 10;

-- 15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
-- the description field. Label content containing these keywords as 'Bad' and all other 
-- content as 'Good'. Count how many items fall into each category.

select case when
		description ilike '%kill%' or description ilike '%violence%' then 'Bad_Filim'
		else 'Good_Filim'
	end content_type, count(*) from netflix
group by 1







