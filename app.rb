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

  get '/api/books/unread/' do
    get_unread_count
  end 

  get '/api/books/reading/' do
    get_reading_count
  end 

  get '/api/books/finished/' do
    get_finished_count
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
    sql = "SELECT * 
             FROM books 
         ORDER BY created_at DESC 
            LIMIT 10"
    ary = Array.new
    @client.xquery(sql).each {|row| ary << row}
    return ary.to_json
  end

  def post_book
    sql = "INSERT INTO books
             (title, image, status)
           VALUES 
             (?, ?, ?)"
    ary = Array.new
    @client.xquery(sql, params[:title], params[:image], params[:status])
    return 
  end

  def update_book
    sql = "UPDATE books 
              SET title = ?
                , image = ?
                , status = ? 
            WHERE id = ?"
    ary = Array.new
    @client.xquery(sql, params[:title], params[:image], params[:status], params[:id])
    return 
  end


  def delete_book
    sql = "DELETE 
             FROM books 
            WHERE id = ?"
    ary = Array.new
    @client.xquery(sql, params[:id])
    return 
  end

  def get_unread_count
    sql = 'SELECT COUNT(*) as count 
             FROM books 
            WHERE status = "unread"'
    ary = Array.new
    @client.xquery(sql).each {|row| ary << row}
    return ary.to_json
  end

  def get_reading_count
    sql = 'SELECT COUNT(*) as count 
             FROM books 
            WHERE status = "reading"'
    ary = Array.new
    @client.xquery(sql).each {|row| ary << row}
    return ary.to_json
  end

  def get_finished_count
    sql = 'SELECT COUNT(*) as count 
             FROM books 
            WHERE status = "finished"'
    ary = Array.new
    @client.xquery(sql).each {|row| ary << row}
    return ary.to_json
  end
end