extends Node3D

var home: Sprite3D
# Called when the node enters the scene tree for the first time.
func _ready():
	home = get_child(0)


func _on_rigid_body_3d_body_entered(body: RigidBody3D):
	if not body.name.begins_with("unit"):
		return
	
	home.modulate = Color(1, 1, 1, 0.4)
