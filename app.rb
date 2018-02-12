require 'sinatra/base'
require 'sinatra/reloader'
require 'sinatra/param'
require 'mysql2-cs-bind'
require 'json'
require 'yaml'

class Bookshelf < Sinatra::Application
  enable :method_override
  set :show_exceptions, false
  helpers Sinatra::Param

  before do
    @client = Mysql2::Client.new(YAML.load_file('database.yml'))  
    content_type :json
  end

  get '/api/books/' do
    get_books
  end

  post '/api/book/' do
    # パラメータ不正：status 400
    param :title , String , required: true
    param :image , String , required: false
    param :status, String , required: true
    post_book
    status 201
    # status 409
  end

  put '/api/book/' do
    param :id    , Integer, required: true
    param :title , String , required: true
    param :image , String , required: false
    param :status, String , required: true
    update_book
    status 204
    # status 404
    # status 409
  end

  delete '/api/book/' do
    param :id    , Integer, required: true
    delete_book
    status 204
    # status 404
    # status 409
  end

  not_found do
    '404 not found'
  end

  error do
    status 500
    '500 server error'
  end

  def get_books
    sql = "SELECT * FROM books ORDER BY created_at DESC LIMIT 10"
    ary = Array.new
    @client.xquery(sql).each {|row| ary << row}
    return ary.to_json
  end

  def post_book
    sql = "INSERT INTO bookshelf.books (title, image, status) VALUES (?, ?, ?)"
    ary = Array.new
    @client.xquery(sql, params[:title], params[:image], params[:status])
    return 
  end

  def update_book
    sql = "UPDATE bookshelf.books SET title = ?, image = ?, status = ? WHERE id = ?"
    ary = Array.new
    @client.xquery(sql, params[:title], params[:image], params[:status], params[:id])
    return 
  end


  def delete_book
    sql = "DELETE FROM bookshelf.books WHERE id = ?"
    ary = Array.new
    @client.xquery(sql, params[:id])
    return 
  end
end