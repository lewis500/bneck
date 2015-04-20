'use strict'
_ = require('lodash')
World = require './World.coffee'
Car = require './models/car.coffee'
Minute = require './models/minute.coffee'
d3 = require 'd3'

class mainCtrl
	constructor: ($scope)->
		@scope = $scope

		@minutes = World.minutes = d3.range(0, World.num_minutes)
			.map (time)=> 	newMinute = new Minute(time)

		@cars = _.range(3, 10, 1/World.num_cars * (10 - 3))
			.map (km, n)=>
				arr_time = _.sample(World.minutes, 1)[0].time
				newCar = new Car(n, km, World.wish_time, arr_time)

		@cars.forEach (car, i, k)=>	
			car.cum_km = car.km + (+k[i-1]?.cum_km?)
			car.place()

	tick: ->
			# physics stage
			World.minutes.forEach (minute)->	
				minute.serve()
				minute.clear()
			# choice stage
			Car.setScale()
			_.sample(@cars, World.sample_size).forEach (car) => car.choose()
			@cars.forEach (car) => car.place()
			@scope.$evalAsync()

	play: ->
		clearInterval @runner
		@runner = setInterval(()=>
			 @tick()
		, World.interval)
		
	stop: -> 
		clearInterval(@runner)


module.exports = mainCtrl
