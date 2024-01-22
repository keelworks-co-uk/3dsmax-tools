DEBUG = false 

if DEBUG then (delete objects)
try(closeRolloutFloater rof)catch()
try(unregisterRedrawViewsCallback debugView)catch()

(
-- Bone Parameters
global bWidth = 2.0
global bHeight = 2.0
global bTaper = 0
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
global swivelControllerPointColor = (color 25 250 80)
global boneColor = (color 174 186 203)

-- controller parameters 
--global controllerColor = color 200 200 255

-- define joints 
global jointArray
global boneArray
global IKArray
global SingleIKArray

-- define properties
global isOffset
global isReverse = false
global swivelAngle

-- main buttons
global UI_3Setup_btn 
global UI_4Setup_btn 
global UI_5Setup_btn 

-- global functions
global createRig
global debugView
global applyBoneProp
global cleanUpScene

-- global setup defenition
global jointType -- [1=3_Joints, 2=4_Joints, 3=5_Joints]
global setupType -- [different types with different setup]

-- mirror matrix function	
fn mirrorMatrixFn axis:"x" flip:"x" tm:(matrix3 1) pivotTm:(matrix3 1) =
(
   fn FetchReflection a = 
   (
 	  case a of (
 	  "x": [-1,1,1]  -- reflect in YZ plane
 	  "y": [1,-1,1]  --	    in ZX plane
 	  "z": [1,1,-1]  --	    in XY plane
 	  )
   )
   aReflection = scalematrix (FetchReflection axis)  
   fReflection = scalematrix (FetchReflection flip)
   fReflection * (tm * (inverse pivotTm)) * aReflection * pivotTm 
)

-- matrix transformation 
fn rotVecAroundAxis r u ang =
(
    u = normalize(u) -- rotate around this	
    -- identity matrix 
    matrix = #((point3 1 0 0), (point3 0 1 0), (point3 0 0 1))
    -- specify the furmola
    matrix[1][1] = ((cos ang) + (u.x ^ 2) * (1 - cos ang))           -- X
    matrix[1][2] = ((u.y * u.x) * (1 - cos ang) + (u.z * (sin ang))) -- Y
    matrix[1][3] = ((u.z * u.x) * (1 - cos ang) - (u.y * (sin ang))) -- Z
    matrix[2][1] = ((u.x * u.y) * (1 - cos ang) - (u.z * (sin ang))) -- X
    matrix[2][2] = ((cos ang) + (u.y ^ 2) * (1 - cos ang))           -- Y
    matrix[2][3] = ((u.z * u.y) * (1 - cos ang) + (u.x * (sin ang))) -- Z
    matrix[3][1] = ((u.x * u.z) * (1 - cos ang) + (u.y * (sin ang))) -- X
    matrix[3][2] = ((u.y * u.z) * (1 - cos ang) - (u.x * (sin ang))) -- Y
    matrix[3][3] = ((cos ang) + (u.z ^ 2) * (1 - cos ang))           -- Z
    row1 = matrix[1][1] * r.x
    row2 = matrix[1][2] * r.x
    row3 = matrix[1][3] * r.x
    row4 = matrix[2][1] * r.y
    row5 = matrix[2][2] * r.y
    row6 = matrix[2][3] * r.y	
    row7 = matrix[3][1] * r.z
    row8 = matrix[3][2] * r.z
    row9 = matrix[3][3] * r.z
    vec = point3 (row1 + row4 + row7) (row2 + row5 + row8) (row3 + row6 + row9)
)

-- a function to clean up the scene
fn cleanUpScene = (
	-- disable buttons 
	UI_3Setup_btn.enabled = true 
	UI_4Setup_btn.enabled = true 
	UI_5Setup_btn.enabled = true 

	-- delete arrays and redefine them 
	try(
	delete jointArray
	delete boneArray
	delete IKArray
    delete SingleIKArray
	)catch()

	jointArray = Array()
    boneArray = Array()
    IKArray = Array()
    SingleIKArray = Array()

	-- Unregister debug view 
	try(unregisterRedrawViewsCallback debugView)catch()

    --clearListener()
    redrawViews()
)

-- apply bone display properties
fn applyBoneProp = (
	for boneNode in boneArray do (
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
		
		boneNode.wirecolor = boneColor
	)
)

-- rig creation function
fn createRig = (
    max create mode
    lastBone = undefined 
    lastBoneM = undefined 
    for i = 1 to jointArray.count-2 do 
    (
        -- define the direction from bone 1 to 2
        dir = jointArray[i+1].pos - jointArray[i].pos			
        forward = (([1, 0, 0] * jointArray[i].transform) - jointArray[i].pos)
        -- create the up vector for boneSys
        X = dir
        Y = forward
        Z = normalize (cross X Y)
        Y = normalize (cross Z X)
        t = matrix3 X Y Z jointArray[i].pos
        upVec = (([0, 0, 1] * t) - t.pos)
        -- create the bone based on vectors
        boneNode = BoneSys.createBone jointArray[i].pos jointArray[i+1].pos upVec 
        if lastBone != undefined then (boneNode.parent = lastBone)
        -- assign the bone to the list and lastbone
        lastBone = boneNode 
        append boneArray boneNode 
    )
    -- send bones to apply display properties 
    applyBoneProp()
    -- create end bone 
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
    append boneArray newBone 
    
    -- split rig setup based on jointType and setupTypes
    -- define type 1:1 [jointType:setupType]
    case jointType of (
        -- three joints : standard setup
        1:(
            -- create root controller 
            rootController = Rectangle transform:jointArray[1].transform length:(conLength * (conParentMult / 100.0)) width:(conWidth * (conParentMult / 100.0)) cornerRadius:conRadius wirecolor:controllerColor 
            -- create IK controller 
            IKController = Rectangle transform:jointArray[3].transform length:conLength width:conWidth cornerRadius:conRadius wirecolor:controllerColor 
            -- create IK child controller 
            IKChildController = Rectangle parent:IKController transform:jointArray[3].transform length:(conLength * (100.0 / conParentMult)) width:(conWidth * (100.0 / conParentMult)) cornerRadius:conRadius wirecolor:controllerColor 
            setTransformLockFlags IKChildController #{1..5, 7..9}

			if conThickCheck then (			
				rootController.render_displayRenderMesh = true
				rootController.render_thickness = conThickness			
				IKController.render_displayRenderMesh = true
				IKController.render_thickness = conThickness
				IKChildController.render_displayRenderMesh = true
				IKChildController.render_thickness = conThickness
				) else (
					rootController.render_displayRenderMesh = false
					IKController.render_displayRenderMesh = false
					IKChildController.render_displayRenderMesh = false
					)

				
            if isOffset then
            (
                swivelPoint = jointArray[3]
                dir = ([0, 0, 1] * IKArray[1][2].transform) - IKArray[1][2].pos 
                pos = rotVecAroundAxis (IKArray[1][3].pos - (IKArray[1][2].pos)) dir swivelAngle
                pos += IKArray[1][2].pos
                offsetPoint = point pos:pos size:5 wirecolor:gray centermarker:false cross:true axistripod:false Box:false constantscreensize:false drawontop:false  
                swivelPoint.pos = pos
                swivelPoint.parent = IKChildController
                -- add attribute holder 
                attHolder = EmptyModifier name:"Offset Control"
                OFFSET_DEF = attributes offsetAttribute
                (
                    Parameters main rollout:params
                    (
                        offset type:#float UI:offset Default:90 Range:[0,360,90]
                    )
                    Rollout Params "Offset Parameter"
                    (
                        spinner 'offset' "Offset" Width:160 Height:16 Align:#Center Type:#float Range:[0,360,90] scale:1
                    )
                )
                -- add atrribute to the modifier
                CustAttributes.add attHolder OFFSET_DEF #Unique 
                addModifier offsetPoint attHolder 
                addModifier swivelPoint attHolder 
                addModifier IKChildController attHolder 
                addModifier IKController attHolder 
                attHolder.offsetAttribute.offset = swivelAngle
                -- create script controller 
                offsetPoint.position.controller=position_script()
                offsetPoint.position.controller.addObject "pointNode" swivelPoint
                offsetPoint.position.controller.addObject "axisNode" IKChildController
                offsetPoint.position.controller.addTarget "a" (getSubAnim attHolder.offsetAttribute 1)
                scriptString =  (
                    "r = (pointNode.pos - (axisNode.pos))\nu = (([0, 0, 1] * axisNode.transform) - axisNode.pos)\nang = -a\nu = normalize(u)\nmatrix = #((point3 1 0 0), (point3 0 1 0), (point3 0 0 1))\nmatrix[1][1] = ((cos ang) + (u.x ^ 2) * (1 - cos ang))           -- X\nmatrix[1][2] = ((u.y * u.x) * (1 - cos ang) + (u.z * (sin ang))) -- Y\nmatrix[1][3] = ((u.z * u.x) * (1 - cos ang) - (u.y * (sin ang))) -- Z\nmatrix[2][1] = ((u.x * u.y) * (1 - cos ang) - (u.z * (sin ang))) -- X\nmatrix[2][2] = ((cos ang) + (u.y ^ 2) * (1 - cos ang))           -- Y\nmatrix[2][3] = ((u.z * u.y) * (1 - cos ang) + (u.x * (sin ang))) -- Z\nmatrix[3][1] = ((u.x * u.z) * (1 - cos ang) + (u.y * (sin ang))) -- X\nmatrix[3][2] = ((u.y * u.z) * (1 - cos ang) - (u.x * (sin ang))) -- Y\nmatrix[3][3] = ((cos ang) + (u.z ^ 2) * (1 - cos ang))           -- Z\nrow1 = matrix[1][1] * r.x\nrow2 = matrix[1][2] * r.x\nrow3 = matrix[1][3] * r.x\nrow4 = matrix[2][1] * r.y\nrow5 = matrix[2][2] * r.y\nrow6 = matrix[2][3] * r.y	\nrow7 = matrix[3][1] * r.z\nrow8 = matrix[3][2] * r.z\nrow9 = matrix[3][3] * r.z\nvec = point3 (row1 + row4 + row7) (row2 + row5 + row8) (row3 + row6 + row9)\nvec += axisNode.pos\nvec"
                    )
                offsetPoint.position.controller.script=scriptString

                swivel = offsetPoint
				offsetPoint.wirecolor = swivelControllerPointColor
            )
            else 
            (
                swivel = jointArray[3]
                swivel.pos = jointArray[4].pos
            )
            -- create IK solver
            boneOneID = (getAppData IKArray[1][1] 100) as integer
            boneTwoID = (getAppData IKArray[1][2] 100) as integer 
            boneOne = boneArray[boneOneID]
            boneTwo = boneArray[boneTwoID]
            try
            (
                ikHelper = ikSys.ikChain boneOne boneTwo "IKHISolver" 
                ikHelper.transform.controller.VHTarget = swivel
            ) 
            catch
            (
                ikHelper = ikSys.ikChain boneTwo boneOne "IKHISolver" 
                ikHelper.transform.controller.VHTarget = swivel
            )
            -- position constraint ik to ik controller 
            ikHelper.parent = IKController
			ikHelper.wirecolor = swivelControllerPointColor
            -- delete swivel to avoid removing by clean up function
			
			jointArray[3].wirecolor = swivelControllerPointColor
            deleteItem jointArray 3
			
        )

        2:(
            case setupType of 
            (
                -- four joints type 1
                1: (
					-- ############ CONTROLLER CREATION ############
					rootController = Rectangle transform:jointArray[1].transform name:"rootController" length:(conLength * (conParentMult / 100.0)) width:(conWidth * (140 / 100.0)) cornerRadius:conRadius wirecolor:controllerColor
					kneeController = Rectangle transform:jointArray[2].transform name:"kneeController" parent:rootController length:conLength width:conWidth cornerRadius:conRadius wirecolor:controllerColor 
					IKController = Rectangle transform:jointArray[4].transform name:"IKController" length:conLength width:conWidth cornerRadius:conRadius wirecolor:controllerColor
					-- link the first bone to rootController
					boneArray[1].parent = rootController
					IKOffsetController = Rectangle transform:jointArray[4].transform name:"IKOffsetController" parent:IKController length:(conLength * (100.0 / conParentMult)) width:(conWidth * (100.0 / conParentMult)) cornerRadius:conRadius wirecolor:controllerColor 

						
					if conThickCheck then (			
						rootController.render_displayRenderMesh = true
						rootController.render_thickness = conThickness	
						kneeController.render_displayRenderMesh = true
						kneeController.render_thickness = conThickness							
						IKController.render_displayRenderMesh = true
						IKController.render_thickness = conThickness
						IKOffsetController.render_displayRenderMesh = true
						IKOffsetController.render_thickness = conThickness
						) else (
							rootController.render_displayRenderMesh = false
							IKController.render_displayRenderMesh = false
							IKOffsetController.render_displayRenderMesh = false
							kneeController.render_displayRenderMesh = false
							)
						
						
					-- ############ IK [1:2] CREATION ############
					boneOneID = (getAppData jointArray[1] 100) as integer
					boneTwoID = (getAppData jointArray[2] 100) as integer 
					boneOne = boneArray[boneOneID]
					boneTwo = boneArray[boneTwoID]
					try
					(
						ikHelper = ikSys.ikChain boneOne boneTwo "IKHISolver" 
						ikHelper.transform.controller.SAParent = 0
					) 
					catch
					(
						ikHelper = ikSys.ikChain boneTwo boneOne "IKHISolver"
						ikHelper.transform.controller.SAParent = 0
					)
					ikHelper.transform = jointArray[2].transform
					ikHelper.parent = KneeController
					ikHelper.wirecolor = swivelControllerPointColor

					-- ############ IK [2:4] CREATION ############
					swivel = jointArray[5]
					swivel.wirecolor = swivelControllerPointColor
					deleteItem jointArray 5 -- delete from array to avoid deleting
                    boneOneID = (getAppData jointArray[2] 100) as integer
                    boneTwoID = (getAppData jointArray[4] 100) as integer 
                    boneOne = boneArray[boneOneID]
                    boneTwo = boneArray[boneTwoID]
                    try
                    (
                        ikHelper = ikSys.ikChain boneOne boneTwo "IKHISolver" 
                        ikHelper.transform.controller.VHTarget = swivel
                    ) 
                    catch
                    (
                        ikHelper = ikSys.ikChain boneTwo boneOne "IKHISolver" 
                        ikHelper.transform.controller.VHTarget = swivel
                    )
                    ikHelper.parent = IKOffsetController
					swivel.parent = IKOffsetController
					ikHelper.wirecolor = swivelControllerPointColor

					-- ############ ROTATION SCRIPT ############
					attHolder = EmptyModifier name:"Offset Control"
					ROTATE_DEF = attributes rotateAttribute
					(
						Parameters main rollout:params
						(
							rotInfluence type:#float UI:rotInfluence Default:0.0 Range:[0,1,0.0]
						)
						Rollout Params "Rotation Influence"
						(
							spinner 'rotInfluence' "Rotation" Width:160 Height:16 Align:#Center Type:#float Range:[0,1,0.0] scale:1
						)
					)
					kneeController.transform = jointArray[2].transform
					-- add attribute to the holder
					CustAttributes.add attHolder ROTATE_DEF #Unique 
					-- rotation infuence 
					nod = KneeController
					nod.rotation.controller = rotation_list()
					aString = "rotX = (a.x_rotation * val + b.x_rotation * val)"
					bString = "rotY = (a.y_rotation * val + b.y_rotation * val)"
					cString = "rotZ = (a.z_rotation * val + b.z_rotation * val)"
					dString = ("eulerangles rotX rotY rotZ")
					result = (aString + "\n" + bString + "\n" + cString + "\n" + dString)
					RS = rotation_script()
					nod.rotation.controller.Available.controller = RS
					RS.addObject "a" rootController.rotation.controller
					RS.addObject "b" IKController.rotation.controller
					RS.AddTarget "val" attHolder.rotateAttribute[#rotInfluence]
					RS.script=result
					
					-- ############ POSITION SCRIPT ############
					-- define attribute and attribute holder 
					OFFSET_DEF = attributes influenceAttribute
					(
						Parameters main rollout:params
						(
							influence type:#float UI:influence Default:20 Range:[0,100,20]
						)
						Rollout Params "Position Influence"
						(
							spinner 'influence' "Influence" Width:160 Height:16 Align:#Center Type:#float Range:[0,100,20] scale:1
						)
					)
					-- add attribute to the holder
					CustAttributes.add attHolder OFFSET_DEF #Unique 
					-- create list controller for infuence node (KneeController)
					kneeController.pos.controller = position_list()
					-- assign the first node and controller (Root Controller)
					posCon2 = Position_Constraint()
					kneeController.pos.controller.Available.controller = posCon2
					posCon2.appendTarget IKController 100
					posCon2.relative = true
					kneeController.pos.controller.weight[2] = 20
					-- wire connect the attribute to second position constraint weight
					paramWire.connect attHolder.influenceAttribute[#influence] (getSubAnim kneeController.transform.controller.Position.controller.weight 2) "influence/100"
					posCon2 = Position_XYZ()
					kneeController.pos.controller.Available.controller = posCon2
					kneeController.pos.controller.setActive 3

					-- ############ ADDING MODIFIERS ############
					-- add mod to the controllers
					addModifier rootController attHolder
					addModifier kneeController attHolder
					addModifier IKController attHolder		

					-- ############ RESET TRANSFORM SCRIPT ############
					attHolder2 = EmptyModifier name:"Freeze Transform"
					addModifier kneeController attHolder2
					OFFSET_DEF = attributes freezeAttribute
					(
						Parameters main rollout:params
						(
							transformData type:#string default:"(matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])"
						)
						Rollout Params "Offset Parameter"
						(
							button UI_store "Store Transform"  height:26 width:160 align:#center
							button UI_reset "Reset Transform"  height:26 width:160 align:#center
							on UI_store pressed do (
								val = yesNoCancelBox "Overwriting Stored Transform?" title:"Warning" beep:true 
								if val == #yes then (			
									selfNode = (refs.dependentNodes (custAttributes.getOwner this))[1]
									old = selfNode.modifiers[2].influenceAttribute.influence
									selfNode.modifiers[2].influenceAttribute.influence = 0
									offset = selfNode.transform * inverse selfNode.parent.transform 
									transformData = offset as string 
									selfNode.modifiers[2].influenceAttribute.influence = old 
									)
							   )	
							on UI_reset pressed do (
								selfNode = (refs.dependentNodes (custAttributes.getOwner this))[1]
								old = selfNode.modifiers[2].influenceAttribute.influence
								selfNode.modifiers[2].influenceAttribute.influence = 0
								offset = execute transformData
								selfNode.transform = offset * selfNode.parent.transform 
								selfNode.modifiers[2].influenceAttribute.influence = old 
						   ) 
						)
					)
					CustAttributes.add attHolder2 OFFSET_DEF #Unique 
					
					-- ############ POLE VECTOR OFFSET ############
					if isOffset then (
						OFFSET_DEF = attributes offsetAttribute
						(
							Parameters main rollout:params
							(
								offset type:#float UI:offset
							)
							Rollout Params "Rotation Offset"
							(
								spinner 'offset' "Offset" Width:160 Height:16 Align:#Center Type:#float Range:[0,360,270] scale:1
							)
						)
						-- add attribute to the holder
						CustAttributes.add attHolder OFFSET_DEF #Unique 
						
						dir = IKArray[1][3].parent.dir 
						testPos = rotVecAroundAxis (IKArray[1][3].pos - (IKArray[1][2].pos)) dir (360 - swivelAngle)
						testPos += IKController.pos
						swivelController = point name:"swivelController" pos:testPos parent:IKOffsetController size:10 wirecolor:swivelControllerPointColor centermarker:false cross:false axistripod:true Box:false constantscreensize:false drawontop:false 
						swivel.name = "Swivel" 
						swivel.position.controller=position_script()
						swivel.position.controller.addObject "pointNode" swivelController
						swivel.position.controller.addObject "axisNode" IKOffsetController
						swivel.position.controller.addTarget "a" (getSubAnim attHolder.offsetAttribute 1)
						scriptString =  ("r = (pointNode.pos - (axisNode.pos))\nu = (([0, 0, 1] * axisNode.transform) - axisNode.pos)\nang = -a\nu = normalize(u)\nmatrix = #((point3 1 0 0), (point3 0 1 0), (point3 0 0 1))\nmatrix[1][1] = ((cos ang) + (u.x ^ 2) * (1 - cos ang))           -- X\nmatrix[1][2] = ((u.y * u.x) * (1 - cos ang) + (u.z * (sin ang))) -- Y\nmatrix[1][3] = ((u.z * u.x) * (1 - cos ang) - (u.y * (sin ang))) -- Z\nmatrix[2][1] = ((u.x * u.y) * (1 - cos ang) - (u.z * (sin ang))) -- X\nmatrix[2][2] = ((cos ang) + (u.y ^ 2) * (1 - cos ang))           -- Y\nmatrix[2][3] = ((u.z * u.y) * (1 - cos ang) + (u.x * (sin ang))) -- Z\nmatrix[3][1] = ((u.x * u.z) * (1 - cos ang) + (u.y * (sin ang))) -- X\nmatrix[3][2] = ((u.y * u.z) * (1 - cos ang) - (u.x * (sin ang))) -- Y\nmatrix[3][3] = ((cos ang) + (u.z ^ 2) * (1 - cos ang))           -- Z\nrow1 = matrix[1][1] * r.x\nrow2 = matrix[1][2] * r.x\nrow3 = matrix[1][3] * r.x\nrow4 = matrix[2][1] * r.y\nrow5 = matrix[2][2] * r.y\nrow6 = matrix[2][3] * r.y	\nrow7 = matrix[3][1] * r.z\nrow8 = matrix[3][2] * r.z\nrow9 = matrix[3][3] * r.z\nvec = point3 (row1 + row4 + row7) (row2 + row5 + row8) (row3 + row6 + row9)\nvec += axisNode.pos\nvec")
						swivel.position.controller.script=scriptString
						attHolder.offsetAttribute.offset = (360 - swivelAngle)
						-- UnParent swivel 
						swivel.parent = undefined 
						addModifier swivelController attHolder

					)
					
					
					-- ############ ADDING MODIFIERS ############
					-- add mod to the controllers
					addModifier rootController attHolder
					addModifier kneeController attHolder
					addModifier IKController attHolder						
					addModifier swivel attHolder
					
					-- ############ END SCRIPT PREPARATION ############
					select kneeController
					setInheritanceFlags $ #{1..5, 7..9}
					attHolder.rotInfluence = 0.2
					
					print isOffset 
                )
                2: (
					-- ############ CONTROLLER CREATION ############
					rootController = Rectangle transform:jointArray[1].transform name:"rootController" length:(conLength * (140 / 100.0)) width:(conWidth * (140 / 100.0)) cornerRadius:conRadius wirecolor:controllerColor 
					kneeController = Rectangle transform:jointArray[2].transform name:"kneeController" parent:rootController length:conLength width:conWidth cornerRadius:conRadius wirecolor:controllerColor 
					IKController = Rectangle transform:jointArray[4].transform name:"IKController" length:conLength width:conWidth cornerRadius:conRadius wirecolor:controllerColor 
					-- link the first bone to rootController
					boneArray[1].parent = rootController
					IKOffsetController = Rectangle transform:jointArray[4].transform name:"IKOffsetController" parent:IKController length:(conLength * (100.0 / conParentMult)) width:(conWidth * (100.0 / conParentMult)) cornerRadius:conRadius wirecolor:controllerColor 

						
						
					if conThickCheck then (			
						rootController.render_displayRenderMesh = true
						rootController.render_thickness = conThickness	
						kneeController.render_displayRenderMesh = true
						kneeController.render_thickness = conThickness							
						IKController.render_displayRenderMesh = true
						IKController.render_thickness = conThickness
						IKOffsetController.render_displayRenderMesh = true
						IKOffsetController.render_thickness = conThickness
						) else (
							rootController.render_displayRenderMesh = false
							IKController.render_displayRenderMesh = false
							IKOffsetController.render_displayRenderMesh = false
							kneeController.render_displayRenderMesh = false
							)
						
						
						
					-- ############ IK [1:2] CREATION ############
					boneOneID = (getAppData jointArray[1] 100) as integer
					boneTwoID = (getAppData jointArray[2] 100) as integer 
					boneOne = boneArray[boneOneID]
					boneTwo = boneArray[boneTwoID]
					try
					(
						ikHelper = ikSys.ikChain boneOne boneTwo "IKHISolver" 
						ikHelper.transform.controller.SAParent = 0
					) 
					catch
					(
						ikHelper = ikSys.ikChain boneTwo boneOne "IKHISolver"
						ikHelper.transform.controller.SAParent = 0
					)
					ikHelper.transform = jointArray[2].transform
					ikHelper.parent = KneeController
					ikHelper.wirecolor = swivelControllerPointColor

					-- ############ IK [2:4] CREATION ############
					swivel = jointArray[5]
					deleteItem jointArray 5 -- delete from array to avoid deleting
                    boneOneID = (getAppData jointArray[2] 100) as integer
                    boneTwoID = (getAppData jointArray[4] 100) as integer 
                    boneOne = boneArray[boneOneID]
                    boneTwo = boneArray[boneTwoID]
                    try
                    (
                        ikHelper = ikSys.ikChain boneOne boneTwo "IKHISolver" 
                        ikHelper.transform.controller.VHTarget = swivel
                    ) 
                    catch
                    (
                        ikHelper = ikSys.ikChain boneTwo boneOne "IKHISolver" 
                        ikHelper.transform.controller.VHTarget = swivel
                    )
                    ikHelper.parent = IKOffsetController
					swivel.parent = IKOffsetController
					ikHelper.wirecolor = swivelControllerPointColor

					-- ############ ROTATION SCRIPT ############
					attHolder = EmptyModifier name:"Offset Control"
					ROTATE_DEF = attributes rotateAttribute
					(
						Parameters main rollout:params
						(
							rotInfluence type:#float UI:rotInfluence Default:0.0 Range:[0,1,0.0]
						)
						Rollout Params "Rotation Influence"
						(
							spinner 'rotInfluence' "Rotation" Width:160 Height:16 Align:#Center Type:#float Range:[0,1,0.0] scale:1
						)
					)
					kneeController.transform = jointArray[2].transform
					-- add attribute to the holder
					CustAttributes.add attHolder ROTATE_DEF #Unique 
					-- rotation infuence 
					nod = KneeController
					nod.rotation.controller = rotation_list()
					aString = "rotX = (a.x_rotation * val + b.x_rotation * val)"
					bString = "rotY = (a.y_rotation * val + b.y_rotation * val)"
					cString = "rotZ = (a.z_rotation * val + b.z_rotation * val)"
					dString = ("eulerangles rotX rotY rotZ")
					result = (aString + "\n" + bString + "\n" + cString + "\n" + dString)
					RS = rotation_script()
					nod.rotation.controller.Available.controller = RS
					RS.addObject "a" rootController.rotation.controller
					RS.addObject "b" IKController.rotation.controller
					RS.AddTarget "val" attHolder.rotateAttribute[#rotInfluence]
					RS.script=result
					
					-- ############ POSITION SCRIPT ############
					-- define attribute and attribute holder 
					OFFSET_DEF = attributes influenceAttribute
					(
						Parameters main rollout:params
						(
							influence type:#float UI:influence Default:20 Range:[0,100,20]
						)
						Rollout Params "Position Influence"
						(
							spinner 'influence' "Influence" Width:160 Height:16 Align:#Center Type:#float Range:[0,100,20] scale:1
						)
					)
					-- add attribute to the holder
					CustAttributes.add attHolder OFFSET_DEF #Unique 
					-- create list controller for infuence node (KneeController)
					kneeController.pos.controller = position_list()
					-- assign the first node and controller (Root Controller)
					posCon2 = Position_Constraint()
					kneeController.pos.controller.Available.controller = posCon2
					posCon2.appendTarget IKController 100
					posCon2.relative = true
					kneeController.pos.controller.weight[2] = 20
					-- wire connect the attribute to second position constraint weight
					paramWire.connect attHolder.influenceAttribute[#influence] (getSubAnim kneeController.transform.controller.Position.controller.weight 2) "influence/100"
					posCon2 = Position_XYZ()
					kneeController.pos.controller.Available.controller = posCon2
					kneeController.pos.controller.setActive 3


					-- ############ RESET TRANSFORM SCRIPT ############
					attHolder2 = EmptyModifier name:"Freeze Transform"
					addModifier kneeController attHolder2
					OFFSET_DEF = attributes freezeAttribute
					(
						Parameters main rollout:params
						(
							transformData type:#string default:"(matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])"
						)
						Rollout Params "Offset Parameter"
						(
							button UI_store "Store Transform"  height:26 width:160 align:#center
							button UI_reset "Reset Transform"  height:26 width:160 align:#center
							on UI_store pressed do (
								val = yesNoCancelBox "Overwriting Stored Transform?" title:"Warning" beep:true 
								if val == #yes then (			
									selfNode = (refs.dependentNodes (custAttributes.getOwner this))[1]
									old = selfNode.modifiers[2].influenceAttribute.influence
									selfNode.modifiers[2].influenceAttribute.influence = 0
									offset = selfNode.transform * inverse selfNode.parent.transform 
									transformData = offset as string 
									selfNode.modifiers[2].influenceAttribute.influence = old 
									)
							   )	
							on UI_reset pressed do (
								selfNode = (refs.dependentNodes (custAttributes.getOwner this))[1]
								old = selfNode.modifiers[2].influenceAttribute.influence
								selfNode.modifiers[2].influenceAttribute.influence = 0
								offset = execute transformData
								selfNode.transform = offset * selfNode.parent.transform 
								selfNode.modifiers[2].influenceAttribute.influence = old 
						   ) 
						)
					)
					CustAttributes.add attHolder2 OFFSET_DEF #Unique 
					
					-- ############ POLE VECTOR OFFSET ############
					if isOffset then (
						OFFSET_DEF = attributes offsetAttribute
						(
							Parameters main rollout:params
							(
								offset type:#float UI:offset
							)
							Rollout Params "Rotation Offset"
							(
								spinner 'offset' "Offset" Width:160 Height:16 Align:#Center Type:#float Range:[0,360,270] scale:1
							)
						)
						-- add attribute to the holder
						CustAttributes.add attHolder OFFSET_DEF #Unique 
						
						dir = IKArray[1][3].parent.dir 
						testPos = rotVecAroundAxis (IKArray[1][3].pos - (IKArray[1][2].pos)) dir (swivelAngle)
						testPos += IKController.pos
						swivelController = point name:"swivelController" pos:testPos parent:IKOffsetController size:10 wirecolor:swivelControllerPointColor centermarker:false cross:false axistripod:true Box:false constantscreensize:false drawontop:false 
						swivel.name = "Swivel" 
						swivel.wirecolor = swivelControllerPointColor
						swivel.position.controller=position_script()
						swivel.position.controller.addObject "pointNode" swivelController
						swivel.position.controller.addObject "axisNode" IKOffsetController
						swivel.position.controller.addTarget "a" (getSubAnim attHolder.offsetAttribute 1)
						scriptString =  ("r = (pointNode.pos - (axisNode.pos))\nu = (([0, 0, 1] * axisNode.transform) - axisNode.pos)\nang = -a\nu = normalize(u)\nmatrix = #((point3 1 0 0), (point3 0 1 0), (point3 0 0 1))\nmatrix[1][1] = ((cos ang) + (u.x ^ 2) * (1 - cos ang))           -- X\nmatrix[1][2] = ((u.y * u.x) * (1 - cos ang) + (u.z * (sin ang))) -- Y\nmatrix[1][3] = ((u.z * u.x) * (1 - cos ang) - (u.y * (sin ang))) -- Z\nmatrix[2][1] = ((u.x * u.y) * (1 - cos ang) - (u.z * (sin ang))) -- X\nmatrix[2][2] = ((cos ang) + (u.y ^ 2) * (1 - cos ang))           -- Y\nmatrix[2][3] = ((u.z * u.y) * (1 - cos ang) + (u.x * (sin ang))) -- Z\nmatrix[3][1] = ((u.x * u.z) * (1 - cos ang) + (u.y * (sin ang))) -- X\nmatrix[3][2] = ((u.y * u.z) * (1 - cos ang) - (u.x * (sin ang))) -- Y\nmatrix[3][3] = ((cos ang) + (u.z ^ 2) * (1 - cos ang))           -- Z\nrow1 = matrix[1][1] * r.x\nrow2 = matrix[1][2] * r.x\nrow3 = matrix[1][3] * r.x\nrow4 = matrix[2][1] * r.y\nrow5 = matrix[2][2] * r.y\nrow6 = matrix[2][3] * r.y	\nrow7 = matrix[3][1] * r.z\nrow8 = matrix[3][2] * r.z\nrow9 = matrix[3][3] * r.z\nvec = point3 (row1 + row4 + row7) (row2 + row5 + row8) (row3 + row6 + row9)\nvec += axisNode.pos\nvec")
						swivel.position.controller.script=scriptString
						attHolder.offsetAttribute.offset = (swivelAngle)
						-- UnParent swivel 
						swivel.parent = undefined
						addModifier swivelController attHolder
					)
					
					-- ############ ADDING MODIFIERS ############
					-- add mod to the controllers
					addModifier rootController attHolder
					addModifier kneeController attHolder
					addModifier IKController attHolder						
					addModifier swivel attHolder
					
					
					-- ############ END SCRIPT PREPARATION ############
					select kneeController
					setInheritanceFlags $ #{1..5, 7..9}
					attHolder.rotInfluence = 0.2
					
					print isOffset 
                )
                3: (
					-- ############ CONTROLLER CREATION ############
					rootController = Rectangle transform:jointArray[1].transform name:"rootController" length:(conLength * (conParentMult / 100.0)) width:(conWidth * (conParentMult / 100.0)) cornerRadius:conRadius wirecolor:controllerColor 
					IKController = Rectangle transform:jointArray[3].transform name:"IKController" length:conLength width:conWidth cornerRadius:conRadius wirecolor:controllerColor 
					-- link the first bone to rootController
					boneArray[1].parent = rootController
					IKOffsetController = Rectangle transform:jointArray[3].transform name:"IKOffsetController" parent:IKController length:(conLength * (100.0 / conParentMult)) width:(conWidth * (100.0 / conParentMult)) cornerRadius:conRadius wirecolor:controllerColor 
					tipController = Rectangle transform:jointArray[4].transform name:"tipController" parent:IKController length:conLength width:conWidth cornerRadius:conRadius wirecolor:controllerColor 
							


						
					if conThickCheck then (	
						tipController.render_displayRenderMesh = true
						tipController.render_thickness = conThickness							
						rootController.render_displayRenderMesh = true
						rootController.render_thickness = conThickness	
						IKController.render_displayRenderMesh = true
						IKController.render_thickness = conThickness
						IKOffsetController.render_displayRenderMesh = true
						IKOffsetController.render_thickness = conThickness
						) else (
							rootController.render_displayRenderMesh = false
							IKController.render_displayRenderMesh = false
							IKOffsetController.render_displayRenderMesh = false
							tipController.render_displayRenderMesh = false
							)

						
					-- ############ IK [1:3] CREATION ############
					swivel = jointArray[5]
					deleteItem jointArray 5 -- delete from array to avoid deleting
					
                    boneOneID = (getAppData jointArray[1] 100) as integer
                    boneTwoID = (getAppData jointArray[3] 100) as integer 
                    boneOne = boneArray[boneOneID]
                    boneTwo = boneArray[boneTwoID]
                    try
                    (
                        ikHelper = ikSys.ikChain boneOne boneTwo "IKHISolver" 
                        ikHelper.transform.controller.VHTarget = swivel
                    ) 
                    catch
                    (
                        ikHelper = ikSys.ikChain boneTwo boneOne "IKHISolver" 
                        ikHelper.transform.controller.VHTarget = swivel
                    )
                    ikHelper.parent = IKOffsetController
					swivel.parent = IKOffsetController
					ikHelper.wirecolor = swivelControllerPointColor
					-- ############ ONE IK [3:4] CREATION ############
                    boneOneID = (getAppData jointArray[3] 100) as integer
                    boneTwoID = (getAppData jointArray[4] 100) as integer 
                    boneOne = boneArray[boneOneID]
                    boneTwo = boneArray[boneTwoID]
                    try
                    (
                        ikHelper = ikSys.ikChain boneOne boneTwo "IKHISolver" 
						d = dummy name:"goalHelper" scale:[0.5, 0.5, 0.5] transform:boneArray[4].transform parent:tipController
						ikHelper.parent = d
						ikHelper.transform.controller.SAParent = 0
                    ) 
                    catch
                    (
                        ikHelper = ikSys.ikChain boneTwo boneOne "IKHISolver" 
						d = dummy name:"goalHelper" scale:[0.5, 0.5, 0.5] size:2 transform:boneArray[4].transform parent:tipController
						ikHelper.parent = d
						ikHelper.transform.controller.SAParent = 0
                    )
					ikHelper.wirecolor = swivelControllerPointColor
					-- ############ POLE VECTOR OFFSET ############
					if isOffset then (
						attHolder = EmptyModifier name:"Offset Control"
						OFFSET_DEF = attributes offsetAttribute
						(
							Parameters main rollout:params
							(
								offset type:#float UI:offset
							)
							Rollout Params "Rotation Offset"
							(
								spinner 'offset' "Offset" Width:160 Height:16 Align:#Center Type:#float Range:[0,360,270] scale:1
							)
						)
						-- add attribute to the holder
						CustAttributes.add attHolder OFFSET_DEF #Unique 
						
						dir = IKArray[1][3].parent.dir 
						testPos = rotVecAroundAxis (IKArray[1][3].pos - (IKArray[1][2].pos)) dir (360 - swivelAngle)
						testPos += IKController.pos
						swivelController = point name:"swivelController" pos:testPos parent:IKOffsetController size:10 wirecolor:swivelControllerPointColor centermarker:false cross:false axistripod:true Box:false constantscreensize:false drawontop:false 
						swivel.name = "Swivel" 
						swivel.wirecolor = swivelControllerPointColor
						swivel.position.controller=position_script()
						swivel.position.controller.addObject "pointNode" swivelController
						swivel.position.controller.addObject "axisNode" IKOffsetController
						swivel.position.controller.addTarget "a" (getSubAnim attHolder.offsetAttribute 1)
						scriptString =  ("r = (pointNode.pos - (axisNode.pos))\nu = (([0, 0, 1] * axisNode.transform) - axisNode.pos)\nang = -a\nu = normalize(u)\nmatrix = #((point3 1 0 0), (point3 0 1 0), (point3 0 0 1))\nmatrix[1][1] = ((cos ang) + (u.x ^ 2) * (1 - cos ang))           -- X\nmatrix[1][2] = ((u.y * u.x) * (1 - cos ang) + (u.z * (sin ang))) -- Y\nmatrix[1][3] = ((u.z * u.x) * (1 - cos ang) - (u.y * (sin ang))) -- Z\nmatrix[2][1] = ((u.x * u.y) * (1 - cos ang) - (u.z * (sin ang))) -- X\nmatrix[2][2] = ((cos ang) + (u.y ^ 2) * (1 - cos ang))           -- Y\nmatrix[2][3] = ((u.z * u.y) * (1 - cos ang) + (u.x * (sin ang))) -- Z\nmatrix[3][1] = ((u.x * u.z) * (1 - cos ang) + (u.y * (sin ang))) -- X\nmatrix[3][2] = ((u.y * u.z) * (1 - cos ang) - (u.x * (sin ang))) -- Y\nmatrix[3][3] = ((cos ang) + (u.z ^ 2) * (1 - cos ang))           -- Z\nrow1 = matrix[1][1] * r.x\nrow2 = matrix[1][2] * r.x\nrow3 = matrix[1][3] * r.x\nrow4 = matrix[2][1] * r.y\nrow5 = matrix[2][2] * r.y\nrow6 = matrix[2][3] * r.y	\nrow7 = matrix[3][1] * r.z\nrow8 = matrix[3][2] * r.z\nrow9 = matrix[3][3] * r.z\nvec = point3 (row1 + row4 + row7) (row2 + row5 + row8) (row3 + row6 + row9)\nvec += axisNode.pos\nvec")
						swivel.position.controller.script=scriptString
						attHolder.offsetAttribute.offset = (360 - swivelAngle)
						-- UnParent swivel 
						swivel.parent = undefined
						addModifier swivelController attHolder
					)
					

                )
                4: (
					-- ############ CONTROLLER CREATION ############
					rootController = Rectangle transform:jointArray[1].transform name:"rootController" length:(conLength * (conParentMult / 100.0)) width:(conWidth * (conParentMult / 100.0)) cornerRadius:conRadius wirecolor:controllerColor 
					IKController = Rectangle transform:jointArray[3].transform name:"IKController" length:conLength width:conWidth cornerRadius:conRadius wirecolor:controllerColor 
					-- link the first bone to rootController
					boneArray[1].parent = rootController
					IKOffsetController = Rectangle transform:jointArray[3].transform name:"IKOffsetController" parent:IKController length:(conLength * (100.0 / conParentMult)) width:(conWidth * (100.0 / conParentMult)) cornerRadius:conRadius wirecolor:controllerColor 
					tipController = Rectangle transform:jointArray[4].transform name:"tipController" parent:IKController length:conLength width:conWidth cornerRadius:conRadius wirecolor:controllerColor 
						



						
					if conThickCheck then (	
						tipController.render_displayRenderMesh = true
						tipController.render_thickness = conThickness							
						rootController.render_displayRenderMesh = true
						rootController.render_thickness = conThickness	
						IKController.render_displayRenderMesh = true
						IKController.render_thickness = conThickness
						IKOffsetController.render_displayRenderMesh = true
						IKOffsetController.render_thickness = conThickness
						) else (
							rootController.render_displayRenderMesh = false
							IKController.render_displayRenderMesh = false
							IKOffsetController.render_displayRenderMesh = false
							tipController.render_displayRenderMesh = false
							)


						
					-- ############ IK [1:3] CREATION ############
					swivel = jointArray[5]
					deleteItem jointArray 5 -- delete from array to avoid deleting
					
                    boneOneID = (getAppData jointArray[1] 100) as integer
                    boneTwoID = (getAppData jointArray[3] 100) as integer 
                    boneOne = boneArray[boneOneID]
                    boneTwo = boneArray[boneTwoID]
                    try
                    (
                        ikHelper = ikSys.ikChain boneOne boneTwo "IKHISolver" 
                        ikHelper.transform.controller.VHTarget = swivel
                    ) 
                    catch
                    (
                        ikHelper = ikSys.ikChain boneTwo boneOne "IKHISolver" 
                        ikHelper.transform.controller.VHTarget = swivel
                    )
                    ikHelper.parent = IKOffsetController
					swivel.parent = IKOffsetController
					ikHelper.wirecolor = swivelControllerPointColor
					-- ############ ONE IK [3:4] CREATION ############
                    boneOneID = (getAppData jointArray[3] 100) as integer
                    boneTwoID = (getAppData jointArray[4] 100) as integer 
                    boneOne = boneArray[boneOneID]
                    boneTwo = boneArray[boneTwoID]
                    try
                    (
                        ikHelper = ikSys.ikChain boneOne boneTwo "IKHISolver" 
						d = dummy name:"goalHelper" scale:[0.5, 0.5, 0.5] transform:boneArray[4].transform parent:tipController
						ikHelper.parent = d
						ikHelper.transform.controller.SAParent = 0
                    ) 
                    catch
                    (
                        ikHelper = ikSys.ikChain boneTwo boneOne "IKHISolver" 
						d = dummy name:"goalHelper" scale:[0.5, 0.5, 0.5] size:2 transform:boneArray[4].transform parent:tipController
						ikHelper.parent = d
						ikHelper.transform.controller.SAParent = 0
                    )
					ikHelper.wirecolor = swivelControllerPointColor
					-- ############ POLE VECTOR OFFSET ############
					if isOffset then (
						attHolder = EmptyModifier name:"Offset Control"
						OFFSET_DEF = attributes offsetAttribute
						(
							Parameters main rollout:params
							(
								offset type:#float UI:offset
							)
							Rollout Params "Rotation Offset"
							(
								spinner 'offset' "Offset" Width:160 Height:16 Align:#Center Type:#float Range:[0,360,270] scale:1
							)
						)
						-- add attribute to the holder
						CustAttributes.add attHolder OFFSET_DEF #Unique 
						
						dir = IKArray[1][3].parent.dir 
						testPos = rotVecAroundAxis (IKArray[1][3].pos - (IKArray[1][2].pos)) dir (swivelAngle)
						testPos += IKController.pos
						swivelController = point name:"swivelController" pos:testPos parent:IKOffsetController size:10 wirecolor:swivelControllerPointColor centermarker:false cross:false axistripod:true Box:false constantscreensize:false drawontop:false 
						swivel.name = "Swivel" 
						swivel.wirecolor = swivelControllerPointColor
						swivel.position.controller=position_script()
						swivel.position.controller.addObject "pointNode" swivelController
						swivel.position.controller.addObject "axisNode" IKOffsetController
						swivel.position.controller.addTarget "a" (getSubAnim attHolder.offsetAttribute 1)
						scriptString =  ("r = (pointNode.pos - (axisNode.pos))\nu = (([0, 0, 1] * axisNode.transform) - axisNode.pos)\nang = -a\nu = normalize(u)\nmatrix = #((point3 1 0 0), (point3 0 1 0), (point3 0 0 1))\nmatrix[1][1] = ((cos ang) + (u.x ^ 2) * (1 - cos ang))           -- X\nmatrix[1][2] = ((u.y * u.x) * (1 - cos ang) + (u.z * (sin ang))) -- Y\nmatrix[1][3] = ((u.z * u.x) * (1 - cos ang) - (u.y * (sin ang))) -- Z\nmatrix[2][1] = ((u.x * u.y) * (1 - cos ang) - (u.z * (sin ang))) -- X\nmatrix[2][2] = ((cos ang) + (u.y ^ 2) * (1 - cos ang))           -- Y\nmatrix[2][3] = ((u.z * u.y) * (1 - cos ang) + (u.x * (sin ang))) -- Z\nmatrix[3][1] = ((u.x * u.z) * (1 - cos ang) + (u.y * (sin ang))) -- X\nmatrix[3][2] = ((u.y * u.z) * (1 - cos ang) - (u.x * (sin ang))) -- Y\nmatrix[3][3] = ((cos ang) + (u.z ^ 2) * (1 - cos ang))           -- Z\nrow1 = matrix[1][1] * r.x\nrow2 = matrix[1][2] * r.x\nrow3 = matrix[1][3] * r.x\nrow4 = matrix[2][1] * r.y\nrow5 = matrix[2][2] * r.y\nrow6 = matrix[2][3] * r.y	\nrow7 = matrix[3][1] * r.z\nrow8 = matrix[3][2] * r.z\nrow9 = matrix[3][3] * r.z\nvec = point3 (row1 + row4 + row7) (row2 + row5 + row8) (row3 + row6 + row9)\nvec += axisNode.pos\nvec")
						swivel.position.controller.script=scriptString
						attHolder.offsetAttribute.offset = (swivelAngle)
						-- UnParent swivel 
						swivel.parent = undefined
						addModifier swivelController attHolder
					)
                )
            )
        )
		
		3: (
			case setupType of 
            (
				1: (
					rootController = Rectangle transform:jointArray[1].transform name:"rootController" length:(conLength * (conParentMult / 100.0)) width:(conWidth * (conParentMult / 100.0)) cornerRadius:conRadius wirecolor:controllerColor 
					IKController = Rectangle transform:jointArray[5].transform name:"IKController" length:conLength width:conWidth cornerRadius:conRadius wirecolor:controllerColor 
					-- link the first bone to rootController
					boneArray[1].parent = rootController
					IKOffsetController = Rectangle transform:jointArray[5].transform name:"IKOffsetController" parent:IKController length:(conLength * (100.0 / conParentMult)) width:(conWidth * (100.0 / conParentMult)) cornerRadius:conRadius wirecolor:controllerColor 
					

						
					if conThickCheck then (	
						rootController.render_displayRenderMesh = true
						rootController.render_thickness = conThickness	
						IKController.render_displayRenderMesh = true
						IKController.render_thickness = conThickness
						IKOffsetController.render_displayRenderMesh = true
						IKOffsetController.render_thickness = conThickness
						) else (
							rootController.render_displayRenderMesh = false
							IKController.render_displayRenderMesh = false
							IKOffsetController.render_displayRenderMesh = false
							)
						
					-- ############ IK [1:5] CREATION ############
					swivel = jointArray[6]
					deleteItem jointArray 6 -- delete from array to avoid deleting
                    boneOneID = (getAppData jointArray[1] 100) as integer
                    boneTwoID = (getAppData jointArray[5] 100) as integer 
                    boneOne = boneArray[boneOneID]
                    boneTwo = boneArray[boneTwoID]
                    try
                    (
                        ikHelper = ikSys.ikChain boneOne boneTwo "IKHISolver" 
                        ikHelper.transform.controller.VHTarget = swivel
                    ) 
                    catch
                    (
                        ikHelper = ikSys.ikChain boneTwo boneOne "IKHISolver" 
                        ikHelper.transform.controller.VHTarget = swivel
                    )
                    ikHelper.parent = IKOffsetController
					swivel.parent = IKOffsetController
					ikHelper.wirecolor = swivelControllerPointColor

					-- ############ POLE VECTOR OFFSET ############
					if isOffset then (
						attHolder = EmptyModifier name:"Offset Control"
						OFFSET_DEF = attributes offsetAttribute
						(
							Parameters main rollout:params
							(
								offset type:#float UI:offset
							)
							Rollout Params "Rotation Offset"
							(
								spinner 'offset' "Offset" Width:160 Height:16 Align:#Center Type:#float Range:[0,360,270] scale:1
							)
						)
						-- add attribute to the holder
						CustAttributes.add attHolder OFFSET_DEF #Unique 
						
						dir = IKArray[1][3].parent.dir 
						testPos = rotVecAroundAxis (IKArray[1][3].pos - (IKArray[1][2].pos)) dir (swivelAngle)
						testPos += IKController.pos
						swivelController = point name:"swivelController" pos:testPos parent:IKOffsetController size:10 wirecolor:swivelControllerPointColor centermarker:false cross:false axistripod:true Box:false constantscreensize:false drawontop:false 
						swivel.name = "Swivel" 
						swivel.wirecolor = swivelControllerPointColor
						swivel.position.controller=position_script()
						swivel.position.controller.addObject "pointNode" swivelController
						swivel.position.controller.addObject "axisNode" IKOffsetController
						swivel.position.controller.addTarget "a" (getSubAnim attHolder.offsetAttribute 1)
						scriptString =  ("r = (pointNode.pos - (axisNode.pos))\nu = (([0, 0, 1] * axisNode.transform) - axisNode.pos)\nang = -a\nu = normalize(u)\nmatrix = #((point3 1 0 0), (point3 0 1 0), (point3 0 0 1))\nmatrix[1][1] = ((cos ang) + (u.x ^ 2) * (1 - cos ang))           -- X\nmatrix[1][2] = ((u.y * u.x) * (1 - cos ang) + (u.z * (sin ang))) -- Y\nmatrix[1][3] = ((u.z * u.x) * (1 - cos ang) - (u.y * (sin ang))) -- Z\nmatrix[2][1] = ((u.x * u.y) * (1 - cos ang) - (u.z * (sin ang))) -- X\nmatrix[2][2] = ((cos ang) + (u.y ^ 2) * (1 - cos ang))           -- Y\nmatrix[2][3] = ((u.z * u.y) * (1 - cos ang) + (u.x * (sin ang))) -- Z\nmatrix[3][1] = ((u.x * u.z) * (1 - cos ang) + (u.y * (sin ang))) -- X\nmatrix[3][2] = ((u.y * u.z) * (1 - cos ang) - (u.x * (sin ang))) -- Y\nmatrix[3][3] = ((cos ang) + (u.z ^ 2) * (1 - cos ang))           -- Z\nrow1 = matrix[1][1] * r.x\nrow2 = matrix[1][2] * r.x\nrow3 = matrix[1][3] * r.x\nrow4 = matrix[2][1] * r.y\nrow5 = matrix[2][2] * r.y\nrow6 = matrix[2][3] * r.y	\nrow7 = matrix[3][1] * r.z\nrow8 = matrix[3][2] * r.z\nrow9 = matrix[3][3] * r.z\nvec = point3 (row1 + row4 + row7) (row2 + row5 + row8) (row3 + row6 + row9)\nvec += axisNode.pos\nvec")
						swivel.position.controller.script=scriptString
						attHolder.offsetAttribute.offset = (swivelAngle)
						-- UnParent swivel 
						swivel.parent = undefined
						addModifier swivelController attHolder
					)
					
				)
				
				2: (
					-- ############ CONTROLLER CREATION ############
					rootController = Rectangle transform:jointArray[1].transform name:"rootController" length:(conLength * (conParentMult / 100.0)) width:(conWidth * (conParentMult / 100.0)) cornerRadius:conRadius wirecolor:controllerColor 
					kneeController = Rectangle transform:jointArray[2].transform name:"kneeController" parent:rootController length:conLength width:conWidth cornerRadius:conRadius wirecolor:controllerColor 
					IKController = Rectangle transform:jointArray[5].transform name:"IKController" length:conLength width:conWidth cornerRadius:conRadius wirecolor:controllerColor 
					-- link the first bone to rootController
					boneArray[1].parent = rootController
					IKOffsetController = Rectangle transform:jointArray[5].transform name:"IKOffsetController" parent:IKController length:(conLength * (100.0 / conParentMult)) width:(conWidth * (100.0 / conParentMult)) cornerRadius:conRadius wirecolor:controllerColor 

					
					if conThickCheck then (	
						rootController.render_displayRenderMesh = true
						rootController.render_thickness = conThickness	
						IKController.render_displayRenderMesh = true
						IKController.render_thickness = conThickness
						kneeController.render_displayRenderMesh = true
						kneeController.render_thickness = conThickness
						IKOffsetController.render_displayRenderMesh = true
						IKOffsetController.render_thickness = conThickness
						) else (
							rootController.render_displayRenderMesh = false
							IKController.render_displayRenderMesh = false
							IKOffsetController.render_displayRenderMesh = false
							kneeController.render_displayRenderMesh = false
							)	
						
					-- ############ IK [1:2] CREATION ############
					boneOneID = (getAppData jointArray[1] 100) as integer
					boneTwoID = (getAppData jointArray[2] 100) as integer 
					boneOne = boneArray[boneOneID]
					boneTwo = boneArray[boneTwoID]
					try
					(
						ikHelper = ikSys.ikChain boneOne boneTwo "IKHISolver" 
						ikHelper.transform.controller.SAParent = 0
					) 
					catch
					(
						ikHelper = ikSys.ikChain boneTwo boneOne "IKHISolver"
						ikHelper.transform.controller.SAParent = 0
					)
					ikHelper.transform = jointArray[2].transform
					ikHelper.parent = KneeController
					ikHelper.wirecolor = swivelControllerPointColor
					-- ############ IK [2:5] CREATION ############
					swivel = jointArray[6]
					deleteItem jointArray 6 -- delete from array to avoid deleting
                    boneOneID = (getAppData jointArray[2] 100) as integer
                    boneTwoID = (getAppData jointArray[5] 100) as integer 
                    boneOne = boneArray[boneOneID]
                    boneTwo = boneArray[boneTwoID]
                    try
                    (
                        ikHelper = ikSys.ikChain boneOne boneTwo "IKHISolver" 
                        ikHelper.transform.controller.VHTarget = swivel
                    ) 
                    catch
                    (
                        ikHelper = ikSys.ikChain boneTwo boneOne "IKHISolver" 
                        ikHelper.transform.controller.VHTarget = swivel
                    )
                    ikHelper.parent = IKOffsetController
					swivel.parent = IKOffsetController
					ikHelper.wirecolor = swivelControllerPointColor

					
					-- ############ POSITION SCRIPT ############
					-- define attribute and attribute holder 
					attHolder = EmptyModifier name:"Offset Control"
					OFFSET_DEF = attributes influenceAttribute
					(
						Parameters main rollout:params
						(
							influence type:#float UI:influence Default:20 Range:[0,100,20]
						)
						Rollout Params "Position Influence"
						(
							spinner 'influence' "Influence" Width:160 Height:16 Align:#Center Type:#float Range:[0,100,20] scale:1
						)
					)
					-- add attribute to the holder
					CustAttributes.add attHolder OFFSET_DEF #Unique 
					-- create list controller for infuence node (KneeController)
					kneeController.pos.controller = position_list()
					-- assign the first node and controller (Root Controller)
					posCon2 = Position_Constraint()
					kneeController.pos.controller.Available.controller = posCon2
					posCon2.appendTarget IKController 100
					posCon2.relative = true
					kneeController.pos.controller.weight[2] = 20
					-- wire connect the attribute to second position constraint weight
					paramWire.connect attHolder.influenceAttribute[#influence] (getSubAnim kneeController.transform.controller.Position.controller.weight 2) "influence/100"
					posCon2 = Position_XYZ()
					kneeController.pos.controller.Available.controller = posCon2
					kneeController.pos.controller.setActive 3

					
					-- ############ RESET TRANSFORM SCRIPT ############
					attHolder2 = EmptyModifier name:"Freeze Transform"
					OFFSET_DEF = attributes freezeAttribute
					(
						Parameters main rollout:params
						(
							transformData type:#string default:"(matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])"
						)
						Rollout Params "Offset Parameter"
						(
							button UI_store "Store Transform"  height:26 width:160 align:#center
							button UI_reset "Reset Transform"  height:26 width:160 align:#center
							on UI_store pressed do (
								val = yesNoCancelBox "Overwriting Stored Transform?" title:"Warning" beep:true 
								if val == #yes then (			
									selfNode = (refs.dependentNodes (custAttributes.getOwner this))[1]
									old = selfNode.modifiers[2].influenceAttribute.influence
									selfNode.modifiers[2].influenceAttribute.influence = 0
									offset = selfNode.transform * inverse selfNode.parent.transform 
									transformData = offset as string 
									selfNode.modifiers[2].influenceAttribute.influence = old 
									)
							   )	
							on UI_reset pressed do (
								selfNode = (refs.dependentNodes (custAttributes.getOwner this))[1]
								old = selfNode.modifiers[2].influenceAttribute.influence
								selfNode.modifiers[2].influenceAttribute.influence = 0
								offset = execute transformData
								selfNode.transform = offset * selfNode.parent.transform 
								selfNode.modifiers[2].influenceAttribute.influence = old 
						   ) 
						)
					)
					CustAttributes.add attHolder2 OFFSET_DEF #Unique 
					
					-- ############ POLE VECTOR OFFSET ############
					if isOffset then (
						--attHolder = EmptyModifier name:"Offset Control"
						OFFSET_DEF = attributes offsetAttribute
						(
							Parameters main rollout:params
							(
								offset type:#float UI:offset
							)
							Rollout Params "Rotation Offset"
							(
								spinner 'offset' "Offset" Width:160 Height:16 Align:#Center Type:#float Range:[0,360,270] scale:1
							)
						)
						-- add attribute to the holder
						CustAttributes.add attHolder OFFSET_DEF #Unique 
						
						dir = IKArray[1][3].parent.dir 
						testPos = rotVecAroundAxis (IKArray[1][3].pos - (IKArray[1][2].pos)) dir (swivelAngle)
						testPos += IKController.pos
						swivelController = point name:"swivelController" pos:testPos parent:IKOffsetController size:10 wirecolor:swivelControllerPointColor centermarker:false cross:false axistripod:true Box:false constantscreensize:false drawontop:false 
						swivel.name = "Swivel" 
						swivel.wirecolor = swivelControllerPointColor
						swivel.position.controller=position_script()
						swivel.position.controller.addObject "pointNode" swivelController
						swivel.position.controller.addObject "axisNode" IKOffsetController
						swivel.position.controller.addTarget "a" (getSubAnim attHolder.offsetAttribute 1)
						scriptString =  ("r = (pointNode.pos - (axisNode.pos))\nu = (([0, 0, 1] * axisNode.transform) - axisNode.pos)\nang = -a\nu = normalize(u)\nmatrix = #((point3 1 0 0), (point3 0 1 0), (point3 0 0 1))\nmatrix[1][1] = ((cos ang) + (u.x ^ 2) * (1 - cos ang))           -- X\nmatrix[1][2] = ((u.y * u.x) * (1 - cos ang) + (u.z * (sin ang))) -- Y\nmatrix[1][3] = ((u.z * u.x) * (1 - cos ang) - (u.y * (sin ang))) -- Z\nmatrix[2][1] = ((u.x * u.y) * (1 - cos ang) - (u.z * (sin ang))) -- X\nmatrix[2][2] = ((cos ang) + (u.y ^ 2) * (1 - cos ang))           -- Y\nmatrix[2][3] = ((u.z * u.y) * (1 - cos ang) + (u.x * (sin ang))) -- Z\nmatrix[3][1] = ((u.x * u.z) * (1 - cos ang) + (u.y * (sin ang))) -- X\nmatrix[3][2] = ((u.y * u.z) * (1 - cos ang) - (u.x * (sin ang))) -- Y\nmatrix[3][3] = ((cos ang) + (u.z ^ 2) * (1 - cos ang))           -- Z\nrow1 = matrix[1][1] * r.x\nrow2 = matrix[1][2] * r.x\nrow3 = matrix[1][3] * r.x\nrow4 = matrix[2][1] * r.y\nrow5 = matrix[2][2] * r.y\nrow6 = matrix[2][3] * r.y	\nrow7 = matrix[3][1] * r.z\nrow8 = matrix[3][2] * r.z\nrow9 = matrix[3][3] * r.z\nvec = point3 (row1 + row4 + row7) (row2 + row5 + row8) (row3 + row6 + row9)\nvec += axisNode.pos\nvec")
						swivel.position.controller.script=scriptString
						attHolder.offsetAttribute.offset = (swivelAngle)
						-- UnParent swivel 
						swivel.parent = undefined
						addModifier swivelController attHolder
					)
					
					
					-- ############ ADDING MODIFIERS ############
					-- add mod to the controllers
					addModifier rootController attHolder
					addModifier kneeController attHolder
					addModifier IKController attHolder	
					addModifier kneeController attHolder2

				)
				
				3: (
					-- ############ CONTROLLER CREATION ############
					rootController = Rectangle transform:jointArray[1].transform name:"rootController" length:(conLength * (conParentMult / 100.0)) width:(conWidth * (conParentMult / 100.0)) cornerRadius:conRadius wirecolor:controllerColor 
					kneeController = Rectangle transform:jointArray[3].transform name:"kneeController" parent:rootController length:conLength width:conWidth cornerRadius:conRadius wirecolor:controllerColor 
					IKController = Rectangle transform:jointArray[5].transform name:"IKController" length:conLength width:conWidth cornerRadius:conRadius wirecolor:controllerColor 
					-- link the first bone to rootController
					boneArray[1].parent = rootController
					IKOffsetController = Rectangle transform:jointArray[5].transform name:"IKOffsetController" parent:IKController length:(conLength * (100.0 / conParentMult)) width:(conWidth * (100.0 / conParentMult)) cornerRadius:conRadius wirecolor:controllerColor 
					
						
						
					if conThickCheck then (	
						rootController.render_displayRenderMesh = true
						rootController.render_thickness = conThickness	
						IKController.render_displayRenderMesh = true
						IKController.render_thickness = conThickness
						kneeController.render_displayRenderMesh = true
						kneeController.render_thickness = conThickness
						IKOffsetController.render_displayRenderMesh = true
						IKOffsetController.render_thickness = conThickness
						) else (
							rootController.render_displayRenderMesh = false
							IKController.render_displayRenderMesh = false
							IKOffsetController.render_displayRenderMesh = false
							kneeController.render_displayRenderMesh = false
							)	
						
						
						
						
					-- ############ IK [1:2] CREATION ############
					boneOneID = (getAppData jointArray[1] 100) as integer
					boneTwoID = (getAppData jointArray[3] 100) as integer 
					boneOne = boneArray[boneOneID]
					boneTwo = boneArray[boneTwoID]
					try
					(
						ikHelper = ikSys.ikChain boneOne boneTwo "IKHISolver" 
						ikHelper.transform.controller.SAParent = 0
					) 
					catch
					(
						ikHelper = ikSys.ikChain boneTwo boneOne "IKHISolver"
						ikHelper.transform.controller.SAParent = 0
					)
					ikHelper.transform = jointArray[3].transform
					ikHelper.parent = KneeController
					ikHelper.wirecolor = swivelControllerPointColor
					-- ############ IK [2:5] CREATION ############
					swivel = jointArray[6]
					deleteItem jointArray 6 -- delete from array to avoid deleting
                    boneOneID = (getAppData jointArray[3] 100) as integer
                    boneTwoID = (getAppData jointArray[5] 100) as integer 
                    boneOne = boneArray[boneOneID]
                    boneTwo = boneArray[boneTwoID]
                    try
                    (
                        ikHelper = ikSys.ikChain boneOne boneTwo "IKHISolver" 
                        ikHelper.transform.controller.VHTarget = swivel
                    ) 
                    catch
                    (
                        ikHelper = ikSys.ikChain boneTwo boneOne "IKHISolver" 
                        ikHelper.transform.controller.VHTarget = swivel
                    )
                    ikHelper.parent = IKOffsetController
					swivel.parent = IKOffsetController
					ikHelper.wirecolor = swivelControllerPointColor

					
					-- ############ POSITION SCRIPT ############
					-- define attribute and attribute holder 
					attHolder = EmptyModifier name:"Offset Control"
					OFFSET_DEF = attributes influenceAttribute
					(
						Parameters main rollout:params
						(
							influence type:#float UI:influence Default:20 Range:[0,100,20]
						)
						Rollout Params "Position Influence"
						(
							spinner 'influence' "Influence" Width:160 Height:16 Align:#Center Type:#float Range:[0,100,20] scale:1
						)
					)
					-- add attribute to the holder
					CustAttributes.add attHolder OFFSET_DEF #Unique 
					-- create list controller for infuence node (KneeController)
					kneeController.pos.controller = position_list()
					-- assign the first node and controller (Root Controller)
					posCon2 = Position_Constraint()
					kneeController.pos.controller.Available.controller = posCon2
					posCon2.appendTarget IKController 100
					posCon2.relative = true
					kneeController.pos.controller.weight[2] = 20
					-- wire connect the attribute to second position constraint weight
					paramWire.connect attHolder.influenceAttribute[#influence] (getSubAnim kneeController.transform.controller.Position.controller.weight 2) "influence/100"
					posCon2 = Position_XYZ()
					kneeController.pos.controller.Available.controller = posCon2
					kneeController.pos.controller.setActive 3

					
					-- ############ RESET TRANSFORM SCRIPT ############
					attHolder2 = EmptyModifier name:"Freeze Transform"
					OFFSET_DEF = attributes freezeAttribute
					(
						Parameters main rollout:params
						(
							transformData type:#string default:"(matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])"
						)
						Rollout Params "Offset Parameter"
						(
							button UI_store "Store Transform"  height:26 width:160 align:#center
							button UI_reset "Reset Transform"  height:26 width:160 align:#center
							on UI_store pressed do (
								val = yesNoCancelBox "Overwriting Stored Transform?" title:"Warning" beep:true 
								if val == #yes then (			
									selfNode = (refs.dependentNodes (custAttributes.getOwner this))[1]
									old = selfNode.modifiers[2].influenceAttribute.influence
									selfNode.modifiers[2].influenceAttribute.influence = 0
									offset = selfNode.transform * inverse selfNode.parent.transform 
									transformData = offset as string 
									selfNode.modifiers[2].influenceAttribute.influence = old 
									)
							   )	
							on UI_reset pressed do (
								selfNode = (refs.dependentNodes (custAttributes.getOwner this))[1]
								old = selfNode.modifiers[2].influenceAttribute.influence
								selfNode.modifiers[2].influenceAttribute.influence = 0
								offset = execute transformData
								selfNode.transform = offset * selfNode.parent.transform 
								selfNode.modifiers[2].influenceAttribute.influence = old 
						   ) 
						)
					)
					CustAttributes.add attHolder2 OFFSET_DEF #Unique 
					
					-- ############ POLE VECTOR OFFSET ############
					if isOffset then (
						--attHolder = EmptyModifier name:"Offset Control"
						OFFSET_DEF = attributes offsetAttribute
						(
							Parameters main rollout:params
							(
								offset type:#float UI:offset
							)
							Rollout Params "Rotation Offset"
							(
								spinner 'offset' "Offset" Width:160 Height:16 Align:#Center Type:#float Range:[0,360,270] scale:1
							)
						)
						-- add attribute to the holder
						CustAttributes.add attHolder OFFSET_DEF #Unique 
						
						dir = IKArray[1][3].parent.dir 
						testPos = rotVecAroundAxis (IKArray[1][3].pos - (IKArray[1][2].pos)) dir (swivelAngle)
						testPos += IKController.pos
						swivelController = point name:"swivelController" pos:testPos parent:IKOffsetController size:10 wirecolor:swivelControllerPointColor centermarker:false cross:false axistripod:true Box:false constantscreensize:false drawontop:false 
						swivel.name = "Swivel" 
						swivel.wirecolor = swivelControllerPointColor
						swivel.position.controller=position_script()
						swivel.position.controller.addObject "pointNode" swivelController
						swivel.position.controller.addObject "axisNode" IKOffsetController
						swivel.position.controller.addTarget "a" (getSubAnim attHolder.offsetAttribute 1)
						scriptString =  ("r = (pointNode.pos - (axisNode.pos))\nu = (([0, 0, 1] * axisNode.transform) - axisNode.pos)\nang = -a\nu = normalize(u)\nmatrix = #((point3 1 0 0), (point3 0 1 0), (point3 0 0 1))\nmatrix[1][1] = ((cos ang) + (u.x ^ 2) * (1 - cos ang))           -- X\nmatrix[1][2] = ((u.y * u.x) * (1 - cos ang) + (u.z * (sin ang))) -- Y\nmatrix[1][3] = ((u.z * u.x) * (1 - cos ang) - (u.y * (sin ang))) -- Z\nmatrix[2][1] = ((u.x * u.y) * (1 - cos ang) - (u.z * (sin ang))) -- X\nmatrix[2][2] = ((cos ang) + (u.y ^ 2) * (1 - cos ang))           -- Y\nmatrix[2][3] = ((u.z * u.y) * (1 - cos ang) + (u.x * (sin ang))) -- Z\nmatrix[3][1] = ((u.x * u.z) * (1 - cos ang) + (u.y * (sin ang))) -- X\nmatrix[3][2] = ((u.y * u.z) * (1 - cos ang) - (u.x * (sin ang))) -- Y\nmatrix[3][3] = ((cos ang) + (u.z ^ 2) * (1 - cos ang))           -- Z\nrow1 = matrix[1][1] * r.x\nrow2 = matrix[1][2] * r.x\nrow3 = matrix[1][3] * r.x\nrow4 = matrix[2][1] * r.y\nrow5 = matrix[2][2] * r.y\nrow6 = matrix[2][3] * r.y	\nrow7 = matrix[3][1] * r.z\nrow8 = matrix[3][2] * r.z\nrow9 = matrix[3][3] * r.z\nvec = point3 (row1 + row4 + row7) (row2 + row5 + row8) (row3 + row6 + row9)\nvec += axisNode.pos\nvec")
						swivel.position.controller.script=scriptString
						attHolder.offsetAttribute.offset = (swivelAngle)
						-- UnParent swivel 
						swivel.parent = undefined
						addModifier swivelController attHolder
					)
					
					
					-- ############ ADDING MODIFIERS ############
					-- add mod to the controllers
					addModifier rootController attHolder
					addModifier kneeController attHolder
					addModifier IKController attHolder	
					addModifier kneeController attHolder2

				)
					
				4: (
					-- ############ CONTROLLER CREATION ############
					rootController = Rectangle transform:jointArray[1].transform name:"rootController" length:(conLength * (conParentMult / 100.0)) width:(conWidth * (conParentMult / 100.0)) cornerRadius:conRadius wirecolor:controllerColor 
					kneeController = Rectangle transform:jointArray[3].transform name:"kneeController" parent:rootController length:conLength width:conWidth cornerRadius:conRadius wirecolor:controllerColor 
					newKneeController = Rectangle transform:jointArray[2].transform name:"kneeController" parent:rootController length:conLength width:conWidth cornerRadius:conRadius wirecolor:controllerColor 
					IKController = Rectangle transform:jointArray[5].transform name:"IKController" length:conLength width:conWidth cornerRadius:conRadius wirecolor:controllerColor 
					-- link the first bone to rootController
					boneArray[1].parent = rootController
					IKOffsetController = Rectangle transform:jointArray[5].transform name:"IKOffsetController" parent:IKController length:(conLength * (100.0 / conParentMult)) width:(conWidth * (100.0 / conParentMult)) cornerRadius:conRadius wirecolor:controllerColor 
					
						
					if conThickCheck then (	
						rootController.render_displayRenderMesh = true
						rootController.render_thickness = conThickness
						newKneeController.render_displayRenderMesh = true
						newKneeController.render_thickness = conThickness	
						IKController.render_displayRenderMesh = true
						IKController.render_thickness = conThickness
						kneeController.render_displayRenderMesh = true
						kneeController.render_thickness = conThickness
						IKOffsetController.render_displayRenderMesh = true
						IKOffsetController.render_thickness = conThickness
						) else (
							rootController.render_displayRenderMesh = false
							IKController.render_displayRenderMesh = false
							IKOffsetController.render_displayRenderMesh = false
							kneeController.render_displayRenderMesh = false
							newKneeController.render_displayRenderMesh = false
							)	
						
						
					-- ############ IK [1:2] CREATION ############
					boneOneID = (getAppData jointArray[1] 100) as integer
					boneTwoID = (getAppData jointArray[2] 100) as integer 
					boneOne = boneArray[boneOneID]
					boneTwo = boneArray[boneTwoID]
					try
					(
						ikHelper = ikSys.ikChain boneOne boneTwo "IKHISolver" 
						--ikHelper.transform.controller.SAParent = 0
						d = dummy name:"goalHelper" scale:[0.5, 0.5, 0.5] transform:boneArray[2].transform parent:newKneeController
						ikHelper.parent = d
						ikHelper.transform.controller.SAParent = 0
					) 
					catch
					(
						ikHelper = ikSys.ikChain boneTwo boneOne "IKHISolver"
						--ikHelper.transform.controller.SAParent = 0
						d = dummy name:"goalHelper" scale:[0.5, 0.5, 0.5] transform:boneArray[2].transform parent:newKneeController
						ikHelper.parent = d
						ikHelper.transform.controller.SAParent = 0
					)
					--ikHelper.transform = jointArray[2].transform
					ikHelper.parent = newKneeController
					ikHelper.wirecolor = swivelControllerPointColor
					
					-- ############ IK [1:2] CREATION ############
					boneOneID = (getAppData jointArray[2] 100) as integer
					boneTwoID = (getAppData jointArray[3] 100) as integer 
					boneOne = boneArray[boneOneID]
					boneTwo = boneArray[boneTwoID]
					try
					(
						ikHelper = ikSys.ikChain boneOne boneTwo "IKHISolver" 
						--ikHelper.transform.controller.SAParent = 0
						d = dummy name:"goalHelper" scale:[0.5, 0.5, 0.5] transform:boneArray[3].transform parent:kneeController
						ikHelper.parent = d
						ikHelper.transform.controller.SAParent = 0
					) 
					catch
					(
						ikHelper = ikSys.ikChain boneTwo boneOne "IKHISolver"
						--ikHelper.transform.controller.SAParent = 0
						d = dummy name:"goalHelper" scale:[0.5, 0.5, 0.5] transform:boneArray[3].transform parent:kneeController
						ikHelper.parent = d
						ikHelper.transform.controller.SAParent = 0
					)
					--ikHelper.transform = jointArray[3].transform
					--ikHelper.parent = kneeController	
					ikHelper.wirecolor = swivelControllerPointColor

					-- ############ IK [2:5] CREATION ############
					swivel = jointArray[6]
					deleteItem jointArray 6 -- delete from array to avoid deleting
                    boneOneID = (getAppData jointArray[3] 100) as integer
                    boneTwoID = (getAppData jointArray[5] 100) as integer 
                    boneOne = boneArray[boneOneID]
                    boneTwo = boneArray[boneTwoID]
                    try
                    (
                        ikHelper = ikSys.ikChain boneOne boneTwo "IKHISolver" 
                        ikHelper.transform.controller.VHTarget = swivel
                    ) 
                    catch
                    (
                        ikHelper = ikSys.ikChain boneTwo boneOne "IKHISolver" 
                        ikHelper.transform.controller.VHTarget = swivel
                    )
					ikHelper.transform = IKController.transform
                    ikHelper.parent = IKOffsetController
					swivel.parent = IKOffsetController
					ikHelper.wirecolor = swivelControllerPointColor					
					
					-- ############ POSITION SCRIPT ############
					-- define attribute and attribute holder 
					attHolder = EmptyModifier name:"Offset Control"
					OFFSET_DEF = attributes influenceAttribute
					(
						Parameters main rollout:params
						(
							influence type:#float UI:influence Default:20 Range:[0,100,20]
						)
						Rollout Params "Position Influence"
						(
							spinner 'influence' "Influence" Width:160 Height:16 Align:#Center Type:#float Range:[0,100,20] scale:1
						)
					)
					-- add attribute to the holder
					CustAttributes.add attHolder OFFSET_DEF #Unique 
					-- create list controller for infuence node (KneeController)
					kneeController.pos.controller = position_list()
					-- assign the first node and controller (Root Controller)
					posCon2 = Position_Constraint()
					kneeController.pos.controller.Available.controller = posCon2
					posCon2.appendTarget IKController 100
					posCon2.relative = true
					kneeController.pos.controller.weight[2] = 20
					-- wire connect the attribute to second position constraint weight
					paramWire.connect attHolder.influenceAttribute[#influence] (getSubAnim kneeController.transform.controller.Position.controller.weight 2) "influence/100"
					posCon2 = Position_XYZ()
					kneeController.pos.controller.Available.controller = posCon2
					kneeController.pos.controller.setActive 3


					-- ############ RESET TRANSFORM SCRIPT ############
					attHolder2 = EmptyModifier name:"Freeze Transform"
					OFFSET_DEF = attributes freezeAttribute
					(
						Parameters main rollout:params
						(
							transformData type:#string default:"(matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])"
						)
						Rollout Params "Offset Parameter"
						(
							button UI_store "Store Transform"  height:26 width:160 align:#center
							button UI_reset "Reset Transform"  height:26 width:160 align:#center
							on UI_store pressed do (
								val = yesNoCancelBox "Overwriting Stored Transform?" title:"Warning" beep:true 
								if val == #yes then (			
									selfNode = (refs.dependentNodes (custAttributes.getOwner this))[1]
									old = selfNode.modifiers[2].influenceAttribute.influence
									selfNode.modifiers[2].influenceAttribute.influence = 0
									offset = selfNode.transform * inverse selfNode.parent.transform 
									transformData = offset as string 
									selfNode.modifiers[2].influenceAttribute.influence = old 
									)
							   )	
							on UI_reset pressed do (
								selfNode = (refs.dependentNodes (custAttributes.getOwner this))[1]
								old = selfNode.modifiers[2].influenceAttribute.influence
								selfNode.modifiers[2].influenceAttribute.influence = 0
								offset = execute transformData
								selfNode.transform = offset * selfNode.parent.transform 
								selfNode.modifiers[2].influenceAttribute.influence = old 
						   ) 
						)
					)
					CustAttributes.add attHolder2 OFFSET_DEF #Unique 
					

					-- ############ POLE VECTOR OFFSET ############
					if isOffset then (
						--attHolder = EmptyModifier name:"Offset Control"
						OFFSET_DEF = attributes offsetAttribute
						(
							Parameters main rollout:params
							(
								offset type:#float UI:offset
							)
							Rollout Params "Rotation Offset"
							(
								spinner 'offset' "Offset" Width:160 Height:16 Align:#Center Type:#float Range:[0,360,270] scale:1
							)
						)
						-- add attribute to the holder
						CustAttributes.add attHolder OFFSET_DEF #Unique 
						
						dir = IKArray[3][3].parent.dir 
						testPos = rotVecAroundAxis (IKArray[3][3].pos - (IKArray[3][2].pos)) dir (swivelAngle)
						testPos += IKController.pos
						swivelController = point name:"swivelController" pos:testPos parent:IKOffsetController size:10 wirecolor:swivelControllerPointColor centermarker:false cross:false axistripod:true Box:false constantscreensize:false drawontop:false 
						swivel.name = "Swivel" 
						swivel.wirecolor = swivelControllerPointColor
						swivel.position.controller=position_script()
						swivel.position.controller.addObject "pointNode" swivelController
						swivel.position.controller.addObject "axisNode" IKOffsetController
						swivel.position.controller.addTarget "a" (getSubAnim attHolder.offsetAttribute 1)
						scriptString =  ("r = (pointNode.pos - (axisNode.pos))\nu = (([0, 0, 1] * axisNode.transform) - axisNode.pos)\nang = -a\nu = normalize(u)\nmatrix = #((point3 1 0 0), (point3 0 1 0), (point3 0 0 1))\nmatrix[1][1] = ((cos ang) + (u.x ^ 2) * (1 - cos ang))           -- X\nmatrix[1][2] = ((u.y * u.x) * (1 - cos ang) + (u.z * (sin ang))) -- Y\nmatrix[1][3] = ((u.z * u.x) * (1 - cos ang) - (u.y * (sin ang))) -- Z\nmatrix[2][1] = ((u.x * u.y) * (1 - cos ang) - (u.z * (sin ang))) -- X\nmatrix[2][2] = ((cos ang) + (u.y ^ 2) * (1 - cos ang))           -- Y\nmatrix[2][3] = ((u.z * u.y) * (1 - cos ang) + (u.x * (sin ang))) -- Z\nmatrix[3][1] = ((u.x * u.z) * (1 - cos ang) + (u.y * (sin ang))) -- X\nmatrix[3][2] = ((u.y * u.z) * (1 - cos ang) - (u.x * (sin ang))) -- Y\nmatrix[3][3] = ((cos ang) + (u.z ^ 2) * (1 - cos ang))           -- Z\nrow1 = matrix[1][1] * r.x\nrow2 = matrix[1][2] * r.x\nrow3 = matrix[1][3] * r.x\nrow4 = matrix[2][1] * r.y\nrow5 = matrix[2][2] * r.y\nrow6 = matrix[2][3] * r.y	\nrow7 = matrix[3][1] * r.z\nrow8 = matrix[3][2] * r.z\nrow9 = matrix[3][3] * r.z\nvec = point3 (row1 + row4 + row7) (row2 + row5 + row8) (row3 + row6 + row9)\nvec += axisNode.pos\nvec")
						swivel.position.controller.script=scriptString
						attHolder.offsetAttribute.offset = (swivelAngle)
						-- UnParent swivel 
						swivel.parent = undefined
						addModifier swivelController attHolder
					)
					
				
					-- ############ ADDING MODIFIERS ############
					-- add mod to the controllers
					addModifier rootController attHolder
					addModifier kneeController attHolder
					addModifier IKController attHolder	
					addModifier kneeController attHolder2
					
					
					

				)
				
				5: (
					-- ############ CONTROLLER CREATION ############
					rootController = Rectangle transform:jointArray[1].transform name:"rootController" length:(conLength * (conParentMult / 100.0)) width:(conWidth * (conParentMult / 100.0)) cornerRadius:conRadius wirecolor:controllerColor 
					--kneeController = Rectangle transform:jointArray[5].transform name:"kneeController" parent:rootController length:20 width:20 wirecolor:green 
					newKneeController = Rectangle transform:jointArray[2].transform name:"kneeController" parent:rootController length:conLength width:conWidth cornerRadius:conRadius wirecolor:controllerColor 
					IKController = Rectangle transform:jointArray[4].transform name:"IKController" length:conLength width:conWidth cornerRadius:conRadius wirecolor:controllerColor 
					-- link the first bone to rootController
					boneArray[1].parent = rootController
					IKOffsetController = Rectangle transform:jointArray[4].transform name:"IKOffsetController" parent:IKController length:(conLength * (100.0 / conParentMult)) width:(conWidth * (100.0 / conParentMult)) cornerRadius:conRadius wirecolor:controllerColor 
					tipController = Rectangle transform:jointArray[5].transform name:"tipController" parent:IKController length:conLength width:conWidth cornerRadius:conRadius wirecolor:controllerColor 

						
						
					if conThickCheck then (	
						rootController.render_displayRenderMesh = true
						rootController.render_thickness = conThickness
						newKneeController.render_displayRenderMesh = true
						newKneeController.render_thickness = conThickness	
						IKController.render_displayRenderMesh = true
						IKController.render_thickness = conThickness
						tipController.render_displayRenderMesh = true
						tipController.render_thickness = conThickness
						IKOffsetController.render_displayRenderMesh = true
						IKOffsetController.render_thickness = conThickness
						) else (
							rootController.render_displayRenderMesh = false
							IKController.render_displayRenderMesh = false
							IKOffsetController.render_displayRenderMesh = false
							tipController.render_displayRenderMesh = false
							newKneeController.render_displayRenderMesh = false
							)	
						
						
					-- ############ IK [1:2] CREATION ############
					boneOneID = (getAppData jointArray[1] 100) as integer
					boneTwoID = (getAppData jointArray[2] 100) as integer 
					boneOne = boneArray[boneOneID]
					boneTwo = boneArray[boneTwoID]
					try
					(
						ikHelper = ikSys.ikChain boneOne boneTwo "IKHISolver" 
						--ikHelper.transform.controller.SAParent = 0
						d = dummy name:"goalHelper" scale:[0.5, 0.5, 0.5] transform:boneArray[2].transform parent:newKneeController
						ikHelper.parent = d
						ikHelper.transform.controller.SAParent = 0
					) 
					catch
					(
						ikHelper = ikSys.ikChain boneTwo boneOne "IKHISolver"
						--ikHelper.transform.controller.SAParent = 0
						d = dummy name:"goalHelper" scale:[0.5, 0.5, 0.5] transform:boneArray[2].transform parent:newKneeController
						ikHelper.parent = d
						ikHelper.transform.controller.SAParent = 0
					)
					--ikHelper.transform = jointArray[2].transform
					ikHelper.parent = newKneeController
					ikHelper.wirecolor = swivelControllerPointColor
					-- ############ IK [2:5] CREATION ############
					swivel = jointArray[6]
					deleteItem jointArray 6 -- delete from array to avoid deleting
                    boneOneID = (getAppData jointArray[2] 100) as integer
                    boneTwoID = (getAppData jointArray[4] 100) as integer 
                    boneOne = boneArray[boneOneID]
                    boneTwo = boneArray[boneTwoID]
                    try
                    (
                        ikHelper = ikSys.ikChain boneOne boneTwo "IKHISolver" 
                        ikHelper.transform.controller.VHTarget = swivel
                    ) 
                    catch
                    (
                        ikHelper = ikSys.ikChain boneTwo boneOne "IKHISolver" 
                        ikHelper.transform.controller.VHTarget = swivel
                    )
					ikHelper.transform = IKController.transform
                    ikHelper.parent = IKOffsetController
					swivel.parent = IKOffsetController
					ikHelper.wirecolor = swivelControllerPointColor


					-- ############ IK [1:2] CREATION ############
					boneOneID = (getAppData jointArray[4] 100) as integer
					boneTwoID = (getAppData jointArray[5] 100) as integer 
					boneOne = boneArray[boneOneID]
					boneTwo = boneArray[boneTwoID]
					try
					(
						ikHelper = ikSys.ikChain boneOne boneTwo "IKHISolver" 
						--ikHelper.transform.controller.SAParent = 0
						d = dummy name:"goalHelper" scale:[0.5, 0.5, 0.5] transform:boneArray[5].transform parent:tipController
						ikHelper.parent = d
						ikHelper.transform.controller.SAParent = 0
					) 
					catch
					(
						ikHelper = ikSys.ikChain boneTwo boneOne "IKHISolver"
						--ikHelper.transform.controller.SAParent = 0
						d = dummy name:"goalHelper" scale:[0.5, 0.5, 0.5] transform:boneArray[5].transform parent:tipController
						ikHelper.parent = d
						ikHelper.transform.controller.SAParent = 0
					)
					--ikHelper.transform = jointArray[3].transform
					--ikHelper.parent = kneeController	
					ikHelper.wirecolor = swivelControllerPointColor


					-- ############ POSITION SCRIPT ############
					-- define attribute and attribute holder 
					attHolder = EmptyModifier name:"Offset Control"
					OFFSET_DEF = attributes influenceAttribute
					(
						Parameters main rollout:params
						(
							influence type:#float UI:influence Default:20 Range:[0,100,20]
						)
						Rollout Params "Position Influence"
						(
							spinner 'influence' "Influence" Width:160 Height:16 Align:#Center Type:#float Range:[0,100,20] scale:1
						)
					)
					-- add attribute to the holder
					CustAttributes.add attHolder OFFSET_DEF #Unique 
					-- create list controller for infuence node (KneeController)
					newKneeController.pos.controller = position_list()
					-- assign the first node and controller (Root Controller)
					posCon2 = Position_Constraint()
					newKneeController.pos.controller.Available.controller = posCon2
					posCon2.appendTarget IKController 100
					posCon2.relative = true
					newKneeController.pos.controller.weight[2] = 20
					-- wire connect the attribute to second position constraint weight
					paramWire.connect attHolder.influenceAttribute[#influence] (getSubAnim newKneeController.transform.controller.Position.controller.weight 2) "influence/100"
					posCon2 = Position_XYZ()
					newKneeController.pos.controller.Available.controller = posCon2
					newKneeController.pos.controller.setActive 3
					
					

					-- ############ RESET TRANSFORM SCRIPT ############
					attHolder2 = EmptyModifier name:"Freeze Transform"
					OFFSET_DEF = attributes freezeAttribute
					(
						Parameters main rollout:params
						(
							transformData type:#string default:"(matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])"
						)
						Rollout Params "Offset Parameter"
						(
							button UI_store "Store Transform"  height:26 width:160 align:#center
							button UI_reset "Reset Transform"  height:26 width:160 align:#center
							on UI_store pressed do (
								val = yesNoCancelBox "Overwriting Stored Transform?" title:"Warning" beep:true 
								if val == #yes then (			
									selfNode = (refs.dependentNodes (custAttributes.getOwner this))[1]
									old = selfNode.modifiers[2].influenceAttribute.influence
									selfNode.modifiers[2].influenceAttribute.influence = 0
									offset = selfNode.transform * inverse selfNode.parent.transform 
									transformData = offset as string 
									selfNode.modifiers[2].influenceAttribute.influence = old 
									)
							   )	
							on UI_reset pressed do (
								selfNode = (refs.dependentNodes (custAttributes.getOwner this))[1]
								old = selfNode.modifiers[2].influenceAttribute.influence
								selfNode.modifiers[2].influenceAttribute.influence = 0
								offset = execute transformData
								selfNode.transform = offset * selfNode.parent.transform 
								selfNode.modifiers[2].influenceAttribute.influence = old 
						   ) 
						)
					)
					CustAttributes.add attHolder2 OFFSET_DEF #Unique 
					

					-- ############ POLE VECTOR OFFSET ############
					if isOffset then (
						--attHolder = EmptyModifier name:"Offset Control"
						OFFSET_DEF = attributes offsetAttribute
						(
							Parameters main rollout:params
							(
								offset type:#float UI:offset
							)
							Rollout Params "Rotation Offset"
							(
								spinner 'offset' "Offset" Width:160 Height:16 Align:#Center Type:#float Range:[0,360,270] scale:1
							)
						)
						-- add attribute to the holder
						CustAttributes.add attHolder OFFSET_DEF #Unique 
						
						dir = IKArray[2][3].parent.dir 
						testPos = rotVecAroundAxis (IKArray[2][3].pos - (IKArray[2][2].pos)) dir (360 - swivelAngle)
						testPos += IKController.pos
						swivelController = point name:"swivelController" pos:testPos parent:IKOffsetController size:10 wirecolor:swivelControllerPointColor centermarker:false cross:false axistripod:true Box:false constantscreensize:false drawontop:false 
						swivel.name = "Swivel" 
						swivel.wirecolor = swivelControllerPointColor
						swivel.position.controller=position_script()
						swivel.position.controller.addObject "pointNode" swivelController
						swivel.position.controller.addObject "axisNode" IKOffsetController
						swivel.position.controller.addTarget "a" (getSubAnim attHolder.offsetAttribute 1)
						scriptString =  ("r = (pointNode.pos - (axisNode.pos))\nu = (([0, 0, 1] * axisNode.transform) - axisNode.pos)\nang = -a\nu = normalize(u)\nmatrix = #((point3 1 0 0), (point3 0 1 0), (point3 0 0 1))\nmatrix[1][1] = ((cos ang) + (u.x ^ 2) * (1 - cos ang))           -- X\nmatrix[1][2] = ((u.y * u.x) * (1 - cos ang) + (u.z * (sin ang))) -- Y\nmatrix[1][3] = ((u.z * u.x) * (1 - cos ang) - (u.y * (sin ang))) -- Z\nmatrix[2][1] = ((u.x * u.y) * (1 - cos ang) - (u.z * (sin ang))) -- X\nmatrix[2][2] = ((cos ang) + (u.y ^ 2) * (1 - cos ang))           -- Y\nmatrix[2][3] = ((u.z * u.y) * (1 - cos ang) + (u.x * (sin ang))) -- Z\nmatrix[3][1] = ((u.x * u.z) * (1 - cos ang) + (u.y * (sin ang))) -- X\nmatrix[3][2] = ((u.y * u.z) * (1 - cos ang) - (u.x * (sin ang))) -- Y\nmatrix[3][3] = ((cos ang) + (u.z ^ 2) * (1 - cos ang))           -- Z\nrow1 = matrix[1][1] * r.x\nrow2 = matrix[1][2] * r.x\nrow3 = matrix[1][3] * r.x\nrow4 = matrix[2][1] * r.y\nrow5 = matrix[2][2] * r.y\nrow6 = matrix[2][3] * r.y	\nrow7 = matrix[3][1] * r.z\nrow8 = matrix[3][2] * r.z\nrow9 = matrix[3][3] * r.z\nvec = point3 (row1 + row4 + row7) (row2 + row5 + row8) (row3 + row6 + row9)\nvec += axisNode.pos\nvec")
						swivel.position.controller.script=scriptString
						attHolder.offsetAttribute.offset = (360 - swivelAngle)
						-- UnParent swivel 
						swivel.parent = undefined
						addModifier swivelController attHolder
					)
					
									
					-- ############ ADDING MODIFIERS ############
					-- add mod to the controllers
					addModifier rootController attHolder
					addModifier newKneeController attHolder
					addModifier IKController attHolder	
					addModifier newKneeController attHolder2
				)
				
			)
		)
    )
	
    -- clean the bone array to avoid getting deleted bu cleanUp function
    boneArray = Array()
    cleanUpScene()
    clearSelection()
	
)

-- define debug view
fn debugView = (
	try(
		-- display joints
		gw.SetColor #line [100,200,200]
		if jointArray.count > 0 then (
			for i=1 to jointArray.count-1 do 
			(
				gw.Polyline #(jointArray[i].pos, jointArray[i+1].pos) false
			)
		)
		-- display IKs
		gw.SetColor #line [0,255,0]
		for i=1 to IKArray.count do
		(
			gw.SetColor #line [255,100,8]
			gw.Polyline #(IKArray[i][1].pos, IKArray[i][2].pos) false 	
			gw.Marker (IKArray[i][1].pos) #circle color:[255,100,8]
			gw.Marker (IKArray[i][2].pos) #circle color:[255,100,8]
			-- show swivel connection
			midpos = (IKArray[i][1].pos + IKArray[i][2].pos) / 2
			gw.Marker (midpos) #circle color:[255,100,8]
			gw.Marker (IKArray[i][3].pos) #circle color:[255,100,8]
			gw.Polyline #(midpos, IKArray[i][3].pos) false 	
		)
		-- display swivel offset
        if isOffset then 
        (
        if isReverse then (
           
            for i=1 to IKArray.count do (
                if (isValidNode IKArray[i][3]) then (
                    --dir = ([0, 0, 1] * IKArray[i][2].transform) - IKArray[i][2].pos 
                    dir = IKArray[i][3].parent.dir 
                    testPos = rotVecAroundAxis (IKArray[i][3].pos - (IKArray[i][2].pos)) dir swivelAngle 
                    gw.Marker (testPos+IKArray[i][2].pos) #circle color:[100,255,8]
                    for n = 1 to 7 do 
                    (
                        testPos = rotVecAroundAxis (IKArray[i][3].pos - (IKArray[i][2].pos)) dir (n*(swivelAngle/8))
                        gw.Marker (testPos+IKArray[i][2].pos) #smallDiamond color:[100,200,8]
                    )
                )
            )
            
        ) 
        else 
        (
            for i=1 to IKArray.count do (
                if (isValidNode IKArray[i][3]) then (
                    --dir = ([0, 0, 1] * IKArray[i][2].transform) - IKArray[i][2].pos 
                    dir = IKArray[i][3].parent.dir 
                    testPos = rotVecAroundAxis (IKArray[i][3].pos - (IKArray[i][2].pos)) dir -swivelAngle 
                    gw.Marker (testPos+IKArray[i][2].pos) #circle color:[100,255,8]
                    for n = 1 to 7 do 
                    (
                        testPos = rotVecAroundAxis (IKArray[i][3].pos - (IKArray[i][2].pos)) dir (n*(-swivelAngle/8))
                        gw.Marker (testPos+IKArray[i][2].pos) #smallDiamond color:[100,200,8]
                    )
                )
            )
        )
        )
	)
	catch()
)


-- define new-three joint setup dialog
rollout threeJointDialog "Three Joints Setup" (
	group "Properties"(
		checkbutton ui_offset_btn "Swivel Offset" height:26 width:218 checked:true align:#center
		label ui_swivel_lbl "Swivel Angle" width:108 align:#left across:2
		spinner ui_swivel_spn "" width:108 range:[0, 360, 90] align:#right scale:1

		on ui_offset_btn changed state do (
			isOffset = state
			redrawViews()
		)
		on ui_swivel_spn changed val do (
			swivelAngle = val 
			redrawViews()
		)
	)
	group "Creation"(
		button ui_create_btn "Create The Rig" height:26 width:218

		on ui_create_btn pressed do (
			-- calling createRig function and clean up the scene
			createRig()
			cleanUpScene()
			DestroyDialog threeJointDialog
		)
	)

    on threeJointDialog open do (
        -- disable buttons 
        UI_3Setup_btn.enabled = false 
        UI_4Setup_btn.enabled = false 
        UI_5Setup_btn.enabled = false 

        -- define arrays 
        jointArray = Array()
        boneArray = Array()
        IKArray = Array()

        -- assing the global color to local col
        col = controllerColor
        isReverse = true

        -- create points
		parentPoint = point pos:[0, 0, 100] size:10 wirecolor:col centermarker:false cross:false axistripod:true Box:false constantscreensize:false drawontop:false 
		secondPoint = point pos:[5, 0, 50] size:10 parent:parentPoint wirecolor:col centermarker:false cross:false axistripod:true Box:false constantscreensize:false drawontop:false 
		thirdPoint = point pos:[0, 0, 0] size:10 parent:secondPoint wirecolor:col centermarker:false cross:false axistripod:true Box:false constantscreensize:false drawontop:false 
		swivelPoint = point pos:[50, 0, 0] size:10 parent:thirdPoint wirecolor:col centermarker:false cross:true axistripod:false Box:false constantscreensize:false drawontop:false 
        
        -- define id to detect bones when creating IKs
		setAppData parentPoint 100 "1"
		setAppData secondPoint 100 "2"
		setAppData thirdPoint 100 "3"

        -- lock the joints 
        setTransformLockFlags secondPoint #{7..9}
        setTransformLockFlags thirdPoint #{7..9}
        setTransformLockFlags swivelPoint #{7..9}

		-- append points to array
		append jointArray parentPoint
		append jointArray secondPoint
		append jointArray thirdPoint
		append jointArray swivelPoint

        -- setup the IK [start bone, end bone, (swivel or undefined)]
		tempArray = Array()
		append tempArray parentPoint 
		append tempArray thirdPoint
		append tempArray swivelPoint
		append IKArray tempArray

		-- define properties
		isOffset = true -- true by default
		swivelAngle = 90

        -- register debug view 
        try(registerRedrawViewsCallback debugView)catch()
    )

    on threeJointDialog close do (
        -- claen up the scene
		cleanUpScene()
    )
)


-- define three joint setup dialog
rollout fourJointDialog "Four Joints Setup" --define another rollout
(
    local prepareSetup

    group "Properties"(
		checkbutton ui_offset_btn "Swivel Offset" height:26 width:218 checked:true align:#center
		label ui_swivel_lbl "Swivel Angle:"  width:108 align:#left across:2
		spinner ui_swivel_spn "" width:108 range:[0, 360, 90] align:#right scale:1
        label ui_type_lbl "Setup Type:" width:108 align:#left across:2
		dropdownList ui_type_ddl "" width:108 items:#("Type 1", "Type 2", "Type 3", "Type 4") align:#center

        on ui_type_ddl selected i do (
			setupType = i
            prepareSetup setupType
        )
		on ui_offset_btn changed state do (
			isOffset = state
			redrawViews()
		)
		on ui_swivel_spn changed val do (
			swivelAngle = val 
			redrawViews()
		)
	)
	group "Creation"(
		button ui_create_btn "Create The Rig" height:26 width:218

		on ui_create_btn pressed do (
			-- calling createRig function and clean up the scene
			createRig()
			cleanUpScene()
			DestroyDialog fourJointDialog
		)
	)

    fn prepareSetup type = (
        case type of (
            1:(
                isReverse = false 
                jointArray[1].transform = (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,150])
                jointArray[2].transform = (matrix3 [1,0,0] [0,1,0] [0,0,1] [5,0,100])
                jointArray[3].transform = (matrix3 [1,0,0] [0,1,0] [0,0,1] [-5,0,50])
                jointArray[4].transform = (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])
                jointArray[5].transform = (matrix3 [1,0,0] [0,1,0] [0,0,1] [-50,0,50])
                jointArray[5].parent = jointArray[3]
                IKArray = Array()
                tempArray = Array()
                append tempArray jointArray[2] 
                append tempArray jointArray[4]
                append tempArray jointArray[5]
                append IKArray tempArray
            )
            2:(
                isReverse = true
                jointArray[1].transform = (matrix3 [1,0,0] [0,1,0] [0,0,1] [-55.919,-1.12364e-05,145.707])
                jointArray[2].transform = (matrix3 [1,0,0] [0,1,0] [0,0,1] [-23.5752,4.21366e-06,102.136])
                jointArray[3].transform = (matrix3 [1,0,0] [0,1,0] [0,0,1] [36.0191,-1.47478e-05,68.1442])
                jointArray[4].transform = (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])
                jointArray[5].transform = (matrix3 [1,0,0] [0,1,0] [0,0,1] [115.467,-4.49457e-05,84.8692])
                jointArray[5].parent = jointArray[3]
                IKArray = Array()
                tempArray = Array()
                append tempArray jointArray[2] 
                append tempArray jointArray[4]
                append tempArray jointArray[5]
                append IKArray tempArray
            )
            3:(
                isReverse = false 
                jointArray[1].transform = (matrix3 [1,0,0] [0,1,0] [0,0,1] [-25.1945,1.76849e-05,147.256])
                jointArray[2].transform = (matrix3 [1,0,0] [0,1,0] [0,0,1] [-35.8765,1.76849e-05,79.2453])
                jointArray[3].transform = (matrix3 [1,0,0] [0,1,0] [0,0,1] [16.2618,0,39.1386])
                jointArray[4].transform = (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])
                jointArray[5].transform = (matrix3 [1,0,0] [0,1,0] [0,0,1] [-91.7407,0,61.3341])
                jointArray[5].parent = jointArray[2]
                IKArray = Array()
                tempArray = Array()
                append tempArray jointArray[1] 
                append tempArray jointArray[3]
                append tempArray jointArray[5]
                append IKArray tempArray
            )            
            4:(
                isReverse = true 
                jointArray[1].pos = [-45.1644,0,146.261]
                jointArray[2].pos = [-2.99105,0,100.498]
                jointArray[3].pos = [-20.0397,0,42.7767]
                jointArray[4].pos = [0, 0, 0]
                jointArray[5].pos = [66.4997,0,114.957]
                jointArray[5].parent = jointArray[2]
                IKArray = Array()
                tempArray = Array()
                append tempArray jointArray[1] 
                append tempArray jointArray[3]
                append tempArray jointArray[5]
                append IKArray tempArray
            )
        )
    )

    on fourJointDialog open do (
        -- disable buttons 
        UI_3Setup_btn.enabled = false 
        UI_4Setup_btn.enabled = false 
        UI_5Setup_btn.enabled = false 

        -- define arrays 
        jointArray = Array()
        boneArray = Array()
        IKArray = Array()

        -- assing the global color to local col
        col = controllerColor
		
        -- create points
		parentPoint = point pos:[0, 0, 150] size:10 wirecolor:col centermarker:false cross:false axistripod:true Box:false constantscreensize:false drawontop:false 
		secondPoint = point pos:[5, 0, 100] size:10 parent:parentPoint wirecolor:col centermarker:false cross:false axistripod:true Box:false constantscreensize:false drawontop:false 
		thirdPoint = point pos:[-5, 0, 50] size:10 parent:secondPoint wirecolor:col centermarker:false cross:false axistripod:true Box:false constantscreensize:false drawontop:false 
		fourthPoint = point pos:[0, 0, 0] size:10 parent:thirdPoint wirecolor:col centermarker:false cross:false axistripod:true Box:false constantscreensize:false drawontop:false 
		swivelPoint = point pos:[-50, 0, 50] size:10 parent:thirdPoint wirecolor:col centermarker:false cross:true axistripod:false Box:false constantscreensize:false drawontop:false 
		
        -- define id to detect bones when creating IKs
		setAppData parentPoint 100 "1"
		setAppData secondPoint 100 "2"
		setAppData thirdPoint 100 "3"
		setAppData fourthPoint 100 "4"

        -- lock the joints 
        setTransformLockFlags secondPoint #{7..9}
        setTransformLockFlags thirdPoint #{7..9}
        setTransformLockFlags swivelPoint #{7..9}

		-- append points to array
		append jointArray parentPoint
		append jointArray secondPoint
		append jointArray thirdPoint
		append jointArray fourthPoint
		append jointArray swivelPoint

        -- setup the IK [start bone, end bone, (swivel or undefined)]
        prepareSetup 1

		-- define properties
		isOffset = true -- true by default
		swivelAngle = 90

        -- register debug view 
        try(registerRedrawViewsCallback debugView)catch()
    )

    on fourJointDialog close do (
        -- claen up the scene
		cleanUpScene()
    )

		
)

