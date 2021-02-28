
if not DeclaredHelicopterGVars then
	DeclaredHelicopterGVars=true
	HelicopterMOD=false
	HelicopterUnit=nil
	HelicopterUnitName=""
	Speedmeter=nil
	IsInHelicopter=true
	EnterPressed=false
	MoveSpeed=0.0
	AngleZ=0.0
end

if Utils:IsInCustody() then
	if Speedmeter then
		Overlay:gui():destroy_workspace(Speedmeter.WorkSpace)
		Speedmeter=nil
	end
	World.delete_unit(World,HelicopterUnit)
	HelicopterMOD=false
end

if HelicopterMOD and not Utils:IsInCustody() and managers.player:player_unit() then
	
	local CanSpeedUp=false
	local CanSpeedDown=false
	local CanMoveLinear=false
	local NewPosition=nil
	local NewRotation=nil
	local AddAngleX=0.0
	local HorizontalOffset=Vector3(0.0,0.0,0.0)
	local VerticalOffset=Vector3(0.0,0.0,0.0)
	local MoveOffset=Vector3(0.0,0.0,0.0)
	
	if Input:keyboard().down(Input:keyboard(),Idstring("right ctrl")) then
		if not EnterPressed then
			if IsInHelicopter then
				IsInHelicopter=false
			else
				IsInHelicopter=true
				managers.player:warp_to(managers.player:player_unit():position(),HelicopterUnit:rotation())
			end
		end
		EnterPressed=true
	else
		EnterPressed=false
	end
	
	if IsInHelicopter then
		if not Speedmeter then
			Speedmeter={}
			Speedmeter.WorkSpace=Overlay:newgui():create_screen_workspace()
			Speedmeter.Label=Speedmeter.WorkSpace:panel():text{
				name="lbl_speed",
				x=RenderSettings.resolution.x*0.89583,
				y=RenderSettings.resolution.y*0.68518,
				text="",
				font=tweak_data.menu.pd2_large_font,
				font_size=RenderSettings.resolution.x*0.03125,
				color=Color.white,
				layer=2000
			}
		end
		Speedmeter.Label:set_text(tostring(math.floor(1.5*MoveSpeed+0.5)).." km/h")
		
		if Input:keyboard().down(Input:keyboard(),Idstring("w")) then
			if MoveSpeed>0.0 then CanMoveLinear=true end
			CanSpeedUp=true
		else
			CanSpeedUp=false
		end
		if Input:keyboard().down(Input:keyboard(),Idstring("s")) then
			if MoveSpeed<0.0 then CanMoveLinear=true end
			CanSpeedDown=true
		else
			CanSpeedDown=false
		end
		
		if CanSpeedUp and MoveSpeed<=50.0 then
			if MoveSpeed<0.0 then
				MoveSpeed=MoveSpeed+0.15
			else
				MoveSpeed=MoveSpeed+0.2
			end
		elseif MoveSpeed>0.0 and not CanSpeedUp then
			CanMoveLinear=true
			MoveSpeed=math.max(MoveSpeed-0.01,0.0)
		end
		if CanSpeedDown and MoveSpeed>=-40.0 then
			if MoveSpeed>0.0 then
				MoveSpeed=MoveSpeed-0.15
			else
				MoveSpeed=MoveSpeed-0.2
			end
		elseif MoveSpeed<0.0 and not CanSpeedDown then
			CanMoveLinear=true
			MoveSpeed=math.min(MoveSpeed+0.01,0.0)
		end

		if Input:keyboard().down(Input:keyboard(),Idstring("a")) then
			if AngleZ>=-10.0 and math.abs(MoveSpeed)>20.0 then AngleZ=AngleZ-0.15 end
			AddAngleX=1.0
		elseif AngleZ<=0.0 then
			AngleZ=AngleZ+0.15
		end
		if Input:keyboard().down(Input:keyboard(),Idstring("d")) then
			if AngleZ<=10.0 and math.abs(MoveSpeed)>20.0 then AngleZ=AngleZ+0.15 end
			AddAngleX=-1.0
		elseif AngleZ>=0.0 then
			AngleZ=AngleZ-0.15
		end
		
		if Input:keyboard().down(Input:keyboard(),Idstring("space")) then VerticalOffset=Vector3(0.0,0.0,6.75) end
		if Input:keyboard().down(Input:keyboard(),Idstring("left shift")) then VerticalOffset=Vector3(0.0,0.0,-6.75) end

		if CanMoveLinear then
			MoveOffset=Vector3(math.sin(HelicopterUnit:rotation():yaw())*MoveSpeed,math.cos(HelicopterUnit:rotation():yaw())*-MoveSpeed,0.0)
			HorizontalOffset=HorizontalOffset+MoveOffset
		end
		
		local pos=HelicopterUnit:position()-MoveOffset+VerticalOffset
		local rot=Rotation(HelicopterUnit:rotation():yaw()+AddAngleX,MoveSpeed/-3.0,AngleZ)
		World.delete_unit(World,HelicopterUnit)
		local new=World.spawn_unit(World,Idstring(HelicopterUnitName),pos,rot)
		HelicopterUnit=new
		
		if managers.player:player_unit() then managers.player:warp_to(HelicopterUnit:get_object(Idstring("g_glass")):position()+Vector3((75.0-AddAngleX*10.0)*math.cos(HelicopterUnit:rotation():yaw()-20.0),(75.0-AddAngleX*10.0)*math.sin(HelicopterUnit:rotation():yaw()-20.0),-100.0-AngleZ*2.0)-HorizontalOffset+VerticalOffset,Rotation(managers.player:player_unit():camera():rotation():yaw()+AddAngleX,managers.player:player_unit():camera():rotation():pitch(),0.0)) end
	elseif Speedmeter then
		Overlay:gui():destroy_workspace(Speedmeter.WorkSpace)

		local pos=HelicopterUnit:position()
		local rot=Rotation(HelicopterUnit:rotation():yaw()+AddAngleX,0.0,0.0)
		World.delete_unit(World,HelicopterUnit)
		local new=World.spawn_unit(World,Idstring(HelicopterUnitName),pos,rot)
		HelicopterUnit=new
		
		MoveSpeed=0.0
		AngleZ=0.0
		Speedmeter=nil
	end

	if Input:keyboard().down(Input:keyboard(),Idstring("left ctrl")) then
		if Speedmeter then
			Overlay:gui():destroy_workspace(Speedmeter.WorkSpace)
			Speedmeter=nil
		end
		World.delete_unit(World,HelicopterUnit)
		HelicopterMOD=false
	end
end
