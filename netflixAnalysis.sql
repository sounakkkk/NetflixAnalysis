CREATE TABLE netflix
(
	show_id	VARCHAR(5),
	type    VARCHAR(10),
	title	VARCHAR(250),
	director VARCHAR(550),
	casts	VARCHAR(1050),
	country	VARCHAR(550),
	date_added	VARCHAR(55),
	release_year	INT,
	rating	VARCHAR(15),
	duration	VARCHAR(15),
	listed_in	VARCHAR(250),
	description VARCHAR(550)
);

-- 1. Count the number of Movies vs TV Shows

select
type,count(show_id) as No_ofMoviesnSeries
from netflix
group by type;

-- 2. Find the most common rating for movies and TV shows

select 
type,rating,count,ranking
from
(select 
type,rating,count(*),
rank() over(partition by type order by count(*) desc) as ranking
from netflix
group by 1,2) as t1
where ranking=1;

-- 3. List all movies released in a specific year (e.g., 2020)

select 
type,title,date_added,release_year
from netflix
where  type='Movie' and  
release_year=2020;

-- 4. Find the top 5 countries with the most content on Netflix


select 
	
	unnest(string_to_array(country,',')) as country,
	count(*) as total_content
from netflix
group by 1
order by total_content desc;

-- 5. Identify the longest movie

select 
duration ,title
from netflix
where type='Movie' and duration=(select max(duration) from netflix)
;

-- 6. Find content added in the last 5 years



select title,
to_date(date_added,'Month DD,YYYY') as date
from netflix
where
	to_date(date_added,'Month DD,YYYY')>=current_date - interval '5 years'
	order by date desc;


-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!


select 
title,director
from netflix
where director ilike '%Rajiv Chilaka%';

-- 8. List all TV shows with more than 5 seasons

select type,title,
cast(split_part(duration,' ',1)as integer) as no_of_seasons
from netflix
where type='TV Show'
and cast(split_part(duration,' ',1)as integer)>5
order by no_of_seasons asc

-- 9. Count the number of content items in each genre


select 
unnest(string_to_array(listed_in,',')) as genre,
count(*)
from netflix
group by 1
order by 2 desc;


-- 10. Find each year and the average numbers of content release by India on netflix. 
-- return top 5 year with highest avg content release !

select 
	extract (year from to_date(date_added ,'Month DD,YYYY')) as release_date,
	country,count(*) as content_count,
	sum(count(*)) over(partition by country) as total_content,
	round(cast(count(*) as numeric)/sum(count(*)) over(partition by country)*100) as avg_content
	from netflix
	where country ilike 'india'
	group by 1,2
	order by content_count desc
limit 5;

-- 11. List all movies that are documentaries

select type ,
listed_in,title
from netflix
where type='Movie'
and listed_in ilike '%documentaries%'
;

-- 12. Find all content without a director

select type,title,director 
from netflix
where director is null;

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!


select type ,
title,casts,release_year
from netflix
where casts ilike '%salman khan%'
and type='Movie'
and release_year>= extract(year from current_date)-10


-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

select * from netflix;

select 
unnest(string_to_array(casts,',')) as actor_name,count(*) 
from netflix 
where type='Movie'
and country='India'
group by 1
order by 2 desc
limit 10;

/*
Question 15:
Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.
*/

select * from netflix;

select 
case
	when description ilike '%kill%' or
			description ilike '%violent%' then 'bad'
	else 'good'
	end as category,
	count(*)
from netflix
group by 1






