require 'sinatra'
require 'sinatra/reloader' if development?
require_relative './hangman'
require 'yaml'

use Rack::Session::Pool, :expire_after => 2592000

private
	#saves a game to ./saves
	def save(game)
		save_name = game.fill_in_word + " (#{session[:game].guesses})"
		Dir.mkdir "saves" unless Dir.exists? "saves"
		file_path = File.join("saves", "#{save_name}")
		File.open(file_path, "w") { |f|
			f.write(YAML.dump(game))
		}
	end
public

def new_game
	game = Hangman.new
	game.dictionary.close_dictionary
	game
end

get "/play" do
	redirect to "/reset" unless session[:game]
	session[:guess] = params["guess"]
	session[:guess].downcase! if session[:guess]
	session[:game].guess_letter(session[:guess])
	word = session[:game].fill_in_word
	bad_guesses = session[:game].bad_guesses.join(", ")
	turns_left = session[:game].guesses
	erb :index, locals: { word: word, bad_guesses: bad_guesses,
												turns_left: turns_left, game: session[:game] }
end

get "/" do
	redirect to session[:game].nil? ? "/reset" : "/play"
end

get "/save" do
	save session[:game]
	redirect to('/')
end

get "/load" do
	if (Dir.exists? "saves") && Dir["saves/*"].length > 0
		saves = Dir.entries("saves")
		saves.delete(".")
		saves.delete("..")
		erb :load, locals: {saves: saves}
	else
		redirect to('/')
	end
end

get "/load/:id" do
	File.open("saves/#{params["id"]}", 'r'){ |f|
		game = YAML.load(f)
	}
	redirect to("/")
end

get "/reset" do
	session[:game] = new_game
	redirect to('/play')
end