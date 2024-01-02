--Opensource, Universal Aim Assist by yepimzenon
--Works in all games like Arsenal, Da Hood, Criminality etc.
--You can upload modified versions of this but please keep the credit

--Discord user is yepimzenon, contact me if you have any script requests

--[[     Settings     ]]--
--Change these to your liking

local Config = "Quiet" --Options: Silent, Quiet, Blatant, Really Blatant. (options go from unnoticable to extremely noticable) Set this to blank if you want to change the settings yourself

--Ignore these if you already have a config

local Bind = "x" --The bind to toggle Aim Assist

local IncludeNPCS = true --If you would like to include non-player characters

local IncludeTheDead = false --If you would like to include dead characters

local LockViewCamera = true --If the closest player is in view of the camera, lock on.
local FOVLockView = 150 --The FOV for when the "LockViewCamera" setting is turned on

local Smooth = true --Add smoothness to the locking
local SmoothRate = 10 --Smoothness Speed

local AimAssistRange = 60 --Max Range


--Utils

local function Distance(a : Vector3, b : Vector3)  : number
	return (b-a).Magnitude
end

local function IsNil(a : any) : boolean
	return a == nil
end

local function Equivalent(a : any, b : any) : boolean
	return a == b
end

local function AngleBetween(vectorA, vectorB)
	return math.acos(math.clamp(vectorA:Dot(vectorB), -1, 1))
end

--Configs

if Equivalent(Config, "Really Blatant") then
	LockViewCamera = false
	Smooth = false
	IncludeTheDead = true
	AimAssistRange = math.huge
elseif Equivalent(Config, "Blatant") then
	LockViewCamera = false
	Smooth = false
	IncludeTheDead = false
	AimAssistRange = 300
elseif Equivalent(Config, "Quiet") then
	LockViewCamera = true
	FOVLockView = workspace.CurrentCamera.ViewportSize.Magnitude/4
	print(FOVLockView)
	SmoothRate = 7.5
	Smooth = true
	IncludeTheDead = false
	AimAssistRange = 140
elseif Equivalent(Config, "Silent") then
	LockViewCamera = true
	FOVLockView = 100
	SmoothRate = 4
	Smooth = true
	IncludeTheDead = false
	AimAssistRange = 120
end


--Code

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Human : Humanoid = Character:WaitForChild("Humanoid",5)
local Camera = game:GetService("Workspace").CurrentCamera
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")


local aimAssist = true -- do not change

--Atrocity below

function GetClosestHumanoid() : Humanoid
	local dist = AimAssistRange
	local closestHum : Humanoid = nil
	if IncludeNPCS then

		for i,v in pairs(workspace:GetDescendants()) do
			if v:IsA("Humanoid") and v ~= Human then
				if not IsNil(v.RootPart) then
					if Distance(Character.PrimaryPart.Position, v.RootPart.Position) < dist then
						if IncludeTheDead then
							dist = Distance(Character.PrimaryPart.Position, v.RootPart.Position)
							closestHum = v
						else
							if not Equivalent(v:GetState(), Enum.HumanoidStateType.Dead) and not Equivalent(v.Health, 0) then
								dist = Distance(Character.PrimaryPart.Position, v.RootPart.Position)
								closestHum = v
							end
						end
					end
				end

			end		
		end
	else
		for i,v in pairs(Players:GetPlayers()) do
			if v.Character then
				local PlayerHum = v.Character:FindFirstChildOfClass("Humanoid")

				if not IsNil(PlayerHum) then
					if not IsNil(PlayerHum.RootPart) then
						if IncludeTheDead then
							dist = Distance(Character.PrimaryPart.Position, PlayerHum.RootPart.Position)
							closestHum = PlayerHum
						else
							if not Equivalent(PlayerHum:GetState(), Enum.HumanoidStateType.Dead) and not Equivalent(v.Health, 0) then
								dist = Distance(Character.PrimaryPart.Position, PlayerHum.RootPart.Position)
								closestHum = PlayerHum
							end
						end
					end

				end
			end
		end
	end
	return closestHum
end

--Atrocity above


UIS.InputBegan:Connect(function(input, gp)
	if gp then return end

	if input.KeyCode == Enum.KeyCode.X then
		aimAssist = not aimAssist
	end
end)


RS:BindToRenderStep("AimAssist", Enum.RenderPriority.Camera.Value, function()
	local dt = RS.RenderStepped:Wait()
	if aimAssist then
		if not LockViewCamera then
			local closestHum = GetClosestHumanoid()

			if not IsNil(closestHum) then
				if not IsNil(closestHum.RootPart) then
					if Equivalent(Smooth, false) then
						Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, closestHum.RootPart.Position + Vector3.yAxis * 0.5)
					else
						Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, closestHum.RootPart.Position + Vector3.yAxis * 0.5), dt * SmoothRate)
					end
					
				end

			end
		else
			local closestHum = GetClosestHumanoid()
			


			if not IsNil(closestHum) then
				if not IsNil(closestHum.RootPart) then
					local nuhuh, OnScreen = Camera:WorldToScreenPoint(closestHum.RootPart.Position + Vector3.yAxis * 0.5)
					
					local center = Camera.ViewportSize/2
					
					local vector2 = Vector2.new(nuhuh.X, nuhuh.Y)
					
					if OnScreen and Distance(vector2, center) < FOVLockView then
						if Equivalent(Smooth, false) then
							Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, closestHum.RootPart.Position + Vector3.yAxis * 0.5)
						else
							Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, closestHum.RootPart.Position + Vector3.yAxis * 0.5), dt * SmoothRate)
						end
						
					end
					
				end

			end
		end

	end
end)
