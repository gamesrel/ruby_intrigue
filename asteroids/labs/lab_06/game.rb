#!/usr/bin/env ruby -w

require 'lib/gosu.for_1_8.bundle'
require 'lib/player'
require 'lib/asteroid'
require 'lib/projectile'

class GameWindow < Gosu::Window
  def initialize
    super(640, 480, false)
    @background_image = Gosu::Image.new(self, "assets/background.png", true)
    @player = Player.new(self)
    @asteroids = Asteroid.spawn(self, 3)
    @projectiles = []
  end

  # 60 times per second
  def update
    control_player
    @player.move
    @asteroids.each{|asteroid| asteroid.move}
    @projectiles.each{|projectile| projectile.move}
    @projectiles.reject!{|projectile| projectile.dead?}
    detect_collisions
  end

  # happens immediately after each iteration of the update method
  def draw
    @background_image.draw(0, 0, 0)
    @player.draw
    @asteroids.each{|asteroid| asteroid.draw}
    @projectiles.each{|projectile| projectile.draw}
  end 

  def button_down(id)
    close if id == Gosu::KbQ
    if id == Gosu::KbSpace
      @projectiles << Projectile.new(self, @player)
    end
  end

  def control_player
    if button_down? Gosu::KbLeft
      @player.turn_left
    end
    if button_down? Gosu::KbRight
      @player.turn_right
    end
    if button_down? Gosu::KbUp
      @player.accelerate
    end
  end

  def detect_collisions
    @asteroids.each do |asteroid| 
      if collision?(asteroid, @player)
        puts 'kaboom'
      end
    end
    @projectiles.each do |projectile| 
      @asteroids.each do |asteroid|
        if collision?(projectile, asteroid)
          projectile.kill
          puts 'hit'
        end
      end
    end
  end

  def collision?(object_1, object_2)
    hitbox_1, hitbox_2 = object_1.hitbox, object_2.hitbox
    common_x = hitbox_1[:x] & hitbox_2[:x]
    common_y = hitbox_1[:y] & hitbox_2[:y]
    common_x.size > 0 && common_y.size > 0 
  end
end

window = GameWindow.new
window.show

