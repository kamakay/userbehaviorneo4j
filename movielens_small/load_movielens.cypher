

MATCH (n) DETACH DELETE n;

CREATE CONSTRAINT ON (m:MOVIE) ASSERT m.movieId IS UNIQUE;
CREATE CONSTRAINT ON (u:USER) ASSERT u.userId IS UNIQUE;
CREATE CONSTRAINT ON (g:GENRE) ASSERT g.name IS UNIQUE;

USING PERIODIC COMMIT 100 LOAD CSV WITH HEADERS FROM "file:///movies.csv" AS row
WITH row
MERGE (movie:MOVIE {movieId: toInteger(row.movieId)}) ON CREATE SET movie.title = row.title
WITH movie, row
UNWIND split(row.genres, '|') as genre
MERGE (g:GENRE {name: genre})
MERGE (movie)-[:HAS_GENRE]->(g);



USING PERIODIC COMMIT 100 LOAD CSV WITH HEADERS FROM "file:///ratings.csv" AS line
MERGE (u:USER {userId : toInteger(line.userId) } )
WITH line, u
MERGE (m:MOVIE {movieId : toInteger(line.movieId) })
WITH line, m, u
MERGE (u)-[:RATED{rating: toFloat(line.rating) }]->(m);



USING PERIODIC COMMIT 100 LOAD CSV WITH HEADERS FROM "file:///tags.csv" AS line
WITH line
MATCH (m:MOVIE { movieId: toInt(line.movieId) })
MERGE (u:USER { userId: toInt(line.userId) })
CREATE (u)-[r:TAG {tag: line.tag}]->(m);


MATCH (n) RETURN COUNT(n);