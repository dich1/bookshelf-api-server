require 'sinatra/base'
require 'sinatra/reloader'
require 'sinatra/param'
require 'sinatra/cross_origin'
require 'mysql2-cs-bind'
require 'json'
require 'yaml'

class Bookshelf < Sinatra::Application
  enable :method_override
  set :show_exceptions, false
  helpers Sinatra::Param

  UNREAD   = "unread"
  READING  = "reading"
  FINISHED = "finished"

  configure do
    enable :cross_origin
    register Sinatra::CrossOrigin
    set :allow_methods, [:get, :post, :put, :delete]
  end

  before do
    cross_origin
    @client = Mysql2::Client.new(YAML.load_file('database.yml'))  
    @ary = Array.new
    @hash = Hash.new { |h, k| h[k] = [] }
    content_type :json
  end

  get '/api/books/' do
    get_books
  end

  get '/api/books/count/unread/' do
    get_count_unread
  end 

  get '/api/books/count/reading/' do
    get_count_reading
  end 

  get '/api/books/count/finished/' do
    get_count_finished
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
    if get_book.count.zero?
      status 404
    else
      update_book
      status 204
    end
    # status 409
  end

  put '/api/book/unread' do
    param :id    , Integer, required: true
    if get_book.count.zero?
      status 404
    else
      update_unread
      status 204
    end
    # status 409
  end

  put '/api/book/reading' do
    param :id    , Integer, required: true
    if get_book.count.zero?
      status 404
    else
      update_reading
      status 204
    end
    # status 409
  end

  put '/api/book/finished' do
    param :id    , Integer, required: true
    if get_book.count.zero?
      status 404
    else
      update_finished
      status 204
    end
    # status 409
  end

  delete '/api/book/' do
    param :id    , Integer, required: true
    if get_book.count.zero?
      status 404
    else
      delete_book
      status 204
    end
    # status 409
  end

  not_found do
    '404 not found'
  end

  error do
    '500 server error'
  end

  def get_books
    sql = "SELECT * 
             FROM books 
         ORDER BY created_at DESC 
            LIMIT 10"
    @client.xquery(sql).each {|row| @ary << row}
    @hash["books"] = @ary
    return @hash.to_json
  end

  def post_book
    sql = "INSERT INTO books
             (title, image, status)
           VALUES 
             (?, ?, ?)"
    @client.xquery(sql, params[:title], params[:image], params[:status])
    return 
  end

  def update_book
    sql = "UPDATE books 
              SET title = ?
                , image = ?
                , status = ? 
            WHERE id = ?"
    @client.xquery(sql, params[:title], params[:image], params[:status], params[:id])
    return 
  end

  def update_unread
    sql = "UPDATE books 
              SET status = ? 
            WHERE id = ?"
    @client.xquery(sql, UNREAD, params[:id])
    return 
  end

  def update_reading
    sql = "UPDATE books 
              SET status = ? 
            WHERE id = ?"
    @client.xquery(sql, READING, params[:id])
    return 
  end

  def update_finished
    sql = "UPDATE books 
              SET status = ? 
            WHERE id = ?"
    @client.xquery(sql, FINISHED, params[:id])
    return 
  end

  def delete_book
    sql = "DELETE 
             FROM books 
            WHERE id = ?"
    @client.xquery(sql, params[:id])
    return 
  end

  def get_count_unread
    sql = "SELECT COUNT(*) as count 
             FROM books 
            WHERE status = ?"
    @hash = @client.xquery(sql, UNREAD).first
    return @hash.to_json
  end

  def get_count_reading
    sql = "SELECT COUNT(*) as count 
             FROM books 
            WHERE status = ?"
    @hash = @client.xquery(sql, READING).first
    return @hash.to_json
  end

  def get_count_finished
    sql = "SELECT COUNT(*) as count 
             FROM books 
            WHERE status = ?"
    @hash = @client.xquery(sql, FINISHED).first
    return @hash.to_json
  end

  def get_book
    sql = "SELECT * 
             FROM books 
            WHERE id = ?"
    @hash = @client.xquery(sql, params[:id]).first
    return @hash
  end
end