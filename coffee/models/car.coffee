d3 = require('d3')
World = require( '../World.coffee')
require('../helpers.coffee')
_ = require('lodash')

scale = d3.scale.linear().range(d3.range(0,World.num_minutes))

class Car 
	constructor: (@n, @km, @wish_time, @arr_time)->
		@sched_pen = Infinity
		@km_left = @km
		@cost = Infinity
		@travel_pen = Infinity
		@exit_time = @wish_time

	@property 'is_done', get: -> @km_left <= 0

	@setScale: ()->	scale.domain(_.pluck(World.minutes,'X'))

	travel: (vel)->	@km_left -= vel

	reset: (time)-> 
		@km_left = @km
		@exit_time = time
		@travel_pen = World.alpha*(@exit_time - @arr_time)
		sched_del = @exit_time - @wish_time
		@sched_pen = if sched_del <= 0 then (-World.beta * sched_del) else (World.gamma * sched_del)
		@cost = @travel_pen + @sched_pen

	getCost: (arr_time, exit_time)->
		travel_pen = World.alpha*(exit_time - arr_time)
		sched_del = exit_time - @wish_time
		sched_pen = if sched_del <= 0 then (-World.beta * sched_del) else (World.gamma * sched_del)
		cost = travel_pen + sched_pen

	choose: ()->
		cost = @cost
		World.minutes.forEach (minute,i)=>
			arr_time = minute.time
			exit_time = scale(minute.X + @km)
			if exit_time < World.num_minutes
				pCost = @getCost(arr_time, exit_time)
				if pCost <= cost 
					@arr_time = arr_time
					cost = pCost

	place: ()-> 
		M = World.minutes[@arr_time]
		M.receive(this)
		M.arrivals++

module.exports = Car