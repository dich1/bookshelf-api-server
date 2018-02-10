require 'active_record'
require 'mysql2'
require 'mysql2-cs-bind'
require 'sinatra'
require 'json'
require 'yaml'
require 'sinatra/reloader'


@@client = Mysql2::Client.new(YAML.load_file('database.yml'))

enable :method_override

get '/api/books/' do
  content_type 'application/json'
  get_books
end

post '/api/book/' do
  content_type 'application/json'
  post_book
  status 201
  # status 404
  # status 409
end

put '/api/book/' do
  content_type 'application/json'
  update_book
  status 204
  # status 404
  # status 409
end

delete '/api/book/' do
  content_type 'application/json'
  delete_book
  status 204
  # status 404
  # status 409
end

def get_books
  sql = "SELECT * FROM books ORDER BY created_at DESC LIMIT 10"

  ary = Array.new
  @@client.xquery(sql).each {|row| ary << row}
  return ary.to_json
end

def post_book
  title  = params[:title]
  image  = params[:image]
  status = params[:status]

  sql = "INSERT INTO bookshelf.books (title, image, status) VALUES (?, ?, ?)"

  ary = Array.new
  @@client.xquery(sql, title, image, status)
  return 
end

def update_book
  id      = params[:id]
  title   = params[:title]
  image   = params[:image]
  status  = params[:status]

  sql = "UPDATE bookshelf.books SET title = ?, image = ?, status = ? WHERE id = ?"

  ary = Array.new
  @@client.xquery(sql, title, image, status, id)
  return 
end


def delete_book
  id  = params[:id]

  sql = "DELETE FROM bookshelf.books WHERE id = ?"

  ary = Array.new
  @@client.xquery(sql, id)
  return 
end
