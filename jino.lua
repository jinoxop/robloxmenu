--// ═══════════════════════════════════════════════════════════
--//  JIN OXX ADMIN PANEL v5.0 (Compact Dark Purple)
--//  Aimbot (mousemoverel) · Fly/Noclip/InfJump · ESP (Black-Purple)
--//  Player TP/Fling · Anti-Fling · Tool loaders · Lucide icons
--//  Toggle panel: Click "-" to minimize, click the floating square to restore
--// ═══════════════════════════════════════════════════════════

if game:GetService("CoreGui"):FindFirstChild("JinoxxAdmin") then game:GetService("CoreGui").JinoxxAdmin:Destroy() end
if _G.JinoxxAdminConns then for _,c in pairs(_G.JinoxxAdminConns) do pcall(function() c:Disconnect() end) end end
if _G.JinoxxESP then for _,o in pairs(_G.JinoxxESP) do for _,d in pairs(o) do pcall(function() d:Remove() end) end end end
_G.JinoxxAdminConns={} _G.JinoxxESP={}
local Players=game:GetService("Players") local RunService=game:GetService("RunService") local UIS=game:GetService("UserInputService") local GuiService=game:GetService("GuiService") local Workspace=game:GetService("Workspace") local TweenService=game:GetService("TweenService") local TeleportService=game:GetService("TeleportService") local LP=Players.LocalPlayer
local mouseMove=rawget(getgenv and getgenv() or _G,"mousemoverel") or mousemoverel or mouse_move_relative
local HAS_MOUSEMOVE=typeof(mouseMove)=="function"
local HAS_DRAW=pcall(function() local d=Drawing.new("Line") d:Remove() end)
local State={FlySpeed=50,WalkSpeed=16,JumpPower=50,Flying=false,Noclip=false,InfJump=false,Aimbot=false,AimHold=true,AimFov=120,AimSmooth=5,AimPart="Head",AimTeamCheck=false,AimAliveCheck=true,ESP=false,ESPBoxes=true,ESPNames=true,ESPTracers=false,ESPHealth=true,ESPTeam=false,AntiFling=false,Fling=false}
local function getChar() return LP.Character or LP.CharacterAdded:Wait() end
local function getHum() local c=getChar() return c:FindFirstChildOfClass("Humanoid") end
local function getRoot() local c=getChar() return c:FindFirstChild("HumanoidRootPart") end
local function conn(sig,fn) local c=sig:Connect(fn) table.insert(_G.JinoxxAdminConns,c) return c end
local LUCIDE pcall(function() LUCIDE=loadstring(game:HttpGet("https://raw.githubusercontent.com/latte-soft/lucide-roblox/master/lib/Icons.luau"))() end)
local function lucide(parent,name,size,color) local img=Instance.new("ImageLabel") img.BackgroundTransparency=1 img.Size=UDim2.fromOffset(size,size) img.ImageColor3=color local set=LUCIDE and LUCIDE["48px"] and LUCIDE["48px"][name] if set then img.Image="rbxassetid://"..set[1] img.ImageRectSize=Vector2.new(set[2][1],set[2][2]) img.ImageRectOffset=Vector2.new(set[3][1],set[3][2]) end img.Parent=parent return img end
conn(RunService.Stepped,function() if State.Noclip then local c=LP.Character if c then for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") and p.CanCollide then p.CanCollide=false end end end end end)
local flyBV,flyBG
local function startFly() local root=getRoot() if not root then return end State.Flying=true flyBV=Instance.new("BodyVelocity") flyBV.MaxForce=Vector3.new(1,1,1)*math.huge flyBV.Velocity=Vector3.zero flyBV.Parent=root flyBG=Instance.new("BodyGyro") flyBG.MaxForce=Vector3.new(1,1,1)*math.huge flyBG.P=9e4 flyBG.CFrame=root.CFrame flyBG.Parent=root local h=getHum() if h then h.PlatformStand=true end end
local function stopFly() State.Flying=false if flyBV then flyBV:Destroy() flyBV=nil end if flyBG then flyBG:Destroy() flyBG=nil end local h=getHum() if h then h.PlatformStand=false end end
conn(RunService.RenderStepped,function() if State.Flying and flyBV and flyBG then local cam=Workspace.CurrentCamera local root=getRoot() if not(cam and root) then return end local dir=Vector3.zero if UIS:IsKeyDown(Enum.KeyCode.W) then dir+=cam.CFrame.LookVector end if UIS:IsKeyDown(Enum.KeyCode.S) then dir-=cam.CFrame.LookVector end if UIS:IsKeyDown(Enum.KeyCode.A) then dir-=cam.CFrame.RightVector end if UIS:IsKeyDown(Enum.KeyCode.D) then dir+=cam.CFrame.RightVector end if UIS:IsKeyDown(Enum.KeyCode.Space) then dir+=Vector3.new(0,1,0) end if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir-=Vector3.new(0,1,0) end flyBV.Velocity=(dir.Magnitude>0 and dir.Unit*State.FlySpeed or Vector3.zero) flyBG.CFrame=cam.CFrame end end)
conn(UIS.JumpRequest,function() if State.InfJump then local h=getHum() if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end end)
local function getTarget() local cam=Workspace.CurrentCamera local best,bestDist=nil,State.AimFov local inset=GuiService:GetGuiInset() local mpos=UIS:GetMouseLocation() for _,plr in ipairs(Players:GetPlayers()) do if plr~=LP and plr.Character then if State.AimTeamCheck and plr.Team==LP.Team then continue end local part=plr.Character:FindFirstChild(State.AimPart) local hum=plr.Character:FindFirstChildOfClass("Humanoid") if part and hum and (not State.AimAliveCheck or hum.Health>0) then local sp,on=cam:WorldToViewportPoint(part.Position) if on then local scr=Vector2.new(sp.X+inset.X,sp.Y+inset.Y) local d=(scr-mpos).Magnitude if d<bestDist then bestDist=d best=part end end end end end return best end
conn(RunService.RenderStepped,function() if not(State.Aimbot and HAS_MOUSEMOVE) then return end local aiming=(not State.AimHold) or UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) if not aiming then return end local target=getTarget() if not target then return end local cam=Workspace.CurrentCamera local inset=GuiService:GetGuiInset() local sp=cam:WorldToViewportPoint(target.Position) local scr=Vector2.new(sp.X+inset.X,sp.Y+inset.Y) local mpos=UIS:GetMouseLocation() local d=scr-mpos local sm=math.max(State.AimSmooth,1) pcall(mouseMove,d.X/sm,d.Y/sm) end)
conn(LP.CharacterAdded,function() task.wait(0.2) local h=getHum() if h then h.WalkSpeed=State.WalkSpeed h.UseJumpPower=true h.JumpPower=State.JumpPower end if State.Flying then stopFly() startFly() end end)
conn(RunService.Stepped,function() if State.AntiFling then local root=getRoot() if root then if root.AssemblyAngularVelocity.Magnitude>40 then root.AssemblyAngularVelocity=Vector3.zero end if not State.Flying and not State.Fling and root.AssemblyLinearVelocity.Magnitude>160 then root.AssemblyLinearVelocity=root.AssemblyLinearVelocity.Unit*100 end end end end)
local flingConn
local function startFling() State.Fling=true flingConn=RunService.Heartbeat:Connect(function() local root=getRoot() if root then root.AssemblyAngularVelocity=Vector3.new(1,1,1)*95000 end end) end
local function stopFling() State.Fling=false if flingConn then flingConn:Disconnect() flingConn=nil end local root=getRoot() if root then root.AssemblyAngularVelocity=Vector3.zero end end
local function tpTo(plr) local tc=plr.Character local troot=tc and tc:FindFirstChild("HumanoidRootPart") local root=getRoot() if troot and root then root.CFrame=troot.CFrame*CFrame.new(0,0,3) end end
local function flingPlayer(plr) local tc=plr.Character local troot=tc and tc:FindFirstChild("HumanoidRootPart") local root=getRoot() local hum=getHum() if not(troot and root) then return end local old=root.CFrame local oldAR=hum and hum.AutoRotate if hum then hum.AutoRotate=false end task.spawn(function() for i=1,16 do local r=getRoot() if not r then break end r.CFrame=troot.CFrame r.AssemblyLinearVelocity=Vector3.new(10000,10000,10000) RunService.Heartbeat:Wait() end local r=getRoot() if r then r.AssemblyLinearVelocity=Vector3.zero r.CFrame=old end if hum then hum.AutoRotate=oldAR end end) end
local function newDraw(t,props) local d=Drawing.new(t) for k,v in pairs(props) do d[k]=v end return d end
local function getESP(plr) if _G.JinoxxESP[plr] then return _G.JinoxxESP[plr] end local o={} if HAS_DRAW then o.out=newDraw("Square",{Thickness=3,Filled=false,Color=Color3.new(0,0,0),Transparency=0.6}) 
    -- ** CHANGED: BLACK-PURPLE ESP COLOR **
    o.box=newDraw("Square",{Thickness=1,Filled=false,Color=Color3.fromRGB(40, 10, 60)}) 
    o.name=newDraw("Text",{Size=13,Center=true,Outline=true,Color=Color3.fromRGB(200, 150, 255),Font=2})
    o.dist=newDraw("Text",{Size=12,Center=true,Outline=true,Color=Color3.fromRGB(150, 100, 180),Font=2}) 
    o.tracer=newDraw("Line",{Thickness=1,Color=Color3.fromRGB(50, 15, 75)})
    o.hpbg=newDraw("Square",{Thickness=1,Filled=true,Color=Color3.new(0,0,0),Transparency=0.6}) 
    o.hp=newDraw("Square",{Thickness=1,Filled=true,Color=Color3.fromRGB(80,220,120)}) end _G.JinoxxESP[plr]=o return o end
