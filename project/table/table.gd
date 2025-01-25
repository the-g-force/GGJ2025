extends StaticBody3D

@onready var _spike_multimesh : MultiMesh = $SpikeMultiMeshInstance.multimesh


func _ready() -> void:
	for i in 72:
		var y_rotation := TAU * i / 72
		var spike_transform := Transform3D.IDENTITY.rotated(Vector3.RIGHT, PI / 2).rotated(Vector3.UP, y_rotation - PI / 2)\
			.translated(Vector3.UP * 0.25 + 9.8 * Vector3.RIGHT.rotated(Vector3.UP, y_rotation))
		_spike_multimesh.set_instance_transform(i, spike_transform)
	$SpikeMultiMeshInstance.show()
