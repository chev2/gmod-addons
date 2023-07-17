local LOCATION_DATA = {
	["Outside"] = {
		Min = Vector(-5259, -3790, -1500),
		Max = Vector(1905, 6480, 10000),
	},
	["Lobby 1"] = {
		Min = Vector(1028, -880, -155),
		Max = Vector(1791, 899, 27),
	},
	["Lobby 2"] = {
		Min = Vector(-3245, -2565, -152),
		Max = Vector(-1033, -1032, 208),
	},
	["Underground"] = {
		Min = Vector(-2975, -2610, -410),
		Max = Vector(-1174, -2063, -144),
	},
	["Color Room"] = {
		Min = Vector(-3311, -4587, -265),
		Max = Vector(-790, -2620, 170),
	},
	["Dark Room Stairs"] = {
		Min = Vector(-5657, -3463, -168),
		Max = Vector(-5257., -2315, 433),
	},
	["Tower"] = {
		Min = Vector(-5000, 4636, -144),
		Max = Vector(-3934, 6024, 2647),
	},
	["Lake"] = {
		Min = Vector(-3115, 2009, -884),
		Max = Vector(1937, 6467, 165),
	},
	["Secret Room"] = {
		Min = Vector(-3111, -1415, -97),
		Max = Vector(-2889, -1051, 13),
	},
	["Backrooms Theater 1"] = {
		Min = Vector(717, -2156, -149),
		Max = Vector(1048, -1803, 57),
		Theater = {
			Name = "Backrooms Theater 1",
			Flags = THEATER_PRIVATE,
			Pos = Vector(728.1, -2032, 16),
			Ang = Angle(0, 90, 0),
			Width = 224,
			Height = 128,
			ThumbInfo = {
				Pos = Vector(1056, -1944, -48),
				Ang = Angle(0, 0, 0)
			}
		}
	},
	["Backrooms Theater 2"] = {
		Min = Vector(707, -1400, -149),
		Max = Vector(1048, -1041, 69),
		Theater = {
			Name = "Backrooms Theater 2",
			Flags = THEATER_PRIVATE,
			Pos = Vector(728.1, -1392, 16),
			Ang = Angle(0, 90, 0),
			Width = 224,
			Height = 128,
			ThumbInfo = {
				Pos = Vector(1056, -1256, -48),
				Ang = Angle(0, 0, 0)
			}
		}
	},
	["Backrooms Theater 3"] = {
		Min = Vector(722, -2172, 1130),
		Max = Vector(1038, -1798, 1265),
		Theater = {
			Name = "Backrooms Theater 3",
			Flags = THEATER_PRIVATE,
			Pos = Vector(728.1, -2032, 1264),
			Ang = Angle(0, 90, 0),
			Width = 224,
			Height = 128,
			ThumbInfo = {
				Pos = Vector(1042, -1940, 1200),
				Ang = Angle(0, 0, 0)
			}
		}
	},
	["Backrooms Theater 4"] = {
		Min = Vector(722, -1401, 1130),
		Max = Vector(1038, -1041, 1265),
		Theater = {
			Name = "Backrooms Theater 4",
			Flags = THEATER_PRIVATE,
			Pos = Vector(728.1, -1392, 1264),
			Ang = Angle(0, 90, 0),
			Width = 224,
			Height = 128,
			ThumbInfo = {
				Pos = Vector(1042, -1260, 1200),
				Ang = Angle(0, 0, 0)
			}
		}
	},
	["Backrooms"] = {
		Min = Vector(843, -2156, -144),
		Max = Vector(1791, -1041, 54),
	},
	["Upper Backrooms"] = {
		Min = Vector(1070, -2172, 1117),
		Max = Vector(1845, -1041, 1290),
	},
	["Backrooms Crossing"] = {
		Min = Vector(1791, -1290, -144),
		Max = Vector(2178, -624, 35),
	},
	["Floor 1 Theater"] = {
		Min = Vector(-2945, -3254, 256),
		Max = Vector(-1665, -2305, 764),
		Theater = {
			Name = "Floor 1 Theater",
			Flags = THEATER_PRIVATE,
			Pos = Vector(-1876, -3227.9, 736),
			Ang = Angle(0, 180, 0),
			Width = 856,
			Height = 480
		}
	},
	["Floor 2 Theater"] = {
		Min = Vector(-3005, -3254, 768),
		Max = Vector(-1600, -2241, 1278),
		Theater = {
			Name = "Floor 2 Theater",
			Flags = THEATER_PRIVATE,
			Pos = Vector(-1876, -3227.9, 1248),
			Ang = Angle(0, 180, 0),
			Width = 856,
			Height = 480
		}
	},
	["Floor 3 Theater"] = {
		Min = Vector(-3005, -3254, 1280),
		Max = Vector(-1600, -2241, 1790),
		Theater = {
			Name = "Floor 3 Theater",
			Flags = THEATER_PRIVATE,
			Pos = Vector(-1876, -3227.9, 1760),
			Ang = Angle(0, 180, 0),
			Width = 856,
			Height = 480
		}
	},
	["Floor 4 Theater"] = {
		Min = Vector(-3005, -3254, 1792),
		Max = Vector(-1600, -2241, 2302),
		Theater = {
			Name = "Floor 4 Theater",
			Flags = THEATER_PRIVATE,
			Pos = Vector(-1876, -3227.9, 2272),
			Ang = Angle(0, 180, 0),
			Width = 856,
			Height = 480
		}
	},
	["Floor 5 Theater"] = {
		Min = Vector(-3005, -3254, 2304),
		Max = Vector(-1600, -2241, 2816),
		Theater = {
			Name = "Floor 5 Theater",
			Flags = THEATER_PRIVATE,
			Pos = Vector(-1876, -3227.9, 2816),
			Ang = Angle(0, 180, 0),
			Width = 856,
			Height = 512
		}
	},
	["Underground Theater"] = {
		Min = Vector(-2928, -2063, -542),
		Max = Vector(-1200, 105, -177),
		Theater = {
			Name = "Underground Theater",
			Flags = THEATER_REPLICATED,
			Pos = Vector(-2360, 79.7, -176),
			Ang = Angle(0, 0, 0),
			Width = 592,
			Height = 336,
			ThumbInfo = {
				Pos = Vector(-2064, -1912, 104),
				Ang = Angle(0, 90, 0)
			}
		}
	},
	["Dark Room Theater"] = {
		Min = Vector(-5660, -2568, -153),
		Max = Vector(-3232, -1037, 201),
		Theater = {
			Name = "Dark Room Theater",
			Flags = THEATER_REPLICATED,
			Pos = Vector(-3980, -2555.5, 160),
			Ang = Angle(0, 180, 0),
			Width = 540,
			Height = 304
		}
	},
	["Tower Theater"] = {
		Min = Vector(-4935, 4692, -120),
		Max = Vector(-4002, 5960, 478),
		Theater = {
			Name = "Tower Theater",
			Flags = THEATER_REPLICATED,
			Pos = Vector(-4927, 4812, 480),
			Ang = Angle(0, 90, 0),
			Width = 1024,
			Height = 576
		}
	}
}