-- define three joint setup dialog
rollout fiveJointDialog "Five Joints Setup" --define another rollout
(
    local prepareSetup

    group "Properties"(
		checkbutton ui_offset_btn "Swivel Offset" height:26 width:218 checked:true align:#center
		label ui_swivel_lbl "Swivel Angle:"  width:108 align:#left across:2
		spinner ui_swivel_spn "" width:108 range:[0, 360, 90] align:#right scale:1
        label ui_type_lbl "Setup Type:" width:108 align:#left across:2
		dropdownList ui_type_ddl "" width:108 items:#("Type 1", "Type 2", "Type 3", "Type 4", "Type 5") align:#center

        on ui_type_ddl selected i do (
			setupType = i
            prepareSetup setupType
        )
		on ui_offset_btn changed state do (
			isOffset = state
			redrawViews()
		)
		on ui_swivel_spn changed val do (
			swivelAngle = val 
			redrawViews()
		)
	)
	group "Creation"(
		button ui_create_btn "Create The Rig" height:26 width:218

		on ui_create_btn pressed do (
			-- calling createRig function and clean up the scene
			createRig()
			cleanUpScene()
			DestroyDialog fiveJointDialog
		)
	)

    fn prepareSetup type = (
        case type of (
            1:(
                isReverse = true 
                jointArray[1].transform = (matrix3 [1,0,0] [0,1,0] [0,0,1] [-73.251,0,131.001])
                jointArray[2].transform = (matrix3 [1,0,0] [0,1,0] [0,0,1] [-12.5206,0,104.991])
                jointArray[3].transform = (matrix3 [1,0,0] [0,1,0] [0,0,1] [24.3227,0,72.677])
                jointArray[4].transform = (matrix3 [1,0,0] [0,1,0] [0,0,1] [45.6724,0,37.2063])
                jointArray[5].transform = (matrix3 [1,0,0] [0,1,0] [0,0,1] [64.1054,0,0])
				jointArray[6].transform = (matrix3 [1,0,0] [0,1,0] [0,0,1] [115.706,0,118.985])

                jointArray[6].parent = jointArray[3]
                IKArray = Array()
                tempArray = Array()
                append tempArray jointArray[1] 
                append tempArray jointArray[5]
                append tempArray jointArray[6]
                append IKArray tempArray
            )
            2:(
                isReverse = true 
                jointArray[1].transform = (matrix3 [1,0,0] [0,1,0] [0,0,1] [-73.251,0,131.001])
                jointArray[2].transform = (matrix3 [1,0,0] [0,1,0] [0,0,1] [-12.5206,0,104.991])
                jointArray[3].transform = (matrix3 [1,0,0] [0,1,0] [0,0,1] [24.3227,0,72.677])
                jointArray[4].transform = (matrix3 [1,0,0] [0,1,0] [0,0,1] [45.6724,0,37.2063])
                jointArray[5].transform = (matrix3 [1,0,0] [0,1,0] [0,0,1] [64.1054,0,0])
				jointArray[6].transform = (matrix3 [1,0,0] [0,1,0] [0,0,1] [115.706,0,118.985])

                jointArray[6].parent = jointArray[3]
                IKArray = Array()
                tempArray = Array()
                append tempArray jointArray[2] 
                append tempArray jointArray[5]
                append tempArray jointArray[6]
                append IKArray tempArray
            )
            3:(
                isReverse = true 
                jointArray[1].transform = (matrix3 [1,0,0] [0,1,0] [0,0,1] [-73.251,0,131.001])
                jointArray[2].transform = (matrix3 [1,0,0] [0,1,0] [0,0,1] [-12.5206,0,104.991])
                jointArray[3].transform = (matrix3 [1,0,0] [0,1,0] [0,0,1] [24.3227,0,72.677])
                jointArray[4].transform = (matrix3 [1,0,0] [0,1,0] [0,0,1] [45.6724,0,37.2063])
                jointArray[5].transform = (matrix3 [1,0,0] [0,1,0] [0,0,1] [64.1054,0,0])
				jointArray[6].transform = (matrix3 [1,0,0] [0,1,0] [0,0,1] [115.706,0,118.985])
			
                jointArray[6].parent = jointArray[2]
			
				IKArray = Array()
			
                tempArray = Array()
                append tempArray jointArray[3] 
                append tempArray jointArray[5]
                append tempArray jointArray[6]
                append IKArray tempArray
			
                tempArray = Array()
                append tempArray jointArray[1] 
                append tempArray jointArray[3]
                append IKArray tempArray
			
            )   
            4:(
                isReverse = true 
                jointArray[1].transform = (matrix3 [1,0,0] [0,1,0] [0,0,1] [-73.251,0,131.001])
                jointArray[2].transform = (matrix3 [1,0,0] [0,1,0] [0,0,1] [-12.5206,0,104.991])
                jointArray[3].transform = (matrix3 [1,0,0] [0,1,0] [0,0,1] [24.3227,0,72.677])
                jointArray[4].transform = (matrix3 [1,0,0] [0,1,0] [0,0,1] [45.6724,0,37.2063])
                jointArray[5].transform = (matrix3 [1,0,0] [0,1,0] [0,0,1] [64.1054,0,0])
				jointArray[6].transform = (matrix3 [1,0,0] [0,1,0] [0,0,1] [115.706,0,118.985])
			
                jointArray[6].parent = jointArray[2]
			
                IKArray = Array()
                tempArray = Array()
                append tempArray jointArray[1] 
                append tempArray jointArray[2]
                append tempArray jointArray[2]
                append IKArray tempArray
			
                tempArray = Array()
                append tempArray jointArray[2] 
                append tempArray jointArray[3]
                append tempArray jointArray[3]
                append IKArray tempArray
			
				tempArray = Array()
                append tempArray jointArray[3] 
                append tempArray jointArray[5]
                append tempArray jointArray[6]
                append IKArray tempArray
            )   
			5:(
                isReverse = true 
                jointArray[1].transform = (matrix3 [1,0,0] [0,1,0] [0,0,1] [-12.2734,-2.02517e-05,144.827])
                jointArray[2].transform = (matrix3 [1,0,0] [0,1,0] [0,0,1] [18.2349,-2.02517e-05,113.793])
                jointArray[3].transform = (matrix3 [1,0,0] [0,1,0] [0,0,1] [-7.36404,-2.02517e-05,78.7256])
                jointArray[4].transform = (matrix3 [1,0,0] [0,1,0] [0,0,1] [10.8707,-2.02517e-05,34.1907])
                jointArray[5].transform = (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])
				jointArray[6].transform = (matrix3 [1,0,0] [0,1,0] [0,0,1] [-87.1202,0,89.0989])
			
                jointArray[6].parent = jointArray[2]
			
                IKArray = Array()
                tempArray = Array()
                append tempArray jointArray[1] 
                append tempArray jointArray[2]
                append tempArray jointArray[2]
                append IKArray tempArray
			
                tempArray = Array()
                append tempArray jointArray[2] 
                append tempArray jointArray[4]
                append tempArray jointArray[6]
                append IKArray tempArray
			
				tempArray = Array()
                append tempArray jointArray[4] 
                append tempArray jointArray[5]
                append tempArray jointArray[5]
                append IKArray tempArray
            ) 	
        )
    )

    on fiveJointDialog open do (
        -- disable buttons 
        UI_3Setup_btn.enabled = false 
        UI_4Setup_btn.enabled = false 
        UI_5Setup_btn.enabled = false 

        -- define arrays 
        jointArray = Array()
        boneArray = Array()
        IKArray = Array()

        -- assing the global color to local col
        col = controllerColor
		
        -- create points
		parentPoint = point pos:[0, 0, 150] size:10 wirecolor:col centermarker:false cross:false axistripod:true Box:false constantscreensize:false drawontop:false 
		secondPoint = point pos:[5, 0, 100] size:10 parent:parentPoint wirecolor:col centermarker:false cross:false axistripod:true Box:false constantscreensize:false drawontop:false 
		thirdPoint = point pos:[-5, 0, 50] size:10 parent:secondPoint wirecolor:col centermarker:false cross:false axistripod:true Box:false constantscreensize:false drawontop:false 
		fourthPoint = point pos:[0, 0, 0] size:10 parent:thirdPoint wirecolor:col centermarker:false cross:false axistripod:true Box:false constantscreensize:false drawontop:false 
		fifthPoint = point pos:[0, 0, 0] size:10 parent:fourthPoint wirecolor:col centermarker:false cross:false axistripod:true Box:false constantscreensize:false drawontop:false 
		swivelPoint = point pos:[-50, 0, 50] size:10 parent:fifthPoint wirecolor:col centermarker:false cross:true axistripod:false Box:false constantscreensize:false drawontop:false 
		
        -- define id to detect bones when creating IKs
		setAppData parentPoint 100 "1"
		setAppData secondPoint 100 "2"
		setAppData thirdPoint 100 "3"
		setAppData fourthPoint 100 "4"
		setAppData fifthPoint 100 "5"

        -- lock the joints 
        setTransformLockFlags secondPoint #{7..9}
        setTransformLockFlags thirdPoint #{7..9}
        setTransformLockFlags swivelPoint #{7..9}

		-- append points to array
		append jointArray parentPoint
		append jointArray secondPoint
		append jointArray thirdPoint
		append jointArray fourthPoint
		append jointArray fifthPoint
		append jointArray swivelPoint

        -- setup the IK [start bone, end bone, (swivel or undefined)]
        prepareSetup 1

		-- define properties
		isOffset = true -- true by default
		swivelAngle = 90

        -- register debug view 
        try(registerRedrawViewsCallback debugView)catch()
    )

    on fiveJointDialog close do (
        -- claen up the scene
		cleanUpScene()
    )

		
)


