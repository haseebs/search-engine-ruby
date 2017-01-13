require 'rubygems'
require 'sinatra'
require './search.rb'

get '/' do
  erb :home_page
end

post '/home_page' do
  words=params[:query]
  search = Search.new
  @array = search.query(words)

  if @array.nil?
    'Please Be more specific'
  else
    erb :display
  end
end

get '/result?*' do
  file=request.fullpath.to_s.match(/\?(.*)/)[1]
  #File.read(File.expand_path("..", Dir.pwd)+ '/repository/' + file)
  @file = File.read(File.expand_path("..",File.expand_path("..", Dir.pwd))+ '/repository/' + file)
  #@file = @file.gsub(/[^\w\s]/, " ")
  erb :content
end