local function hideESP(o) for _,d in pairs(o) do d.Visible=false end end
local function removeESP(plr) local o=_G.JinoxxESP[plr] if o then for _,d in pairs(o) do pcall(function() d:Remove() end) end _G.JinoxxESP[plr]=nil end end
if HAS_DRAW then conn(RunService.RenderStepped,function() local cam=Workspace.CurrentCamera if not cam then return end for _,plr in ipairs(Players:GetPlayers()) do if plr~=LP then local o=getESP(plr) local char=plr.Character local hum=char and char:FindFirstChildOfClass("Humanoid") local root=char and char:FindFirstChild("HumanoidRootPart") local head=char and (char:FindFirstChild("Head") or root) if State.ESP and root and hum and head and hum.Health>0 and not(State.ESPTeam and plr.Team==LP.Team) then local tp,on=cam:WorldToViewportPoint(head.Position+Vector3.new(0,0.6,0)) local bp=cam:WorldToViewportPoint(root.Position-Vector3.new(0,3.2,0)) if on then local h=math.abs(bp.Y-tp.Y) local w=h*0.5 local x=tp.X-w/2 local y=tp.Y local col=(State.ESPTeam==false and plr.Team==LP.Team) and Color3.fromRGB(40, 10, 60) or Color3.fromRGB(40, 10, 60) o.box.Visible=State.ESPBoxes o.out.Visible=State.ESPBoxes o.box.Color=col o.box.Size=Vector2.new(w,h) o.box.Position=Vector2.new(x,y) o.out.Size=Vector2.new(w,h) o.out.Position=Vector2.new(x,y) o.name.Visible=State.ESPNames o.name.Text=plr.DisplayName o.name.Position=Vector2.new(tp.X,y-16) local dist=math.floor((cam.CFrame.Position-root.Position).Magnitude) o.dist.Visible=State.ESPNames o.dist.Text=dist.."m" o.dist.Position=Vector2.new(tp.X,y+h+2) o.tracer.Visible=State.ESPTracers o.tracer.From=Vector2.new(cam.ViewportSize.X/2,cam.ViewportSize.Y) o.tracer.To=Vector2.new(tp.X,y+h) if State.ESPHealth then local r=math.clamp(hum.Health/math.max(hum.MaxHealth,1),0,1) o.hpbg.Visible=true o.hp.Visible=true o.hpbg.Size=Vector2.new(3,h) o.hpbg.Position=Vector2.new(x-6,y) o.hp.Size=Vector2.new(3,h*r) o.hp.Position=Vector2.new(x-6,y+h*(1-r)) o.hp.Color=Color3.fromRGB(math.floor(255*(1-r)),math.floor(220*r+35),80) else o.hpbg.Visible=false o.hp.Visible=false end else hideESP(o) end else hideESP(o) end end end end) end
conn(Players.PlayerRemoving,function(plr) removeESP(plr) end)
local function loadTool(name,url) local ok,err=pcall(function() loadstring(game:HttpGet(url))() end) if ok then print("[Jinoxx] Loaded "..name) else warn("[Jinoxx] Failed "..name..": "..tostring(err)) end end

