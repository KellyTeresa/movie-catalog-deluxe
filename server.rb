require 'pry'
require 'sinatra'
require 'pg'

def db_connection
  begin
    connection = PG.connect(dbname: "movies")
    yield(connection)
  ensure
    connection.close
  end
end

get '/' do
  '''<ul>
  <li><a href="/actors">Actors</a></li>
  <li><a href="/movies">Movies</a></li>
  </ul>
  '''
end

get '/actors' do
  actors_list = db_connection do |conn|
    conn.exec("SELECT id, name FROM actors ORDER BY name;")
  end
  erb :'actors/index', locals: {actors_list: actors_list.to_a}
end

get '/actors/:id' do
  # binding.pry
  actor_info = db_connection do |conn|
    conn.exec("SELECT
    actors.name AS actor,
    cast_members.character AS character,
    movies.title AS movies,
    movies.id AS movie_id
    FROM actors
    JOIN cast_members ON cast_members.actor_id = actors.id
    JOIN movies ON cast_members.movie_id = movies.id
    WHERE actors.id = #{params['id'].to_i};")
  end

  erb :'actors/show', locals: { actor_info: actor_info.to_a }
end

get '/movies' do
  movies_list = db_connection do |conn|
    conn.exec("SELECT
    movies.id,
    movies.title,
    movies.year,
    movies.rating,
    genres.name AS genre,
    studios.name AS studio
    FROM movies
    JOIN genres ON genres.id = movies.genre_id
    LEFT OUTER JOIN studios ON studios.id = movies.studio_id;")
  end
  erb :'movies/index', locals: {movies_list: movies_list.to_a}
end

get '/movies/:id' do
  erb :'movies/show'
end
