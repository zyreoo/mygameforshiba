extends Node3D

func _ready():
	# Find the mesh inside this node
	var mesh_instance = $MeshInstance3D  # adjust path if named differently

	if mesh_instance == null or mesh_instance.mesh == null:
		return

	var aabb = mesh_instance.mesh.get_aabb()

	# Create StaticBody3D
	var body = StaticBody3D.new()
	add_child(body)

	# Create CollisionShape3D
	var collider = CollisionShape3D.new()
	body.add_child(collider)

	# Box shape matches the mesh bounds
	var shape = BoxShape3D.new()
	shape.size = aabb.size
	collider.shape = shape

	# Position collider correctly
	collider.transform.origin = aabb.position + (aabb.size / 2.0)