-- ** NEW COLOR PALETTE (DARK PURPLE - VERY DARK) **
local C={
    bg=Color3.fromRGB(8, 5, 12),          -- خلفية الشاشة الرئيسية (أسود بنفسجي)
    header=Color3.fromRGB(12, 8, 18),     -- رأس القائمة (داكن جداً)
    colbg=Color3.fromRGB(18, 12, 25),     -- خلفية الأعمدة
    border=Color3.fromRGB(35, 25, 45),    -- لون الحدود (بنفسجي معتم)
    hover=Color3.fromRGB(30, 20, 40),     -- عند التمرير
    text=Color3.fromRGB(230, 230, 235),   -- لون النص الرئيسي
    dim=Color3.fromRGB(160, 150, 170),    -- نص خافت
    faint=Color3.fromRGB(90, 75, 105),    -- نص باهت جداً
    blue=Color3.fromRGB(130, 50, 200),    -- لون الأزرار/الشرائح (بنفسجي ساطع)
    red=Color3.fromRGB(220, 80, 90),
    trackOff=Color3.fromRGB(35, 25, 45),
    pill=Color3.fromRGB(25, 18, 32),
    pillBrd=Color3.fromRGB(45, 35, 55),
    knob=Color3.fromRGB(240, 240, 245)
}
local FONT=Enum.Font.Gotham local FONTM=Enum.Font.GothamMedium local FONTB=Enum.Font.GothamBold
-- ** COMPACT WIDTH FOR PANEL **
local COLW=170
local gui=Instance.new("ScreenGui") gui.Name="JinoxxAdmin" gui.ResetOnSpawn=false gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling gui.IgnoreGuiInset=true gui.Parent=game:GetService("CoreGui")
local function corner(p,r) local u=Instance.new("UICorner") u.CornerRadius=UDim.new(0,r or 6) u.Parent=p return u end
local function strokeOf(p,col,t) local s=Instance.new("UIStroke") s.Color=col or C.border s.Thickness=1 s.Transparency=t or 0 s.Parent=p return s end
local WIN_W=COLW*4+6*3+16
local main=Instance.new("Frame") 
main.Size=UDim2.new(1, -20, 0, 0) -- يأخذ عرض الشاشة مع ترك مسافة صغيرة
main.Position=UDim2.new(0.5, 0, 0.05, 0) 
main.AnchorPoint=Vector2.new(0.5,0)
main.AutomaticSize=Enum.AutomaticSize.Y 
main.BackgroundColor3=C.bg main.BorderSizePixel=0 main.Active=true main.Draggable=true main.ClipsDescendants=false main.Parent=gui 
corner(main,12) strokeOf(main,C.border,0)
local shadow=Instance.new("ImageLabel") shadow.BackgroundTransparency=1 shadow.Image="rbxassetid://6014261993" shadow.ImageColor3=Color3.new(0,0,0) shadow.ImageTransparency=0.5 shadow.ScaleType=Enum.ScaleType.Slice shadow.SliceCenter=Rect.new(49,49,450,450) shadow.Size=UDim2.new(1,50,1,50) shadow.Position=UDim2.fromOffset(-25,-25) shadow.ZIndex=0 shadow.Parent=main
local header=Instance.new("Frame") header.Size=UDim2.new(1,0,0,44) header.BackgroundColor3=C.header header.BorderSizePixel=0 header.Parent=main corner(header,12)
local hfix=Instance.new("Frame") hfix.Size=UDim2.new(1,0,0,14) hfix.Position=UDim2.new(0,0,1,-14) hfix.BackgroundColor3=C.header hfix.BorderSizePixel=0 hfix.Parent=header
local hLine=Instance.new("Frame") hLine.Size=UDim2.new(1,0,0,1) hLine.Position=UDim2.new(0,0,1,0) hLine.BackgroundColor3=C.border hLine.BorderSizePixel=0 hLine.Parent=header
local hIcon=lucide(header,"zap",14,C.blue) hIcon.Position=UDim2.fromOffset(14,15)
local tlabel=Instance.new("TextLabel") tlabel.Size=UDim2.new(0.5,0,1,0) tlabel.Position=UDim2.fromOffset(34,0) tlabel.BackgroundTransparency=1 tlabel.Font=FONTB tlabel.Text="Jinoxx Admin" tlabel.TextColor3=C.text tlabel.TextSize=14 tlabel.TextXAlignment=Enum.TextXAlignment.Left tlabel.Parent=header
local function hdrBtn(txt,xoff) local b=Instance.new("TextButton") b.Size=UDim2.fromOffset(28,28) b.Position=UDim2.new(1,xoff,0.5,-14) b.BackgroundColor3=C.hover b.BackgroundTransparency=1 b.Text=txt b.Font=FONTB b.TextSize=15 b.TextColor3=C.dim b.AutoButtonColor=false b.Parent=header corner(b,7) b.MouseEnter:Connect(function() b.BackgroundTransparency=0 b.TextColor3=C.text end) b.MouseLeave:Connect(function() b.BackgroundTransparency=1 b.TextColor3=C.dim end) return b end
local closeBtn=hdrBtn("✕",-38) local minBtn=hdrBtn("—",-72)

