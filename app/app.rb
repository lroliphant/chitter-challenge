require 'sinatra/base'
require 'sinatra/flash'
require './app/data_mapper_setup.rb'

class Chitter < Sinatra::Base
  use Rack::MethodOverride
  register Sinatra::Flash

  enable :sessions, :static
  set :sessions_secret, 'v secret'
  set :public_folder, Proc.new { File.join(root, '..', 'public') }

  get '/' do
    @posts = Post.all
    # @posts = Post.sort_posts
    erb :index
  end

  get '/users/new' do
    @user = User.new
    erb :'users/new'
  end

  post '/users' do
    @user = User.new(name: params[:name],
                username: params[:username],
                email: params[:email],
                password: params[:password],
                password_confirmation: params[:password_confirmation])
    if @user.save # save returns true if model has been saved to the db
      session[:user_id] = @user.id
      redirect to('/')
    else
      flash.now[:errors] = @user.errors.full_messages
      erb :'users/new'
    end
  end

  get '/sessions/new' do
    erb :'sessions/new'
  end

  post '/sessions' do
    user = User.authenticate(params[:username], params[:password])
    if user
      session[:user_id] = user.id
      redirect to('/')
      # redirect to('/post/new')
    else
      flash.now[:errors] = ['The username or password is incorrect']
      erb :'sessions/new'
    end
  end

  delete '/sessions' do
    session[:user_id] = nil
    flash[:notice] = 'Goodbye!'
    # user = User.get(session[:user_id]).destroy
    redirect to('/')
  end

  # get '/' do
  #   @posts = Post.all
  #   # @posts = Post.sort_posts
  #   erb :index
  # end

  # get '/posts' do
  #   @posts = Post.all
  #   # @posts = Post.sort_posts
  #   erb :index
  # end

  get '/posts/new' do
    erb :'posts/new'
  end

  post '/posts/new' do
    if current_user
      @post = Post.new
      erb :'posts/new'
    else
      flash.now[:notice] = 'Please log in to post messages'
      erb :'sessions/new'
    end
  end

  post '/posts/new' do
    @post = Post.new(message: params[:message], created_at: DateTime.now)
    if @post.save
      redirect to('/posts')
    else
      # flash.now[:notice] = 'Please add message text'
      erb :'posts/new'
    end
    # current_user.post_message.create(message: params[:message], created_at: DateTime.now)
    # redirect to('/posts')
    # erb :'posts/index'
  end

  get '/peeps' do
    @posts = Post.all
    erb :index
  end


  def current_user
    @current_user ||= User.get(session[:user_id])
  end

  # start the server if ruby file executed directly
  run! if app_file == $PROGRAM_NAME

end
