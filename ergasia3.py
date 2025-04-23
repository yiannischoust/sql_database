#Ιωάννης Χουστουλάκης 1115202300296
#Άννα Μπαρδάι 1115202000137
#Γεώργιος Σωτήριος Ξενιός 1115202200121

# ----- CONFIGURE YOUR EDITOR TO USE 4 SPACES PER TAB ----- #
import sys,os
sys.path.append(os.path.join(os.path.split(os.path.abspath(__file__))[0], 'lib'))
import pymysql

def connection():
    ''' User this function to create your connections '''    
    con = pymysql.connect(host='127.0.0.1', port=3306, user='root', passwd='1234', db='movies') #update with your settings
    
    return con

def updateRank(rank1, rank2, movieTitle):
    #select m.rank from movie m where m.title = "UHF";
    # Create a new connection
    con=connection()
    rank1 = float(rank1)
    rank2 = float(rank2)
 
    # Create a cursor on the connection
    cur=con.cursor()

    try :
        if not (0 <= rank1 <= 10) or not (0 <= rank2 <= 10):
            raise ValueError("Rank should be between 0 and 10")
        cur.execute('select m.rank from movie m where m.title = %s',(movieTitle,))
        rows = cur.fetchall()
        if len(rows) != 1:
            raise ValueError("Movie title not found or more than one movies found")
        else:
            currentrank = rows[0][0]

        if currentrank is not None:
            currentrank = (currentrank + rank1 + rank2) / 3
        else:
            currentrank = (rank1 + rank2)/2
        cur.execute('update `movie` set `rank` = %s where title = %s',(currentrank, movieTitle))
        con.commit()
    except ValueError as e:
        print(e)
        return [("status",), ("error",),]


    print (rank1, rank2, rows, currentrank)

    return [("status",),("ok",),]

def colleaguesOfColleagues(actorId1, actorId2):
    con = connection()
    cur = con.cursor()
    cur.execute("SELECT movie_id FROM role WHERE actor_id = %s", (actorId1,))
    movies_of_actor1 = cur.fetchall()

    colleague_of_actor1 = set()
    for movie in movies_of_actor1:
        cur.execute("SELECT actor_id FROM role WHERE movie_id = %s AND actor_id != %s", (movie[0], actorId1))
        colleague_of_actor1.update(col[0] for col in cur.fetchall())

    cur.execute("SELECT movie_id FROM role WHERE actor_id = %s", (actorId2,))
    movies_of_actor2 = cur.fetchall()

    colleague_of_actor2 = set()
    for movie in movies_of_actor2:
       # print(movie[0])
        cur.execute("SELECT actor_id FROM role WHERE movie_id = %s AND actor_id != %s", (movie[0], actorId2))
        colleague_of_actor2.update(col[0] for col in cur.fetchall())


    results = []
    for actor1 in colleague_of_actor1:
        cur.execute("SELECT movie_id FROM role WHERE actor_id = %s", (actor1,))
        movies_of_actor1_colleague = set(movie[0] for movie in cur.fetchall())
        
        for actor2 in colleague_of_actor2:
            cur.execute("SELECT movie_id FROM role WHERE actor_id = %s", (actor2,))
            movies_of_actor2_colleague = set(movie[0] for movie in cur.fetchall())
            
            common_movies = movies_of_actor1_colleague.intersection(movies_of_actor2_colleague)
            for movie_id in common_movies:
                cur.execute("SELECT title FROM movie WHERE movie_id = %s", (movie_id,))
                movie_title = cur.fetchone()[0]
                results.append((movie_title, actor1, actor2, actorId1, actorId2))

    print('Results are' + len(list(results)))
    return [("movieTitle", "colleagueOfActor1", "colleagueOfActor2", "actor1", "actor2"),] + results

def actorPairs(actorId):

    # Create a new connection
    con=connection()

    # Create a cursor on the connection
    cur=con.cursor()
    cur.execute("SELECT r.actor_id FROM role r, role r2, role r3, movie_has_genre mg, movie_has_genre mg2 WHERE r2.actor_id = %s AND r.actor_id <> r2.actor_id and r.movie_id = r2.movie_id and mg.movie_id = r.movie_id and mg2.movie_id <> r2.movie_id and mg2.genre_id <> mg.genre_id GROUP BY r.actor_id having count(distinct mg.genre_id) > 6", (actorId,))
    #print (actorId)
    actors = cur.fetchall()
    print('Results are' + len(list(actors)))
    return [("actorId",),] + len(list(actors))

def selectTopNactors(n):

    # Create a new connection
    con=connection()

    # Create a cursor on the connection
    cur=con.cursor()
    cur.execute("SELECT distinct g.genre_id from genre g")
    genres = cur.fetchall()
    actors = []
    for genre in genres:
        cur.execute("SELECT g.genre_name, r.actor_id, count(mg.movie_id) FROM role r, genre g, movie_has_genre mg WHERE r.movie_id = mg.movie_id AND g.genre_id = mg.genre_id AND g.genre_id = %s GROUP BY r.actor_id, g.genre_name ORDER BY genre_name ASC, count(mg.movie_id) DESC",(genre))
        results = cur.fetchmany(int(n))
        for result in results:
            actors.append(result)
    print (n)
    
    return [("genreName", "actorId", "numberOfMovies"),] + list(actors)

def traceActorInfluence(actorId):
    # Create a new connection
    con=connection()

    # Create a cursor on the connection
    cur=con.cursor()


    return [("influencedActorId",),]