-- ** FLOATING SQUARE BUTTON (APPEARS WHEN MINIMIZED) **
local miniIcon = Instance.new("TextButton")
miniIcon.Size = UDim2.new(0, 45, 0, 45)
miniIcon.Position = UDim2.new(1, -55, 0, 15)
miniIcon.AnchorPoint = Vector2.new(1, 0)
miniIcon.BackgroundColor3 = C.header
miniIcon.Text = "☰"
miniIcon.TextColor3 = Color3.fromRGB(130, 50, 200)
miniIcon.Font = Enum.Font.GothamBold
miniIcon.TextSize = 22
miniIcon.Visible = false -- يظهر فقط عند التصغير
miniIcon.Parent = gui
corner(miniIcon, 10)
strokeOf(miniIcon, C.border)

local body=Instance.new("Frame") body.Size=UDim2.new(1,0,0,0) body.AutomaticSize=Enum.AutomaticSize.Y body.Position=UDim2.fromOffset(0,44) body.BackgroundTransparency=1 body.Parent=main
local bpad=Instance.new("UIPadding") bpad.PaddingTop=UDim.new(0,10) bpad.PaddingBottom=UDim.new(0,10) bpad.PaddingLeft=UDim.new(0,6) bpad.PaddingRight=UDim.new(0,6) bpad.Parent=body
local rowL=Instance.new("UIListLayout") rowL.FillDirection=Enum.FillDirection.Horizontal rowL.Padding=UDim.new(0,6) rowL.SortOrder=Enum.SortOrder.LayoutOrder rowL.VerticalAlignment=Enum.VerticalAlignment.Top rowL.Parent=body
local function column(order) local col=Instance.new("Frame") col.Size=UDim2.fromOffset(COLW,0) col.AutomaticSize=Enum.AutomaticSize.Y col.BackgroundColor3=C.colbg col.BorderSizePixel=0 col.LayoutOrder=order col.Parent=body corner(col,8) strokeOf(col,C.border,0.25) local p=Instance.new("UIPadding") p.PaddingTop=UDim.new(0,6) p.PaddingBottom=UDim.new(0,8) p.PaddingLeft=UDim.new(0,6) p.PaddingRight=UDim.new(0,6) p.Parent=col local l=Instance.new("UIListLayout") l.Padding=UDim.new(0,2) l.SortOrder=Enum.SortOrder.LayoutOrder l.Parent=col return col end
local function section(parent,name,iconName,first) local w=Instance.new("Frame") w.Size=UDim2.new(1,0,0,first and 18 or 28) w.BackgroundTransparency=1 w.Parent=parent local xo=4 if iconName then local ic=lucide(w,iconName,12,C.faint) ic.Position=UDim2.new(0,3,1,-15) xo=20 end local l=Instance.new("TextLabel") l.Size=UDim2.new(1,-xo,0,12) l.Position=UDim2.new(0,xo,1,-14) l.BackgroundTransparency=1 l.Font=FONTB l.Text=string.upper(name) l.TextColor3=C.faint l.TextSize=10 l.TextXAlignment=Enum.TextXAlignment.Left l.Parent=w end
local function rowbase(parent,t,h) local f=Instance.new("Frame") f.Size=UDim2.new(1,0,0,h or 32) f.BackgroundColor3=C.hover f.BackgroundTransparency=1 f.BorderSizePixel=0 f.Parent=parent corner(f,6) f.MouseEnter:Connect(function() TweenService:Create(f,TweenInfo.new(0.12),{BackgroundTransparency=0}):Play() end) f.MouseLeave:Connect(function() TweenService:Create(f,TweenInfo.new(0.12),{BackgroundTransparency=1}):Play() end) local lbl=Instance.new("TextLabel") lbl.Size=UDim2.new(1,-48,1,0) lbl.Position=UDim2.fromOffset(8,0) lbl.BackgroundTransparency=1 lbl.Font=FONTM lbl.Text=t lbl.TextColor3=C.text lbl.TextSize=12 lbl.TextXAlignment=Enum.TextXAlignment.Left lbl.TextTruncate=Enum.TextTruncate.AtEnd lbl.Parent=f return f,lbl end
local function toggle(parent,name,default,cb) local f=rowbase(parent,name,32) local sw=Instance.new("TextButton") sw.Size=UDim2.fromOffset(34,20) sw.Position=UDim2.new(1,-40,0.5,-10) sw.BackgroundColor3=default and C.blue or C.trackOff sw.Text="" sw.AutoButtonColor=false sw.Parent=f corner(sw,10) local knob=Instance.new("Frame") knob.Size=UDim2.fromOffset(16,16) knob.Position=default and UDim2.new(1,-17,0.5,-8) or UDim2.new(0,2,0.5,-8) knob.BackgroundColor3=C.knob knob.BorderSizePixel=0 knob.Parent=sw corner(knob,8) local st=default sw.MouseButton1Click:Connect(function() st=not st TweenService:Create(sw,TweenInfo.new(0.15),{BackgroundColor3=st and C.blue or C.trackOff}):Play() TweenService:Create(knob,TweenInfo.new(0.15,Enum.EasingStyle.Quad),{Position=st and UDim2.new(1,-17,0.5,-8) or UDim2.new(0,2,0.5,-8)}):Play() cb(st) end) end
local function slider(parent,name,min,max,default,cb) local f=rowbase(parent,"",42) local lbl=f:FindFirstChildOfClass("TextLabel") lbl.Size=UDim2.new(1,-20,0,18) lbl.Position=UDim2.fromOffset(8,5) lbl.TextColor3=C.dim lbl.Text=name local val=Instance.new("TextLabel") val.Size=UDim2.fromOffset(45,18) val.Position=UDim2.new(1,-52,0,5) val.BackgroundTransparency=1 val.Font=FONTB val.Text=tostring(default) val.TextColor3=C.text val.TextSize=12 val.TextXAlignment=Enum.TextXAlignment.Right val.Parent=f local bar=Instance.new("Frame") bar.Size=UDim2.new(1,-20,0,4) bar.Position=UDim2.fromOffset(8,28) bar.BackgroundColor3=C.trackOff bar.BorderSizePixel=0 bar.Parent=f corner(bar,2) local fill=Instance.new("Frame") fill.Size=UDim2.new((default-min)/(max-min),0,1,0) fill.BackgroundColor3=C.blue fill.BorderSizePixel=0 fill.Parent=bar corner(fill,2) local knob=Instance.new("Frame") knob.Size=UDim2.fromOffset(12,12) knob.AnchorPoint=Vector2.new(0.5,0.5) knob.Position=UDim2.new((default-min)/(max-min),0,0.5,0) knob.BackgroundColor3=C.knob knob.BorderSizePixel=0 knob.Parent=bar corner(knob,6) local drag=false local function setX(x) local rel=math.clamp((x-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1) local v=math.floor(min+(max-min)*rel+0.5) fill.Size=UDim2.new(rel,0,1,0) knob.Position=UDim2.new(rel,0,0.5,0) val.Text=tostring(v) cb(v) end bar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=true setX(i.Position.X) end end) knob.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=true end end) conn(UIS.InputEnded,function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end end) conn(UIS.InputChanged,function(i) if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then setX(i.Position.X) end end) end
local function pill(parent,name,iconName,cb) local b=Instance.new("TextButton") b.Size=UDim2.new(1,0,0,32) b.BackgroundColor3=C.pill b.Text="" b.AutoButtonColor=false b.Parent=parent corner(b,6) strokeOf(b,C.pillBrd,0) if iconName then local ic=lucide(b,iconName,12,C.dim) ic.Position=UDim2.new(0,12,0.5,-6) end local l=Instance.new("TextLabel") l.Size=UDim2.new(1,-40,1,0) l.Position=UDim2.fromOffset(iconName and 30 or 12,0) l.BackgroundTransparency=1 l.Font=FONTM l.Text=name l.TextColor3=C.text l.TextSize=12 l.TextXAlignment=Enum.TextXAlignment.Left l.Parent=b b.MouseEnter:Connect(function() TweenService:Create(b,TweenInfo.new(0.12),{BackgroundColor3=C.hover}):Play() end) b.MouseLeave:Connect(function() TweenService:Create(b,TweenInfo.new(0.12),{BackgroundColor3=C.pill}):Play() end) b.MouseButton1Click:Connect(cb) end

