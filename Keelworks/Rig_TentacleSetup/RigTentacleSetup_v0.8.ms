


(
try(closeRolloutFloater rof)catch()
	
	
-- Bones Parameters
global boneCount = 22
global bezierHandleLength = 12.0

-- Bone Parameters
global bWidth = 2.0
global bHeight = 2.0
global bTaper = 0

-- Bone Fins Parameters
global sideFinCheck = true
global sideFinSize = 2.0
global sideFinTaper = .4
global sideFinTaperEnd = .4

global frontFinCheck = true
global frontFinSize = 2.0
global frontFinTaper = 10.0
global frontFinTaperEnd = 10.0

global backFinCheck = true
global backFinSize = 1.0
global backFinTaper = 10.0
global backFinTaperEnd = 10.0

-- Controller Size 
global conLength = 20
global conWidth = 20
global conRadius = 0.15
global conThickCheck = true
global conThickness = 1
global conParentMult = 140

	
global controllerColor = (color 255 188 8)
global pointColor = (color 255 0 0)
global ikColor = (color 25 25 25)
global boneColor = (color 174 186 203)
	

global allNodes = #() -- collection of all the nodes
global allMods = #() -- collection of all the modifiers

fn createTentacle spline boneCount = (
	
-- disableSceneRedraw()

start = 1
end = boneCount

-- conver odd numbers to even 
if (mod end 2) != 0 then (end += 1)

-- select the spline
cv = spline

nodeArray = #() -- collection of nodes
nodeArrayIK = #() -- collection of IK nodes
nodeArrayBones = #() -- collection of bones 

nodeTangentCtrlPoints = #() -- collection of tangent control points 
nodeScaleCtrlPoints = #() -- scale control points 

num = numKnots cv 1 -- get the number of spline knots 
	
max create mode -- switch to create mod 

-- creating tangent and scale controllers 
for i = 1 to num-1 do 
	(
		-- iterate through the bones ...
		if i < num then
		(
			pos = interpBezier3D cv 1 i 0 pathParam:false
			dir = tangentBezier3D cv 1 i 0 pathParam:false
			tanNode = point pos:pos wirecolor:pointColor name:("SP_Controller_" + i as string) centermarker:false axistripod:false cross:true Box:false size:15
			sclNode = rectangle width:15 length:15 pos:pos name:("Controller_" + i as string) wirecolor:controllerColor

			-- local controlRow1=pathTangent cv 1 ((i-1)/(num-1) as float)
			X = dir
			Y = [0, 0, 1]
			Z = normalize (cross X Y)
			Y = normalize (cross Z X)

			t = matrix3 X Y Z pos
			sclNode.transform = t
			tanNode.transform = t
			
			
			tanNode.parent = sclNode
			setInheritanceFlags tanNode #{1..6}
			setTransformLockFlags tanNode #{1..6}

			-- assing UI params 
			tanNode.size = (conLength + conWidth) / 2
			sclNode.length = conLength
			sclNode.width = conWidth
			sclNode.cornerRadius = conRadius
			if conThickCheck then (
				sclNode.render_displayRenderMesh = true
				sclNode.render_thickness = conThickness
				) else (
					sclNode.render_displayRenderMesh = false
					)

				
			append nodeScaleCtrlPoints sclNode
			append nodeTangentCtrlPoints tanNode
				
			append allNodes sclNode
			append allNodes tanNode 
		)
		
		-- if it's the last iteration do ...
		if i == num-1 then
		(
			pos = interpBezier3D cv 1 i 1 pathParam:false
			dir = tangentBezier3D cv 1 i 1 pathParam:false
			tanNode = point pos:pos wirecolor:pointColor name:("SP_Controller_" + (i+1) as string) centermarker:false axistripod:false cross:true Box:false size:15
			sclNode = rectangle width:15 length:15 pos:pos name:("Controller_" + (i+1) as string) wirecolor:controllerColor
			
			-- local controlRow1=pathTangent cv 1 ((i-1)/(num-1) as float)
			X = dir
			Y = [0, 0, 1]
			Z = normalize (cross X Y)
			Y = normalize (cross Z X)

			t = matrix3 X Y Z pos

			sclNode.transform = t
			tanNode.transform = t
			
			tanNode.parent = sclNode
			setInheritanceFlags tanNode #{1..6}
			setTransformLockFlags tanNode #{1..6}
			
			-- assing UI params 
			tanNode.size = (conLength + conWidth) / 2
			sclNode.length = conLength
			sclNode.width = conWidth
			sclNode.cornerRadius = conRadius
			if conThickCheck then (
				sclNode.render_displayRenderMesh = true
				sclNode.render_thickness = conThickness
				) else (
					sclNode.render_displayRenderMesh = false
					)

			append nodeScaleCtrlPoints sclNode
			append nodeTangentCtrlPoints tanNode
			
			append allNodes sclNode
			append allNodes tanNode 
		)
	)


for i=1 to num do
(
	--print (getknotType cv 1 i)
	--print nodeScaleCtrlPoints[i].name
	if (getknotType cv 1 i != #bezier) then 
	(
	setknotType cv 1 i #bezier
	local knotPos=(getKnotPoint cv 1 i)
		
	t = nodeScaleCtrlPoints[i].transform 
	newIn = [-bezierHandleLength, 0, 0] *  t 
	newOut = [bezierHandleLength, 0, 0] *  t 
		
	setInVec cv 1 i newIn
	setOutVec cv 1 i newOut

	--setInVec cv 1 i (((getInVec cv 1 i)-knotPos)*(nodeScaleCtrlPoints[i].transform.rotation)+knotPos)
	--setOutVec cv 1 i (((getOutVec cv 1 i)-knotPos)*(nodeScaleCtrlPoints[i].transform.rotation)+knotPos)
	)
)
updateshape cv


-- remove all the modifiers of the spline
while cv.modifiers.count > 0 do (
	deleteModifier cv 1
	)	
	
max modify mode --switch to modify panel
	
select cv --select the spline 

-- loop through the controllers and assign linked xform to
for i = 1 to num do (
	sselect = splineselect name:(i as string + "_Blocker") --Add a SplineSelect to stop the flow
	addmodifier cv sselect before:(cv.modifiers.count) --Add it BEFORE the first Edit_Spline!
	es2 = edit_spline name:(i as string + "_ES") --Create second Edit_Spline
	addmodifier cv es2 before:(cv.modifiers.count) --Add it BEFORE the SlineSelect "Blocker"
	modPanel.setCurrentObject es2 --Set the Modifier stack to it 
	subobjectLevel = 1 --vertex SO level
	setKnotSelection cv 1 #(i) --select second vertex
	LX2 = Linked_XForm name:(i as string + "_XForm") --create new Linked XForm
	modPanel.addModToSelection LX2 --Add on top of the current selection
	LX2.Control = nodeTangentCtrlPoints[i] --set second control
)
updateShape cv -- update the shape

lastPointIK = undefined 
curveLen = curveLength cv

dis = curveLen / end -- get the distance of each bone based on bone count and curve length
for i = start to end+1 do (
	p = point pos:[-100 +i*dis, 0, 0] name:("IK_Points_" + (i) as string) wirecolor:ikColor centermarker:false axistripod:false cross:false Box:true size:1
	p.size = ((bWidth + bHeight) / 2) / 5
	if lastPointIK != undefined then (p.parent = lastPointIK)
	lastPointIK = p

	append nodeArrayIK p
	append allNodes p 
)

-- create spline IK 
sp = ikSys.ikChain nodeArrayIK[1] nodeArrayIK[nodeArrayIK.count] "SplineIKSolver" 
append allNodes sp 
sp.controller.dispGoal = false
sp.controller.pickShape = cv
nodeArrayIK[1].position.controller=path_constraint()
nodeArrayIK[1].position.controller.appendTarget cv 100
deletekeys nodeArrayIK[1].position.controller.percent.controller

-- create up nodes (points)
for i = start to end+1 do (
	p = point pos:[0, 0, 0] name:("UpNodePoints_" + (i) as string) size:10 wirecolor:gray centermarker:false axistripod:false cross:false Box:true size:2
	p.size = ((bWidth + bHeight) / 2) / 5

	p.pos.controller = position_list ()
	
	p.pos.controller.Available.controller = Path_Constraint ()
	deletekeys p.pos.controller.Path_Constraint.controller.percent.controller
	p.pos.controller.Path_Constraint.controller.path = cv	
	p.pos.controller.Path_Constraint.controller.percent = (((i-1) as float) / end) * 100 
	
	posCon =  Position_Constraint()
	p.pos.controller.Available.controller = posCon
	posCon.appendTarget nodeArrayIK[i] 100
	
	append nodeArray p
	append allNodes p 
)

-- create bones for nodes
lastBone = undefined 
for i = start to end do (

	boneNode = BoneSys.createBone nodeArray[i].pos nodeArray[i+1].pos [0, 0, 1]  
	boneNode.wireColor = boneColor
	
	boneNode.pos.controller = Position_Constraint()
	boneNode.pos.controller.appendTarget nodeArray[i] 1

	boneNode.rotation.controller = LookAt_Constraint()
	boneNode.rotation.controller.appendTarget nodeArray[i+1] 1
	boneNode.rotation.controller.lookat_vector_length = 0
	boneNode.rotation.controller.upnode_world = off
	boneNode.rotation.controller.pickUpNode = nodeArray[i]
	
	setInheritanceFlags boneNode #{1..3}

	if lastBone != undefined then (boneNode.parent = lastBone)
	append nodeArrayBones boneNode
	append allNodes boneNode
	lastBone = boneNode

	-- assign UI params
	boneNode.width = bWidth
	boneNode.height = bHeight
	boneNode.Taper = bTaper

	if sideFinCheck then (
		boneNode.sidefins = true
		boneNode.sidefinssize = sideFinSize
		boneNode.sidefinsstarttaper = sideFinTaper
		boneNode.sidefinsendtaper = sideFinTaperEnd
	) else (
		boneNode.sidefins = false
	)
	if frontFinCheck then (
		boneNode.frontfin = true
		boneNode.frontfinsize = frontfinsize
		boneNode.frontfinstarttaper = frontFinTaper
		boneNode.frontfinendtaper = frontFinTaperEnd
	) else(
		boneNode.frontfin = false
	)
	if backFinCheck then (
		boneNode.backfin = true
		boneNode.backfinsize = backFinSize
		boneNode.backfinstarttaper = backFinTaper
		boneNode.backfinendtaper = backFinTaperEnd
	) else(
		boneNode.backfin = false
	)

	curveVal =  (getValue crv 0 (i as float / end))
	boneNode.width *= curveVal
	boneNode.height *= curveVal
	
	if boneNode.sidefins then (boneNode.sidefinssize *= curveVal)
	if boneNode.frontfin then (boneNode.frontfinsize *= curveVal)
	if boneNode.backfin then (boneNode.backfinsize *= curveVal)
)

-- create end bone (Nub-Bone)
parentBone = lastBone
parentTrans = lastBone.transform
parentPos = parentTrans.translation
newBone = BoneSys.createBone parentPos (parentPos+6) parentBone.dir
newBone.transform = parentTrans
oldTrans = newBone.transform
newTrans = newBone.transform * Inverse newBone.transform
newTrans.position += [parentBone.length,0,0]
trans = (newTrans * oldTrans)
newBone.transform = trans
newBone.parent = parentBone
newBone.width = parentBone.width
newBone.height = parentBone.height
newBone.taper = 90
newBone.length = (parentBone.width+parentBone.height)/2
newBone.wireColor = parentBone.wireColor
setInheritanceFlags newBone #{1..3}
append nodeArrayBones newBone
append allNodes newBone

hide newBone
hide cv 

newBone.pos.controller = Position_Constraint()
newBone.pos.controller.appendTarget nodeArray[nodeArray.count] 1


-- distribute scale and rotation
n = end
c = num-1
div = n as float / c as float 
ind = 1

for i = 1 to c do(
	val = (((i as float) * div) + 0.5) as integer 
	
	--print ("First Node Index: " + i as string)
	--print ("Second Node Index: " + (i+1) as string)
	
	aNode = nodeScaleCtrlPoints[i]
	bNode = nodeScaleCtrlPoints[i + 1]
	
	
	cc = ind
	maxVal =  (val - ind)
	--print "START"
	currentInd = 0
	for item = cc to val do 
	(
		inter = ((currentInd as float) / abs(maxVal))

		--print (i as string + " " + item as string + " " + inter as string)
		nod = nodeArrayBones[ind]
		nod.scale.controller=scale_script()
		nod.scale.controller.addObject "a" aNode
		nod.scale.controller.addObject "b" bNode
		nod.scale.controller.script=("a.scale * (1 - " + (inter as string) + ") + b.scale * " + (inter as string) + "\n")
		
		nod = nodeArray[ind]
		aString = ("rotX= (a.x_rotation* " +  (1.0 - inter) as string + "+b.x_rotation* " + (inter) as string + ")")
		bString = ("rotY= (a.y_rotation* " +  (1.0 - inter) as string + "+b.y_rotation* " + (inter) as string + ")")
		cString = ("rotZ= (a.z_rotation* " +  (1.0 - inter) as string + "+b.z_rotation* " + (inter) as string + ")")
		dString = ("eulerangles rotX rotY rotZ")
		result = (aString + "\n" + bString + "\n" + cString + "\n" + dString)
		nod.rotation.controller = rotation_script()	
		nod.rotation.controller.addObject "a" aNode.rotation.controller
		nod.rotation.controller.addObject "b" bNode.rotation.controller
		nod.rotation.controller.script=result

		ind += 1
		currentInd += 1
	)
	--print "END"
)


-- create and assign stretch attribute 
attHolder = EmptyModifier name:"Stretch Control"
append allMods attHolder 
STRCH_DEF = attributes stretchAttribute
(
	Parameters main rollout:params
	(
		strch type:#float UI:strch Default:1.0 range:[0,1.0,1.0]
	)
	Rollout Params "Stretch Parameter"
	(
		spinner 'strch' "Stretch" Width:160 Height:16 Align:#Center Type: #float Range:[0,1.0,1.0] scale:0.001
	)
)
-- add atrribute to the modifier
CustAttributes.add attHolder STRCH_DEF #Unique 
   


-- create reset scale attribute 
scaleReset = attributes scaleResetAttribute
(
	Parameters main rollout:params
	(
		strch type:#float UI:strch Default:1.0 range:[0,1.0,1.0]
		
	)
	
   rollout params "Controller Size"
   ( 
	   
        button UI_reset "Reset Scale" width:160 height:24
	   
		spinner 'strch' "Stretch" Width:160 Height:16 Align:#Center Type: #float Range:[0,1.0,1.0] scale:0.001

	   on UI_reset pressed do (
		   selfNode = (refs.dependentNodes (custAttributes.getOwner this))
		    --selfNode.scale = [1, 1, 1]
			   in coordsys parent selfNode.scale = [1, 1, 1]

		   )
    )
)

-- add mod To Controllers 
for i in nodeScaleCtrlPoints do 
(	
	addModifier i attHolder 
	
	m = EmptyModifier name:"Scale Attribute"
	custAttributes.add m scaleReset #unique 
	addModifier i m 
	
)
for i in nodeTangentCtrlPoints do 
(
	addModifier i attHolder 
	
	m = EmptyModifier name:"Scale Attribute"
	custAttributes.add m scaleReset #unique 
	addModifier i m 
	
)


-- Set Up Wire Frame For Helpers 
for i in nodeArray do 
(
	paramWire.connect attHolder.stretchAttribute[#strch] i.pos.controller[#weights][#Weight__Position_Constraint] "1.0 - strch"
)

for i in nodeScaleCtrlPoints do (
	paramWire.connect2Way i.modifiers[#Scale_Attribute].scaleResetAttribute[#strch] i.modifiers[#Stretch_Control].stretchAttribute[#strch] "strch" "strch"
)
for i in nodeTangentCtrlPoints do (
	paramWire.connect2Way i.modifiers[#Scale_Attribute].scaleResetAttribute[#strch] i.modifiers[#Stretch_Control].stretchAttribute[#strch] "strch" "strch"
)


-- create parent node 
parentNode = rectangle width:20 length:20 name:"Parent" wirecolor:green 
parentNode.transform = nodeScaleCtrlPoints[1].transform
append allNodes parentNode 

-- assing UI params 
parentNode.length = conLength * (conParentMult / 100.0)
parentNode.width = conWidth  * (conParentMult / 100.0)
parentNode.cornerRadius = conRadius  * (conParentMult / 100.0)
if conThickCheck then (
	parentNode.render_displayRenderMesh = true
	parentNode.render_thickness = conThickness
	) else (
		parentNode.render_displayRenderMesh = false
		)

		
addModifier parentNode attHolder 
	
m = EmptyModifier name:"Scale Attribute"
custAttributes.add m scaleReset #unique 
addModifier parentNode m 

-- assign parent node to created nodes
nodeArrayBones[1].parent = parentNode
nodeArrayIK[1].parent = parentNode
for i in nodeScaleCtrlPoints do 
(
	i.parent = parentNode 
)

for i = 1 to nodeScaleCtrlPoints.count do 
(
	nodeScaleCtrlPoints[i].parent = parentNode 
)

for i in nodeArray do (
	i.parent = parentNode
)

sp.parent = parentNode
cv.parent = parentNode

-- hiding unnecessary nodes 
hide nodeArray
hide nodeArrayIK

--EnableSceneRedraw()
clearSelection()
redrawViews()
)

rollout a "Rig: Tentacle Rig Creator" 
(
	group "Bones" (
		spinner UI_Bones "Bones: " width:119 height:16 range:[2,10000,boneCount] type:#integer align:#right
		spinner UI_Handle_Length "Handle Length: " width:119 height:16 range:[-1e+22, 1e+22, bezierHandleLength] type:#float align:#right

		on UI_Bones changed val do (boneCount = val)
		on UI_Handle_Length changed val do (bezierHandleLength = val)
		)
		
	group "Bone Parameters" (
		spinner UI_bWidth "Width" width:80 align:#right range:[-1e+22, 1e+22, bWidth]
		spinner UI_bHeight "Height" width:80 align:#right range:[-1e+22, 1e+22, bHeight]
		spinner UI_bTaper "Taper" width:80 align:#right range:[-100, 100, bTaper]
		
		on UI_bWidth changed val do (bWidth = val)
		on UI_bHeight changed val do (bHeight = val)
		on UI_bTaper changed val do (bTaper = val)
		)
		 
	group "Bone Fins" (
		checkbox UI_sideFinCheck "Side Fins" align:#left across:1 checked:sideFinCheck
		spinner UI_sideFinSize "Size" width:80 align:#right range:[-1e+22, 1e+22, sideFinSize]
		spinner UI_sideFinTaper "Start Taper" width:80 align:#right range:[-100, 100, sideFinTaper]
		spinner UI_sideFinTaperEnd "End Taper" width:80 align:#right range:[-100, 100, sideFinTaperEnd]
		
		checkbox UI_frontFinCheck "Front Fins" align:#left across:1 checked:frontFinCheck
		spinner UI_frontFinSize "Size" width:80 align:#right range:[-1e+22, 1e+22, frontFinSize]
		spinner UI_frontFinTaper "Start Taper" width:80 align:#right range:[-100, 100, frontFinTaper]
		spinner UI_frontFinTaperEnd "End Taper" width:80 align:#right range:[-100, 100, frontFinTaperEnd]
		
		checkbox UI_backFinCheck "Back Fins" align:#left across:1 checked:backFinCheck
		spinner UI_backFinSize "Size" width:80 align:#right range:[-1e+22, 1e+22, backFinSize]
		spinner UI_backFinTaper "Start Taper" width:80 align:#right range:[-100, 100, backFinTaper]
		spinner UI_backFinTaperEnd "End Taper" width:80 align:#right range:[-100, 100, backFinTaperEnd]
		
		on UI_sideFinCheck changed state do (sideFinCheck = state)
		on UI_sideFinSize changed val do (sideFinSize = val)
		on UI_sideFinTaper changed val do (sideFinTaper = val)
		on UI_sideFinTaperEnd changed val do (sideFinTaperEnd = val)

		on UI_frontFinCheck changed state do (frontFinCheck = state)
		on UI_frontFinSize changed val do (frontFinSize = val)
		on UI_frontFinTaper changed val do (frontFinTaper = val)
		on UI_frontFinTaperEnd changed val do (frontFinTaperEnd = val)

		on UI_backFinCheck changed state do (backFinCheck = state)
		on UI_backFinSize changed val do (backFinSize = val)
		on UI_backFinTaper changed val do (backFinTaper = val)
		on UI_backFinTaperEnd changed val do (backFinTaperEnd = val)
		)	
		
	group "Controller Size" (
		spinner UI_conLength "Length" width:80 align:#right range:[0, 1e+22, conLength]
		spinner UI_conWidth "Width" width:80 align:#right range:[0, 1e+22, conWidth]
		spinner UI_conRadius "Corner Radius" width:80 align:#right range:[0, 1e+22, conRadius]
		checkbox UI_conThickCheck "In Viewport" align:#left across:2 checked:conThickCheck
		spinner UI_conThickness "Thickness" align:#right range:[0, 1e+22, conThickness]
		spinner UI_conParentMult "Parent Size Multiplier" align:#right range:[-500,500,conParentMult]
		
		on UI_conLength changed val do (conLength = val)
		on UI_conWidth changed val do (conWidth = val)
		on UI_conRadius changed val do (conRadius = val)
		on UI_conThickCheck changed state do (conThickCheck = state)
		on UI_conThickness changed val do (conThickness = val)
		on UI_conParentMult changed val do (conParentMult = val)		
		)	
		
	group "Controller Color" (
		colorPicker UI_Controller_Color "Controller: " color:controllerColor align:#right across:2
		colorPicker UI_Point_Color "Point: " color:pointColor align:#right 
		colorPicker UI_IK_Point_Color "IK Point: " color:ikColor align:#right  across:2
		colorPicker UI_Bone_Color "Bone: " color:boneColor align:#right
		
		on UI_Controller_Color changed col do (controllerColor = col)
		on UI_Point_Color changed col do (pointColor = col)
		on UI_IK_Point_Color changed col do (ikColor = col)
		on UI_Bone_Color changed col do (boneColor = col)
		)
	
	group "Bone Size Curve" (
		
	
		CurveControl cc_test 

		height:100
		width:208

		align:#center
		numCurves:1
		visible:true
		x_range:[0,1]
		y_range:[0,1]
		commandMode:#move_xy
		-- The following parameters default to all flags if not specified
		--uiFlags:#(#drawBG, #drawgrid, #upperToolbar, #showReset, #scrollBars, #constrainY, #xvalue)
		--uiFlags:#(#constrainY)
		uiFlags:#(#constrainY)
		
		rcmFlags:#(#delete)
		asPopup:false
			
		button btn6 "Reset Curve" width:208
		on btn6 pressed do 
		(
			local crv = cc_test.curves[1]
			local cp = crv.points[1]
			
			crv.points[1].outTangent = [0.2,0]
			crv.points[1].value = [0, 1]

			crv.points[2].inTangent = [-0.2, 0]
			crv.points[2].value = [0, 1]			
		)		
		on a open do
		(

		local colors = #(color 160 160 160, green, blue)
		--local styles = #(#solid, #dash, #dot, #dashDot, #dashDotDot, #null, #insideFrame)
		local styles = #(#dashDotDot)
		local num = cc_test.numCurves
		global crv
			
		-- Initialize curve properties

		crv = cc_test.curves[1]
		crv.name = "Curve"
		crv.color = colors[1]
		crv.disabledColor = colors[1]*0.5
		crv.width = 3
		crv.numPoints = 2
			
		local cp = crv.points[1]
		cp.corner = true
			
		crv.points[1].value = [0, 1]
		crv.points[1].outTangent = [0.4,-0.0]

		crv.points[2].value = [0, 0]
		crv.points[2].inTangent = [-0.4, 0.6]

		zoom cc_test #all
		
		crv.points[1].outTangent = [0.2,0]
		crv.points[1].value = [0, 1]

		crv.points[2].inTangent = [-0.2, 0]
		crv.points[2].value = [0, 1]
			
		)

	)

	fn box_filt obj = (classof obj == SplineShape or classof obj == Line)
		

	group "Creation" (
		button btn4 "01 - Create Spline" height:32 width:208 tooltip:"Create the base spline, Hint: for best and manageable animation Use less points, for most cases 3 Points should be optimal"
		on btn4 pressed do 
		(
			curve = startObjectCreation Line returnNewNodes:True 
			
		)
		
		button chooseit "02 - Select Created Spline" height:32 width:208 filter:box_filt tooltip:"Select the created spline to apply the Rig to"
			
		on chooseit pressed do
		(
			chooseit.text = "..." 
			obj = pickObject filter:box_filt

			if obj != undefined do
			(
				undo on (
				obj.wirecolor = red
				chooseit.text = obj.name
				createTentacle obj boneCount
				chooseit.text = "Spline" 
				obj = undefined 
				)
			)
		)
		
	)
)



-- Check if the master Keelworks manager script and loading client scripts
if globalKeelworksLoading == true  then
(
	-- Add the rollout to the manager rollout window
    addRollout a masterRolloutFloat
	-- And close/collapse it by default
	a.open = false
	--cui.RegisterDialogBar alignToSurface -- your can't dock it in this mode as it is part of a rollout floater
)
else 
(
	-- Create a new dialogue window for the rollout
	rof = newrolloutfloater "Rig: Tentacle setup v0.8" 240 926
	addrollout a rof
)

)


