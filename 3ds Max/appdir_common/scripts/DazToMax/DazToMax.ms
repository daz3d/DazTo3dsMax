--19 Oct 20
dotNet.loadAssembly "system.xml"
global selectedObject = undefined
global listWeight = #()
global listBoneSource = #()
global listBoneTarget =#()
global listBoneTarget1 =#()
--global listXML = #(#("ThighTwist,ThighBend,Shin,chestLower,abdomenUpper","objguides_Genesis3Female.xml"),)
global listXML = #(#("rThighTwist,rThighBend,rShin,chestLower,abdomenUpper","objguides_Genesis3Female.xml"),#("abdomen,abdomen2,chest","objguides_Genesis2Male.xml"),#("SENTINEL_177853,abdomen","objguides_SENTINEL_177853.xml"))

--global d2mFbxPath = "C:\TEMP3D\d2m.fbx"
global d2mFbxPath = "C:\\TEMP3D\\DazToMax.fbx"
global d2mDaePath = "C:\\TEMP3D\\DazToMax.dae"
	
global d2mXmlDoc = dotNetObject "system.xml.XmlDocument"
global d2mConfigpath = getfilenamePath (getThisScriptFilename())
global d2mLogo = openBitmap (d2mConfigpath+"d2m.png")
	
	
	global file_xml = "C:\\TEMP3D\\DazToMax.xml"
	global propDaz 
	global propVray 
	global propCorona 
	global propArnold
	global propPhysical
	global propStandard
try(destroyDialog rPBar )catch()	

function loadXML_loadPropertyPair =
(
	local filename = (d2mConfigpath+"/prop.xml")	
	if doesFileExist filename then
	(
		local d2mXmlDoc = dotNetObject "system.xml.XmlDocument"
		local d2mConfigpath = getfilenamePath (getThisScriptFilename())
		d2mXmlDoc.load 	filename
		local data = d2mXmlDoc.selectNodes "//props/prop"
		local listProp = #(#(),#(),#(),#(),#(),#())
		for i=0 to data.count-1 do
		(
			append listProp[1] data.itemof[i].attributes.Itemof["propDaz"].value
			append listProp[2] data.itemof[i].attributes.Itemof["propVray"].value
			append listProp[3] data.itemof[i].attributes.Itemof["propCorona"].value
			append listProp[4] data.itemof[i].attributes.Itemof["propArnold"].value
			append listProp[5] data.itemof[i].attributes.Itemof["propStandard"].value
			append listProp[6] data.itemof[i].attributes.Itemof["propPhysical"].value
		)
		propDaz = listProp[1]
		propVray = listProp[2]
		propCorona = listProp[3]
		propArnold = listProp[4]
		propStandard = listProp[5]
		propPhysical = listProp[6]
		return listProp
	)
	return undefined
)
loadXML_loadPropertyPair()
rollout rPBar "Progress"
(
	progressBar pbBar value:0 height:30 color:[0,210,255]
)
function getBitmapFromSubShader subShader =
(
	if classof subShader == MultiTile then
		if subShader.tileCount() >= 1 then
			subShader = subShader.getTileTexmap 1
		else
			return undefined
		
	return subShader
)
function vrayMaterialFromStandard  mat =
(
	tt = VRayMtl()
	tt.texmap_diffuse = getBitmapFromSubShader mat.diffusemap
	tt.diffuse = mat.diffuse
	tt.name = mat.name
	return tt	
)
function vrayMaterialFromPhysical  mat =
(
	tt = VRayMtl()
	tt.texmap_diffuse = getBitmapFromSubShader mat.base_color_map
	tt.diffuse = mat.base_color
	tt.name = mat.name
	return tt	
)
function convertToVrayScene =
(
	for o in geometry do 
	(
		if classof o.material == Standard do 
			o.material = vrayMaterialFromStandard o.material
		if classof o.material == PhysicalMaterial do 
			o.material = vrayMaterialFromPhysical o.material
		if classof o.material == Multimaterial then 
			for m = 1 to o.material.numsubs do
			(
				if classof o.material [m] == Standard do
					o.material [m] = vrayMaterialFromStandard o.material[m]
				if classof o.material [m] == PhysicalMaterial do
					o.material [m] = vrayMaterialFromPhysical o.material[m]
			)
	)
)

function anorldMaterialFromStandard  mat =
(
	tt = ai_standard_surface()
	tt.base_color_shader  = getBitmapFromSubShader mat.diffusemap
	tt.base_color = mat.diffuse
	tt.name = mat.name
	return tt	
)
function anorldMaterialFromPhysical  mat =
(
	tt = ai_standard_surface()
	tt.base_color_shader = getBitmapFromSubShader mat.base_color_map
	tt.base_color = mat.base_color
	tt.name = mat.name
	return tt	
)

function convertToAnorldScene =
(
	for o in geometry do 
	(
		if classof o.material == Standard do 
			o.material = anorldMaterialFromStandard o.material
		if classof o.material == PhysicalMaterial do 
			o.material = anorldMaterialFromPhysical o.material
		if classof o.material == Multimaterial then 
			for m = 1 to o.material.numsubs do
			(
				if classof o.material [m] == Standard do
					o.material [m] = anorldMaterialFromStandard o.material[m]
				if classof o.material [m] == PhysicalMaterial do
					o.material [m] = anorldMaterialFromPhysical o.material[m]
			)
	)
)


function physicalMaterialFromStandard  mat =
(
	tt = PhysicalMaterial()
	tt.base_color_map  = getBitmapFromSubShader mat.diffusemap
	tt.base_color = mat.diffuse
	tt.name = mat.name
	return tt	
)
function convertToPhysicalScene =
(
	for o in geometry do 
	(
		if classof o.material == Standard do 
			o.material = physicalMaterialFromStandard o.material
		if classof o.material == Multimaterial then 
			for m = 1 to o.material.numsubs do
			(
				if classof o.material [m] == Standard do
					o.material [m] = physicalMaterialFromStandard o.material[m]
			)
	)
)
	function isValidMorph obj =
	(
		if (obj != undefined)  then
		try
		(
			for objmod in obj.modifiers do
			(
				if (classof objmod == Morpher) then
				(
					local n = 0
					for i=1 to 100 do
						if WM3_MC_HasData objmod i then
							n+= 1
					if n>0 then
						return true
				)
			)
		)catch ()
		return false
	)	
	function getModMorph obj =
	(
		if (obj != undefined)  then
		try
		(
			for objmod in obj.modifiers do
			(
				if (classof objmod == Morpher) then
					return objmod
			)
		)catch ()
		return undefined
	)	
function cleanupMorpher obj =
(
	if obj != undefined and isValidMorph obj then
	(
		objmorph = getModMorph obj
		for i=1 to 200 do
			if WM3_MC_HasData objmorph i == false then
				for j=i+1 to 200 do
					if WM3_MC_HasData objmorph j then
					(
						WM3_MoveMorph objmorph j i
						exit
					)
	)
)
	