-- COLUMN 1
local c1=column(1)
section(c1,"Aimbot"..(HAS_MOUSEMOVE and "" or " ⚠"),"crosshair",true)
toggle(c1,"Aimbot enabled",false,function(o) State.Aimbot=o end)
toggle(c1,"Hold RMB to aim",true,function(o) State.AimHold=o end)
toggle(c1,"Target head",true,function(o) State.AimPart=o and "Head" or "HumanoidRootPart" end)
toggle(c1,"Team check",false,function(o) State.AimTeamCheck=o end)
slider(c1,"Aim FOV",20,500,State.AimFov,function(v) State.AimFov=v end)
slider(c1,"Smoothness",1,30,State.AimSmooth,function(v) State.AimSmooth=v end)
section(c1,"Camera","camera")
slider(c1,"Field of view",30,120,70,function(v) Workspace.CurrentCamera.FieldOfView=v end)

-- COLUMN 2
local c2=column(2)
section(c2,"Movement","move",true)
toggle(c2,"Fly",false,function(o) if o then startFly() else stopFly() end end)
toggle(c2,"Noclip",false,function(o) State.Noclip=o if not o then local c=LP.Character if c then for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then p.CanCollide=true end end end end end)
toggle(c2,"Infinite jump",false,function(o) State.InfJump=o end)
slider(c2,"Fly speed",10,300,State.FlySpeed,function(v) State.FlySpeed=v end)
slider(c2,"Walk speed",16,500,State.WalkSpeed,function(v) State.WalkSpeed=v local h=getHum() if h then h.WalkSpeed=v end end)
slider(c2,"Jump power",50,500,State.JumpPower,function(v) State.JumpPower=v local h=getHum() if h then h.UseJumpPower=true h.JumpPower=v end end)
section(c2,"Combat","swords")
toggle(c2,"Anti-fling",false,function(o) State.AntiFling=o end)
toggle(c2,"Fling (spin)",false,function(o) if o then startFling() else stopFling() end end)

