require 'rubygems'
require 'pry'

module Hand
  def show_hand
    puts "#{name}'s hand:"
    cards.each do|card|
      puts "#{card}"
    end
    puts "Total ==> #{calculate_hand_total}"
  end

  def add_a_card(new_card)
    cards << new_card
  end

  def show_both_hands
    system 'Clear'
    stack.show_stack
    player.show_hand
    puts " "
    puts " ---------------------"
    puts " "
    dealer.show_hand
    sleep 2
  end

  def calculate_hand_total
    card_values = cards.map {|card| card.value}
    total = 0
    card_values.each do |value|
      if value == 'A'
        total += 11
      elsif value.to_i == 0
        total += 10
      else
        total += value.to_i
      end
    end
    card_values.each do |value|
      if value == 'A' && total > 21
        total -= 10
      end
    end
    total
  end
end

class Player
  include Hand
  attr_accessor :cards, :name, 

  def initialize
    @name = name
    @cards = []
  end

  
end

class Dealer
  include Hand
  attr_reader :name
  attr_accessor :cards

  def initialize
    @name = "Dealer"
    @cards = []
  end
end

class Deck
  attr_accessor :cards

  def initialize
    @cards = []
    ['H', 'C', 'D', 'S'].each do |suit|
      ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A'].each do |value|
        @cards << Card.new(suit, value)
      end
    end
  end

  def shuffle_deck
    system 'Clear'
    puts "Shuffling deck..."
    sleep 1
    system 'Clear'
    cards.shuffle!
  end

  def deal_one_card
    cards.shift
  end

end 

class Card
  attr_accessor :suit, :value

  def initialize(suit, value)
    @suit = suit
    @value = value
  end

  def display_card
    "#{value} of #{suit_name}"
  end

  def suit_name
    case suit
      when 'C' then 'clubs'
      when 'S' then 'spades'
      when 'D' then 'diamonds'
      when 'H' then 'hearts'
    end
  end

  def to_s
    display_card
  end
end

class Stack
  attr_accessor :amount

  def initialize
    @amount = 30
  end

  def show_stack
    puts "STACK SIZE: $" + amount.to_s
    puts "================="
  end

  def to_s
    show_stack
  end
end

class Game
  include Hand
  attr_accessor :deck, :dealer, :player, :stack, :bet
  def initialize
    @deck = Deck.new
    @dealer = Dealer.new
    @player = Player.new
    @stack = Stack.new
    @bet = bet
  end

  def blackjack_check
    if player.calculate_hand_total == 21 && dealer.calculate_hand_total == 21
      show_both_hands
      puts "Both players get Blackjack. Keep your money."
    elsif player.calculate_hand_total == 21
      show_both_hands
      puts "Blackjack! #{player.name} wins!"
    elsif dealer.calculate_hand_total == 21
      show_both_hands
      puts "#{dealer.name} got Blackjack. Dealer wins."
      lose_bet
    else
      return false
    end
  end

  def opening_hand_deal
    2.times do
      @player.add_a_card(@deck.deal_one_card)
      @dealer.add_a_card(@deck.deal_one_card)
    end
  end

  def dealer_opening_hand
    puts " "
    puts " ---------------------"
    puts " "
    puts "#{dealer.name}'s hand:"
    puts "#{dealer.cards[0]}"
    puts " X of X"
    puts " "
  end

  def player_bet
    stack.show_stack
    begin
      puts "Place your bet. (maximum of $20)"
      @bet = gets.chomp.to_i
    end until (0..20).include?(bet)
    system 'Clear'
  end

  def lose_bet
    stack.amount -= @bet
  end

  def player_turn
   while player.calculate_hand_total < 21
      puts "Press (1) to hit or (2) to stay."
      hit_or_stay = gets.chomp.to_i
     
      if hit_or_stay == 1
        player.add_a_card(@deck.deal_one_card)
        player.calculate_hand_total
        system 'Clear'
        stack.show_stack
        player.show_hand
        dealer_opening_hand
        if player.calculate_hand_total == 21
          puts "#{player.name} got 21!"
        elsif player.calculate_hand_total > 21
          puts "Bust! Dealer wins."
          lose_bet
        end
      elsif hit_or_stay == 2
        puts "#{player.name} is staying with #{player.calculate_hand_total}."
        sleep 1
        break
      else
        puts "Sorry I didn't get that. Please just hit a (1) or a (2)."
      end     
    end
  end

  def dealer_turn
    if player.calculate_hand_total <= 21
      system 'Clear' 
      puts "Dealer's second card is #{dealer.cards[1]} for a total of #{dealer.calculate_hand_total}."
      sleep 2
      stack.show_stack
      show_both_hands
      if (17..21).include?(dealer.calculate_hand_total)
        puts "Dealer must stay with #{dealer.calculate_hand_total}."
        compare_total
      end
      
      while dealer.calculate_hand_total < 17
        dealer.add_a_card(@deck.deal_one_card)
        stack.show_stack
        show_both_hands
        if dealer.calculate_hand_total < 17
        elsif (17..21).include?(dealer.calculate_hand_total)
          puts "Dealer must stay."
          compare_total
        else
          puts "Dealer busts! #{player.name} wins!"
        end
      end
    end
  end

  def compare_total
    sleep 1
    if dealer.calculate_hand_total >= player.calculate_hand_total
      winning_message(dealer.name, dealer.calculate_hand_total, player.calculate_hand_total)
      lose_bet
    else
      winning_message(player.name, player.calculate_hand_total, dealer.calculate_hand_total)
    end
  end

  def winning_message(winner, winner_total, loser_total)
    puts "#{winner} won with a total of #{winner_total} over #{loser_total}!"
  end


  def welcome_message
    puts "Welcome to Blackjack! What is your name?"
    @player.name = gets.chomp
    system 'Clear'
    puts "Ok, #{player.name}, let's deal!"
    sleep 1
  end

  def new_game
    @deck = Deck.new
    player.cards = []
    dealer.cards = []
  end

  def play_again?
    sleep 1
    puts "Would you like to play again? (Y/N)"
    gets.chomp.upcase == 'Y'
  end 

  def play
    welcome_message
    loop do
      new_game
      deck.shuffle_deck
      player_bet
      opening_hand_deal
      stack.show_stack
        if blackjack_check == false
          player.show_hand
          dealer_opening_hand
          player_turn
          dealer_turn
        end
      break unless play_again?
    end
  end 
end

Game.new.play




