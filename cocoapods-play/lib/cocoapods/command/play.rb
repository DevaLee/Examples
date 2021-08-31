# frozen_string_literal: true

require "cocoapods"

module PlayBall
  class BaseketGame
    def self.shotBall
        new
    end

    def initialize
      puts "BaseketGame 初始化"
      puts "进了一个三分球"
    end
  end
end


module Pod
  class Commands
    class Play < Command
      def initialize(argv)
        puts argv
        super(argv)
      end
      
      def run 
        puts "[Cocoapods play] begin -------------"
        PlayBall::BaseketGame.shotBall
        puts "[Cocoapods play] end ---------------"
      end
    end
  end
end