-- COLUMN 3
local c3=column(3)
section(c3,"Visuals"..(HAS_DRAW and "" or " ⚠"),"eye",true)
toggle(c3,"ESP enabled",false,function(o) State.ESP=o end)
toggle(c3,"Boxes",true,function(o) State.ESPBoxes=o end)
toggle(c3,"Names + distance",true,function(o) State.ESPNames=o end)
toggle(c3,"Tracers",false,function(o) State.ESPTracers=o end)
toggle(c3,"Health bars",true,function(o) State.ESPHealth=o end)
toggle(c3,"Team check",false,function(o) State.ESPTeam=o end)
section(c3,"Tools","wrench")
pill(c3,"Infinite Yield","terminal",function() loadTool("Infinite Yield","https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source") end)
pill(c3,"Dex Explorer","folder-tree",function() loadTool("Dex","https://raw.githubusercontent.com/infyiff/backup/main/dex.lua") end)
pill(c3,"Simple Spy","radar",function() loadTool("SimpleSpy","https://raw.githubusercontent.com/78n/SimpleSpy/main/SimpleSpySource.lua") end)
pill(c3,"Hydroxide","bug",function() loadTool("Hydroxide","https://raw.githubusercontent.com/Upbolt/Hydroxide/revision/init.lua") end)

