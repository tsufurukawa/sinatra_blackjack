require 'rubygems'
require 'sinatra'
require 'pry'

set :sessions, true
BLACKJACK = 21
DEALER_HIT_MIN = 17

helpers do
  # calculate total of player/dealer hand
  def evaluate_total(cards)
    ace_count = 0 
    total = 0
    cards.each do |card|
      if card[0] == "Ace"
        ace_count += 1
        total += 11
      elsif card[0] == "Jack"|| card[0] == "Queen" || card[0] == "King"
        total += 10
      else
        total += card[0].to_i
      end
    end

    # ace correction
    ace_count.times do
      total -= 10 if total > BLACKJACK
    end
    total
  end

  def busted?(cards)
    evaluate_total(cards) > BLACKJACK
  end

  # dealer stays on all 17
  def dealer_hit?(cards)
    evaluate_total(cards) < DEALER_HIT_MIN
  end

  def decide_winner(player_cards, dealer_cards)
    @play_again_btn = true
    @show_hit_or_stay_buttons = false

    if busted?(player_cards)
      session[:win_amount] = -session[:bet_amount]
      session[:money] += session[:win_amount]          
      "BUST!! #{session[:username].upcase} LOSES $#{session[:bet_amount]}..."
    elsif hit21?(player_cards) && player_cards.count == 2 && busted?(dealer_cards)
      session[:win_amount] = 1.5 * session[:bet_amount]
      session[:money] += session[:win_amount]
      "BLACKJACK!!! #{session[:username].upcase} WINS $#{session[:win_amount]}!!!"
    elsif busted?(dealer_cards)
      session[:win_amount] = session[:bet_amount]
      session[:money] += session[:win_amount]
      "DEALER BUSTS!! #{session[:username].upcase} WINS $#{session[:bet_amount]}!!!"
    elsif evaluate_total(player_cards) > evaluate_total(dealer_cards)
      if hit21?(player_cards) && player_cards.count == 2
        session[:win_amount] = 1.5 * session[:bet_amount]
        session[:money] += session[:win_amount]
        "BLACKJACK!!! #{session[:username].upcase} WINS $#{session[:win_amount]}!!!"
      else 
        session[:win_amount] = session[:bet_amount]
        session[:money] += session[:win_amount]
        "CONGRATULATIONS!!! #{session[:username].upcase} WINS $#{session[:bet_amount]}!!!"
      end
    elsif evaluate_total(player_cards) < evaluate_total(dealer_cards)
      session[:win_amount] = -session[:bet_amount]
      session[:money] += session[:win_amount]
      "BUMMER, #{session[:username].upcase} LOSES $#{session[:bet_amount]}..."
    else
      session[:win_amount] = 0
      "PUSH. #{session[:username].upcase} WINS $0"
    end  
  end

  # returns string that'll be part of the <img> url
  def display_image(card)
    suit = card[1].downcase
    value = card[0].downcase
    "#{suit}_#{value}"
  end

  def hit21?(card)
    evaluate_total(card) == BLACKJACK
  end

  def show_result?(player, dealer)
    busted?(player) || busted?(dealer) || (session[:stay] && !dealer_hit?(dealer))
  end
end

before do 
  @show_hit_or_stay_buttons = true
end

get '/' do 
  erb :set_name
end

post '/set_name' do
  if params[:username].lstrip.rstrip.empty?
    @error = "Please enter a valid name"
    erb :set_name
  else
    session[:username] = params[:username]
    session[:money] = 500
    redirect '/bet'
  end
end

get '/bet' do 
  erb :bet
end

post '/bet' do 
  # non-numeric values and decimals will display an error message
  if params[:bet_amount].to_i.to_s != params[:bet_amount]
    @error = "Please enter a valid bet"
    erb :bet
  # betting more than player's bankroll will display an error message 
  elsif params[:bet_amount].to_i > session[:money]
    @error = "You cannot bet more than $#{session[:money]}"
    erb :bet
  else
    session[:bet_amount] = params[:bet_amount].to_i
    redirect '/game'
  end
end

get '/game' do 
  # initialize deck
  values = %w( 2 3 4 5 6 7 8 9 10 Jack Queen King Ace)
  suits = %w(Spades Clubs Diamonds Hearts)
  session[:win_amount] = 0
  session[:stay] = false
  session[:deck] = values.product(suits)
  session[:deck].shuffle!
  session[:player_hand] = []
  session[:dealer_hand] = []
  session[:player_hand] << session[:deck].pop
  session[:dealer_hand] << session[:deck].pop
  session[:player_hand] << session[:deck].pop
  session[:dealer_hand] << session[:deck].pop

  if hit21?(session[:player_hand])
    @dealer_turn_btn = true
    @show_hit_or_stay_buttons = false
  end

  erb :game
end

post '/game/player_hit' do
  session[:player_hand] << session[:deck].pop

  if hit21?(session[:player_hand])
    @dealer_turn_btn = true
    @show_hit_or_stay_buttons = false
  end

  erb :game
end

post '/game/player_stay' do 
  session[:stay] = true
  session[:stay_message] = "#{session[:username]} stays with a total of #{evaluate_total(session[:player_hand])}"
  redirect '/game/dealer'
end

get '/game/dealer' do 
  @show_hit_or_stay_buttons = false
  erb :game
end

post '/game/dealer_hit' do 
  session[:dealer_hand] << session[:deck].pop
  redirect '/game/dealer'
end

post '/play_again' do 
  if session[:money] == 0
    erb :game_over
  else 
    redirect '/bet'
  end
end

post '/game_over' do 
  redirect '/'
end