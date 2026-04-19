
-- // Made with love and my fucking half-broken keyboard.
-- // Don't have to be credited, so you can use it if you want, I don't really care lmao.
-- // I don't know the original creator, but I edited the script and optimized it.

-- // Have fun!


local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")


local localPlayer = Players.LocalPlayer


local camera = workspace.CurrentCamera


local gui = Instance.new("ScreenGui", RunService:IsStudio() and localPlayer.PlayerGui or CoreGui)
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


function Snapline:draw(target, color)
	local line = Instance.new("Frame", gui)
	line.Name = "Snapline" .. " / " .. target.Name
	line.AnchorPoint = Vector2.new(0.5, 0.5)
	line.BorderSizePixel = 0

	local circle = Instance.new("Frame", line)
	circle.Size = UDim2.new(0, 5, 0, 5)
	circle.AnchorPoint = Vector2.new(0.5, 0.5)
	circle.Position = UDim2.new(1, 0.5)
	circle.BackgroundColor3 = color

	local corner = Instance.new("UICorner", circle)
	corner.CornerRadius = UDim.new(1, 0)

	local outline = Instance.new("UIStroke", circle)


	local args = {
		Line = line,
		LineColor = color,
		Destination = target,
	}

	table.insert(activeLines, args)

	local ancestryChanged = target.AncestryChanged:Once(function()
		removeLine(args, line)
	end)

	local functions = {}

	function functions:remove()
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
	line.BackgroundTransparency = 0.1
	line.Rotation = math.deg(math.atan2(destination.Y - origin.Y, destination.X - origin.X))
end


camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
	lineOrigin = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y * 0.9)
end)


function updateLines()
	for _, lineTable in activeLines do
		local line:Frame = lineTable.Line
		local lineColor = lineTable.LineColor
		local target = lineTable.Destination

		local destination

		local isModel = target:IsA("Model")
		if isModel then
			target = target:GetPivot()
		end

		local screenPoint, onScreen = camera:WorldToScreenPoint(target.Position)
		destination = Vector2.new(screenPoint.X, screenPoint.Y)

		if not onScreen then
			line.Visible = false
		else
			line.Visible = true
		end

		setLine(line, lineColor, lineOrigin, destination)
	end
end


UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if input.KeyCode == Enum.KeyCode.P then
		gui.Enabled = gui.Enabled == false and true or false
	end
end)


RunService.RenderStepped:Connect(updateLines)


return Snapline
