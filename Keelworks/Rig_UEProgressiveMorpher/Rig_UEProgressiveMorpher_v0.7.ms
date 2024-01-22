

----- V0.7
		rollout snap "Rig: UE Progressive Morpher" width:190 height:500
		(
			
			button 'create' "05 - Create" pos:[9,400] width:148 height:30 align:#left
			GroupBox 'grp2' "03 - Name Prefix for morph targets" pos:[0,312] width:200 height:50 align:#left tooltip:"Name for the newly created morph targets "
			edittext 'BASE_NAME' "" pos:[08,335] width:140 height:15 align:#left
			
			spinner Channelnu "04 - Start on Channel:" pos:[70,370] width:100 height:16 range:[0,100,0] type:#integer scale:1 tooltip:"If you already have other morph targets present in the channels, use this to set a number for the channel where you want the new morphs to come in"
		
			pickbutton 'MorphTarget' "02 - Pick Target" pos:[8,250] width:136 height:30 align:#left tooltip:"Pick the Skinned Mesh with Morpher modifier you want to apply the result to."

			listbox 'testList' "" pos:[13,55] width:136 height:8 align:#left
			button 'addToList' "01 - Add Progressive Targets                (select in order | 3 objects only)" pos:[8,174] width:155 height:40 align:#left tooltip:"(CTRL select) 3 objects in order "
			button 'clearList' "Clear List" pos:[8,220] width:80 height:19 align:#left
			
			


checkbox myCheckBox "Accurate (creates 6 Morphs)" pos:[4,20] triState:1 tooltip:"Check this for more accurate morph results"
on myCheckBox changed theState do
	
(
Checkboxstate = theState
)
	

	



-- 			
-- 			
-- 		
-- 		------------------------------------------------------------------------------------------------------------------------------------------------------
-- 		

			on create pressed do
			(
				
				---------------------------------------------------------------------------------------------- Modes -----------------------------------------------------------------------
				
				
			
				if (Checkboxstate == true) then
				
					
			(
				varFrom = 16                
				varTo   = 96                 
				varEveryXFrame = 16    
			)
			
			else
			
			(
				varFrom = 19                
			    varTo   = 96                 
				varEveryXFrame = 19  
			)
			
				-------------------------------------------------------------------------------------------------------------------------
					
			        ObjArray = #()
					append ObjArray MorphTarget.object
					TargetArray = #()
					TargetMorpher = ObjArray[1].modifiers[2]
			        Target = ObjArray[1]
			
					select Target
				
			
							 												
			----------------------------------------------    Create temp object from original to apply morph on ---------------------------------------------------------------
						
						
			sliderTime = 0
			
			For obj in selection do
			(
			Local Selectedobj02= (snapshot obj)
			convertto Selectedobj02 editable_mesh
			Selectedobj02.name = "TempSource01"
			)
			
			select $TempSource01
			
			m = Morpher ()
			
			addmodifier $TempSource01 m
			
			
			WM3_MC_BuildFromNode$TempSource01.morpher 1 listobjects[1] 
			WM3_AddProgressiveMorphNode$TempSource01.morpher 1 listobjects[2] 
			WM3_AddProgressiveMorphNode$TempSource01.morpher 1 listobjects[3] 
			
			
			slidertime = 96
			
			with animate on
			(
			WM3_MC_SetValue m 1 100.0
			)
			
			---------------------------------------------change keys to linear --------------------------------------
			
			$TempSource01.modifiers[#Morpher][1].controller.keys.inTangentType = #linear
			
			$TempSource01.modifiers[#Morpher][1].controller.keys.outTangentType = #linear
					
			
			-------------------------------------------------------------------------   Create snapshots in between as morph targets  --------------------------------
			-- 								   
			                   select $TempSource01
			               
			
								For i = varFrom to varTo by varEveryXFrame do 
									(
										sliderTime = i
										 For obj in selection do
										 (
										 	Local Selectedobj= (snapshot obj)
											convertto Selectedobj editable_mesh
											Selectedobj.name = uniquename base_name.text
											append TargetArray Selectedobj
										 )
									
									)
									
									
			---------------------------------------------------------------------------------------apply morph targets to original mesh-------------------------------------
			
			
										for i = 1 to TargetArray.count do
										(	
											WM3_MC_BuildFromNode TargetMorpher (i + Channelnu.value) TargetArray[i]
										)
			
			
										
										
			------------------------------------------------------------------------------------------- Create Custom Attribue helper ----------------------------------------------------------------------
			
			
			pt_CTRL = point Box:on size:20 wirecolor:red cross:off centermarker:on
			pt_CTRL.pos = [0,0,0]
			pt_CTRL.name = uniquename "AttributeHolder_Pmorph"
			
			select pt_CTRL
			
			modPanel.addModToSelection (EmptyModifier ()) ui:on
			
			ca=attributes ProgressiveMorphs01
			 (
				parameters params rollout:Controls
			 	(
					p01 type:#float ui:Spin01
			 		
			 	)
				
			 	rollout Controls "Controls" width:162 height:77
			 	(
					spinner Spin01 "Channel 01:" pos:[60,8] width:75 height:16 range:[0,100,0]
			 		
			 	)
			)
			 
			 custAttributes.add pt_CTRL.modifiers[1] ca
			
			select ObjArray
			
			
			--------------------------------------------------------------------------------- Wire Link up  Accurate ---------------------------------------------------

if (Checkboxstate == true) then

(
		
paramWire.connect pt_CTRL.modifiers[#Attribute_Holder].ProgressiveMorphs01[#p01] $.modifiers[#Morpher][1] "result = 0 
if ( p01 >= 0 and p01<=16.6 ) then  
(
result = p01 *6
)
else if
( p01 >16.6  and p01<=33.2 ) then  
(
result = 100 - ( (p01 - 16.6) *6) 
)
result"

paramWire.connect pt_CTRL.modifiers[#Attribute_Holder].ProgressiveMorphs01[#p01] $.modifiers[#Morpher][2] "result = 0
if (p01 < 16.6) then result = 0

else if ( p01 >= 16.6 and p01<=33.2 ) then  
(
result = (p01 - 16.6) *6
)
else if
( p01 >33.2  and p01<=49.8) then  
(
result = 100 - ( (p01 - 33.2) *6) 
)
result"

paramWire.connect pt_CTRL.modifiers[#Attribute_Holder].ProgressiveMorphs01[#p01] $.modifiers[#Morpher][3] "result = 0
if (p01 < 33.2) then result = 0

else if ( p01 >= 33.2 and p01<=49.8 ) then  
(
result = (p01 - 33.2) *6
)
else if
( p01 >49.8  and p01<=66.4) then  
(
result = 100 - ( (p01 - 49.8) *6) 
)
result"

paramWire.connect pt_CTRL.modifiers[#Attribute_Holder].ProgressiveMorphs01[#p01] $.modifiers[#Morpher][4] "result = 0
if (p01 < 49.8) then result = 0

else if ( p01 >= 49.8 and p01<=66.4 ) then  
(
result = (p01 - 49.8) *6
)
else if
( p01 >66.4  and p01<=83) then  
(
result = 100 - ( (p01 - 66.4 ) *6) 
)
result"

paramWire.connect pt_CTRL.modifiers[#Attribute_Holder].ProgressiveMorphs01[#p01] $.modifiers[#Morpher][5] "result = 0
if (p01 < 66.4) then result = 0

else if ( p01 >= 66.4 and p01<=83 ) then  
(
result = (p01 - 66.4) *6
)
else if
( p01 >83  and p01<=99.6) then  
(
result = 100 - ( (p01 - 83 ) *6) 
)
result"

paramWire.connect pt_CTRL.modifiers[#Attribute_Holder].ProgressiveMorphs01[#p01] $.modifiers[#Morpher][6] "result = 0
if (p01 < 83) then result = 0

else if ( p01 >= 83 and p01<=100 ) then  
(
result = (p01 - 83) *6
)
else if
( p01 >83  and p01<=100) then  
(
result = 100 - ( (p01 - 83 ) *6) 
)
result"



)
--------------------------------------------------------------------------------- Wire Link up  Normal ---------------------------------------------------

else


(
paramWire.connect pt_CTRL.modifiers[#Attribute_Holder].ProgressiveMorphs01[#p01] $.modifiers[#Morpher][1] "result = 0 
if ( p01 >= 0 and p01<=20 ) then  
(
result = p01 *5
)
else if
( p01 >20  and p01<=40 ) then  
(
result = 100 - ( (p01 - 20) *5) 
)
result"

paramWire.connect pt_CTRL.modifiers[#Attribute_Holder].ProgressiveMorphs01[#p01] $.modifiers[#Morpher][2] "result = 0
if (p01 < 20) then result = 0

else if ( p01 >= 20 and p01<=40 ) then  
(
result = (p01 - 20) *5
)
else if
( p01 >40  and p01<=60) then  
(
result = 100 - ( (p01 - 40) *5) 
)
result"

paramWire.connect pt_CTRL.modifiers[#Attribute_Holder].ProgressiveMorphs01[#p01] $.modifiers[#Morpher][3] "result = 0
if (p01 < 40) then result = 0

else if ( p01 >= 40 and p01<=60 ) then  
(
result = (p01 - 40) *5
)
else if
( p01 >60  and p01<=80) then  
(
result = 100 - ( (p01 - 60) *5) 
)
result"

paramWire.connect pt_CTRL.modifiers[#Attribute_Holder].ProgressiveMorphs01[#p01] $.modifiers[#Morpher][4] "result = 0
if (p01 < 60) then result = 0

else if ( p01 >= 60 and p01<=80 ) then  
(
result = (p01 - 60) *5
)
else if
( p01 >80  and p01<=100) then  
(
result = 100 - ( (p01 - 80 ) *5) 
)
result"

paramWire.connect pt_CTRL.modifiers[#Attribute_Holder].ProgressiveMorphs01[#p01] $.modifiers[#Morpher][5] "result = 0
if (p01 < 80) then result = 0

else if ( p01 >= 80 and p01<=100 ) then  
(
result = (p01 - 80) *5
)
else if
( p01 >100  and p01<=100) then  
(
result = 100 - ( (p01 - 100 ) *5) 
)
result"

)

            -----------------------------------------------------------------------------------UI ListBox and clean up -------------------------------------------------------------------------
					
					
			
			select TargetArray
			hide TargetArray
			delete $TempSource01

max tool animmode
set animate off

max tool animmode
set animate off
	slidertime = 0
				
			)
			on MorphTarget picked obj do
			MorphTarget.text = obj.name
			on addToList pressed do
			(
				
			    for item in selection do (
					
					testList.items = append testList.items (item.name)
					append listobjects item
				
				)
				
			)
			on clearList pressed do
			(
			
			free listobjects
			
			while testList.items.count > 0 do (
				
				testList.items = deleteitem testList.items 1
				
			)
			
			)
			
			
			
		)
	


-- Check if the master Keelworks manager script and loading client scripts
if globalKeelworksLoading == true  then
(

    -- Add the rollout to the manager rollout window
    addRollout snap masterRolloutFloat
    -- And close/collapse it by default
    snap.open = false

)
else 
(
    -- Create a new dialogue window for the rollout
    createDialog snap width:320 height:512   
)



