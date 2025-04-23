#Project 2 of Class "Design and Use of Database Systems"

#1
#Movie names in which an actor with the last name Allen plays a part and the movie genre is comedy 

SELECT DISTINCT m.title 
FROM movie m, movie_has_genre mg, genre g, actor a, role r 
WHERE m.movie_id = mg.movie_id 
AND a.actor_id = r.actor_id 
AND m.movie_id = r.movie_id 
AND mg.genre_id = g.genre_id 
AND g.genre_name="Comedy" 
AND a.last_name = "Allen";

#2
#The last names of the directors and the titles of their movies, that have an actor with the last name Allen, provided
#that this director have made movies of at least two different genres

SELECT d.last_name, m.title 
FROM director d, movie m, movie m1, movie m2, movie_has_director md, movie_has_director md1, 
movie_has_director md2, movie_has_genre mg1, movie_has_genre mg2, role r, actor a, genre g 
WHERE md.director_id = d.director_id 
AND md1.director_id = d.director_id 
AND md2.director_id = d.director_id 
AND md.movie_id = m.movie_id 
AND md1.movie_id = m1.movie_id 
AND md2.movie_id = m2.movie_id 
AND mg1.movie_id = m1.movie_id 
AND mg2.movie_id = m2.movie_id 
AND r.movie_id = m.movie_id 
AND r.actor_id = a.actor_id 
AND a.last_name="Allen" 
AND mg1.genre_id <> mg2.genre_id
GROUP BY m.title, d.last_name 
ORDER BY d.last_name asc;

#3
#The last names of the actors that have been in a movie directed by a Director with the same last name as the actor, and have been
#in at least one other movie with a director with a different last name, and the movie is of the same genre as another movie in which the actor is not in,
#but was directed by the director with the same last name

SELECT DISTINCT a.last_name 
FROM actor a, director d, director d2, movie_has_director md, movie_has_director md2, 
movie_has_director md3, movie_has_genre mg2, movie_has_genre mg3, role r, role r2, role r3 
WHERE md.director_id = d.director_id 
AND r.actor_id = a.actor_id 
AND md.movie_id = r.movie_id 
AND a.last_name= d.last_name 
AND r2.actor_id = a.actor_id 
AND md2.movie_id = r2.movie_id 
AND md2.director_id = d2.director_id 
AND a.last_name <> d2.last_name 
AND mg2.movie_id = md2.movie_id 
AND mg3.movie_id = md3.movie_id 
AND md2.movie_id = md3.movie_id 
AND md3.director_id = d2.director_id 
AND r3.movie_id = md3.movie_id 
AND r3.actor_id <> a.actor_id;

#4
#Check if a movie exists that has the drama genre, was made in 1995. Return yes or no.
SELECT DISTINCT 'Yes' as answer 
WHERE EXISTS 
( SELECT 1 FROM movie_has_genre, movie m, genre g 
WHERE movie_has_genre.genre_id = g.genre_id 
AND movie_has_genre.movie_id = m.movie_id 
AND g.genre_name = 'Drama' AND m.year =1995)
UNION 
SELECT DISTINCT 'No' as answer 
WHERE NOT EXISTS ( SELECT 1 
FROM movie_has_genre, movie m, genre g 
WHERE movie_has_genre.genre_id = g.genre_id 
AND movie_has_genre.movie_id = m.movie_id 
AND g.genre_name = 'Drama' 
AND m.year =1995);


#5
#Find the last names of pairs of directors who have directed the same movie together between 2000 and 2006, provided the two directors
#are associated with at least 6 different movie genres. Confirm that each pair is only printed once.

select distinct d.last_name as director_1, d2.last_name as director_2 
from director d, director d2, movie_has_director md, movie_has_director md2, movie m, movie_has_genre mg 
where md.director_id = d.director_id and md2.director_id = d2.director_id 
and d2.director_id <> d.director_id and d.director_id < d2.director_id and md.movie_id = md2.movie_id and m.movie_id = mg.movie_id
and m.movie_id = md.movie_id and m.year >= 2000 and m.year <= 2006 and md.director_id in 
(select md6.director_id
from movie_has_director md6, movie_has_genre mg6
where md6.movie_id = mg6.movie_id
group by md6.director_id
having count(distinct mg6.genre_id) >= 6);

#6
#For each actor that has been in exactly 3 movies, find the name and last name of the actors as well as the number of different directors of their movies

SELECT  a.first_name as actor_name, a.last_name as actor_surname, count(DISTINCT md.director_id) as count FROM actor a, role r, movie_has_director md WHERE a.actor_id =r.actor_id AND r.movie_id = md.movie_id
GROUP BY a.actor_id
Having COUNT( DISTINCT r.movie_id) = 3;

#7
#For each movie that has exactly one genre, print that genre as well as the number of directors that have made a movie with that genre

SELECT DISTINCT mg.genre_id AS genre_id , count(DISTINCT md.director_id) AS count
FROM  movie_has_director md, movie_has_genre mg, movie_has_genre mg2
WHERE mg.movie_id = md.movie_id AND mg.genre_id= mg2.genre_id AND mg2.movie_id in
(SELECT mg.movie_id from movie_has_genre mg
GROUP BY mg.movie_id
HAVING COUNT(mg.genre_id) = 1)
GROUP BY  mg.genre_id;

#8 
#Find the IDs of actors that have played in movies of all genres
SELECT DISTINCT r.actor_id
FROM role r
WHERE (SELECT COUNT(DISTINCT mg.genre_id) FROM movie_has_genre mg) = (SELECT COUNT(DISTINCT mg.genre_id) 
FROM movie_has_genre mg WHERE mg.movie_id IN (SELECT movie_id FROM role WHERE r.actor_id = actor_id));

#9
#For each pair of genre IDs, find the number of directors that have made movies of both genres

SELECT mg.genre_id as genre_id1, mg2.genre_id as genre_id2, count(distinct md.director_id) as count
FROM movie_has_genre mg, movie_has_genre mg2, movie_has_director md, movie_has_director md2
WHERE md.movie_id = mg.movie_id AND md2.movie_id = mg2.movie_id AND md.director_id = md2.director_id
AND mg.genre_id < mg2.genre_id
GROUP BY mg.genre_id, mg2.genre_id
ORDER BY mg.genre_id asc;


#10 
#For each actor and genre, find the number of movies of the genre in which the actor was in, provided these movies as a whole do not have a director
#that has made a movie of a different genre

SELECT distinct mg.genre_id as genre, r.actor_id as actor, count(distinct mg.genre_id) as count
FROM role r, movie_has_genre mg
WHERE mg.movie_id = r.movie_id  AND
NOT EXISTS 
(SELECT 1 FROM movie_has_genre mg1, movie_has_director md WHERE md.movie_id = mg1.movie_id AND md.director_id IN
(SELECT md2.director_id
FROM movie_has_director md2, movie_has_genre mg2
WHERE md2.movie_id = mg2.movie_id
GROUP BY md2.director_id
HAVING COUNT(DISTINCT mg2.genre_id) > 1)
AND md.movie_id = mg.movie_id)
GROUP BY mg.genre_id, r.actor_id
ORDER BY mg.genre_id,r.actor_id asc;
