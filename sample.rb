# >---------------------------[ Install Command ]-----------------------------<
#  rails new APP_NAME -m http://railswizard.local/b9755a02fbf7886df8b2.rb
# >---------------------------------------------------------------------------<

# >----------------------------[ Initial Setup ]------------------------------<

initializer 'generators.rb', <<-RUBY
Rails.application.config.generators do |g|
end
RUBY

recipes = ["activerecord", "devise", "prototype"]

def say_custom(tag, text); say "\033[1m\033[36m" + tag.to_s.rjust(10) + "\033[0m" + "  #{text}" end
def say_recipe(name); say "\033[1m\033[36m" + "recipe".rjust(10) + "\033[0m" + "  Running #{name} recipe..." end
def say_wizard(text); say_custom('composer', text) end
def ask_wizard(question)
  ask "\033[1m\033[30m\033[46m" + "prompt".rjust(10) + "\033[0m\033[36m" + "  #{question}\033[0m"
end
def yes_wizard?(question)
  answer = ask_wizard(question + " \033[33m(y/n)\033[0m")
  case answer.downcase
    when "yes", "y"
      true
    when "no", "n"
      false
    else
      yes_wizard?(question)
  end
end
def no_wizard?(question); !yes_wizard?(question) end
def multiple_choice(question, choices)
  say_custom('question', question)
  values = {}
  choices.each_with_index do |choice,i|
    values[(i + 1).to_s] = choice[1]
    say_custom (i + 1).to_s + '.', choice[0]
  end
  answer = ask_wizard("Enter your selection:") while !values.keys.include?(answer)
  values[answer]
end

@after_blocks = []
def stage_two(&block); @after_blocks << block; end


say_wizard ask_wizard("What do you want to know?")
say_wizard yes_wizard?("Is there a god?")
say_wizard multiple_choice("What do you like?", [["Puppies","puppies"],["Kitties","kitties"]])

# >-----------------------------[ Run Bundler ]-------------------------------<

say_wizard "Running Bundler install. This will take a while."
run 'bundle install --path vendor/bundle'
say_wizard "Running after Bundler callbacks."
@after_blocks.each{|b| b.call}
