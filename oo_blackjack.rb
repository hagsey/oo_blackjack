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
  attr_accessor :cards, :name

  def initialize
    @name = name
    @cards = []
  end

  def calculate_score
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

class Game
  attr_accessor :deck, :dealer, :player
  def initialize
    @deck = Deck.new
    @dealer = Dealer.new
    @player = Player.new
  end

  def deal_card
  end

  def blackjack_check
    if player.calculate_hand_total == 21 && dealer.calculate_hand_total == 21
      puts "Both players get Blackjack. Keep your money."
    elsif player.calculate_hand_total == 21
      puts "Blackjack! #{player.name} wins!"
    elsif dealer.calculate_hand_total == 21
      system 'Clear'
      player.show_hand
      dealer.show_hand
      puts "#{dealer.name} got Blackjack. Dealer wins."
    end
  end

  def opening_hand_deal
    2.times do
      @player.add_a_card(@deck.deal_one_card)
      @dealer.add_a_card(@deck.deal_one_card)
    end
  end

  def display_opening_hand
    opening_hand_deal
    player.show_hand
    puts "#{dealer.name}'s hand:"
    puts "#{dealer.cards[0]}"
    puts " X of X"
    # puts "#{dealer.calculate_hand_total(cards)}"
  end

  def compare_total
  end

  def declare_winner
  end

  def welcome_message
    puts "Welcome to Blackjack! What is your name?"
    @player.name = gets.chomp
    system 'Clear'
    puts "Ok, #{player.name}, let's deal!"
    sleep 1
  end

  def play
    welcome_message
    deck.shuffle_deck
    display_opening_hand
    if player.calculate_hand_total == 21 || dealer.calculate_hand_total == 21
      blackjack_check 
    else end


    # blackjack check
  end
end

Game.new.play

# 2.times {player.add_a_card(deck.deal_one_card)}



# player.show_hand

# puts dealer.show_hand

# puts deck.cards.size




