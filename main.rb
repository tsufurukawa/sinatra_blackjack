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
      if card[0] == 'Ace'
        ace_count += 1
        total += 11
      elsif card[0] == 'Jack' || card[0] == 'Queen' || card[0] == 'King'
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

  # dealer stays on soft 17
  def dealer_hit?(cards)
    evaluate_total(cards) < DEALER_HIT_MIN
  end

  def decide_winner(player_cards, dealer_cards)
    @play_again_btn = true

    if evaluate_total(player_cards) > 21
      session[:money] -= session[:bet_amount]          
      "BUST!! #{session[:username]} Loses..."
    elsif evaluate_total(dealer_cards) > 21
      session[:money] += session[:bet_amount]
      "Dealer Busts!! #{session[:username]} Wins!!!"
    elsif evaluate_total(player_cards) > evaluate_total(dealer_cards)
      session[:money] += session[:bet_amount]
      "Congratulations!!! #{session[:username]} Wins!!!"
    elsif evaluate_total(player_cards) < evaluate_total(dealer_cards)
      session[:money] -= session[:bet_amount]
      "I'm Sorry, #{session[:username]} Loses..."
    else
      "Draw."
    end  
  end

  # returns string that'll be part of the <img> url
  def display_image(card)
    suit = card[1].downcase
    value = card[0].downcase
    "#{suit}_#{value}"
  end

  def hit21?(card)
    evaluate_total(card) == 21
  end
end

get '/' do 
  erb :set_name
end

post '/' do
  session[:username] = params[:username]
  session[:money] = 500
  redirect '/bet'
end

get '/bet' do 
  erb :bet
end

post '/bet' do 
  # non-numeric values and decimals will display an error message
  if params[:bet_amount].to_i.to_s != params[:bet_amount]
    @error = "Please enter a valid bet"
    erb :bet
  # betting more than what's available will display an error message 
  elsif params[:bet_amount].to_i > session[:money]
    @error = "You can only bet #{session[:money]}"
    erb :bet
  else
    session[:bet_amount] = params[:bet_amount].to_i
    redirect '/game'
  end
end

get '/game' do 
  # initialize deck
  values = %w(2 3 4 5 6 7 8 9 10 Jack Queen King Ace)
  suits = %w(Spades Clubs Diamonds Hearts)
  session[:stay] = false
  session[:deck] = values.product(suits)
  session[:deck].shuffle!
  session[:player_hand] = []
  session[:dealer_hand] = []
  session[:player_hand] << session[:deck].pop
  session[:dealer_hand] << session[:deck].pop
  session[:player_hand] << session[:deck].pop
  session[:dealer_hand] << session[:deck].pop

  @dealer_turn_btn = true if hit21?(session[:player_hand])
  erb :game
end

post '/game/player_hit' do
  session[:player_hand] << session[:deck].pop
  @dealer_turn_btn = true if hit21?(session[:player_hand])
  erb :game
end

post '/game/player_stay' do 
  session[:stay] = true
  session[:stay_message] = "#{session[:username]} stays with a total of #{evaluate_total(session[:player_hand])}"
  redirect '/game/dealer'
end

get '/game/dealer' do 
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