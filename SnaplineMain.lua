-- // Made with love and my fucking half-broken keyboard.
-- // Don't have to be credited, so you can use it if you want, I don't really care lmao.
-- // I don't know the original creator, but I edited the script and optimized it.
-- // Have fun


local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local localPlayer = Players.LocalPlayer

local camera = workspace.CurrentCamera

local gui = Instance.new("ScreenGui", localPlayer.PlayerGui)
gui.Name = "Snapline"

local lineOrigin = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y * 0.9)

local activeLines = {}

local Snapline = {} -- main module

function _warn(text)
	warn("Snapline Library: // " .. text)
end

function removeLine(args, line)
	local index = table.find(activeLines, args)
	if not index then
		_warn("Line not found.")
		return
	end
	
	line:Destroy()
	
	_warn("Successfully removed Line from the table.")
	table.remove(activeLines, index)
end

function Snapline:draw(part:BasePart, color)
	if not part:IsA("BasePart") then
		_warn("This is not a part, you fucking retarted.")
		return
	end
	
	local line = Instance.new("Frame", gui)
	line.Name = "Snapline" .. " / " .. part.Name
	line.AnchorPoint = Vector2.new(0.5, 0.5)
	line.BorderSizePixel = 0
	
	local args = {
		Line = line,
		LineColor = color,
	--	LineOrigin = lineOrigin,
		Destination = part,
	}
	
	table.insert(activeLines, args)
	
	local ancestryChanged = part.AncestryChanged:Once(function()
		removeLine(args, line)
	end)
	
	local functions = {}
	
	function functions:Remove()
		removeLine(args, line)
		ancestryChanged:Disconnect()
	end
	
	return functions
end

function setLine(line, lineColor, origin, destination)
	local position = (origin + destination) / 2
	line.Position = UDim2.new(0, position.X, 0, position.Y)
	line.Size = UDim2.new(0, (origin - destination).Magnitude, 0, 1)
	line.BackgroundColor3 = lineColor
	line.Rotation = math.deg(math.atan2(destination.Y - origin.Y, destination.X - origin.X))
end

camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
	lineOrigin = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y * 0.9)
end)

function updateLines()
	for _, lineTable in activeLines do
		local line:Frame = lineTable.Line
		local lineColor = lineTable.LineColor
		
		local targetPart = lineTable.Destination
		
		local screenPoint, onScreen = camera:WorldToScreenPoint(targetPart.Position)
		
		local destination = Vector2.new(screenPoint.X, screenPoint.Y)
		
		if not onScreen then
			line.Visible = false
		else
			line.Visible = true
		end
		
		setLine(line, lineColor, lineOrigin, destination)
	end
end

RunService.RenderStepped:Connect(updateLines)

return Snapline
