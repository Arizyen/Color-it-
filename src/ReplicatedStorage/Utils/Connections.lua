local Connections = {}
--[[
    A module used to store an instance's connections and to manage it
]]
-- Services
-- local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Folders
-- local Source = ReplicatedStorage:WaitForChild("Source")
-- local Packages = ReplicatedStorage:WaitForChild("Packages")

-- Modulescripts

-- KnitControllers

-- Instances

-- Configs

-- Variables

-- Tables
Connections.connections = {}
local keyIds = {}
--------------------------------------------------------------------------
-- LOCAL FUNCTIONS -------------------------------------------------------
--------------------------------------------------------------------------
local function CreateKeyConnectionsTable(key)
	if key and not Connections.connections[key] then
		Connections.connections[key] = {}
	end
end

local function GetKeyConnections(key)
	if not key then
		return
	end
	if Connections.connections[key] then
		return Connections.connections[key]
	else
		Connections.connections[key] = {}
		return Connections.connections[key]
	end
end

local function GetKeyConnection(key, connectionName)
	if not key or not connectionName then
		return
	end

	if Connections.connections[key] then
		return Connections.connections[key][connectionName]
	end
end

local function DisconnectConnection(connection)
	if connection then
		if
			(typeof(connection) == "RBXScriptConnection")
			or (typeof(connection) == "table" and connection["Disconnect"])
		then
			connection:Disconnect()
		elseif typeof(connection) == "Instance" then
			if connection:IsA("Tween") then
				connection:Cancel()
				connection = nil
			elseif connection:IsA("Sound") then
				local tween = TweenService:Create(
					connection,
					TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
					{ Volume = 0 }
				)
				tween.Completed:Connect(function()
					if connection.Parent then
						connection:Destroy()
					end
					connection = nil
				end)
			elseif connection:IsA("AnimationTrack") then
				if connection.IsPlaying then
					connection.Stopped:Connect(function()
						if connection.Parent then
							connection:Destroy()
						end
						connection = nil
					end)
					connection:Stop(0.15)
				else
					if connection.Parent then
						connection:Destroy()
					end
				end
			end
		end
	end
end

local function DisconnectKeyConnection(key, connectionName)
	if not key or not connectionName or not Connections.connections[key] then
		-- print("Connections L41. Cannot disconnect connection.")
		return
	end

	DisconnectConnection(Connections.connections[key][connectionName])
	Connections.connections[key][connectionName] = nil
end

local function DisconnectKeyConnections(key)
	if not key or not Connections.connections[key] then
		return
	end

	for _, eachConnection in pairs(Connections.connections[key]) do
		DisconnectConnection(eachConnection)
	end

	table.clear(Connections.connections[key])
	Connections.connections[key] = nil
	keyIds[key] = nil
end
--------------------------------------------------------------------------
-- GLOBAL FUNCTIONS ------------------------------------------------------
--------------------------------------------------------------------------
Connections.GetKeyConnections = GetKeyConnections
Connections.GetKeyConnection = GetKeyConnection
Connections.CreateKeyConnectionsTable = CreateKeyConnectionsTable
Connections.DisconnectKeyConnection = DisconnectKeyConnection
Connections.DisconnectKeyConnections = DisconnectKeyConnections

function Connections.Add(key, connectionName, connection) -- connection: pass a function that returns the connection/or simply pass the connection itself
	if not key or not connectionName or not connection then
		print("Connections: No connection received", tostring(connectionName) or nil)
		print(debug.traceback("Stack trace:", 2))
		return
	end

	local connections = GetKeyConnections(key)
	DisconnectKeyConnection(key, connectionName)
	connections[connectionName] = connection
	-- print(connectionName, type(connection), typeof(connection))
	return connection
end

function Connections.GetUniqueKeyConnectionId(key)
	if not keyIds[key] then
		keyIds[key] = 0
	end

	if keyIds[key] > 10000000 then
		keyIds[key] = 1
	else
		keyIds[key] += 1
	end

	return tostring(keyIds[key])
end

return Connections
