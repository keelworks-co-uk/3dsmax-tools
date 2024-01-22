

	rollout WireColorizer "5: Wire Colorizer"
(
	
	colorpicker cl01 ""  pos:[9,5] width:35 height:30  color:[0,0,0] 
	button btn01 "Set" pos:[13,40] width:30 height:30 

	colorpicker cl02 ""  pos:[44,5] width:35 height:30  color:[10,10,10] 
	button btn02 "Set" pos:[49,40] width:30 height:30 
	
	--colorpicker cl03 ""  pos:[120,5] width:35 height:30  color:[20,20,20] 
	--button btn03 "Set" pos:[124,40] width:30 height:30 
	
	colorpicker cl04 ""  pos:[80,5] width:35 height:30  color:[50,50,50] 
	button btn04 "Set" pos:[85,40] width:30 height:30 
	
	colorpicker cl05 ""  pos:[115,5] width:35 height:30  color:[0,255,255]
	button btn05 "Set" pos:[120,40] width:30 height:30 
	
	colorpicker cl06 ""  pos:[150,5] width:35 height:30  color:[0,255,0] 
	button btn06 "Set" pos:[155,40] width:30 height:30 
	
	colorpicker cl07 ""  pos:[185,5] width:35 height:30  color:[255,0,0]
	button btn07 "Set" pos:[190,40] width:30 height:30 
	
	colorpicker cl08 ""  pos:[220,5] width:35 height:30  color:[254,255,0]
	button btn08 "Set" pos:[225,40] width:30 height:30

	--colorpicker cl09 ""  pos:[360,5] width:35 height:30  color:[254,255,0]
	--button btn09 "Set" pos:[364,40] width:30 height:30
	
	
	--colorpicker cl10 ""  pos:[5,5] width:25 height:22  color:[0,0,0]
	
	--button btn10 "ID" pos:[9,28] width:21 height:21
	--button btn11 "Rnd" pos:[9,50] width:30 height:20
	
	on btn11 pressed do
	(
		colorA = random 0 254
		colorB = random 0 254
		colorC = random 0 254
		cl01.color =[colorA,colorB,colorC]
		colorA = random 0 254
		colorB = random 0 254
		colorC = random 0 254
		cl02.color =[colorA,colorB,colorC]
		colorA = random 0 254
		colorB = random 0 254
		colorC = random 0 254
		cl03.color =[colorA,colorB,colorC]
		colorA = random 0 254
		colorB = random 0 254
		colorC = random 0 254
		cl04.color =[colorA,colorB,colorC]
		colorA = random 0 254
		colorB = random 0 254
		colorC = random 0 254
		cl05.color =[colorA,colorB,colorC]
		colorA = random 0 254
		colorB = random 0 254
		colorC = random 0 254
		--cl06.color =[colorA,colorB,colorC]
		colorA = random 0 254
		colorB = random 0 254
		colorC = random 0 254
		--cl07.color =[colorA,colorB,colorC]
		colorA = random 0 254
		colorB = random 0 254
		colorC = random 0 254
		--cl08.color =[colorA,colorB,colorC]
		colorA = random 0 254
		colorB = random 0 254
		colorC = random 0 254
		--cl09.color =[colorA,colorB,colorC]
	)
		
	on btn10 pressed do
	(
		cl01.color =black
		cl02.color =white
		cl03.color =gray
		cl04.color =red
		cl05.color =green
		--cl06.color =blue
		--cl07.color =yellow
		--cl08.color =orange
		--cl09.color =brown
	)
	
	on cl10 changed col do
	(
		cl01.color = black
		theColor = cl10.color
		theColor.value = col.value
		cl02.color = theColor/8
		

		cl03.color = theColor/4
		
		cl04.color = theColor/2
		cl05.color = theColor
		--cl06.color = theColor/8
		--cl07.color = theColor/4
		--cl08.color = theColor/2
		--cl09.color = theColor
	)
	
	
	on btn01 pressed do ( selection.wirecolor = cl01.color )
	on btn02 pressed do ( selection.wirecolor = cl02.color )
	on btn03 pressed do ( selection.wirecolor = cl03.color )
	on btn04 pressed do ( selection.wirecolor = cl04.color )
	on btn05 pressed do ( selection.wirecolor = cl05.color )
	on btn06 pressed do ( selection.wirecolor = cl06.color )
	on btn07 pressed do ( selection.wirecolor = cl07.color )
	on btn08 pressed do ( selection.wirecolor = cl08.color )
	on btn09 pressed do ( selection.wirecolor = cl09.color )
	
)
	
				
				
				

--------------------------------------------------------------------------------------- END EXTRA TOOLS
-- Check if the master Keelworks manager script and loading client scripts
if globalKeelworksLoading == true  then
(

    -- Add the rollout to the manager rollout window
    addRollout WireColorizer masterRolloutFloat
    -- And close/collapse it by default
    WireColorizer.open = false

)
else 
(
    -- Create a new dialogue window for the rollout
    createDialog WireColorizer width:300 height:400
    
)

	