-- COLUMN 4
local c4=column(4)
section(c4,"Players","users",true)
local plistWrap=Instance.new("Frame") plistWrap.Size=UDim2.new(1,0,0,180) plistWrap.BackgroundColor3=C.bg plistWrap.BackgroundTransparency=0.4 plistWrap.BorderSizePixel=0 plistWrap.Parent=c4 corner(plistWrap,6)
local plist=Instance.new("ScrollingFrame") plist.Size=UDim2.new(1,-4,1,-4) plist.Position=UDim2.fromOffset(2,2) plist.BackgroundTransparency=1 plist.BorderSizePixel=0 plist.ScrollBarThickness=3 plist.ScrollBarImageColor3=C.border plist.CanvasSize=UDim2.new() plist.AutomaticCanvasSize=Enum.AutomaticSize.Y plist.Parent=plistWrap
local pl=Instance.new("UIListLayout") pl.Padding=UDim.new(0,2) pl.SortOrder=Enum.SortOrder.Name pl.Parent=plist
local pp=Instance.new("UIPadding") pp.PaddingTop=UDim.new(0,2) pp.PaddingLeft=UDim.new(0,2) pp.PaddingRight=UDim.new(0,2) pp.Parent=plist
local function miniBtn(parent,txt,xoff,cb,col) local b=Instance.new("TextButton") b.Size=UDim2.fromOffset(30,24) b.Position=UDim2.new(1,xoff,0.5,-12) b.BackgroundColor3=col or C.pill b.Text=txt b.Font=FONTM b.TextSize=10 b.TextColor3=C.text b.AutoButtonColor=true b.Parent=parent corner(b,5) strokeOf(b,C.pillBrd,0.3) b.MouseButton1Click:Connect(cb) return b end
local function refreshPlayers() for _,ch in ipairs(plist:GetChildren()) do if ch:IsA("Frame") then ch:Destroy() end end for _,plr in ipairs(Players:GetPlayers()) do if plr~=LP then local f=Instance.new("Frame") f.Name=plr.Name f.Size=UDim2.new(1,0,0,26) f.BackgroundColor3=C.hover f.BackgroundTransparency=1 f.BorderSizePixel=0 f.Parent=plist corner(f,5) f.MouseEnter:Connect(function() f.BackgroundTransparency=0 end) f.MouseLeave:Connect(function() f.BackgroundTransparency=1 end) local n=Instance.new("TextLabel") n.Size=UDim2.new(1,-74,1,0) n.Position=UDim2.fromOffset(8,0) n.BackgroundTransparency=1 n.Font=FONTM n.Text=plr.DisplayName n.TextColor3=C.text n.TextSize=12 n.TextXAlignment=Enum.TextXAlignment.Left n.TextTruncate=Enum.TextTruncate.AtEnd n.Parent=f miniBtn(f,"TP",-38,function() tpTo(plr) end) miniBtn(f,"Fling",-4,function() flingPlayer(plr) end,C.red) end end end
refreshPlayers()
conn(Players.PlayerAdded,function() task.wait(0.3) refreshPlayers() end)
conn(Players.PlayerRemoving,function() task.wait(0.1) refreshPlayers() end)
section(c4,"Utility","settings")
pill(c4,"Teleport to Spawn","flag",function() local root=getRoot() local sp=Workspace:FindFirstChildOfClass("SpawnLocation") if root and sp then root.CFrame=sp.CFrame+Vector3.new(0,5,0) end end)
pill(c4,"Reset Character","rotate-ccw",function() local h=getHum() if h then h.Health=0 end end)
pill(c4,"Rejoin Server","refresh-cw",function() TeleportService:Teleport(game.PlaceId,LP) end)

