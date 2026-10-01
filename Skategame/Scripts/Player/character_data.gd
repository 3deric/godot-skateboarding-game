class_name CharacterData 
extends Resource

@export var char_name = "Skategame Character"
@export var customization_data = {
	CustomizationPart.Part.BODY : { 
									"category": "body",
									"gender" : 0,
									"size" :  1.0,
									"color" : 0.5,
									"eyes": Color(0.356,0.425,0.583,1.0)
	},
	CustomizationPart.Part.TOP : {	
									"category": "clothes",
									"mesh" : 1,
									"base":  Color("5d7937"),
									"accent": Color("5d7937"),
									"detail": Color("adaca0"),
									"decal_top" : 0
								},
	CustomizationPart.Part.BOTTOM : {
									"category": "clothes",
									"mesh" : 1,
									"base": Color("826a4a"),
									"accent" : Color("b7b7b7"),
									"detail" : Color("e9a174")
									},
	CustomizationPart.Part.SHOES : { 
									"category": "clothes",
									"mesh" : 1,
									"base" : Color("323232"),
									"accent" : Color("8e7247"),
									"detail" : Color("9e9e9e")
									},
	CustomizationPart.Part.BOARD : {
									"category": "board",
									#"mesh": 0, add adjustable board meshes later
									"base" :Color(0.758,0.721,0.471,1.0),
									"accent": Color(0.354,0.95,0.45,1.0),
									"detail": Color(0.8,0.8,0.8,1.0),
									"decal_board": 1
									},
	CustomizationPart.Part.HAIR : {
									"category": "body",
									"mesh": 1,
									"base" : Color(0.555,0.465,0.351,1.0)
									},
	CustomizationPart.Part.HELMET : {
									"category": "clothes",
									"mesh" : 0
									},
	CustomizationPart.Part.GLASSES : {
									"category": "clothes",
									"mesh" : 0
									}
}
