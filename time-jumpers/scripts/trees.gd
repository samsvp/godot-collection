extends Node3D

var trees: Array[Sprite3D]
# Called when the node enters the scene tree for the first time.
func _ready():
	trees = [get_child(0), get_child(1), get_child(2)]


func _on_rigid_body_3d_body_entered(body: RigidBody3D):
	if not body.name.begins_with("unit"):
		return
	
	for tree in trees:
		tree.modulate = Color(1, 1, 1, 0.4)