Location.Add("cinema_construct", LOCATION_DATA)

if SERVER then
	local CinemaConstructChairOffsets = {
		["models/props_trainstation/benchoutdoor01a.mdl"] = {
			{ Pos = Vector(0, 21, 0), Ang = Angle(0, 90, 0) },
			{ Pos = Vector(0, -26, 0), Ang = Angle(0, 90, 0) },
		},
		["models/cinema/theater_curve_couch_s.mdl"] = {
			{ Pos = Vector(-73.6, 17.3, 16), Ang = Angle(0, -128, 0) },
			{ Pos = Vector(-65.2, 50.3, 16), Ang = Angle(0, -128, 0) },
			{ Pos = Vector(-37.5, 71.7, 16), Ang = Angle(0, -153, 0) },
			{ Pos = Vector(0, 80, 16), Ang = Angle(0, -180, 0) },
			{ Pos = Vector(37.5, 71.7, 16), Ang = Angle(0, 153, 0) },
			{ Pos = Vector(65.2, 50.3, 16), Ang = Angle(0, 128, 0) },
			{ Pos = Vector(73.6, 17.3, 16), Ang = Angle(0, 128, 0) },
		}
	}

	-- Add chair offsets used by props in this map
	local function AddChairOffsets()
		for mdlName, chairData in pairs(CinemaConstructChairOffsets) do
			ChairOffsets[mdlName] = chairData
		end

		print("[cinema_construct] Map-specific chair offsets initialized.")
	end

	hook.Add("Initialize", "cinema_construct.InitializeMapSpecificChairOffsets", AddChairOffsets)

	-- Restrict usable buttons in theaters to theater owners only (admins exempt).
	-- This code is taken from gamemodes/cinema/gamemode/maps/cinema_theatron.lua
	-- Uses a custom hook name however, so server owners can remove the PlayerUse hook for this map as they see fit
	local UseCooldown = 0.3

	hook.Add("PlayerUse", "cinema_construct.PrivateTheaterLightSwitch", function(ply, ent)
		if ply.LastUse and ply.LastUse + UseCooldown > CurTime() then
			return false
		end

		-- Always admit admins
		if ply:IsAdmin() then return true end

		-- Only private theater owners can switch the lights
		local Theater = ply:GetTheater()
		if Theater and Theater:IsPrivate() and ent:GetClass() == "func_button" then
			ply.LastUse = CurTime()

			if Theater:GetOwner() ~= ply then
				return false
			end
		end
		return true
	end)
end
