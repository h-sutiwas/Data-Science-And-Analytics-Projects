select * from artist;
select * from canvas_size;
select * from image_link;
select * from museum;
select * from museum_hours;
select * from product_size;
select * from subject;
select * from work;


-- Problem Number 10

SELECT 
	m.name museum_name,
	m.city
FROM museum_hours mh1
JOIN museum m 
ON m.museum_id=mh1.museum_id
WHERE day = 'Sunday'
AND EXISTS (
	SELECT 
		1 
	FROM museum_hours mh2
	WHERE mh2.museum_id = mh1.museum_id 
	AND mh2.day = 'Monday');