function morphRenamer =
(
	for obj in geometry do
		if obj.modifiers[#Morpher] != undefined then
		(
			print obj
			for i = 200 to 1 by -1 do
			(
				
				oldName = WM3_MC_GetName obj.modifiers[#Morpher] i
				 newName = oldName +""
				if oldName != "- empty -" do
				(
					newName = substituteString oldName "head__eCTRL" ""
					newName = substituteString newName "head__CTRL" ""
					newName = substituteString newName "head__VSM" ""
					newName = substituteString newName "head__PHM" ""
					newName = substituteString newName "head__CTRL" ""
					newName = substituteString newName "head__pCTRL" ""

					WM3_MC_SetName obj.modifiers[#Morpher] i newName
					
					local j = findString newName "RIG_"
					local k = findString newName "Male__"
					if j == 1 or k != undefined then
						WM3_MC_Delete obj.modifiers[#Morpher] i
				)
			)
			
			clearSelection()			
			cleanupMorpher obj
		)
)

function dazFixRotationsGen8 = 
(
	$rThighBend.rotation.controller.value = (quat 0.0126759 -0.0997517 -0.0776372 0.99191)
	$lThighBend.rotation.controller.value = (quat 0.0126759 0.0997517 0.0776372 0.99191)

	$rShldrBend.rotation.controller.value = (quat -0.00328944 0.00726182 0.39814 0.91729)
	$lShldrBend.rotation.controller.value = (quat -0.00328944 -0.00726182 -0.39814 0.91729)

	$rForearmBend.rotation.controller.value = (quat -0.103241 0.0882683 -0.0253197 0.990408)
	$lForearmBend.rotation.controller.value = (quat -0.103241 -0.0882683 0.0253197 0.990408)
	
	$rHand.rotation.controller.value = (quat 0.0962666 -0.0871907 -0 0.991529)
	$lHand.rotation.controller.value = (quat 0.0962666 0.0871907 0 0.991529)
	
	$rIndex1.rotation.controller.value = (quat -0.0348971 0.0316071 -0 0.998891)
	$lIndex1.rotation.controller.value = (quat -0.0348971 -0.0316071 0 0.998891)
	
	$rMid1.rotation.controller.value = (quat -0.00998664 0.00904512 -0 0.999909)
	$lMid1.rotation.controller.value = (quat -0.00998664 -0.00904512 0 0.999909)
	
	$rRing1.rotation.controller.value = (quat 0 0 0 1)
	$lRing1.rotation.controller.value = (quat 0 0 0 1)
)

function loadImage bt filepath =
	(
		try(bt.images = #(filepath, undefined, 1,1,1,1,1 ))catch()
	)
function loadXML =
(
	global d2mXmlDoc = dotNetObject "system.xml.XmlDocument"
	global d2mConfigpath = getfilenamePath (getThisScriptFilename())
	global d2mLogo = openBitmap (d2mConfigpath+"d2m.png")

	d2mXmlDoc.load (d2mConfigpath+"/config_locator.xml")
	--"L Toe02" --> "L Toe0Nub"
	global data = d2mXmlDoc.selectNodes "//config/bone"
	global n = data.count
	global arr=#()
	for i=0 to n-1 do
	(
		local a =  #(data.itemof[i].attributes.Itemof["name"].value,data.itemof[i].attributes.Itemof["syncpos"].value,data.itemof[i].attributes.Itemof["source"].value,data.itemof[i].attributes.Itemof["target"].value,data.itemof[i].attributes.Itemof["size"].value as float,data.itemof[i].attributes.Itemof["color"].value)
		append arr a
	)
)
fn selectHierachy obj =
(
	if obj != undefined do
	(
		selAry = #()
		append selAry obj
		i=1
		while i <= selAry.count do
		(
			childCount = selAry[i].children.count
			if childCount !=0 do
			(
				for j=1 to childCount do append selAry selAry[i].children[j]
			)
			i+=1
		)
		select selAry
	)
)
function getRoot obj = 
(
	if obj!= undefined then 
		while (obj.parent != undefined) do
			obj = obj.parent
	return obj
)
function n2n s =
(
	return (getNodebyname s)
)
function name2Index arr boneName =
(
	for i=1 to arr.count do
		if (boneName == arr[i][1]) then 
			return i
	return 0
)

function setCATposition cat pos =
(
	local offset = pos - cat.transform.pos
	move cat offset
	forceCompleteRedraw()
)
function getDirVector arr s1 s2 s3 =
(
	local i = name2Index arr s1
	local j = name2Index arr s2
	local k = name2Index arr s3
	local p1 = (n2n arr[i][4]).transform.pos
	local p2 = (n2n arr[j][4]).transform.pos
	local p3 = (n2n arr[k][4]).transform.pos
	return ((p2+p3)/2.0-p1)
)
function getNormalVector arr s1 s2 s3 =
(
	local i = name2Index arr s1
	local j = name2Index arr s2
	local k = name2Index arr s3
	local p1 = (n2n arr[i][4]).transform.pos
	local p2 = (n2n arr[j][4]).transform.pos
	local p3 = (n2n arr[k][4]).transform.pos
	return (normalize (cross (p3-p1) (p2-p1)))
)


function getMirrorName s rN =
(
	local ss = s+""
	if (ss.count >=rN) then
		if (ss[rN] == "L") then
			ss[rN] = "R"
		else
			ss = ""
	else
			ss = ""
	return ss
)
function setArmUp obj =
(
	if obj == undefined then 
		return true
	local m = obj.transform
	mx = m[1]
	my = m[2]
	my.z = 0
	my = normalize my
	mz = cross mx my
	mx = m[1]
	obj.transform = matrix3 mx my mz m[4]
)


function syncBipedLength source target1 target2 =
(
	
	local l = 1
	if (classOf target1 != Float) then
		l = length (target1.transform.pos-target2.transform.pos)
	else
		l = target1
	biped.setTransform source #scale [l,l,l] false
)
function syncBipedRotation source t1 t2 dir type =	
(
	---0 spine, 1 arm, 2 palm, 3 leg, 4 foot, 5 toe 6 finger
	Box lengthsegs:1 widthsegs:1 heightsegs:1 length:30 width:10 height:10 mapcoords:on pos:[0,0,0] isSelected:on
	local l = 0
	if (classOf t2 == float) then
		l = t2
	else
			l = length (t1.transform.pos-t2.transform.pos)
	local temp = $
	local rot = t1.transform.rotation
	temp.transform = t1.transform
	if (type==1) then
		in coordsys temp rotate temp (angleaxis 180 [1,0,0])
	local xdir
	local ydir
	local zdir


	
	if (type==3) then
	(
		xdir = dir
		ydir = [0,-1,0]
		zdir = cross xdir ydir
		zdir = normalize zdir
		ydir = cross zdir xdir
		ydir = normalize ydir
		temp.transform = matrix3  xdir ydir zdir temp.transform[4]
	)

	if (type==4) then
	(
		ydir = normalize (t2.transform.pos-t1.transform.pos)
		ydir.z = 0
		xdir = dir
		zdir = cross xdir ydir
		zdir = normalize zdir
		ydir = cross xdir zdir
		ydir = normalize ydir
		temp.transform = matrix3  xdir ydir zdir temp.transform[4]
	)	
	if (type==5) then
	(
		xdir = dir
		xdir.z = 0
		ydir = [0,0,1]
		zdir = cross xdir ydir
		zdir = normalize zdir
		temp.transform = matrix3  xdir ydir zdir temp.transform[4]
	)
		
	if (type==6) then
	(
		xdir = dir
		ydir = t1.transform[2]
		zdir = cross xdir ydir
		zdir = normalize zdir
		ydir = cross zdir xdir
		ydir = normalize ydir
		temp.transform = matrix3  xdir ydir zdir temp.transform[4]
	)
	
	temp.pos = biped.getTransform source #pos
	local rot = (in coordsys source temp.rotation as eulerAngles) as angleAxis
	in coordsys source rotate source rot
	delete temp
	
	local s = biped.getTransform source #scale
	if (type <=3) then
		s= [l,l,l]
	if (type == 4) then
		s.y = l
	if (type == 5 or type==6) then
		s.x = l
		
	biped.setTransform source #scale s false
)
	function removeCurrentLocator lbName type arr =
	(
		local newName = lbName
		if (type ==1) then
		(
			newName = arr[name2Index arr lbName][4]
			print (lbName +" - " + newName)
		)
		local oldNode = getNodeByName newName
		if (oldNode != undefined) then
			delete oldNode
	)
function syncBipedXML arrInput baseTarget sourceObj =
(
	local n = arrInput[1][3].count+1
	baseTarget = getRoot baseTarget
	local arr = #()
	local marr =#()
	local prefix = ""
	local prefix1 = arrInput[1][3]
	prefix = sourceObj.name+" "
	local j = 0
	for i=1 to arrInput.count do
	(
		append arr #(arrInput[i][1]+"",arrInput[i][2]+"",arrInput[i][3]+"",arrInput[i][4]+"",arrInput[i][5]+0,arrInput[i][6]+"")
		if i>1 then
			arr[i][3] = prefix1+arr[i][3]
		if (arrInput[i][2] == "4" or arrInput[i][2] == "5" or arrInput[i][1] == "LShoulder" or arrInput[i][1] == "LPFoot") then
		(
			j += 1
			append marr #(arr[i][1]+"",arr[i][2]+"",arr[i][3]+"",arr[i][4]+"",arr[i][5]+0,arr[i][6]+"")
			marr[j][1][1] = "R"
			if (marr[j][3].count >= n) then
				marr[j][3][n] = "R"
			marr[j][4][1] = "R"
		)
	)
	for a in arr do
	(
		local t = a[3]+""
		a[3] = a[4]+""
		a[4] = t+""
		a[3] = prefix + a[3]
	)
	for a in marr do
	(
		local t = a[3]+""
		a[3] = a[4]+""
		a[4] = t+""
		a[3] = prefix + a[3]
	)
	---scale Biped to target size
	base = sourceObj
	local k = 0
	local j = 0
	local i = name2Index arr ("Head")
	base.controller.height = (n2n arr[i][4]).max.z - baseTarget.min.z
	
	i = name2Index arr "Pelvis"
	biped.setTransform base #pos (n2n arr[i][4]).transform.position false

	local xc = base.transform.pos.x
	--sync biped bone length
	local list1 =#("Spine01","Spine02","Spine03","Spine04","Neck","Head")
	for i=1 to list1.count-1 do
	(
		j = name2Index arr list1[i]
		k = name2Index arr list1[i+1]
		syncBipedRotation (n2n arr[j][3]) (n2n arr[j][4]) (n2n arr[k][4]) [0,0,1] 0
	)
	--fix the spine01 size
	i = name2Index arr list1[1]
	j = name2Index arr list1[2]
	local l = (length ((n2n arr[j][4]).transform.pos-(biped.getTransform (n2n arr[i][3]) #pos )))
	biped.setTransform (n2n arr[i][3]) #scale [l,l,l] false
		
	--sync Arm
	local list2 =#("Shoulder","Arm" ,"ForeArm","Palm","Middle1")
	i = name2Index arr ("L"+list2[1])
	biped.setTransform (n2n arr[i][3]) #pos  (n2n arr[i][4]).transform.pos false
	for i=1 to list2.count-1 do
	(
		j = name2Index arr ("L"+list2[i])
		k = name2Index arr ("L"+list2[i+1])
		syncBipedRotation (n2n arr[j][3]) (n2n arr[j][4]) (n2n arr[k][4]) [1,0,0] 1
	)
	--sync finger
	local list3 =#("Index" ,"Middle","Ring","Pinky")
	for i=1 to 3 do
		for ol in list3 do
		(
			j = name2Index arr ("L"+ol+i as string)
			if (i==1) then
				biped.setTransform (n2n arr[j][3]) #pos  (n2n arr[j][4]).transform.pos false
			if (i<3) then
			(
				k = name2Index arr ("L"+ol+ (i+1) as string)
				syncBipedRotation (n2n arr[j][3]) (n2n arr[j][4]) (n2n arr[k][4]) [1,0,0] 1
			)
			else
			(
				local l = ((n2n arr[j][4]).length*(n2n arr[j][4]).CATunits) 
				syncBipedRotation (n2n arr[j][3]) (n2n arr[j][4]) l [1,0,0] 1
			)
		)
	--sync thumb
	j = name2Index arr ("LPalm")
	local p1 = (n2n arr[j][4]).transform.pos		
	j = name2Index arr ("LThumb1")
	local p2 = (n2n arr[j][4]).transform.pos
	local p = (p1+p2)/2.0
	biped.setTransform (n2n arr[j][3]) #pos p false
	k = name2Index arr ("LThumb2")
	local dir = (n2n arr[j][4]).transform.pos - p
	l = length dir
	dir = normalize  dir
	syncBipedRotation (n2n arr[j][3]) (n2n arr[j][4]) l dir 6
	j = name2Index arr ("LThumb1")
	k = name2Index arr ("LThumb2")
	syncBipedRotation (n2n arr[k][3]) (n2n arr[j][4]) (n2n arr[k][4]) [1,0,0] 1		
	j = name2Index arr ("LThumb2")
	k = name2Index arr ("LThumb3")
	dir = (n2n arr[j][4]).transform[1]
	l =  ((n2n arr[j][4]).length*(n2n arr[j][4]).CATunits) 
	syncBipedRotation (n2n arr[k][3]) (n2n arr[j][4]) l dir 6
		
	--sync thigh
	local list4 =#("LegUp","Leg" ,"Foot","Toe","Toe1")
	j = name2Index arr ("LLegUp")
	k = name2Index arr ("LLeg")
	local dir = (n2n arr[k][4]).transform.pos - biped.getTransform (n2n arr[j][3]) #pos
	local l = length dir
	dir = normalize dir
	syncBipedRotation (n2n arr[j][3]) (n2n arr[j][4]) l dir 3
	--sync leg
	j = name2Index arr ("LLeg")
	k = name2Index arr ("LFoot")
	dir = (n2n arr[k][4]).transform.pos - (n2n arr[j][4]).transform.pos
	l = length dir
	dir = normalize dir
	syncBipedRotation (n2n arr[j][3]) (n2n arr[j][4]) l dir 3
	--sync foot
	j = name2Index arr "LFoot"
	k = name2Index arr "LToe"
	syncBipedRotation (n2n arr[j][3]) (n2n arr[j][4]) (n2n arr[k][4]) [0,0,1] 4
	--fix toe length
	i = name2Index arr ("LFoot")
	j = name2Index arr ("LToe")
	k = name2Index arr ("LToe1")
	local dir = normalize ((n2n arr[j][4]).transform.pos - (n2n arr[i][4]).transform.pos)
	local l = ((n2n arr[j][4]).length*(n2n arr[j][4]).CATunits) 
	syncBipedRotation (n2n arr[j][3]) (n2n arr[j][4]) l dir 5
	
	local pT = (n2n arr[j][4]).transform.pos
	local pF = (n2n arr[i][4]).transform.pos
	pT.z = pF.z - (biped.getTransform (n2n arr[i][3]) #scale ).x	
	biped.setTransform (n2n arr[j][3]) #pos pT false	
	
	biped.createCopyCollection base.controller "myCollection"
	j = name2Index arr ("LLegUp")
	k = name2Index marr ("RLegUp")
	select (n2n arr[j][3])
	actionMan.executeAction 0 "40180"
	myThigh = biped.copyPosture (n2n arr[j][3]).controller #posture True True True
	biped.pastePosture (n2n marr[k][3]).controller #posture True myThigh	
	j = name2Index arr ("LShoulder")
	k = name2Index marr ("RShoulder")
	select (n2n arr[j][3])
	actionMan.executeAction 0 "40180"
	myThigh = biped.copyPosture (n2n arr[j][3]).controller #posture True True True
	biped.pastePosture (n2n marr[k][3]).controller #posture True myThigh		

	for a in marr do
		append arr a
	return arr
)

function getCATRatio CATBase CATHead targetObj =
(	
	local h1 = CATHead.max.z-CATBase.transform.pos.z
	local h2 = 0
	if (classOf targetObj == Biped_Object) then
		h2 = targetObj.controller.height
	else
		h2 = targetObj.max.z-targetObj.min.z
	return (h2*CATBase.CATUnits/h1)
)


function syncCATBone CATRoot boneRoot type boneDir vectorUp =
(
	if CATRoot == undefined then
		return false
	--position only
	if (type == 1) then
	(
		--print (CATRoot.name +"--"+boneRoot.name+"---"+boneRoot.transform.pos as string)
		setCATposition CATRoot boneRoot.transform.pos	
	)
	--rotation only
	if (type == 2) then
	(
		local m = boneRoot.transform
		CATRoot.transform = matrix3 m[1] m[2] m[3] CATRoot.transform[4]
	)
	--foot rotation and length
	if (boneDir != undefined and type==3) then
	(
		local m = CATRoot.transform
		local mx= [0,0,1]
		local l = 1
		if (classOf boneDir == Point3) then
		(
			l = length boneDir
			mx = normalize boneDir
		)
		else
		(
			mx = normalize (boneDir.transform.pos-boneRoot.transform.pos)
			l = distance boneRoot.transform.pos boneDir.transform.pos
		)
		CATRoot.length = l/CATRoot.CATUnits			
		local mz = normalize (cross  mx vectorUp)
		local my = normalize (cross mz mx)
		CATRoot.transform = matrix3 mx my mz CATRoot.transform[4]		
	)
	--sync platform
	if (boneDir != undefined and type==4) then
	(
		local pos =  boneRoot.transform.pos	
		pos.z =0
		setCATposition CATRoot pos
		local m = CATRoot.transform
		local mx= [0,0,1]
		if (classOf boneDir == Point3) then
		(
			my = normalize boneDir
		)
		else
		(
			my = normalize (boneDir.transform.pos-boneRoot.transform.pos)
		)
		my.z = 0
		local mz = normalize (cross  vectorUp my)
		mz.z =0
		local my = normalize (cross mz mx)
		CATRoot.transform = matrix3 mx my mz CATRoot.transform[4]		
	)	
	forceCompleteRedraw()
)

function syncCATBoneByName arr n1 type n2 vectorUp =
(
	local i = name2Index arr n1
	if (n2 == "") then
	(
		if (arr[i][3] != "" and arr[i][4] !="") then
		try(
			syncCATBone (n2n arr[i][3]) (n2n arr[i][4]) type undefined vectorUp
		)catch( 	
			print (arr[i][3]+"---"+arr[i][4])
		)
	)
	else
	(
		local j = name2Index arr n2
		if (classOf n2 == Point3) then
			syncCATBone (n2n arr[i][3]) (n2n arr[i][4]) type n2 vectorUp
		else
			syncCATBone (n2n arr[i][3]) (n2n arr[i][4]) type (n2n arr[j][4]) vectorUp
	)
)

function syncCATMirrorBone  cL cR xc =
(
		--print (CATName+"--"+cL as tring +"--"+cR as string)
	try(
		--if abs (cR.controller.length - cL.controller.length)/cL.controller.length > 0.01 then
			cR.controller.length = cL.controller.length
	)catch(
		cR.length = cL.length
	)
	local pos = cL.transform.pos
	pos.x = xc-(pos.x-xc)
	setCATposition cR pos
	local mx = cL.transform[1]
	local my = cL.transform[2]
	local mz = cL.transform[3]
	mx.x = -mx.x
	my.x = -my.x
	mz.x = -mz.x
	cR.transform = matrix3 mx my -mz cR.transform.pos					
	

	if classof cR == CATBone and classof cL == CATBone then 
	try
	(
		cR.controller.Width = cL.controller.Width+0.0
		cR.controller.Depth = cL.controller.Depth+0.0
	)catch(
		cR.Width = cL.Width+0.0
		cR.Depth = cL.Depth+0.0
	)
)

function syncMirror CATName type xc rN =
(
	local r = getMirrorName CATName rN
	if r != "" then 
	(
		local cL = n2n CATName
		local cR = n2n r
		
		syncCATMirrorBone cL cR xc
	)	
)

function syncCATXML arrInput baseTarget isArmUp thumbMode =
(
	local n = arrInput[1][3].count+1
	local arr = #()
	local marr =#()
	local prefix = ""
	local prefix1 = arrInput[1][3]
	local isBiped = (classof baseTarget == Biped_Object)
	if (isBiped) then
	(
		prefix = baseTarget.name+" "
		baseTarget = getRoot baseTarget
	)
	local j = 0
	for i=1 to arrInput.count do
	(
		append arr #(arrInput[i][1]+"",arrInput[i][2]+"",arrInput[i][3]+"",arrInput[i][4]+"",arrInput[i][5]+0,arrInput[i][6]+"")
		if i>1 then
			arr[i][3] = prefix1+arr[i][3]
		if (arrInput[i][2] == "4" or arrInput[i][2] == "5" or arrInput[i][1] == "LShoulder" or arrInput[i][1] == "LPFoot") then
		(
			j += 1
			append marr #(arr[i][1]+"",arr[i][2]+"",arr[i][3]+"",arr[i][4]+"",arr[i][5]+0,arr[i][6]+"")
			marr[j][1][1] = "R"
			if (marr[j][3].count >= n) then
				marr[j][3][n] = "R"
			marr[j][4][1] = "R"
			marr[j][4] = prefix + marr[j][4]
		)
		arr[i][4] = prefix + arr[i][4]
	)
	try (	rPBar.pbBar.value = 22 ) catch ()

	---scale CAT to target size
	local i= name2Index arr "Human"
	local j =name2Index arr "Head"
	--local k = 0
	base = (n2n arr[i][3])
	base.LengthAxis = "X"
	base.CATUnits = getCATRatio base (n2n arr[j][3]) baseTarget
	
	-- hide all cat bone
	for a in arr do 
	(
		local temp = (n2n a[3])
		if temp != undefined then 
		(
			hide temp
			hide temp.children 
			local r = getMirrorName  a[3] n
			if r != "" then 
			(
				temp = n2n r
				if temp != undefined then 
					hide temp
			)
		)
	)
	
	--return true
	local pos = [0,0,0]
	if isBiped then
	(
		pos = baseTarget.transform.pos
		pos.z = 0
	)
	else
	(
		pos = baseTarget.center
		pos.z = baseTarget.min.z
		pos.z = 0
	)
	setCATposition	 base pos
	
	for a in arr do 
		if a[2] == "3" then 
		(
			local temp = n2n a[4]
			if (temp !=undefined) then
				temp.transform.pos.x = base.transform.pos.z
		)
	local xc = base.transform.pos.x
		
	--sync platform
	syncCATBoneByName arr "LPFoot" 4 "LToe" [0,0,1]
	if (isBiped) then
	(
		syncCATBoneByName marr "RPFoot" 4 "RToe" [0,0,1]
	)
	try (	rPBar.pbBar.value = 23 ) catch ()
	
	--sync Ribcage
	if (isBiped == false) then
	(
		local i = name2Index arr "Ribcage"
		local j = name2Index arr "Spine03"
		(n2n arr[i][3]).height = ((n2n "Neck").pos.z-(n2n arr[j][4]).pos.z)/base.CATUnits			
	)
	try (	rPBar.pbBar.value = 24 ) catch ()
	
	--sync head height
	if (isBiped == false) then
	(
		i= name2Index arr ("Head")
		j= name2Index arr ("Head1")	
		
		local h = ((n2n arr[j][4]).pos.z-(n2n arr[i][4]).pos.z)/(n2n arr[i][3]).CATUnits
		if h <0.1 then h = 23
		(n2n arr[i][3]).height = h
	)
		
	--sync palm
	local dir = getDirVector arr "LPalm" "LPinky1" "LIndex1"
	local up = getNormalVector arr "LPalm" "LPinky1" "LIndex1"
	syncCATBoneByName arr "LPalm" 3 dir up
	try (	rPBar.pbBar.value = 25 ) catch ()
	
	--sync position first
	local i=1
	for a in arr do 
	(
		i += 1
		if a[2] != "0" then syncCATBoneByName arr a[1] 1 "" [0,0,0]
		try (	rPBar.pbBar.value = (25+i*10/arr.count) ) catch ()
	)
	i=1
	for a in arr do
	(
		i += 1
		if a[2] != "0" then syncCATBoneByName arr a[1] 1 "" [0,0,0]
		try (	rPBar.pbBar.value = (35+i*10/arr.count) ) catch ()
	)
		

	if isBiped == false and isArmUp then
	(
		i= name2Index arr ("LShoulder")
		setArmUp (n2n arr[i][3])
		i= name2Index arr ("LArm")
		setArmUp (n2n arr[i][3])
		i= name2Index arr ("LForeArm")
		setArmUp (n2n arr[i][3])
		i= name2Index arr ("LForeArm1")
		if i>0 then
			setArmUp (n2n arr[i][3])

		--sync palm
		syncCATBoneByName arr "LPalm" 3 dir up
		
		local i=1
		for a in arr do 
		(
			i += 1
			if a[2] != "0" then syncCATBoneByName arr a[1] 1 "" [0,0,0]
			try (	rPBar.pbBar.value = (45+i*10/arr.count) ) catch ()
		)
		i = 1
		for a in arr do 
		(
			i += 1
			if a[2] != "0" then syncCATBoneByName arr a[1] 1 "" [0,0,0]
			try (	rPBar.pbBar.value = (55+i*10/arr.count) ) catch ()
		)
	)
		
	syncCATBoneByName arr "LLeg" 1 "" [0,0,1]
	/*
	i= name2Index arr ("LLeg")
	p = (n2n arr[i][3]).transform.pos
	p.y -= p.z/10.0
	setCATPosition (n2n arr[i][3]) p
	*/
	--sync shoulder
	i= name2Index arr ("LShoulder")
	if (isBiped == false) then
	(
		local j= name2Index arr ("Spine04")
		try (
			setCATposition	(n2n arr[i][3]) (n2n arr[j][3]).center
		) catch()
	)
	--sync finger dot length, rotation
	local list =#("Thumb","Index","Middle","Ring","Pinky")
	for m in list do
	(
		local i= name2Index arr ("L"+m+"1")
		syncCATBoneByName arr ("L"+m+"2") 3 ("L"+m+"3") (n2n arr[i][3]).transform[2]
		
		--change xml
		if (m!="Thumb") then
		(
			i= name2Index arr ("L"+m+"2")
			if (isBiped) then
			(
				local j= name2Index arr ("L"+m+"3")
				local l = (length ((n2n arr[j][3]).transform.pos-(n2n arr[i][3]).transform.pos))
				syncCATBoneByName arr ("L"+m+"3") 3 ((n2n arr[j][4]).transform[1]*l) [0,0,0]
			)
			else
				syncCATBoneByName arr ("L"+m+"3") 3 ("L"+m+"4") (n2n arr[i][3]).transform[2]
		)
	)
	try (	rPBar.pbBar.value = 70 ) catch ()
	
	if (thumbMode == 3) then
	(
		h= name2Index arr ("LPalm")
		i= name2Index arr ("LThumb1")
		j= name2Index arr ("LThumb2")
		k= name2Index arr ("LThumb3")
		p1 = ((n2n arr[h][4]).transform.pos+(n2n arr[i][4]).transform.pos)/2
		setCATposition (n2n arr[i][3]) p1
		setCATposition (n2n arr[j][3]) (n2n arr[i][4]).transform.pos
		setCATposition (n2n arr[k][3]) (n2n arr[j][4]).transform.pos
		dir = (n2n arr[k][4]).transform.pos-(n2n arr[j][4]).transform.pos
		syncCATBone (n2n arr[k][3])  (n2n arr[j][4]) 3 dir (n2n arr[j][3]).transform[2]
		
	)
	if (isBiped) then
	(
		i= name2Index arr ("LThumb1")
		j= name2Index arr ("LThumb2")
		k= name2Index arr ("LThumb3")
		setCATPosition (n2n arr[j][3]) (n2n arr[k][4]).transform.pos
		setCATPosition (n2n arr[i][3]) (n2n arr[j][4]).transform.pos
		syncCATBoneByName arr ("LThumb2") 3 ("LThumb3") (n2n arr[k][4]).transform[2]
	)

	syncCATBoneByName arr "LFoot" 3 "LToe" [0,0,1]
	i= name2Index arr ("LFoot")
	j= name2Index arr ("LToe")
	local k= name2Index arr ("LToe1")
	local dir = (n2n arr[i][3]).transform[1]
	dir.z = 0
	dir = normalize dir
	local l = 0
	
	if (isBiped) then
	(
		local dir1 = (n2n arr[k][4]).transform.pos - (n2n arr[j][4]).transform.pos
		l = dot dir1 dir
	)
	else
	(
		local dir1 = (n2n arr[k][4]).transform.pos - (n2n arr[j][4]).transform.pos
		l = dot dir1 dir
	)
	syncCATBoneByName arr "LToe" 1 "" [0,0,0]
	syncCATBoneByName arr "LToe" 3  (dir*l) [0,0,1]
	try (	rPBar.pbBar.value = 73 ) catch ()

	--mirror
	if (isBiped) then
	(		--sync Palm
		dir = getDirVector marr "RPalm" "RPinky1" "RIndex1"
		up = getNormalVector marr "RPalm" "RPinky1" "RIndex1"
		syncCATBoneByName marr ("RPalm") 3 dir up
		--sync position first
		for a in marr do if a[2] != "0" then syncCATBoneByName marr a[1] 1 "" [0,0,0]
		for a in marr do if a[2] != "0" then syncCATBoneByName marr a[1] 1 "" [0,0,0]
		
		for m in list do
		(
			local i= name2Index marr ("R"+m+"1")
			if i>0 then
				syncCATBoneByName marr ("R"+m+"2") 3 ("R"+m+"3") (n2n marr[i][3]).transform[2]
			
			if (m!="Thumb") then
			(
				i= name2Index marr ("R"+m+"2")
				local j= name2Index marr ("R"+m+"3")
				local l = (length ((n2n marr[j][3]).transform.pos-(n2n marr[i][3]).transform.pos))
				syncCATBoneByName marr ("R"+m+"3") 3 ((n2n marr[j][4]).transform[1]*l) [0,0,0]
			)
		)		
		if (isBiped) then
		(
			i= name2Index marr ("RThumb1")
			j= name2Index marr ("RThumb2")
			k= name2Index marr ("RThumb3")
			setCATPosition (n2n marr[j][3]) (n2n marr[k][4]).transform.pos
			setCATPosition (n2n marr[i][3]) (n2n marr[j][4]).transform.pos
			syncCATBoneByName marr ("RThumb2") 3 ("RThumb3") (n2n marr[k][4]).transform[2]
		)
		
		--sync ankle and toe
		syncCATBoneByName marr "RFoot" 3 "RToe" [0,0,1]
		i= name2Index marr ("RFoot")
		j= name2Index marr ("RToe")
		k= name2Index marr ("RToe1")
		dir = (n2n marr[i][3]).transform[1]
		dir.z = 0
		dir = normalize dir
		syncCATBoneByName marr "RToe" 1 "" [0,0,0]
		syncCATBoneByName marr "RToe" 3  (dir*l) [0,0,1]		
	)
	else
	(
		--mirror platform
		i= name2Index arr ("LPFoot")
		syncMirror arr[i][3] 2 xc n
		--mirror R Palm
		i= name2Index arr ("LPalm")
		syncMirror arr[i][3] 2 xc n
		--mirror all bone
		for i = 1 to 2 do
			for a in arr do 
				if (a[1][1] =="L") then
				(
					syncMirror a[3] 1 xc n
				)
		if (isArmUp) then
		(
			i= name2Index arr ("LShoulder")
			r = getMirrorName arr[i][3] n
			setArmUp (n2n r)
			i= name2Index arr ("LArm")
			r = getMirrorName arr[i][3] n
			setArmUp (n2n r)
			i= name2Index arr ("LForeArm")
			r = getMirrorName arr[i][3] n
			setArmUp (n2n r)
			i= name2Index arr ("LForeArm1")
			if i>0 then
			(
				r = getMirrorName arr[i][3] n
				setArmUp (n2n r)
			)

			--mirror R Palm
			i= name2Index arr ("LPalm")
			syncMirror arr[i][3] 2 xc n
					
			--mirror all bone (re-update)
			for i = 1 to 2 do
				for a in arr do 
					if (a[1][1] =="L") then
					(
						syncMirror a[3] 1 xc n
					)
		)
				
		--mirro finger tip
		local list1 =#("Thumb2","Index3","Middle3","Ring3","Pinky3")
		if thumbMode == 3 then list1[1] = "Thumb3"
		for m in list1 do
		(
			i= name2Index arr ("L"+m)
			syncMirror arr[i][3] 2 xc n
		)

		--mirror Foot, Toe
		--King
		i= name2Index arr ("LFoot")
		print arr[i][3]
		print xc
		print n
		syncMirror arr[i][3] 3 xc n
		i= name2Index arr ("LToe")
		try (	rPBar.pbBar.value = 82 ) catch ()
		syncMirror arr[i][3] 3 xc n
		
		
	)
	-- unhide all cat bone
	for a in arr do 
	(
		local temp = (n2n a[3])
		if temp != undefined then 
		(
			unhide temp
			unhide temp.children 
			local r = getMirrorName  a[3] n
			if r != "" then 
			(
				temp = n2n r
				if temp != undefined then 
					unhide temp
			)
		)
	)	
		for a in marr do
			append arr a
		return arr

)

-------------------------------------------------------------


	function getBoneWeightByVert selObj v =
	(
		local selSkin = selObj.modifiers[#skin]
		local n = skinOps.getVertexWeightCount selSkin v
		local b = #()
		for i = 1 to n do
		(
			local boneID = skinOps.getVertexWeightBoneId selSkin v i
			local boneName = skinOps.GetBoneName selSkin boneID 0
			local boneWeight = skinOps.getVertexWeight selSkin v i			
			append b #(boneID,boneWeight)
		)
		return b
	)
	function setBoneWeightByVert selObj v listWeight=
	(
		local selSkin = selObj.modifiers[#skin]
		for w in listWeight do
			skinOps.SetVertexWeights selSkin v w[1] w[2]
	)
	
	function getMappingArray arrInput  sourceObj =
	(
		local arr = #()
		local marr =#()
		local prefix = ""
		local prefix1 = arrInput[1][3]
		prefix = sourceObj+" "
		local j = 0
		for i=1 to arrInput.count do
		(
			append arr #(arrInput[i][1]+"",arrInput[i][2]+"",arrInput[i][3]+"",arrInput[i][4]+"",arrInput[i][5]+0,arrInput[i][6]+"")
			if i>1 then
				arr[i][3] = prefix1+arr[i][3]
			if (arrInput[i][2] == "4" or arrInput[i][2] == "5" or arrInput[i][1] == "LShoulder" or arrInput[i][1] == "LPFoot") then
			(
				j += 1
				append marr #(arr[i][1]+"",arr[i][2]+"",arr[i][3]+"",arr[i][4]+"",arr[i][5]+0,arr[i][6]+"")
				marr[j][1][1] = "R"
				if (marr[j][3].count >= 11) then
					marr[j][3][11] = "R"
				marr[j][4][1] = "R"
			)
		)
		for a in arr do
		(
			local t = a[3]+""
			a[3] = a[4]+""
			a[4] = t+""
			a[3] = prefix + a[3]
		)
		for a in marr do
		(
			local t = a[3]+""
			a[3] = a[4]+""
			a[4] = t+""
			a[3] = prefix + a[3]
		)
		for a in marr do
			append arr a
		return arr
	)
	function getTargetName arr SourceName =
	(
		for a in arr do
			if (toLower a[4]) == (toLower SourceName) then
				return a[3]
		return ""
	)
	--skinOps.addbone <Skin> <Bone_node> <Update_integer> 
	--skinOps.SetVertexWeights <Skin> <vertex_integer> \ ( <vertex_bone_integer> | <vertex_bone_array> ) \ ( <weight_float> | <weight_array
	--skinOps.copySelectedBone <Skin <Skin> 
	--skinOps.pasteToBone <Skin> <BoneID_int> 
	--skinOps.SelectBone $.modifiers[#Skin] 8

	function saveSkinData selObj =
	(
		listWeight = #()
		listBoneSource = #()
		select selObj
		max modify mode
		selSkin = selObj.modifiers[#skin]
		local n = polyOp.getNumVerts selObj
		local nBone = skinOps.GetNumberBones selSkin
		for i=1 to nBone do 
			append listBoneSource (skinOps.GetBoneName selSkin i 0)
		for i = 1 to n do
			append listWeight (getBoneWeightByVert selObj i)
	)
	function loadSkinData newarr1 selObj = 
	(
		--remove old CAT bone
		select selObj
		selSkin = selObj.modifiers[#skin]
		listBoneTarget = #()
		for c in listBoneSource do
		(
			local t = (getTargetName newarr1 c)
			append listBoneTarget t
		)
		for i=1 to listBoneSource.count do
		(
			skinOps.SelectBone selSkin 1
			skinOps.removeBone selSkin 1
		)
		--add new biped Bone
		for i=1 to listBoneTarget.count do
		(
			local b = (getNodeByName listBoneTarget[i])
			if b!= undefined then
				skinOps.addbone selSkin b -1
			else
				print listBoneTarget[i]
		)
		local nBone = skinOps.GetNumberBones selSkin
		listBoneTarget1 = #()
		for i=1 to nBone do 
			append listBoneTarget1 (skinOps.GetBoneName selSkin i 0)		
		--for i = 1 to nBone do
		--	print (listBoneSource[i]+":"+listBoneTarget[i]+":"+listBoneTarget1[i])
		--apply CAT bone weight to biped bone weight
		local n = polyOp.getNumVerts selObj
		local nBone = skinOps.GetNumberBones selSkin
		for i = 1 to n do
			setBoneWeightByVert selObj i listWeight[i]
	)
	
	global rootLocator
	function defineRootLocator mainObj =
	(
		rootLocator = getNodeByname "tempLocators"
		if (rootLocator != undefined) then
			rootLocator.pos = mainObj.pos
		else
		(
			Point pos:[210.796,53.3288,0] isSelected:on
			rootLocator = $
			rootLocator.name =  "tempLocators"
			rootLocator.pos = mainObj.pos
		)
	)	
	function newBone newName pos l w h c isCenter = 
	(
		removeCurrentLocator newName 0 arr
		Box lengthsegs:1 widthsegs:1 heightsegs:1 length:l width:w height:h mapcoords:on pos:pos isSelected:on
		$.name = newName
		$.mat =  standardmaterial()
		$.mat.diffuse = c
		$.wirecolor = c
		if isCenter then
			$.pivot = $.center
		$.pos = pos
		$.parent = rootLocator
		return $	
	)	


try(destroyDialog rConverter )catch()	
rollout rConverter "DazToMax v1.00" height:470 width:400
(
	imgTag ikmaxlogo "" width:400  height:90 bitmap:d2mLogo enabled:false border:false pos:[0 ,0]
	local moveOne = -53
	label 'lbl3' "If importing from Temp folder, save to another location (!)" pos:[62,224+moveOne] width:288 height:16 align:#left
	button btnAutoImport "Auto-Import" pos:[10,150+moveOne] width:379 height:60 align:#left
	button btnSaveScene "Save Scene with Textures..." pos:[10,244+moveOne] width:379 height:60 align:#left
	checkbox cbShowReminder "Show me a reminder after importing from Temp folder." pos:[60,309+moveOne] width:280 height:16 align:#left

	button btnConvertMat "Convert Materials" pos:[10,350+moveOne] width:226 height:25 align:#left
	dropDownList ddlConvert items:#("Vray","Physical / Arnold") pos:[245,352+moveOne] width:145 height:21 align:#left
	
	groupBox 'grp1' "" pos:[5,210+moveOne] width:390 height:120 align:#left
	groupBox 'grp2' "" pos:[5,335+moveOne] width:390 height:50 align:#left
	groupBox 'grp3' "" pos:[5,390+moveOne] width:390 height:96 align:#left
	local moveExtra = 3
	label 'lbl5' "Global Skin Parameters:" pos:[10,405+moveOne] width:288 height:16 align:#left
	label 'lbl6' "Specular Weight:" pos:[56,425+moveOne+moveExtra] width:128 height:16 align:#left
	spinner spnSpecularW "" pos:[144,425+moveOne+moveExtra] width:64 height:16 range:[0,100,50] align:#left
	slider sldSpecularW "" pos:[216,415+moveOne+moveExtra] width:182 height:25 range:[0,100,50] align:#left
	label 'lbl8' "Specular Roughness:" pos:[38,457+moveOne+moveExtra] width:104 height:16 align:#left
	spinner spnSpecularR "" pos:[144,457+moveOne+moveExtra] width:64 height:16 range:[0,100,50] align:#left
	slider sldSpecularR "" pos:[216,445+moveOne+moveExtra] width:182 height:25 range:[0,100,50] align:#left
	---------------------------------
	label 'lbl4' "Copyright (c) 2020. All rights reserved." pos:[115,497+moveOne] width:250 height:24 align:#left
	button btnHelp "?" pos:[360,492+moveOne] width:24 height:24 align:#left
	--checkbox chkMerge "Merge Import" checked:false visible:true pos:[10,445] visible:false
	--checkbox chkBump "Use Normal only" checked:false visible:true pos:[10,450]

	checkbox chkMorph "only keep figure morphs" checked:true visible:false
	--filterString 

	function setBitmapShaderValue subshader uTile vTile uOffset vOffset = 
	(
		subshader.coords.U_Tiling = uTile
		subshader.coords.V_Tiling = vTile
		subshader.coords.U_Offset = uOffset
		subshader.coords.V_Offset = vOffset
		
		return subShader
	)
	
	function loadXML_getPropValue xmlItem propDaz =
	(
		local propValue = #()
		for props in propDaz do
		(
			local listProp = filterString props ","
			local val = undefined 
			for prop in listProp do
				if xmlItem.attributes.Itemof[prop] != undefined then
				(
					val = xmlItem.attributes.Itemof[prop].value
					exit 
				)
			append propValue val
		)
		return propValue
	)
	function loadXML_DazMaterial filename matName diffuseName objectName =
	(
		if doesFileExist filename then
		(
			local xmlDoc = dotNetObject "system.xml.xmlDocument"
			xmlDoc.load filename
			local data = xmlDoc.selectNodes "//materials"

			data = xmlDoc.selectNodes "//materials/material"
			local n = data.count
			local found = false
			local propValue = #()
			local propIndex = #()
			for i=0 to n-1 do
				if (tolower data.itemof[i].attributes.Itemof["name"].value ==tolower matName) then
					append propIndex i

			if propIndex.count == 1 then
				return (loadXML_getPropValue data.itemof[propIndex[1]] propDaz)
			
			
			if diffuseName != "" then
				for i in propIndex do
				(
					local temp = data.itemof[i]
					local listProp = filterString propDaz[2] ","
					local val = undefined 
					for prop in listProp do
						if temp.attributes.Itemof[prop] != undefined then
							val = temp.attributes.Itemof[prop].value
						
					if val != undefined and pathConfig.pathsResolveEquivalent val  diffuseName then
					(	
						return (loadXML_getPropValue temp propDaz)
					)
				)
			--if propIndex.count> 1 and diffuseName == "" then
			if propIndex.count> 1  then
			(
				--print ("hererrrrrrr: "+objectName)
				for i in propIndex do
				(
					local temp = data.itemof[i]
					if temp.attributes.Itemof["object"].value == objectName then
						return (loadXML_getPropValue temp propDaz)
				)
				for i in propIndex do
				(
					local temp = data.itemof[i]
					if findString objectName temp.attributes.Itemof["label"].value  == 1 then
						return (loadXML_getPropValue temp propDaz)
				)				
			)
		)
		return undefined 
	)

	function getPropertyValue43dsmax listProp propName propType=
	(
		local props = propVray
		if propType ==2 then props = propCorona
		if propType ==3 then props = propArnold	
		if propType ==4 then props = propStandard	
		if propType ==5 then props = propPhysical
		for i = 1 to props.count do
			if tolower props[i] == tolower propName then
			(
				return listProp[i]
			)
		return undefined
	)
	function newVrayMaterialFromXML xmlPath mat objName =
	(
		local diffuseName = ""
		if classof mat == Vraymtl and classof mat.texmap_diffuse == BitmapTexture then
			diffuseName = mat.texmap_diffuse.filename 
		local  listProp = loadXML_DazMaterial xmlPath mat.Name diffuseName objName
		print(mat.Name+":"+diffuseName)
		
		local uTile = 1.0
		local vTile = 1.0
		local uOffset = 0.0
		local vOffset = 0.0
		if listProp!=  undefined then
		(

			temp = getPropertyValue43dsmax listProp "coords_U_Tiling" 4
			if temp != undefined then 
				uTile = execute temp
			temp = getPropertyValue43dsmax listProp "coords_V_Tiling" 4
			if temp != undefined then 
				vTile = execute temp
			temp = getPropertyValue43dsmax listProp "coords_U_Offset" 4
			if temp != undefined then 
				hOffset = execute temp
			temp = getPropertyValue43dsmax listProp "coords_V_Offset" 4
			if temp != undefined then 
				vOffset = execute temp
			
			local m = Vraymtl()
			if classof mat == Vraymtl then
			(
				m = mat
				print m
			)
			else
			(
				try (
					temp = getPropertyValue43dsmax listProp "Diffuse" 1
					if temp != undefined then m.Diffuse = execute temp
				) catch ()
				
				try (
					temp = getPropertyValue43dsmax listProp "texmap_diffuse" 1
					if temp != undefined then 
					(
						m.texmap_diffuse = Bitmaptexture fileName:temp
						m.texmap_diffuse = setBitmapShaderValue m.texmap_diffuse uTile vTile uOffset vOffset											
						
					)
				) catch ()	
									
			)
				
			m.name =  mat.Name
			try(m.reflection_lockIOR = off)catch()
			-- m.brdf_useRoughness = on --metalness specific
			-- m.Reflection = color 255 255 255 --metalness specific
			print("**********?????******")
			print("found: "+diffuseName)
	
			
			try (
				temp = getPropertyValue43dsmax listProp "texmap_opacity" 1
				if temp != undefined then 
				(
					m.texmap_opacity = Bitmaptexture fileName:temp
					m.texmap_opacity.output.output_amount = 2
				)
			) catch ()	
			
			try (
				local normalMap = VRayNormalMap ()
				temp = getPropertyValue43dsmax listProp "bump_map_multiplier" 1
				if temp != undefined then normalMap.bump_map_multiplier =  execute temp
				temp = getPropertyValue43dsmax listProp "bump_map" 1
				if temp != undefined then 
				(
					normalMap.bump_map =  Bitmaptexture fileName:temp					
					normalMap.bump_map = setBitmapShaderValue normalMap.bump_map uTile vTile uOffset vOffset						
				)
					
				temp = getPropertyValue43dsmax listProp "normal_map_multiplier" 1
				if temp != undefined then normalMap.normal_map_multiplier =  execute temp
				temp = getPropertyValue43dsmax listProp "normal_map" 1
				if temp != undefined then
				(
					normalMap.normal_map =  Bitmaptexture fileName:temp				
					normalMap.normal_map = setBitmapShaderValue normalMap.normal_map uTile vTile uOffset vOffset	
				)
				m.texmap_bump = normalMap
				
				normalMap.normal_map_on = on
				normalMap.bump_map_on = on				
				normalMap.bump_map_multiplier = 0.5
				
				m.texmapBump = normalMap
				
			) catch ()
			try (
				temp = getPropertyValue43dsmax listProp "refraction" 1
				if temp != undefined then m.refraction = (execute temp)*(color 255 255 255)
				else
				(
					temp = getPropertyValue43dsmax listProp "refraction1" 1
					if temp != undefined then m.refraction = (1-(execute temp))*(color 255 255 255)
				)
			) catch ()
			try (
				temp = getPropertyValue43dsmax listProp "refraction_ior" 1
				if temp != undefined then m.refraction_ior = (execute temp)
			) catch ()
			try (
				temp = getPropertyValue43dsmax listProp "texmap_refraction" 1
				if temp != undefined then
				(
					m.texmap_refraction = Bitmaptexture fileName:temp
					m.texmap_refraction = setBitmapShaderValue m.texmap_refraction uTile vTile uOffset vOffset	
					
				)
			) catch ()		
			
			try (
				temp = getPropertyValue43dsmax listProp "reflection" 1
				if temp != undefined then 
				(
					--print ("reflection: "+temp)
					m.reflection = (execute temp)*(color 255 255 255)
				)
			) catch ()
			try (
				temp = getPropertyValue43dsmax listProp "texmap_reflection" 1
				if temp != undefined then 
				(
					m.texmap_reflection = Bitmaptexture fileName:temp
					m.texmap_reflection = setBitmapShaderValue m.texmap_reflection uTile vTile uOffset vOffset						
					m.reflection_ior = 3.0
				)
			) catch ()			
			
			try (
				temp = getPropertyValue43dsmax listProp "reflection_glossiness" 1
				if temp != undefined then 
				(
					m.reflection_glossiness = 1-(execute temp)
					print("reflection_glossiness:"+ temp+":"+m.reflection_glossiness as string)
				)
				
			) catch ()
			try (
				temp = getPropertyValue43dsmax listProp "texmap_reflectionGlossiness" 1
				if temp != undefined then
				(
					m.texmap_reflectionGlossiness = Bitmaptexture fileName:temp
					m.texmap_reflectionGlossiness = setBitmapShaderValue m.texmap_reflectionGlossiness uTile vTile uOffset vOffset						
				)
			) catch ()				

			try (
				m.texmap_bump_multiplier = 50
			) catch()
			try (
				m.reflection_metalness = 0
			) catch()			

			if m.name == "Eyelashes" then
			(
				m.Diffuse = color 0 0 0
			)
			return m
		)
		return mat
	)
	function newCoronaMaterialFromXML xmlPath mat objName =
	(
		local  listProp = loadXML_DazMaterial xmlPath mat.Name objName
		if listProp!=  undefined then
		(
			local m = CoronaMtl()
			m.name =  mat.Name
			try (
				temp = getPropertyValue43dsmax listProp "colorDiffuse" 2
				if temp != undefined then m.colorDiffuse = execute temp
			) catch ()
			try (
				temp = getPropertyValue43dsmax listProp "texmapDiffuse" 2
				if temp != undefined then
				(
					m.texmapDiffuse = Bitmaptexture fileName:temp
					m.texmapDiffuse = setBitmapShaderValue m.texmapDiffuse uTile vTile uOffset vOffset						
				)
			) catch ()	
			try (
				temp = getPropertyValue43dsmax listProp "ior" 2
				if temp != undefined then m.ior = execute temp
			) catch ()
			try (
				temp = getPropertyValue43dsmax listProp "texmapIor" 2
				if temp != undefined then
				(
					m.texmapIor = Bitmaptexture fileName:temp
					m.texmapIor = setBitmapShaderValue m.texmapIor uTile vTile uOffset vOffset						
				)
			) catch ()		
			try (
				temp = getPropertyValue43dsmax listProp "refractGlossiness" 2
				if temp != undefined then m.refractGlossiness = execute temp
			) catch ()
			try (
				temp = getPropertyValue43dsmax listProp "texmapRefractGlossiness" 2
				if temp != undefined then m.texmapRefractGlossiness = Bitmaptexture fileName:temp
			) catch ()				
			try (
				local normalMap = CoronaNormal ()
				temp = getPropertyValue43dsmax listProp "additionalBumpStrength" 2
				if temp != undefined then normalMap.additionalBumpStrength =  execute temp
				temp = getPropertyValue43dsmax listProp "additionalBump" 2
				if temp != undefined then normalMap.additionalBump =  Bitmaptexture fileName:temp					
					
				temp = getPropertyValue43dsmax listProp "multiplier" 2
				if temp != undefined then normalMap.multiplier =  execute temp
				temp = getPropertyValue43dsmax listProp "normalMap" 2
				if temp != undefined then normalMap.normalMap =  Bitmaptexture fileName:temp		

				m.texmapBump = normalMap
				
			) catch ()		
			return m
		)
		return mat
	)	
	function newArnoldMaterialFromXML xmlPath mat objName =
	(
		local diffuseName = ""
		if classof mat == ai_standard_surface and classof mat.base_color == BitmapTexture then
			diffuseName = mat.base_color.filename 
		local  listProp = loadXML_DazMaterial xmlPath mat.Name diffuseName objName
		print(mat.Name+":"+diffuseName)
		
		local uTile = 1.0
		local vTile = 1.0
		local uOffset = 0.0
		local vOffset = 0.0
			
		if listProp!=  undefined then
		(	
			temp = getPropertyValue43dsmax listProp "coords_U_Tiling" 3
			if temp != undefined then 
				uTile = execute temp
			temp = getPropertyValue43dsmax listProp "coords_V_Tiling" 3
			if temp != undefined then 
				vTile = execute temp
			temp = getPropertyValue43dsmax listProp "coords_U_Offset" 3
			if temp != undefined then 
				hOffset = execute temp
			temp = getPropertyValue43dsmax listProp "coords_V_Offset" 3
			if temp != undefined then 
				vOffset = execute temp
			
			local m = ai_standard_surface()
			m.name =  mat.Name
			if classof mat == ai_standard_surface then
			(
				m = mat
				print m
			)		
			else
			(
				try (
					temp = getPropertyValue43dsmax listProp "base_color" 3
					if temp != undefined then m.base_color = execute temp
				) catch ()
				
				try (
					temp = getPropertyValue43dsmax listProp "base_color_shader" 3
					if temp != undefined then 
					(
						m.base_color_shader = Bitmaptexture fileName:temp
						m.base_color_shader = setBitmapShaderValue m.base_color_shader uTile vTile uOffset vOffset							
					)
				) catch ()	
			)

	
			try (
				temp = getPropertyValue43dsmax listProp "opacity_shader" 3
				if temp != undefined then 
				(
					m.opacity_shader = Bitmaptexture fileName:temp
					m.opacity_shader.output.output_amount = 2
				)
			) catch ()				
		
			try (
				try (
					local normalMap = ai_bump2d()
					temp = getPropertyValue43dsmax listProp "bump_map" 5
					if temp != undefined then normalMap.bump_map =  execute temp
					temp = getPropertyValue43dsmax listProp "bump_map_shader" 5
					if temp != undefined then
					(
						normalMap.bump_map_shader =  Bitmaptexture fileName:temp					
						normalMap.bump_map_shader = setBitmapShaderValue normalMap.bump_map_shader uTile vTile uOffset vOffset	
					)
						
					temp = getPropertyValue43dsmax listProp "normal" 5
					if temp != undefined then normalMap.normal =  (execute temp)*[1,1,1]
					temp = getPropertyValue43dsmax listProp "normal_shader" 5
					if temp != undefined then
					(
						normalMap.normal_shader =  Bitmaptexture fileName:temp				
						normalMap.normal_shader = setBitmapShaderValue normalMap.normal_shader uTile vTile uOffset vOffset							
					)
					normalMap.bump_map_connected = on
					normalMap.normal_connected = on				

					mat.normal_shader = normalMap
					--mat.bump_map_amt = 0.05
				) catch ()				
				
			) catch ()		
			
			
			try (
				temp = getPropertyValue43dsmax listProp "transmission_color" 1
				if temp != undefined then m.transmission_color = (execute temp)*(color 255 255 255)
				else
				(
					temp = getPropertyValue43dsmax listProp "transmission_color1" 1
					if temp != undefined then m.transmission_color = (1-(execute temp))*(color 255 255 255)
				)
			) catch ()
		
			
			try (
				temp = getPropertyValue43dsmax listProp "transmission_color_shader" 1
				if temp != undefined then
				(
					m.transmission_color_shader = Bitmaptexture fileName:temp
					m.transmission_color_shader = setBitmapShaderValue m.transmission_color_shader uTile vTile uOffset vOffset							
				)
			) catch ()				

			
			try (
				temp = getPropertyValue43dsmax listProp "specular_color" 3
				if temp != undefined then 
				(
					m.specular_color = (execute temp)*(color 255 255 255)
				)
			) catch ()
			
			try (
				temp = getPropertyValue43dsmax listProp "specular_color_shader" 3
				if temp != undefined then
				(
					m.specular_color_shader = Bitmaptexture fileName:temp
					m.specular_color_shader = setBitmapShaderValue m.specular_color_shader uTile vTile uOffset vOffset						
				)
				m.specular_IOR = 3.0
			) catch ()	
			
			/*			
			try (
				m.reflection_metalness = 0
			) catch()			
			*/
			try (
				temp = getPropertyValue43dsmax listProp "metalness" 3
				if temp != undefined then 
				(
					m.metalness = (execute temp)
					--print("reflection_glossiness:"+ temp+":"+m.reflection_glossiness as string)
				)
				
			) catch ()	
			
			if m.name == "Eyelashes" then
			(
				m.base_color = color 0 0 0
			)
			
			return m
		)
		return mat
	)	
	
	function newPhysicalMaterialFromXML xmlPath mat objName =
	(
		local diffuseName = ""
		
		if classof mat == PhysicalMaterial and classof mat.base_color_map == BitmapTexture then
			diffuseName= mat.base_color_map.filename 
		local  listProp = loadXML_DazMaterial file_xml mat.Name diffuseName objName
		
		local uTile = 1.0
		local vTile = 1.0
		local uOffset = 0.0
		local vOffset = 0.0
			
		if listProp != undefined then
		(
			temp = getPropertyValue43dsmax listProp "coords_U_Tiling" 5
			if temp != undefined then 
				uTile = execute temp
			temp = getPropertyValue43dsmax listProp "coords_V_Tiling" 5
			if temp != undefined then 
				vTile = execute temp
			temp = getPropertyValue43dsmax listProp "coords_U_Offset" 5
			if temp != undefined then 
				hOffset = execute temp
			temp = getPropertyValue43dsmax listProp "coords_V_Offset" 5
			if temp != undefined then 
				vOffset = execute temp		
			
			local m = PhysicalMaterial()
			m.name =  mat.Name
			if classof mat == PhysicalMaterial then
			(
				m = mat
				try (
					m.base_color_map = setBitmapShaderValue m.base_color_map uTile vTile uOffset vOffset
				) catch()
				print m
			)		
			else
			(
				try (
					temp = getPropertyValue43dsmax listProp "base_color" 5
					if temp != undefined then m.base_color = execute temp
				) catch ()
				
				try (
					temp = getPropertyValue43dsmax listProp "base_color_map" 5
					if temp != undefined then 
					(
						m.base_color_map = Bitmaptexture fileName:temp
						m.base_color_map = setBitmapShaderValue m.base_color_map uTile vTile uOffset vOffset
					)
				) catch ()	
			)
			
			try (
				temp = getPropertyValue43dsmax listProp "trans_ior" 5
				if temp != undefined then m.trans_ior = ((execute temp)*1.0)

			) catch ()
			try (
				temp = getPropertyValue43dsmax listProp "trans_color" 5
				if temp != undefined then m.trans_color = execute temp
			) catch ()			
			
			try (
				temp = getPropertyValue43dsmax listProp "transparency" 5
				print  (m.name + ":" +temp)
				-- temp != undefined then m.transparency = (100-(execute temp)*100.0)
				if temp != undefined then m.transparency = ((execute temp)*100.0)
				else
				(
					temp = getPropertyValue43dsmax listProp "transparency1" 5
					print  (m.name + ":" +temp)
					if temp != undefined then m.transparency = (execute temp)*100.0
				)

			) catch ()
			try (
				temp = getPropertyValue43dsmax listProp "transparency_map" 5
				if temp != undefined then 
				(
					m.transparency_map = Bitmaptexture fileName:temp
					m.transparency_map = setBitmapShaderValue m.transparency_map uTile vTile uOffset vOffset
				)
			) catch ()					
			
			
			try (
				temp = getPropertyValue43dsmax listProp "cutout_map" 5
				if temp != undefined then 
				(
					m.cutout_map = Bitmaptexture fileName:temp
					m.cutout_map = setBitmapShaderValue m.cutout_map uTile vTile uOffset vOffset
					m.cutout_map.output.output_amount = 2
					m.transparency_map = undefined
				)
			) catch ()		
			
			try (
				local normalMap = ai_bump2d()
				temp = getPropertyValue43dsmax listProp "bump_height" 5
				if m.name == "Stand" then 
				(
					print "Standddddddddddddddddddddddddddd"
					print temp
				)
					
				if temp != undefined then normalMap.bump_height =  execute temp
				temp = getPropertyValue43dsmax listProp "bump_map_shader" 5
				if temp != undefined then 
				(
					normalMap.bump_map_shader =  Bitmaptexture fileName:temp					
					normalMap.bump_map_shader = setBitmapShaderValue normalMap.bump_map_shader uTile vTile uOffset vOffset
				)
					
				temp = getPropertyValue43dsmax listProp "normal" 5
				if temp != undefined then normalMap.normal =  (execute temp)*[1,1,1]
				temp = getPropertyValue43dsmax listProp "normal_shader" 5
				if temp != undefined then 
				(
					normalMap.normal_shader =  Bitmaptexture fileName:temp				
					normalMap.normal_shader = setBitmapShaderValue normalMap.normal_shader uTile vTile uOffset vOffset
				)					
				normalMap.bump_map_connected = on
				normalMap.normal_connected = on				

				m.bump_map = normalMap
				m.bump_map_amt = 0.02
			) catch ()
			
			try (
				temp = getPropertyValue43dsmax listProp "refl_color_map" 5
				if temp != undefined then 
				(
					m.refl_color_map = Bitmaptexture fileName:temp
					m.refl_color_map = setBitmapShaderValue m.refl_color_map uTile vTile uOffset vOffset

				)
			) catch ()									
			try (
				temp = getPropertyValue43dsmax listProp "roughness" 5
				if temp != undefined then m.roughness = 1-(execute temp)
			) catch ()				
			try (
				temp = getPropertyValue43dsmax listProp "roughness_map" 5
				if temp != undefined then 
				(
					m.roughness_map = Bitmaptexture fileName:temp
					m.roughness_map = setBitmapShaderValue m.roughness_map uTile vTile uOffset vOffset

				)
			) catch ()				
			try (
				temp = getPropertyValue43dsmax listProp "reflectivity" 5
				if temp != undefined then m.reflectivity = (execute temp)
			) catch ()									
		)
		m = mat
		if m==  undefined then return m
		try (
			if m.trans_color == (color 0 0 0 255) then
				m.transparency = 0								
			m.trans_ior = 3.0
		) catch ()
		if m.name == "Eyelashes" then
		(
			try(m.base_color = color 0 0 0)catch()
			try(m.base_color_map = undefined)catch()
		)
		if m.name == "Cornea" then
		(
			try(m.base_color = color 0 0 0)catch()
			try(m.roughness = 0)catch()
			try(m.trans_color = color 255 255 255 255)catch()
			try(m.transparency = 1.0)catch()
		)								
		if m.name == "EyeMoisture" then
		(
			try(m.base_color = color 0 0 0 255)catch()
			try(m.transparency_map = undefined)catch()
			try(m.cutout_map = undefined)catch()
			try(m.refl_color = color 255 255 255 255)catch()
			try(m.reflectivity = 1.0)catch()
			try(m.roughness_inv = off)catch()
			try(m.roughness = 0.0)catch()
			try(m.reflectivity = 1.0)catch()
			try(m.trans_ior = 1.3)catch()
			try(m.trans_color = color 255 255 255 255)catch()
			try(m.transparency = 1.0)catch()
			print "EyeMoisture"
		)		
		if m.name == "Sclera" or m.name == "Irises"  or m.name == "Pupils" then
		(
			try(m.reflectivity = 0.0)catch()
		)	
		if m.name == "Lips" then
		(
			try(m.roughness = 0.45)catch()
			try(m.reflectivity = 0.40)catch()
		)			
		return m
	)	
	
	function loadOriginalObjectName objName = 
	(
		local i = findString objName "_dup_"
		local j = findString objName ".Shape"
		if i != undefined and j != undefined then
		(
			objName = (substring objName 1 (i-1)) + ".Shape"
			--print objName
		)
			
		return objName
	)
	
	function loadAllMaterialFromXML xmlFile matType =
	(
		for obj in objects do
		(
			local listMat = #()
			local isMultiSub = false

			
			if obj.mat != undefined then
			(
				if classof obj.mat == Multimaterial then
				(
					for mat in obj.mat do
						append listMat mat
					isMultiSub = true
				)
				else
					append listMat obj.mat
			)
			local i = 1
			if listMat.count >0 then
			(
				---print ("zzzz"+obj.name)
				--print (listMat as string)
			
				objName = loadOriginalObjectName obj.name
				--print objName
			
				
				for mat in listMat do
					if mat != undefined then
					(
						if substring mat.name 1 5 == "vray " then
							mat.name = substring mat.name 6 -1
						local newMat = undefined 
						if matType == 1 then newMat = newVrayMaterialFromXML xmlFile mat objName
						if matType == 2 then newMat = newCoronaMaterialFromXML xmlFile mat objName
						if matType == 3 then newMat= newArnoldMaterialFromXML xmlFile mat objName			
						if matType == 5 then newMat= newPhysicalMaterialFromXML xmlFile mat objName			
							--print newmat
						
						if isMultiSub then
							obj.mat[i] = newMat
						else
							obj.mat = newMat
						
						i += 1
					)
				
			)
		)
	)


	local mainobj
	local CATh = 0.0


	on pickSelected pressed do
	(
		if classOf $ == Editable_Poly or classOf $ == PolyMeshObject then
		(
			selectedObject = $
			editSelected.text = selectedObject.name
		)
	)

	function selectHierarchy obj =
    (
		if obj.children != undefined do
		(
			selectmore obj.children
			for o in obj.children do
				selectHierarchy o
		)
    )
	
	function autoRename root prefix newPrefix list =
	(
		local selObjs = #()
		select root
		selectHierarchy root
		for obj in selection do
		(
			if findString obj.name prefix == 1 then
				obj.name = replace obj.name 1 (prefix.count) newPrefix

		)
		for li in list do
		(
			 local temp = getNodeByName (prefix+li)
			if temp != undefined then
				temp.name = newPrefix+li
		)
	)

	global temparr
	function isCAT cbone = 
	(
		local list = #(HubObject,IKTarget,CATParent,CATBone)
		for l in list do
		(
			if classof cbone == l then
				return true
		)
		return false
	)
	function getCATRoot cbone arr =
	(
		if classof cbone == CATParent then 
			return cbone
		local s = tolower cbone.name
		for a in arr do
		(	
			local i = findstring s (tolower a[3])
			local n1 = a[3]+""
			n1[1] = "R"
			local j = findstring s (tolower n1)
			if (i != undefined) then
			(
				local rootName = substring cbone.name 1 (i-1)
				return (n2n rootName)
			)
			if (j != undefined) then
			(
				local rootName = substring cbone.name 1 (j-1)
				return (n2n rootName)
			)
		)
		
		return undefined
	)
	function collectListMat listMatName = 
	(
		local listMat = #()
		for obj in objects do
		(
			if obj.mat != undefined then
			(
				if classof obj.mat == Multimaterial then
				(
					for mat in obj.mat do
						if findItem listMatName (tolower mat.name) >0 then
							appendIfUnique listMat mat
					isMultiSub = true
				)
				else
					if findItem listMatName (tolower obj.mat.name) >0 then
						appendIfUnique listMat obj.mat
			)
		)	
		return listMat
	)
	function updateSpecularW =
	(
		local listMatName = #("face","ears","legs","arms","neck","forearms", "nipples", "torso")
		local listMat= collectListMat listMatName
		for mat in listMat do
		(
			if classof mat == VrayMtl then
			(
				try(mat.Reflection =(color 255 255 255)*spnSpecularW.value/100)catch()
				try(mat.reflection_ior = 1.0+2.0*spnSpecularW.value/100.0)catch()
			)
			if classof mat == StandardMaterial then
				try(mat.glossiness = spnSpecularW.value)catch()
			if classof mat == PhysicalMaterial then
			(
				try(mat.refl_color =(color 255 255 255)*spnSpecularW.value/100)catch()
				try(mat.trans_ior = 1.0+2.0*spnSpecularW.value/100.0)catch()
			)
		)		
	)
	function updateSpecularR =
	(
		local listMatName = #("face","ears","legs","arms","neck","forearms", "nipples", "torso")
		local listMat= collectListMat listMatName
		for mat in listMat do
		(
			if classof mat == VrayMtl then
				try (mat.reflection_glossiness = spnSpecularR.value/100.0) catch()
			if classof mat == StandardMaterial then
				try (mat.specularLevel = spnSpecularR.value) catch()
			if classof mat == PhysicalMaterial then
				try (mat.roughness = spnSpecularR.value/100.0) catch()
		)

	)
	on spnSpecularW changed  val do
	(
		sldSpecularW.value  = val
		updateSpecularW()
		
	)
	on spnSpecularR changed  val do
	(
		sldSpecularR.value  = val
		updateSpecularR()
	)	
	on sldSpecularW changed  val do
	(
		spnSpecularW.value  = val
		updateSpecularW()
		
	)
	on sldSpecularR changed  val do
	(
		spnSpecularR.value  = val
		updateSpecularR()
	)		
	on btSync44 pressed do 
		if selection.count == 1 and isCAT $  then
		(
			local selObj = getCATRoot $ arr 
			if selObj == undefined then 
				return false
			max select none 
			obj = getNodeByName (selObj.name+"__")
			if obj != undefined then
				delete obj
			mergeMAXFile (d2mConfigpath+"QR_Bip002.max") quiet:true
			obj = getNodeByName arr[1][4]
			autoRename obj arr[1][4] (selObj.name+"__") #(" Footsteps")

			
			local newarr = deepcopy arr
			newarr[1][3] = selObj.name
			newarr = syncBipedXML newarr selObj obj
			temparr = newarr
			if (selectedObject != undefined) then
			(
				saveSkinData selectedObject
				loadSkinData newarr selectedObject	
			)

		)	
	on btSync33 pressed do 
	if classof $ == Biped_Object then
	(
		local root = getRoot $
		max select none 
		local listmain = #("","Pelvis","LPlatform","RPlatform")
		for li in listmain do
		(
			obj = getNodeByName (root.name+"__"+li)
			if obj != undefined then
				delete obj		
		)
		
		local prefix = arr[1][3]
		local newPrefix = root.name+"__"
		mergeMAXFile (d2mConfigpath+"QR_CAT2.max") quiet:true		
		

		local newarr = deepcopy arr
		
		newarr = syncCATXML newarr root false 2

		if (selectedObject != undefined) then
		(
			saveSkinData selectedObject
			loadSkinData newarr selectedObject	
		)
		
		obj = getNodeByName (arr[1][3]+"Pelvis")
		if obj != undefined then
			autoRename obj prefix newPrefix	 listmain
		for a in newarr do
		(
			if findString a[3] prefix == 1 then
				a[3] = replace a[3] 1 prefix.count newPrefix			
		)
	)
	

	function doesBoneExist textname =
	(
		local listbone = filterString textname ","
		local notexist = false
		--print textname
		for b in listbone do
			if getNodeByName b == undefined then
			(
				print b
				notexist = true
			)
		if notexist then 
			return ""
		else	
			return listbone[1]
	)

	function fixMultiTile obj =
	(
		for b = 1 to 20 do (
			try(
				--print obj.mat[b].name
				if obj.mat[b].name == "EyeMoisture" then
				(
					obj.mat[b].opacity = 1
				)
				if obj.mat[b].name == "Cornea" then
				(
					obj.mat[b].opacity = 1
				)
			)catch()
			try(
				map = obj.mat[b].diffuseMap.getTileTexmap(1)
				--print map.filename
				--print obj.mat[b].name
				obj.mat[b].diffuseMap = Bitmaptexture fileName:map.filename
			)catch()
		)
	)

	function fixMultiTileMaterials =
	(
		for mat in Geometry do
		(
		fixMultiTile mat
		)
	)

	fn importFBXFiles =
	(
		--FBXImporterSetParam "ConvertUnit" units.SystemType
		importFile (d2mFbxPath) #noPrompt using:FBXIMP
	
	)
	fn importDAEFiles =
	(

		--FBXImporterSetParam "ConvertUnit" "mm"
		importFile (d2mDaePath) #noPrompt using:DAEIMP
		print d2mDaePath
	)
	on btnMorphsManager pressed do
	(
		--CHECK THIS CHANGE PATH ETC...
		print d2mConfigpath
		filein (d2mConfigpath+"morphermanager_v12.ms")

	)
	
	function getMorphIndexByName modmorph morphName =
	(
		for i=1 to 200 do
			if (WM3_MC_HasData modmorph i) then
				if WM3_MC_GetName modmorph i == morphName then
					return i
		return undefined 
	)
	function getVariableinMorph mor =
	(
		local morName = mor as string
		morName = (substring morName 9 -1) +"_"
		return morName
	)	
	function wireConnect wire_mainObj =
	(
		global wire_eyeObj = undefined 

	

		if isValidMorph wire_mainObj then
		(
			local mainName = substring wire_mainObj.name 1 (wire_mainObj.name.count-6)
			print mainName
			local eyeName = mainName +"Eyelashes.Shape"
			wire_eyeObj = getNodeByName eyeName
			if isValidMorph wire_eyeObj then
			(
				global objmorph = getModMorph wire_mainObj
				global eyemorph = getModMorph wire_eyeObj
				print eyemorph
				
				for i=1 to 200 do
					if (WM3_MC_HasData objmorph i) then
					(
						local mIndex = getMorphIndexByName eyemorph (WM3_MC_GetName objmorph i)
						if mIndex != undefined then
						(
							paramWire.connect2Way objmorph[i] eyemorph[mIndex] (getVariableinMorph eyemorph[mIndex]) (getVariableinMorph objmorph[i])
						)
						--append listAllMorph #(i ,WM3_MC_GetName objmorph i,WM3_MC_GetValue objmorph i)
					)
				
				
			)
		)
	--paramWire.openEditor() 
	)
	fn GetBitmapTextures theObjects =
	(
		texMaps = #()
		for obj in theObjects do
		(
			join texMaps (getClassInstances bitmapTexture target:obj asTrackViewPick:off)
		)
		makeUniqueArray texMaps
	)		
	function CollectAllTexture filename =
	(
		print filename
		makedir (filename +"_maps")
		if (getFiles (filename +"_maps\\*.*")).count > 0 then
			if queryBox "Overwrite textures?" title:"DazToMax" == false then 
				return false
			
		for f in (getFiles (filename +"_maps\\*.*")) do
			deleteFile f
		--if (selection.count ==0) then
		--max select all
		
			/*
		local texMaps = (GetBitmapTextures selection)
		for texMap in texMaps do 
		(
			print texMap.filename
			copyFile texMap.filename (filename +"_maps\\"+(getFilenameFile texMap.filename)+(getFileNameType texMap.filename))
		)		
			*/
		---strip all path
		mBitmaps = getClassInstances BitmapTexture
		local orgFileName = #()
		for i=1 to mBitmaps.count do 
		(
			m = mBitmaps[i]
			-- for every bitmap texture in the scene
			if (isProperty m #filename) then 
			(
				-- that has a #filename property	
				if m.filename != "" then 
				(
					print m.filename
					copyFile m.filename (filename +"_maps\\"+(getFilenameFile m.filename)+(getFileNameType m.filename))
					
					append orgFileName #(i,m.filename)
					m.filename = (filename +"_maps\\"+ (filenamefrompath m.filename))

						
				)
				
			)
		)		
		saveMaxFile (filename+".max")
		print (filename+".max") 
		loadMaxFile (filename+".max") quiet:true
		---restore all path
		/*
		for org in orgFileName do
		(
			i = org[1]
			mBitmaps[i].filename = org[2]
		)		
		*/

	)	
	on btnSaveScene pressed do
	(
		local filename = getMAXSaveFileName ()
		if filename != undefined then
		(
			/*
			if doesFileExist filename then
				if queryBox "Overwrite file?" title:"DazToMax" == false then 
					return false
			*/
			local newfile = (getFilenamePath filename)+(getFileNameFile filename)
			CollectAllTexture newfile
		)
			
	)

	function loadStandardOrPhysicalMaterial = 
	(
		--load standard material
		for obj in objects do
		(
			local listMat = #()
			local isMultiSub = false

			
			if obj.mat != undefined then
			(
				if classof obj.mat == Multimaterial then
				(
					for mat in obj.mat do
						append listMat mat
					isMultiSub = true
				)
				else
					append listMat obj.mat
				
				local i = 1
				if listMat.count >0 then
				(
					objName = loadOriginalObjectName obj.name	
					
					for mat in listMat do
						if mat != undefined then
						(
							local diffuseName = ""
							if classof mat == Standardmaterial then
							(
								mat.diffuseMap = getBitmapFromSubShader mat.diffuseMap
								if classof mat == Standardmaterial and classof mat.diffuseMap == BitmapTexture then
									diffuseName= mat.diffuseMap.filename 
								local  listProp = loadXML_DazMaterial file_xml mat.Name diffuseName objName
								local uTile = 1.0
								local vTile = 1.0
								local uOffset = 0.0
								local vOffset = 0.0
								if listProp != undefined then
								(
									temp = getPropertyValue43dsmax listProp "coords_U_Tiling" 4
									if temp != undefined then 
										uTile = execute temp
									temp = getPropertyValue43dsmax listProp "coords_V_Tiling" 4
									if temp != undefined then 
										vTile = execute temp
									temp = getPropertyValue43dsmax listProp "coords_U_Offset" 4
									if temp != undefined then 
										hOffset = execute temp
									temp = getPropertyValue43dsmax listProp "coords_V_Offset" 4
									if temp != undefined then 
										vOffset = execute temp
									
									print "--------------------------------tiling values:---------------------------"
									print uTile
									print vTile
									print hOffset
									print vOffset
									try (
										mat.diffuseMap = setBitmapShaderValue mat.diffuseMap uTile vTile uOffset vOffset											
									) catch()
									
									try (
										temp = getPropertyValue43dsmax listProp "opacity" 4
										print  (mat.name + ":" +temp)
										if temp != undefined then mat.opacity = (100-(execute temp)*100.0)
										else
										(
											temp = getPropertyValue43dsmax listProp "opacity1" 4
											print  (mat.name + ":" +temp)
											if temp != undefined then 
											(
												mat.opacity = (execute temp)*100.0
											)
										)
									) catch ()
									
									try (
										temp = getPropertyValue43dsmax listProp "opacityMap" 4
										if temp != undefined then 
										(
											mat.opacityMap = Bitmaptexture fileName:temp
											mat.opacityMap.output.output_amount = 2
											mat.opacityMap = setBitmapShaderValue mat.opacityMap uTile vTile uOffset vOffset
										)
									) catch ()	
									try(
										temp = getPropertyValue43dsmax listProp "bumpMap" 4
										if temp != undefined then 
										(
											mat.bumpMap =  Bitmaptexture fileName:temp	
											mat.bumpMap = setBitmapShaderValue mat.bumpMap uTile vTile uOffset vOffset											
										)
									)catch()
									if mat.name == "Eyelashes" then
									(
										try(mat.Diffuse = color 0 0 0)catch()
										try(mat.diffuseMap = undefined)catch()
									)
								)
							)
							if classof mat == PhysicalMaterial  then
							(
								newPhysicalMaterialFromXML file_xml mat objName 
							)							
							i += 1
						)
				)				
			)

		)
		actionMan.executeAction 0 "63545"
	)
	on btnAutoImport pressed do
	(
		-- local temp = (yesNoCancelBox  "The scene will be replaced.\nSave changes?")
		-- if temp == #yes then saveMaxFile maxfilename
		-- if temp == #cancel  then return true
		-- if chkMerge.checked == false then
		filename = @"C:\TEMP3D\DazToMax.xml"
		print (doesFileExist filename)
		if (doesFileExist filename) == false then
		(
			messageBox "Nothing to import.\nPlease export from Daz Studio first." title:"DazToMax"
			return true
		)
		if queryBox "This will replace current scene, are you sure to continue?" title:"DazToMax" == false then
			return true
	
		local xmlDoc = dotNetObject "system.xml.xmlDocument"
		xmlDoc.load file_xml
		local data = xmlDoc.selectNodes "//materials"
		local filename = data.itemof[0].attributes.Itemof["filename"].value
		print filename
		--return true
		local isFBX = (getFileNameType filename) == ".fbx"
	
		--if chkMerge.checked == false then
		--	resetMaxFile #noprompt 
		if isFBX then
		(
			importFBXFiles()
		)
		else
		(
			importDAEFiles()
		)
		--IMPORT DONE
		try(backgroundColor = color 19 19 19)catch()
		--try(actionMan.executeAction -844228238 "15")catch()  -- Viewport Lighting and Shadows: DX Mode
		try(actionMan.executeAction -844228238 "7")catch()  -- Viewport Lighting and Shadows: Viewport Lighting Illuminate with Default Lights


		local temp = getNodeByName "cryAnimationExportNode"
		if temp != undefined then delete temp
		temp = getNodeByName "cryExporterSettingsNode"
		if temp != undefined then delete temp
		
		loadStandardOrPhysicalMaterial()
		if isFBX == false then
		(
			if cbShowReminder.checked then
				messagebox "Remember to save scene with textures..." title:"DazToMax"	
			
			return true
		)
			
		 --fixMultiTileMaterials()

		

		
		--actionMan.executeAction -844228238 "13"  -- Viewport Lighting and Shadows: Standard
		morphRenamer()
		--return true
		try(destroyDialog rPBar )catch()	
		createDialog rPBar
		rPBar.pbBar.value = 0
		rPBar.pbBar.value = 5
	
		local selectedObject = undefined
		local b = ""
		local xmlFile = ""
		for xml in listXML do
		(
			b = doesBoneExist xml[1]
			if  b != "" then 
			(
				xmlFile = xml[2]
				exit
			)
		)
		if b== "" then  
		(
			try(destroyDialog rPBar )catch()	
			return true
			
		)
		disableSceneRedraw() 
		
		--print xmlFile
		local d2mXmlDoc = dotNetObject "system.xml.XmlDocument"
		d2mXmlDoc.load (d2mConfigpath + "\\"+xmlFile)
		local data = d2mXmlDoc.selectNodes "//config/bone"
		local n = data.count
		local arr=#()
		for i=0 to n-1 do
		(
			local a =  #(data.itemof[i].attributes.Itemof["name"].value,data.itemof[i].attributes.Itemof["syncpos"].value,data.itemof[i].attributes.Itemof["source"].value,data.itemof[i].attributes.Itemof["target"].value,data.itemof[i].attributes.Itemof["size"].value as float,data.itemof[i].attributes.Itemof["color"].value,data.itemof[i].attributes.Itemof["dazsource"].value,data.itemof[i].attributes.Itemof["dazconstraint"].value)
			append arr a
		)
		local prefix1 = arr[1][3]
		for a in arr do
		(
			local t = filterString a[8] ","
			for tt in t do
			(
				local t2 = n2n tt
				if (tt2 !=  undefined) then
				(
					t2.pos.controller = Position_XYZ()
				)
			)
		)		
		rPBar.pbBar.value = 10

		selectedObject = getNodeByName b
		
		
		if isFBX then
		(
			while selectedObject.parent != undefined do 
				selectedObject = selectedObject.parent
		)
		else
		(
			local rNode = getNodeByName "rootNode"
			while (selectedObject.parent != rNode )  do 
				selectedObject = selectedObject.parent
		)
		print selectedObject
		--Genesis8Male-skinInstance

			
		selectHierachy selectedObject
		if $.min.z < selectedObject.pos.z then
		(
			local delta =  selectedObject.pos.z - $.min.z 
			selectedObject.pos.z += delta
			selectedObject.pivot.z = 0
		)
		
		
		local listDummy = #()
		for obj in selection do
			if classOf obj == Dummy then
			(
				deleteKeys obj #allKeys
				obj.showLinks = false
				append listDummy obj
				hide obj
			)
		
		
		--delete all old locator
		t = n2n "tempLocators"
		if (t!= undefined) then
		(
			selectmore t
			selectmore t.children
			delete $
		)
		
		local thumbMode = arr[1][5] as integer
		
		mergeMAXFile (d2mConfigpath+"QR_Locator.max") quiet:true
		rPBar.pbBar.value = 15
		defineRootLocator selectedObject
		i = name2Index arr "Head"		
		j = name2Index arr "Head1"		
		dir =  (n2n arr[j][4]).pos-(n2n arr[i][4]).pos
		for i=2 to arr.count do
		(
			local t1 = n2n arr[i][4]
			local t2 = n2n arr[i][7]
			if (t1 != undefined and t2 !=  undefined) then
				t1.pos = t2.transform.pos
		)
		i = name2Index arr "Head"		
		j = name2Index arr "Head1"		
		(n2n arr[j][4]).pos = (n2n arr[i][4]).pos + dir
		local list3 =#("Thumb","Index" ,"Middle","Ring","Pinky")
		for ol in list3 do
		(
			local t = 2
			if (ol == "Thumb") then t =1 
			i = name2Index arr ("L"+ol+t as string)
			j = name2Index arr ("L"+ol+(t+1) as string)
			k = name2Index arr ("L"+ol+(t+2) as string)
			p1 = (n2n arr[i][4]).pos
			p2 = (n2n arr[j][4]).pos
			p3 = 2*p2-p1
			(n2n arr[k][4]).pos = p3
		)
		-- set ribcage, lowspine position
		i = name2Index arr "Head"		
		j = name2Index arr "Pelvis"		
		local pelvisPos = (n2n arr[j][4]).pos
		local headPos = (n2n arr[i][4]).pos
		local ribcagePos = pelvisPos+(headPos-pelvisPos)/2.6
		(n2n "lowRibcage").pos = ribcagePos
		local spinePos = pelvisPos+(ribcagePos-pelvisPos)/4.0
		(n2n "lowSpine").pos = spinePos
		
		--merge and sync CAT 
		if isFBX then
			selectedObject = n2n (selectedObject.name+".Shape")
		else
			selectedObject = n2n (selectedObject.name+"-skinInstance")
				
		wireConnect selectedObject
		max select none 
		local listmain = #("","Pelvis","LPlatform","RPlatform")
		
		for li in listmain do
		(
			obj = getNodeByName (selectedObject.name+"_"+li)
			if obj != undefined then
				delete obj		
		)
		
		local prefix = arr[1][3]
		local newPrefix = selectedObject.name+"_"
		
		mergeMAXFile (d2mConfigpath+arr[1][8]) quiet:true #select
		print (d2mConfigpath+arr[1][8])
		local auto = false


		local newarr = deepcopy arr
		
		if  (n2n arr[name2Index arr "Spine01"][7]) == undefined then auto = true
		if  (n2n arr[name2Index arr "Spine02"][7]) == undefined then auto = true
		if  (n2n arr[name2Index arr "Spine03"][7]) == undefined then auto = true
		if  (n2n arr[name2Index arr "Spine04"][7]) == undefined then auto = true
		print ("autooooooooo "+auto as string)

		

		local selObj = selectedObject
		local listSpine = #()
		if auto then
		(
			print "autooooooooooooo"
			local lsPos = (n2n "lowSpine").pos
			local lrPos = (n2n "lowRibcage").pos
			local neckPos = (n2n "Neck").pos
			local h = (n2n "Neck").max.z-(n2n "Neck").min.z
			local w = (n2n "Neck").max.x-(n2n "Neck").min.x
			local p1 = lsPos+[0,0,0]
			local p2 = lsPos+ (lrPos-lsPos)*1.0/3.0
			local p3 = lsPos+ (lrPos-lsPos)*2.0/3.0
			local p4 = lsPos+ (lrPos-lsPos)*3.1/3.0
			p4.y = neckPos.y
			p3.y = (p4.y+p3.y)/2.0
			append listSpine (newBone arr[name2Index arr "Spine01"][4] p1 w w h (execute arr[name2Index arr "Spine01"][6]) true)
			append listSpine (newBone arr[name2Index arr "Spine02"][4] p2 w w h (execute arr[name2Index arr "Spine01"][6]) true)
			append listSpine (newBone arr[name2Index arr "Spine03"][4] p3 w w h (execute arr[name2Index arr "Spine01"][6]) true)
			append listSpine (newBone arr[name2Index arr "Spine04"][4] p4 w w h (execute arr[name2Index arr "Spine01"][6]) true)
		)
		else
		(
			local h = (n2n "Neck").max.z-(n2n "Neck").min.z
			local w = (n2n "Neck").max.x-(n2n "Neck").min.x
			print arr[name2Index arr "Spine01"][7]
			print arr[name2Index arr "Spine02"][7]
			print arr[name2Index arr "Spine03"][7]
			print arr[name2Index arr "Spine04"][7]
			local p1 = (n2n arr[name2Index arr "Spine01"][7]).pos
			local p2 = (n2n arr[name2Index arr "Spine02"][7]).pos
			local p3 = (n2n arr[name2Index arr "Spine03"][7]).pos
			local p4 = (n2n arr[name2Index arr "Spine04"][7]).pos
			append listSpine (newBone arr[name2Index arr "Spine01"][4] p1 w w h (execute arr[name2Index arr "Spine01"][6]) true)
			append listSpine (newBone arr[name2Index arr "Spine02"][4] p2 w w h (execute arr[name2Index arr "Spine01"][6]) true)
			append listSpine (newBone arr[name2Index arr "Spine03"][4] p3 w w h (execute arr[name2Index arr "Spine01"][6]) true)
			append listSpine (newBone arr[name2Index arr "Spine04"][4] p4 w w h (execute arr[name2Index arr "Spine01"][6]) true)
		)

		rPBar.pbBar.value = 20
		syncCATXML newarr selObj true thumbMode
		for obj in listSpine do
			delete obj

	
		--add constraint Left
		rPBar.pbBar.value = 90
		for a in arr do
		(
			local t1 = n2n (prefix1+a[3])
			local t = filterString a[8] ","
			for tt in t do
			(
				local t2 = n2n tt
				if (t1 != undefined and t2 !=  undefined) then
				(
					t2.pos.controller = Position_Constraint()
					t2.pos.controller.appendTarget t1 100.0
					t2.pos.controller.relative = on				
					t2.rotation.controller =  Orientation_Constraint ()
					t2.rotation.controller.appendTarget t1 100.0
					t2.rotation.controller.relative = on									
				)
			)
		)
		--add constraint Right
		rPBar.pbBar.value = 93
		for a in arr do
			if a[3][1] =="L" then
			(
				a[3][1] = "R"
				local t1 = n2n (prefix1+a[3])
				local t = filterString a[8] ","
				for tt in t do
				(
					tt[1] = "R"
					local t2 = n2n tt
					if (t1 != undefined and t2 !=  undefined) then
					(
						t2.pos.controller = Position_Constraint()
						t2.pos.controller.appendTarget t1 100.0
						t2.pos.controller.relative = on				
						t2.rotation.controller =  Orientation_Constraint ()
						t2.rotation.controller.appendTarget t1 100.0
						t2.rotation.controller.relative = on									
					)
				)
			)
		---move Calf forward
		rPBar.pbBar.value = 95
		local t1 = n2n (prefix1+"LCalf")
		local t2 = n2n (prefix1+"RCalf")
		setCATposition t1 (t1.transform.pos+[0,-t1.transform.pos.z/20.0,0])
		setCATposition t2 (t2.transform.pos+[0,-t2.transform.pos.z/20.0,0])
		
		--update name
		obj = getNodeByName (prefix+"Pelvis")
		if obj != undefined then
			autoRename obj prefix newPrefix	 listmain
		--for obj in listDummy do
		--	hide obj
		select $tempLocators...*
		delete selection
		

		rPBar.pbBar.value = 97
		if chkMorph.checked then
		(
			for obj in geometry do
			(
				local objname = tolower obj.name
				local ii  = findString objname "genesis"
				if ii == undefined then
				(
					for i = 1  to obj.modifiers.count do
						if classof obj.modifiers[i] == Morpher then
							deleteModifier obj i
				)
			)
		)
		max select none
		max create mode
		try(destroyDialog rPBar )catch()	

		local catroot = getNodeByName (selectedObject.name +"_")
		if catroot != undefined then
		(
			catRoot.transform.controller.Layers.controller.AppendLayer "CATMotion Layer1" #absolute
			catRoot.CATmode = 1
		)
		
		for obj in geometry  do
			if classof obj == PolyMeshObject then
			try
			(
				obj.showFrozenInGray = off
				freeze obj
			) catch()
		
		enableSceneRedraw() 
		completeRedraw()
		local temp = getNodeByName "cryAnimationExportNode"
		if temp != undefined then delete temp
		temp = getNodeByName "cryExporterSettingsNode"
		if temp != undefined then delete temp
			
		if cbShowReminder.checked then
			messagebox "Remember to save scene with textures"	
	)

	on btnLoadClip pressed do
	if (classof $ == CATParent) then
	(
		cat_file = "C:\IKMax_AniMTest.clp"
		cat_node = $
		cat_root = cat_node.controller
		anim_range = animationrange

		if (cat_root != undefined) do 
		(
			 format "Removing % Existing Layers.\n" cat_root.NumLayers
			 for i = cat_root.NumLayers to 1 by -1 do (  -- in reverse order
			 cat_root.RemoveLayer i
		 )
		 
		 format "Loading CAT clip: %\n" cat_file
		 cat_root.LoadClip cat_file anim_range.start
		 cat_root.CATMode = 1
		 max time play
		)
	)
	on btnClearClip pressed do
	if (classof $ == CATParent) then
	(
		cat_node = $
		cat_node.catmode = 0

		  curLayerState = cat_node.layers.controller[1].controller.LayerEnabled
		  cat_node.layers.controller[1].controller.LayerEnabled = not curLayerState
		  cat_node.layers.controller[1].controller.LayerEnabled = curLayerState
		
		
		cat_root = cat_node.controller
		if (cat_root != undefined) do 
		(
			 format "Removing % Existing Layers.\n" cat_root.NumLayers
			 for i = cat_root.NumLayers to 1 by -1 do
				cat_root.RemoveLayer i
		 )
	)
	on btnConvertMat pressed do
	(
		--convert to vray
		if ddlConvert.selection == 1 then
		(
			try ( renderers.current = Vray()) 
			catch
			(
				messageBox "not vray found"
				return true
			)
			if queryBox "Once converted you can't re-convert.\nYou may want to save first.\nProceed?" title:"DazToMax" == false then 
				return false
			convertToVrayScene()
			loadAllMaterialFromXML file_xml 1
		)
		--convert to arnold/physical
		if ddlConvert.selection == 2 then
		(
			try ( renderers.current = Arnold()) catch()
			try (macros.run "Render" "RenderButtonMenu_Switch_To_ActiveShade_Mode") catch()
			try ( renderers.current = Arnold()) 
			catch
			(
				messageBox "not Arnold found"
				return true
			)
			if queryBox "Once converted you can't re-convert.\nYou may want to save first.\nProceed?" title:"DazToMax" == false then 
				return false
			convertToPhysicalScene()
			loadAllMaterialFromXML file_xml 5
		)
		actionMan.executeAction 0 "63547"  -- Views: Viewport Materials Display as Realistic with Maps
		messageBox "Convert Completed" title:"DazToMax" beep:off
		--actionMan.executeAction 0 "63545"
		
	)
	on rConverter open do
	(
		loadXML()
		--loadImage ikmaxlogo (d2mConfigpath+"d2m.jpg")
		
		
		loadImage btSync11 (d2mConfigpath+"imgs/convert_iconBo2B.jpg")
		loadImage btSync22 (d2mConfigpath+"imgs/convert_iconBo2C.jpg")

		loadImage btSync33 (d2mConfigpath+"imgs/convert_iconB2C.jpg")
		loadImage btSync44 (d2mConfigpath+"imgs/convert_iconC2B.jpg")
		loadImage btnXmlGuides (d2mConfigpath+"imgs/convert_iconDaz.jpg")

		loadImage btnHelp (d2mConfigpath+"images/btnHelp.png")
		loadImage btnConvertMat (d2mConfigpath+"images/btnConvertMats.png")
		loadImage btnAutoImport (d2mConfigpath+"images/btnAutoImport.png")
		loadImage btnSaveScene (d2mConfigpath+"images/btnSaveWithTextures.png")
		

		local list = #()
		for a in arr do
			if (a[2] =="4" or a[2] =="5") then
			(
				append list a[1]
			)
	)
)
try(destroyDialog rConverter )catch()	
	createDialog rConverter

--mapPaths.getFullFilePath $.mat.diffusemap.filename