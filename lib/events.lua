-- luacheck: globals script global game

--Generate Table of events
--Portions of this code graciously liberated from Smart Trains and Custom Events Mods
local events = {}
events.on_player_opened = script.generate_event_name()
events.on_player_closed = script.generate_event_name()

--[[ on_init - Setup the global tables ]]--
function events.init()
end

function events.closed( player, type, entity )
	game.raise_event( events.on_player_closed,
		{ player_index = player.index, type = type, entity = entity }
	)
end

function events.opened( player, type, entity )
	game.raise_event( events.on_player_opened,
		{ player_index = player.index, type = type, entity = entity }
	)
end

function events.raiseEvents(event)

	if event.tick % 30 == 0 then -- check twice per second

		for _, player in pairs( game.players ) do -- iterate players...

			if player.connected then

				local had, now = global.playerData[player.index], player

				-- check if something closed...
				if had.opened_self and not now.opened_self then -- closed self
					events.closed( player, 'self' )
				elseif had.opened and ( not now.opened or not now.opened.valid ) then -- closed entity
					events.closed( player, 'entity', had.opened )
				end

				-- Note: Should get 2 events...
				-- if something was open (closed event),
				-- but now something else is open (open event),
				-- ...hence no else/elseif at this point.

				-- check if something opened...
				if not had.opened_self and now.opened_self then -- opened self
					events.opened( player, 'self' )
				elseif ( not had.opened ) and now.opened and now.opened.valid then -- opened entity
					events.closed( player, 'entity', now.opened )
				end

				-- remember current state
				-- quicker to just assign vals rather than recalc what changed
				had.opened      = now.opened and now.opened.valid and now.opened--> intentional
				had.opened_self = now.opened_self

			end--if player.connected

		end--for player

	end--if event.tick

end

return events