-- ** FIX SIZE FOR MOBILE **
local cols={c1,c2,c3,c4}
task.spawn(function() for _=1,4 do RunService.Heartbeat:Wait() end local maxH=0 for _,col in ipairs(cols) do maxH=math.max(maxH,col.AbsoluteSize.Y) end for _,col in ipairs(cols) do col.AutomaticSize=Enum.AutomaticSize.None col.Size=UDim2.fromOffset(COLW,maxH) end main.AutomaticSize=Enum.AutomaticSize.None body.AutomaticSize=Enum.AutomaticSize.None body.Size=UDim2.new(1,0,0,maxH+20) main.Size=UDim2.new(1, -20, 0, 44+maxH+20) end)

local function cleanup() stopFly() State.Noclip=false State.Aimbot=false State.ESP=false stopFling() for plr,_ in pairs(_G.JinoxxESP) do removeESP(plr) end end
local minimized=false

-- ** MINIMIZE / RESTORE LOGIC **
minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    main.Visible = not minimized
    miniIcon.Visible = minimized
end)

miniIcon.MouseButton1Click:Connect(function()
    minimized = false
    main.Visible = true
    miniIcon.Visible = false
end)

closeBtn.MouseButton1Click:Connect(function() cleanup() gui:Destroy() end)

print("[Jinoxx] DarkPurple/Compact loaded | Lucide:"..tostring(LUCIDE~=nil).." Drawing:"..tostring(HAS_DRAW).." mousemove:"..tostring(HAS_MOUSEMOVE))
