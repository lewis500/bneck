d3 = require 'd3'
World = require('../World')
num_cars = require('../World').num_cars
require('../helpers.coffee')

class Minute 
	constructor: (@time)->
		@queue = []
		@vel = 0
		@X = 0
		@cum_arrivals = 0
		@cum_exits = 0
		@arrivals = 0
		@exits = 0

	findVel: (u)->.5*(1 - .35*u / num_cars)

	@property 'next', get: ->World.minutes[@time+1] ? false

	@property 'prev', get: ->World.minutes[@time-1] ? false

	serve: ->
		@X = 0
		@vel = @findVel(@queue.length)
		@queue.forEach (car)=>
			car.travel(@vel)
			if car.is_done or !@next
				@exits++
				car.reset(@time)
			else @next.receive(car)

		@cum_exits = @exits + (if @prev then @prev.cum_exits else 0 )
		@cum_arrivals = @arrivals + (if @prev then @prev.cum_arrivals else 0 )
		@X = if @prev then (@prev.vel + @prev.X ) else 0

	clear: ->
		@queue = []
		@arrivals = 0
		@exits = 0

	receive: (car)->
		@queue.push(car)

module.exports = Minute