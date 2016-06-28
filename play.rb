require 'sinatra'
require 'sinatra/reloader' if development?
require_relative './hangman'
require 'yaml'
private

private
	#saves a game to ./saves
	def save(game)
		save_name = game.fill_in_word
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

game = new_game

get "/" do
	guess = params["guess"]
	guess.downcase! if guess
	game.guess_letter(guess)
	word = game.fill_in_word
	bad_guesses = game.bad_guesses.join(", ")
	turns_left = game.guesses
	erb :index, locals: { word: word, bad_guesses: bad_guesses,
												turns_left: turns_left, game: game }
end

get "/save" do
	save game
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

get "/new_game" do
	game = Hangman.new
	redirect to('/')
end