require 'rubygems'
require 'sinatra'

get '/' do
  erb :home_page
end


post '/home_page' do
 array=params[:query]

   @array=function
   erb :display

 end

get '/result?*' do
   file=request.fullpath.to_s.match(/\?(.*)/)[1]
 File.read(file)
end




def function
return ['Pakistan','Database',]
end
