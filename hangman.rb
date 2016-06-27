require_relative './dictionary'

class Hangman

	attr_reader :fill_in_word, :bad_guesses, :guesses

	def initialize(guesses = 5, min = 5, max = 12)
		@dictionary = Dictionary.new
		@secret = @dictionary.find_random_word(min, max).downcase.split ""
		@secret_save = @secret.join
		@guesses = guesses
		@guessed_letters = []
		@bad_guesses = []
		@turns = 0
		@bad_guess_count = 0 # for the animation
		@fill_in_word = ("_ "*@secret.length).strip
		@drawing = ["    -----",
								"       ||",
								"       ||",
								"       ||",
								"       ||",
								" ______||______",
								"|______||______|\n\n"]
		@drawing_animation = ["    |  ||",
													"   0   ||",
													"   T   ||",
												  "   ^   ||"]
	end

	def dictionary
		@dictionary
	end

	def peek
		@secret_save
	end

	#Prompts a user for a guess
	#uses the guess to move game forward
	def guess_letter(guess)
		if (guess && guess.between?('a','z') && !(@guessed_letters.include? guess)\
			&& guess.length == 1)
			process_guess(guess)
			@guessed_letters << guess
			@turns += 1
		else
		
		end
	end

	#returns true if the game has ended, false otherwise
	def ended?
		ended = false
		ended = true if(!(@fill_in_word.include? "_") || @guesses <= 0)
		ended
	end

	#returns true if the player has won, false otherwise
	def won?
		won = false
		won = true if (ended? && @guesses > 0)
		won
	end

	private

		#Uses the guess to affect the rest of the game
		def process_guess(guess)
			unless @secret.include? guess
				@bad_guesses << guess
				@guesses -= 1
				@bad_guess_count += 1
			end

			while @secret.include? guess
				@fill_in_word[@secret.index(guess) * 2] = guess
				@secret[@secret.index guess] = " "
			end
		end

end