rollout mainDialog "Rig: Leg Setup" --define a rollout and create a dialog 
(
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
		
	group "Color" (
		colorPicker UI_Controller_Color "Controller: " color:controllerColor align:#right across:2
		colorPicker UI_IK_Point_Color "Swivel: " color:swivelControllerPointColor align:#right  across:2
		colorPicker UI_Bone_Color "Bone: " color:boneColor align:#right
		
		on UI_Controller_Color changed col do (controllerColor = col)
		on UI_IK_Point_Color changed col do (swivelControllerPointColor = col)
		on UI_Bone_Color changed col do (boneColor = col)
		)
	
	
    group "Creation" (
        button UI_3Setup "Create Three Joints Setup" height:26 width:208 align:#center
        button UI_4Setup "Create Four Joints Setup" height:26 width:208 align:#center
        button UI_5Setup "Create Five Joints Setup" height:26 width:208 align:#center

        
        on UI_3Setup pressed do 
        (
			
            pos = rof.pos -- get parent position
            pos += [250, 0] -- shift the parent position
			-- define joints setup for this button
			jointType = 1
            -- create and assign new rollout as a child of the main parent 
            createDialog threeJointDialog parent:rof.hwnd height:200 width:240 pos:pos
            setFocus mainDialog
            redrawViews()
        )

        on UI_4Setup pressed do 
        (
            pos = rof.pos -- get parent position
            pos += [250, 0] -- shift the parent position
            jointType = 2
            setupType = 1
            -- create and assign new rwollout as a child of the main parent 
            createDialog fourJointDialog parent:rof.hwnd height:220 width:240 pos:pos
            setFocus mainDialog
            redrawViews()
        )
		
		on UI_5Setup pressed do 
        (
            pos = rof.pos -- get parent position
            pos += [250, 0] -- shift the parent position
            jointType = 3
            setupType = 1
            -- create and assign new rwollout as a child of the main parent 
            createDialog fiveJointDialog parent:rof.hwnd height:220 width:240 pos:pos
            setFocus mainDialog
            redrawViews()
        )		
    )

    on mainDialog open do (
        -- asign buttons to make them global
        UI_3Setup_btn = UI_3Setup
        UI_4Setup_btn = UI_4Setup
        UI_5Setup_btn = UI_5Setup

		try(unregisterRedrawViewsCallback debugView)catch()
    )
)



-- Check if the master Keelworks manager script and loading client scripts
if globalKeelworksLoading == true  then
(

    -- Add the rollout to the manager rollout window
    addRollout mainDialog masterRolloutFloat
    -- And close/collapse it by default
    mainDialog.open = false

)
else 
(
    -- Create a new dialogue window for the rollout
	rof = newrolloutfloater "Rig: LegSetup v1.7" 240 720
	--rof.pos.x += -800
	--rof.pos.y += -20
	addrollout mainDialog rof
    
)

)

